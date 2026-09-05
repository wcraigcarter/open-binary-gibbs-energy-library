#!/usr/bin/env python3
"""Develop, diagnose, and plot provisional 1-atm H2O unary reductions.

This is a development tool.  It deliberately does not write data/unary JSON.
The scientific source equations are IAPWS-95 for fluid water and IAPWS
R10-06(2009) for Ice Ih.  The pinned ``iapws`` Python package is the numerical
implementation adapter; published IAPWS verification values are checked before
any samples are generated.

Outputs are deterministic CSV, JSON, and PNG files under ``generated/``.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import tempfile
import warnings
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Callable, Iterable

os.environ.setdefault(
    "MPLCONFIGDIR", str(Path(tempfile.gettempdir()) / "obgel-matplotlib")
)

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from iapws import IAPWS95, __version__ as iapws_version
from iapws._iapws import _Ice
from scipy.optimize import brentq, root

PRESSURE_PA = 101_325.0
PRESSURE_KPA = PRESSURE_PA / 1_000.0
PRESSURE_MPA = PRESSURE_PA / 1_000_000.0
T_MIN = 250.0
T_MAX = 500.0

# Development-only acceptance targets.  They select a compact candidate; they
# are not OBGEL-wide standards and do not authorize canonical promotion.
MAX_G_TARGET_J_MOL = 0.25
MAX_CP_TARGET_J_MOL_K = 1.0

HERE = Path(__file__).resolve().parent
DEFAULT_OUTPUT = HERE / "generated"


@dataclass(frozen=True)
class Sample:
    phase: str
    temperature_K: float
    pressure_Pa: float
    density_kg_m3: float | None
    gibbs_J_mol: float | None
    cp_J_mol_K: float | None
    region_status: str
    source_model: str
    note: str


@dataclass(frozen=True)
class Fit:
    name: str
    phase: str
    domain_K: list[float]
    terms: list[str]
    coefficients: dict[str, float]
    max_abs_delta_g_J_mol: float
    rms_delta_g_J_mol: float
    max_abs_delta_cp_J_mol_K: float
    rms_delta_cp_J_mol_K: float
    selected: bool
    selection_note: str


class FluidEvaluator:
    """Branch-aware adapter around the IAPWS-95 Helmholtz formulation."""

    def __init__(self) -> None:
        self.model = IAPWS95()
        # The package reports molar mass in g/mol.  Multiplying a kJ/kg value
        # by this number gives the same numerical value in J/mol.
        self.molar_factor = float(self.model.M)

    def pressure_kpa(self, temperature_K: float, density_kg_m3: float) -> float:
        return float(self.model._Helmholtz(density_kg_m3, temperature_K)["P"])

    def dp_drho_kpa_m3_kg(
        self, temperature_K: float, density_kg_m3: float
    ) -> float:
        delta = density_kg_m3 / self.model.rhoc
        tau = self.model.Tc / temperature_K
        residual = self.model._phir(tau, delta)
        return float(
            self.model.R
            * temperature_K
            * (
                1.0
                + 2.0 * delta * residual["fird"]
                + delta * delta * residual["firdd"]
            )
        )

    def molar_g_cp(
        self, temperature_K: float, density_kg_m3: float
    ) -> tuple[float, float]:
        state = self.model._Helmholtz(density_kg_m3, temperature_K)
        delta = density_kg_m3 / self.model.rhoc
        tau = self.model.Tc / temperature_K
        ideal = self.model._phi0(tau, delta)
        residual = self.model._phir(tau, delta)
        denominator = (
            1.0
            + 2.0 * delta * residual["fird"]
            + delta * delta * residual["firdd"]
        )
        cp_kj_kg_K = self.model.R * (
            -tau * tau * (ideal["fiott"] + residual["firtt"])
            + (
                1.0
                + delta * residual["fird"]
                - delta * tau * residual["firdt"]
            )
            ** 2
            / denominator
        )
        g_kj_kg = state["h"] - temperature_K * state["s"]
        return (
            float(g_kj_kg * self.molar_factor),
            float(cp_kj_kg_K * self.molar_factor),
        )

    def liquid_density_series(self, temperatures_K: Iterable[float]) -> list[float]:
        temperatures = list(temperatures_K)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            previous = float(IAPWS95(T=temperatures[0], P=PRESSURE_MPA).rho)
        densities: list[float] = []
        for temperature in temperatures:
            objective = (
                lambda density: self.pressure_kpa(temperature, density)
                - PRESSURE_KPA
            )
            low, high = previous - 30.0, previous + 30.0
            for _ in range(30):
                if objective(low) * objective(high) <= 0.0:
                    break
                low -= 20.0
                high += 20.0
            else:
                raise RuntimeError(f"Could not bracket liquid root at {temperature} K")
            previous = float(brentq(objective, low, high, xtol=1e-11))
            if self.dp_drho_kpa_m3_kg(temperature, previous) <= 0.0:
                raise RuntimeError(f"Liquid root is mechanically unstable at {temperature} K")
            densities.append(previous)
        return densities

    def liquid_density(self, temperature_K: float) -> float:
        # The high-density root is the final sign change on a broad liquid grid.
        grid = np.linspace(500.0, 1_200.0, 2_801)
        values = np.array(
            [self.pressure_kpa(temperature_K, rho) - PRESSURE_KPA for rho in grid]
        )
        roots: list[float] = []
        for low, high, f_low, f_high in zip(
            grid[:-1], grid[1:], values[:-1], values[1:]
        ):
            if f_low * f_high < 0.0:
                candidate = float(
                    brentq(
                        lambda rho: self.pressure_kpa(temperature_K, rho)
                        - PRESSURE_KPA,
                        low,
                        high,
                    )
                )
                if self.dp_drho_kpa_m3_kg(temperature_K, candidate) > 0.0:
                    roots.append(candidate)
        if not roots:
            raise RuntimeError(f"No mechanically stable liquid root at {temperature_K} K")
        return roots[-1]

    def vapor_density(self, temperature_K: float) -> float | None:
        # The low-density root lies just above the ideal-gas estimate.  A root
        # only counts when it has positive isothermal stiffness dP/drho.
        ideal_density = PRESSURE_KPA / (self.model.R * temperature_K)
        objective = (
            lambda density: self.pressure_kpa(temperature_K, density)
            - PRESSURE_KPA
        )
        low = 1.0e-12
        high = 1.25 * ideal_density
        if objective(low) * objective(high) > 0.0:
            return None
        density = float(brentq(objective, low, high, xtol=1e-13))
        if self.dp_drho_kpa_m3_kg(temperature_K, density) <= 0.0:
            return None
        return density

    def vapor_spinodal_at_pressure(self) -> tuple[float, float]:
        def equations(values: np.ndarray) -> np.ndarray:
            temperature, density = values
            return np.array(
                [
                    self.pressure_kpa(float(temperature), float(density))
                    - PRESSURE_KPA,
                    self.dp_drho_kpa_m3_kg(float(temperature), float(density)),
                ]
            )

        solution = root(equations, np.array([326.4, 0.82]))
        if not solution.success:
            raise RuntimeError("Could not solve the 1-atm vapor spinodal")
        return float(solution.x[0]), float(solution.x[1])


def verify_implementations(fluid: FluidEvaluator) -> dict[str, float]:
    """Check package results against published IAPWS release tables."""
    # IAPWS R6-95(2018), Tables 6 and 7, T=500 K, rho=838.025 kg/m3.
    temperature, density = 500.0, 838.025
    delta = density / fluid.model.rhoc
    tau = fluid.model.Tc / temperature
    ideal = fluid.model._phi0(tau, delta)
    residual = fluid.model._phir(tau, delta)
    state = fluid.model._Helmholtz(density, temperature)
    checks = {
        "iapws95_phi0": abs(float(ideal["fio"]) - 2.04797733),
        "iapws95_phir": abs(float(residual["fir"]) - (-3.42693206)),
        "iapws95_pressure_MPa": abs(float(state["P"]) / 1000.0 - 10.0003858),
        "iapws95_cv_kJ_kg_K": abs(float(state["cv"]) - 3.22106219),
        "iapws95_entropy_kJ_kg_K": abs(float(state["s"]) - 2.56690919),
    }
    tolerances = {
        "iapws95_phi0": 5e-8,
        "iapws95_phir": 5e-8,
        "iapws95_pressure_MPa": 5e-7,
        "iapws95_cv_kJ_kg_K": 5e-8,
        "iapws95_entropy_kJ_kg_K": 5e-8,
    }

    # IAPWS R10-06(2009), Table 6, normal-pressure melting point.
    ice = _Ice(273.152519, PRESSURE_MPA)
    checks.update(
        {
            "ice_a_kJ_kg": abs(float(ice["a"]) - (-0.00918701567)),
            "ice_u_kJ_kg": abs(float(ice["u"]) - (-333.465403393)),
            "ice_cp_kJ_kg_K": abs(float(ice["cp"]) - 2.09671391024),
        }
    )
    tolerances.update(
        {
            "ice_a_kJ_kg": 5e-11,
            "ice_u_kJ_kg": 5e-9,
            "ice_cp_kJ_kg_K": 5e-11,
        }
    )
    failed = [name for name, error in checks.items() if error > tolerances[name]]
    if failed:
        raise RuntimeError(f"IAPWS implementation verification failed: {failed}")
    return checks


def solve_phase_boundaries(fluid: FluidEvaluator) -> tuple[float, float]:
    molar_factor = fluid.molar_factor

    def ice_minus_liquid(temperature: float) -> float:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            ice_g = float(_Ice(temperature, PRESSURE_MPA)["g"]) * molar_factor
        density = fluid.liquid_density(temperature)
        liquid_g, _ = fluid.molar_g_cp(temperature, density)
        return ice_g - liquid_g

    melting = float(brentq(ice_minus_liquid, 273.0, 273.16, xtol=1e-11))

    def liquid_minus_vapor(temperature: float) -> float:
        liquid_g, _ = fluid.molar_g_cp(
            temperature, fluid.liquid_density(temperature)
        )
        vapor_density = fluid.vapor_density(temperature)
        if vapor_density is None:
            raise RuntimeError("Missing vapor root while solving boiling point")
        vapor_g, _ = fluid.molar_g_cp(temperature, vapor_density)
        return liquid_g - vapor_g

    boiling = float(brentq(liquid_minus_vapor, 372.5, 373.8, xtol=1e-11))
    return melting, boiling


def sample_sources(
    fluid: FluidEvaluator, melting_K: float, boiling_K: float, spinodal_K: float
) -> list[Sample]:
    samples: list[Sample] = []
    ice_temperatures = sorted(set(np.arange(250.0, 274.0).tolist() + [melting_K]))
    for temperature in ice_temperatures:
        with warnings.catch_warnings():
            # The independently solved coexistence temperature is a fraction
            # of a microkelvin above the package's rounded melting correlation.
            warnings.simplefilter("ignore")
            state = _Ice(temperature, PRESSURE_MPA)
        samples.append(
            Sample(
                "iceIh",
                temperature,
                PRESSURE_PA,
                float(state["rho"]),
                float(state["g"]) * fluid.molar_factor,
                float(state["cp"]) * fluid.molar_factor,
                "phase-boundary" if abs(temperature - melting_K) < 1e-7 else "stable",
                "IAPWS R10-06(2009)",
                "Ice Ih Gibbs formulation evaluated directly at fixed pressure.",
            )
        )

    liquid_temperatures = sorted(
        set(np.arange(T_MIN, T_MAX + 1.0).tolist() + [melting_K, boiling_K])
    )
    liquid_densities = fluid.liquid_density_series(liquid_temperatures)
    for temperature, density in zip(liquid_temperatures, liquid_densities):
        g_molar, cp_molar = fluid.molar_g_cp(temperature, density)
        if abs(temperature - melting_K) < 1e-7 or abs(temperature - boiling_K) < 1e-7:
            status = "phase-boundary"
        elif temperature < melting_K:
            status = "metastable-source-formulation-derived"
        elif temperature < boiling_K:
            status = "stable"
        else:
            status = "metastable-source-formulation-derived"
        note = (
            "Subcooled liquid; IAPWS-95 calls this an extrapolation and notes a "
            "separate supercooled-water guideline gives a better representation."
            if temperature < melting_K
            else (
                "Superheated liquid; positive-pressure IAPWS-95 extrapolation."
                if temperature > boiling_K
                else "IAPWS-95 liquid root at fixed pressure."
            )
        )
        samples.append(
            Sample(
                "liquid",
                temperature,
                PRESSURE_PA,
                density,
                g_molar,
                cp_molar,
                status,
                "IAPWS R6-95(2018)",
                note,
            )
        )

    vapor_temperatures = sorted(
        set(np.arange(T_MIN, T_MAX + 1.0).tolist() + [boiling_K, spinodal_K])
    )
    for temperature in vapor_temperatures:
        density = fluid.vapor_density(temperature)
        if density is None or temperature < spinodal_K + 1e-7:
            samples.append(
                Sample(
                    "vapor",
                    temperature,
                    PRESSURE_PA,
                    None,
                    None,
                    None,
                    "unsupported-no-mechanically-stable-root",
                    "IAPWS R6-95(2018)",
                    "At 1 atm the low-density root is absent or at the vapor spinodal; "
                    "the low-temperature ideal-gas extension does not change this.",
                )
            )
            continue
        g_molar, cp_molar = fluid.molar_g_cp(temperature, density)
        if abs(temperature - boiling_K) < 1e-7:
            status = "phase-boundary"
            note = "IAPWS-95 vapor root at liquid-vapor coexistence."
        elif temperature < boiling_K:
            status = "metastable-source-formulation-derived-caution"
            note = (
                "Subcooled vapor. IAPWS reports no experimental data, recommends "
                "its Helmholtz equation only close to saturation, and points to an "
                "alternative gas equation farther away."
            )
        else:
            status = "stable"
            note = "IAPWS-95 vapor root at fixed pressure."
        samples.append(
            Sample(
                "vapor",
                temperature,
                PRESSURE_PA,
                density,
                g_molar,
                cp_molar,
                status,
                "IAPWS R6-95(2018)",
                note,
            )
        )
    return samples


def cp_column(temperature: np.ndarray, term: str) -> np.ndarray:
    if term == "TlnT":
        return -np.ones_like(temperature)
    exponent = int(term[1:])
    return -exponent * (exponent - 1) * temperature ** (exponent - 1)


def g_column(temperature: np.ndarray, term: str) -> np.ndarray:
    if term == "TlnT":
        return temperature * np.log(temperature)
    exponent = int(term[1:])
    return temperature**exponent


def evaluate_fit(fit: Fit, temperature: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    coefficients = fit.coefficients
    g = coefficients["constant"] + coefficients["temperature"] * temperature
    cp = np.zeros_like(temperature)
    for term in fit.terms:
        g += coefficients[term] * g_column(temperature, term)
        cp += coefficients[term] * cp_column(temperature, term)
    return g, cp


def fit_branch(
    name: str,
    phase: str,
    temperatures: np.ndarray,
    gibbs: np.ndarray,
    cp: np.ndarray,
    terms: list[str],
    selected: bool,
    selection_note: str,
) -> Fit:
    # Fit curvature-bearing coefficients to Cp first.  Then solve the two
    # integration constants (1 and T) against G.  This makes the curvature
    # diagnostic an explicit part of construction instead of an afterthought.
    cp_matrix = np.column_stack([cp_column(temperatures, term) for term in terms])
    scales = np.linalg.norm(cp_matrix, axis=0)
    nonlinear = np.linalg.lstsq(cp_matrix / scales, cp, rcond=None)[0] / scales
    residual_g = gibbs.copy()
    for coefficient, term in zip(nonlinear, terms):
        residual_g -= coefficient * g_column(temperatures, term)
    linear = np.linalg.lstsq(
        np.column_stack([np.ones_like(temperatures), temperatures]),
        residual_g,
        rcond=None,
    )[0]
    coefficients = {"constant": float(linear[0]), "temperature": float(linear[1])}
    coefficients.update({term: float(value) for term, value in zip(terms, nonlinear)})
    provisional = Fit(
        name,
        phase,
        [float(temperatures.min()), float(temperatures.max())],
        terms,
        coefficients,
        0.0,
        0.0,
        0.0,
        0.0,
        selected,
        selection_note,
    )
    fitted_g, fitted_cp = evaluate_fit(provisional, temperatures)
    delta_g = fitted_g - gibbs
    delta_cp = fitted_cp - cp
    return Fit(
        **{
            **asdict(provisional),
            "max_abs_delta_g_J_mol": float(np.max(np.abs(delta_g))),
            "rms_delta_g_J_mol": float(np.sqrt(np.mean(delta_g**2))),
            "max_abs_delta_cp_J_mol_K": float(np.max(np.abs(delta_cp))),
            "rms_delta_cp_J_mol_K": float(np.sqrt(np.mean(delta_cp**2))),
        }
    )


def phase_arrays(
    samples: list[Sample], phase: str, predicate: Callable[[Sample], bool]
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    selected = [
        sample
        for sample in samples
        if sample.phase == phase and sample.gibbs_J_mol is not None and predicate(sample)
    ]
    selected.sort(key=lambda sample: sample.temperature_K)
    return (
        np.array([sample.temperature_K for sample in selected]),
        np.array([sample.gibbs_J_mol for sample in selected]),
        np.array([sample.cp_J_mol_K for sample in selected]),
    )


def build_fits(
    samples: list[Sample], melting_K: float, boiling_K: float
) -> list[Fit]:
    fits: list[Fit] = []
    base = ["TlnT", "T2", "T3"]

    ice_T, ice_G, ice_Cp = phase_arrays(samples, "iceIh", lambda _: True)
    fits.append(
        fit_branch(
            "ice-standard5",
            "iceIh",
            ice_T,
            ice_G,
            ice_Cp,
            base,
            True,
            "The initial five-term basis already exceeds the development targets.",
        )
    )

    liquid_T, liquid_G, liquid_Cp = phase_arrays(samples, "liquid", lambda _: True)
    fits.append(
        fit_branch(
            "liquid-standard5",
            "liquid",
            liquid_T,
            liquid_G,
            liquid_Cp,
            base,
            False,
            "Rejected: the Cp endpoint residual exceeds the development target.",
        )
    )
    fits.append(
        fit_branch(
            "liquid-standard6",
            "liquid",
            liquid_T,
            liquid_G,
            liquid_Cp,
            base + ["T-1"],
            False,
            "Rejected: one inverse-power term does not meet both targets.",
        )
    )
    fits.append(
        fit_branch(
            "liquid-standard7",
            "liquid",
            liquid_T,
            liquid_G,
            liquid_Cp,
            base + ["T-1", "T-2"],
            True,
            "Smallest tested basis meeting the stated development targets.",
        )
    )

    all_vapor_T, all_vapor_G, all_vapor_Cp = phase_arrays(
        samples, "vapor", lambda sample: sample.temperature_K >= 327.0
    )
    fits.append(
        fit_branch(
            "vapor-evaluable-standard5-diagnostic",
            "vapor",
            all_vapor_T,
            all_vapor_G,
            all_vapor_Cp,
            base,
            False,
            "Diagnostic only: near-spinodal Cp divergence makes one compact fit unusable.",
        )
    )
    fits.append(
        fit_branch(
            "vapor-evaluable-standard8-diagnostic",
            "vapor",
            all_vapor_T,
            all_vapor_G,
            all_vapor_Cp,
            base + ["T-1", "T-2", "T-3"],
            False,
            "Diagnostic only: added complexity still fails badly near the spinodal.",
        )
    )

    stable_vapor_T, stable_vapor_G, stable_vapor_Cp = phase_arrays(
        samples, "vapor", lambda sample: sample.temperature_K >= boiling_K - 1e-7
    )
    fits.append(
        fit_branch(
            "vapor-stable-standard5",
            "vapor",
            stable_vapor_T,
            stable_vapor_G,
            stable_vapor_Cp,
            base,
            True,
            "The initial basis meets the development targets on the supported stable branch.",
        )
    )
    return fits


def selected_fit(fits: list[Fit], phase: str) -> Fit:
    matches = [fit for fit in fits if fit.phase == phase and fit.selected]
    if len(matches) != 1:
        raise RuntimeError(f"Expected one selected fit for {phase}, found {len(matches)}")
    return matches[0]


def fitted_crossings(fits: list[Fit]) -> tuple[float, float]:
    ice = selected_fit(fits, "iceIh")
    liquid = selected_fit(fits, "liquid")
    vapor = selected_fit(fits, "vapor")

    def difference(left: Fit, right: Fit, temperature: float) -> float:
        value = np.array([temperature])
        return float(evaluate_fit(left, value)[0][0] - evaluate_fit(right, value)[0][0])

    melting = float(brentq(lambda T: difference(ice, liquid, T), 272.5, 273.8))
    boiling = float(brentq(lambda T: difference(liquid, vapor, T), 372.0, 374.5))
    return melting, boiling


def write_samples(path: Path, samples: list[Sample]) -> None:
    fields = list(Sample.__dataclass_fields__)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        for sample in samples:
            writer.writerow(asdict(sample))


def plot_residuals(path: Path, samples: list[Sample], fits: list[Fit]) -> None:
    figure, axes = plt.subplots(3, 2, figsize=(11, 10), sharex="row")
    for row, phase in enumerate(["iceIh", "liquid", "vapor"]):
        fit = selected_fit(fits, phase)
        temperature, gibbs, cp = phase_arrays(
            samples,
            phase,
            lambda sample, lower=fit.domain_K[0], upper=fit.domain_K[1]: (
                lower - 1e-7 <= sample.temperature_K <= upper + 1e-7
            ),
        )
        fitted_g, fitted_cp = evaluate_fit(fit, temperature)
        axes[row, 0].plot(temperature, fitted_g - gibbs, color="#1f77b4")
        axes[row, 1].plot(temperature, fitted_cp - cp, color="#d95f02")
        axes[row, 0].set_ylabel(f"{phase}\nΔG (J mol⁻¹)")
        axes[row, 1].set_ylabel(f"{phase}\nΔCp (J mol⁻¹ K⁻¹)")
        for axis in axes[row]:
            axis.axhline(0.0, color="0.25", linewidth=0.7)
            axis.grid(alpha=0.25)
    axes[-1, 0].set_xlabel("Temperature (K)")
    axes[-1, 1].set_xlabel("Temperature (K)")
    figure.suptitle("Selected provisional H₂O reduced-fit residuals at 101325 Pa")
    figure.tight_layout()
    figure.savefig(path, dpi=180)
    plt.close(figure)


def plot_envelope(
    path: Path,
    fits: list[Fit],
    source_melting_K: float,
    source_boiling_K: float,
    fit_melting_K: float,
    fit_boiling_K: float,
) -> None:
    figure = plt.figure(figsize=(11, 8))
    grid = figure.add_gridspec(2, 2, height_ratios=[2.2, 1.0])
    axis = figure.add_subplot(grid[0, :])
    styles = {
        "iceIh": ("#4c78a8", "Ice Ih"),
        "liquid": ("#2ca02c", "liquid"),
        "vapor": ("#e45756", "vapor (selected stable domain)"),
    }
    for phase in ["iceIh", "liquid", "vapor"]:
        fit = selected_fit(fits, phase)
        temperature = np.linspace(fit.domain_K[0], fit.domain_K[1], 500)
        gibbs, _ = evaluate_fit(fit, temperature)
        color, label = styles[phase]
        axis.plot(temperature, gibbs, color=color, label=label)
    axis.axvline(
        source_melting_K, color="0.25", linestyle="--", linewidth=0.9,
        label="source-equation crossing"
    )
    axis.axvline(source_boiling_K, color="0.25", linestyle="--", linewidth=0.9)
    axis.axvline(
        fit_melting_K, color="0.25", linestyle=":", linewidth=1.1,
        label="reduced-fit crossing"
    )
    axis.axvline(fit_boiling_K, color="0.25", linestyle=":", linewidth=1.1)
    axis.set_xlabel("Temperature (K)")
    axis.set_ylabel("Molar Gibbs energy (J mol⁻¹)")
    axis.set_title("Provisional reduced H₂O branches and lower-envelope crossings")
    axis.grid(alpha=0.25)
    axis.legend()

    ice = selected_fit(fits, "iceIh")
    liquid = selected_fit(fits, "liquid")
    vapor = selected_fit(fits, "vapor")
    for zoom_axis, left, right, source_crossing, fit_crossing, limits, title in [
        (
            figure.add_subplot(grid[1, 0]),
            ice,
            liquid,
            source_melting_K,
            fit_melting_K,
            (273.13, 273.18),
            "Melting crossing detail",
        ),
        (
            figure.add_subplot(grid[1, 1]),
            vapor,
            liquid,
            source_boiling_K,
            fit_boiling_K,
            (373.09, 373.16),
            "Boiling crossing detail",
        ),
    ]:
        temperature = np.linspace(*limits, 300)
        left_g, _ = evaluate_fit(left, temperature)
        right_g, _ = evaluate_fit(right, temperature)
        zoom_axis.plot(temperature, left_g - right_g, color="#6f4c9b")
        zoom_axis.axhline(0.0, color="0.25", linewidth=0.7)
        zoom_axis.axvline(source_crossing, color="0.25", linestyle="--", linewidth=0.9)
        zoom_axis.axvline(fit_crossing, color="0.25", linestyle=":", linewidth=1.1)
        zoom_axis.set_xlim(*limits)
        zoom_axis.set_xlabel("Temperature (K)")
        zoom_axis.set_ylabel("Branch ΔG (J mol⁻¹)")
        zoom_axis.set_title(
            f"{title}\nsource {source_crossing:.6f} K; fit {fit_crossing:.6f} K",
            fontsize=10,
        )
        zoom_axis.grid(alpha=0.25)
    figure.tight_layout()
    figure.savefig(path, dpi=180)
    plt.close(figure)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    arguments = parser.parse_args()
    output = arguments.output.resolve()
    output.mkdir(parents=True, exist_ok=True)

    fluid = FluidEvaluator()
    verification = verify_implementations(fluid)
    source_melting_K, source_boiling_K = solve_phase_boundaries(fluid)
    spinodal_K, spinodal_density = fluid.vapor_spinodal_at_pressure()
    samples = sample_sources(
        fluid, source_melting_K, source_boiling_K, spinodal_K
    )
    fits = build_fits(samples, source_melting_K, source_boiling_K)
    fit_melting_K, fit_boiling_K = fitted_crossings(fits)

    write_samples(output / "h2o-iapws-samples.csv", samples)
    plot_residuals(output / "h2o-fit-residuals.png", samples, fits)
    plot_envelope(
        output / "h2o-phase-envelope.png",
        fits,
        source_melting_K,
        source_boiling_K,
        fit_melting_K,
        fit_boiling_K,
    )

    diagnostic = {
        "status": "development-only-not-canonical",
        "pressure_Pa": PRESSURE_PA,
        "molar_mass_g_mol_used_by_iapws_adapter": fluid.model.M,
        "implementation": {
            "package": "iapws",
            "version": iapws_version,
            "verification_absolute_errors": verification,
        },
        "source_boundaries": {
            "melting_temperature_K": source_melting_K,
            "boiling_temperature_K": source_boiling_K,
            "vapor_spinodal_temperature_at_1atm_K": spinodal_K,
            "vapor_spinodal_density_kg_m3": spinodal_density,
        },
        "fit_boundaries": {
            "melting_temperature_K": fit_melting_K,
            "boiling_temperature_K": fit_boiling_K,
            "melting_shift_K": fit_melting_K - source_melting_K,
            "boiling_shift_K": fit_boiling_K - source_boiling_K,
        },
        "development_targets": {
            "max_abs_delta_g_J_mol": MAX_G_TARGET_J_MOL,
            "max_abs_delta_cp_J_mol_K": MAX_CP_TARGET_J_MOL_K,
            "scope": "candidate-selection-only; not a canonical acceptance standard",
        },
        "vapor_domain_finding": {
            "requested_domain_K": [T_MIN, T_MAX],
            "unsupported_at_1atm_K": [T_MIN, spinodal_K],
            "metastable_iapws95_root_with_caution_K": [spinodal_K, source_boiling_K],
            "selected_fit_domain_K": [source_boiling_K, T_MAX],
            "reason": (
                "No mechanically stable IAPWS-95 vapor root exists below the 1-atm "
                "spinodal. Near it Cp diverges and IAPWS cautions that its subcooled-"
                "vapor extrapolation is only reasonable close to saturation."
            ),
            "low_temperature_guideline_note": (
                "IAPWS G9-12 changes the ideal-gas term below 130 K (down to 50 K). "
                "It is not activated in the requested 250-500 K interval and does "
                "not cure the fixed-pressure spinodal limitation."
            ),
        },
        "fits": [asdict(fit) for fit in fits],
    }
    with (output / "h2o-fit-diagnostics.json").open("w", encoding="utf-8") as handle:
        json.dump(diagnostic, handle, indent=2, sort_keys=True)
        handle.write("\n")

    print(json.dumps(diagnostic, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
