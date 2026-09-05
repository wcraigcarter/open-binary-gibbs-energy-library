# Plutonium Unary Thermodynamic Source Data

## Purpose and development status

This record documents historical source observations for unary plutonium from
Tables 3.8, 3.11, and 3.12 of the 1967 *Plutonium Handbook*. It accompanies
`data/unary/pu-standard-reference.json`.

The literal table transcription is **source-transcription-audited** against the
supplied Handbook screenshots. The JSON also contains an executable,
**assumption-dependent Handbook-derived Gibbs-energy model** whose encoded
implementation has been verified. These are separate claims: the source
tables do not by themselves uniquely establish the adopted heat-capacity fits,
Gibbs-energy construction, reference normalization, phase-function
dependencies, or extension rules.

## Source

O. J. Wick, editor, *Plutonium Handbook: A Guide to the Technology*, Gordon
and Breach Science Publishers, 1967. Library of Congress Control Number
65-27855.

```bibtex
@book{wick1967plutonium,
  title = {Plutonium Handbook: A Guide to the Technology},
  editor = {Wick, Oswald J.},
  year = {1967},
  publisher = {Gordon and Breach Science Publishers},
  lccn = {65027855}
}
```

The transcription below was checked visually against the supplied Handbook
screenshots. Table numbers provide the source locations available in the
current record; volume and page locations have not yet been independently
audited.

## Source notation and repository phase names

The source uses Greek phase labels and `L` for liquid. The source-data JSON
uses stable, readable identifiers without changing the phase identities.

| Source label | JSON phase name |
|---|---|
| \(\alpha\) | `alpha` |
| \(\beta\) | `beta` |
| \(\gamma\) | `gamma` |
| \(\delta\) | `delta` |
| \(\delta'\) | `deltaPrime` |
| \(\epsilon\) | `epsilon` |
| \(L\), Liquid | `liquid` |

## Literal source-data transcription

Values, significant figures, approximation marks, uncertainty notation, and
footnote marks are retained as printed. No unit conversions appear in this
section.

### Table 3.8 — Transformation Temperatures of Plutonium

| Transformation | Temperature (°C) |
|---|---:|
| \(\alpha \rightarrow \beta\) | 115 |
| \(\beta \rightarrow \gamma\) | \(\sim185\) |
| \(\gamma \rightarrow \delta\) | 310 |
| \(\delta \rightarrow \delta'\) | 452 |
| \(\delta' \rightarrow \epsilon\) | 480 |
| \(\epsilon \rightarrow L\) | 640 |

The approximation mark on the \(\beta \rightarrow \gamma\) temperature is
explicit in the source. No approximation mark is added to the other five
temperatures.

### Table 3.11 — Heats of Transition of the Plutonium Allotropes

The column headings are printed as `ΔH, cal/g-atom` and
`ΔS, (cal/deg)/g-atom`.

| Transformation | \(\Delta H\) (cal/g-atom) | \(\Delta S\) ((cal/deg)/g-atom) |
|---|---:|---:|
| \(\alpha \rightarrow \beta\) | \(900 \pm 20\) | 2.28 |
| \(\beta \rightarrow \gamma\) | \(160 \pm 10\) | 0.33 |
| \(\gamma \rightarrow \delta\) | \(148 \pm 15\) | 0.25 |
| \(\delta \rightarrow \delta'\) | \(10 \pm 10\) | 0.01 |
| \(\delta' \rightarrow \epsilon\) | \(444 \pm 10\) | 0.59 |
| \(\epsilon \rightarrow L\) | \(676 \pm 10\) | 0.74 |

No uncertainty is printed for the entropy values. The record therefore does
not manufacture entropy uncertainties from the reported enthalpy
uncertainties or transition temperatures.

### Table 3.12 — Specific Heat of Plutonium

The table prints temperature in `°C` and the specific-heat column as
`Specific Heat, Cp, cal/g-atom`. Because \(C_p\) is a heat capacity, the JSON
records the explicit interpreted unit `cal/(g-atom*K)` and separately retains
the source heading `cal/g-atom`. This unit clarification is not a fitted model
or a conversion of any numerical value.

| Phase | Temperature (°C) | \(C_p\) (cal/g-atom, as printed) |
|---|---:|---:|
| \(\alpha\) | -13 | 8.0 |
| \(\alpha\) | 27 | 8.48 |
| \(\alpha\) | 47 | 8.66 |
| \(\alpha\) | 67 | 8.84 |
| \(\beta\) | 140 | 8.20 |
| \(\beta\) | 150 | 8.24 |
| \(\beta\) | 160 | 8.28 |
| \(\beta\) | 170 | 8.34 |
| \(\beta\) | 180 | 8.41 |
| \(\beta\) | 190 | 8.46 |
| \(\gamma\) | 230 | 8.58 |
| \(\gamma\) | 240 | 8.62 |
| \(\gamma\) | 250 | 8.67 |
| \(\gamma\) | 260 | 8.76 |
| \(\gamma\) | 270 | 8.85 |
| \(\delta\) | 327 | 9.0 |
| \(\delta\) | 377 | 9.0 |
| \(\delta\) | 427 | 9.0 |
| \(\delta'\) | 455 | 13.2† |
| \(\epsilon\) | 500 | 8.4 |
| \(\epsilon\) | 600 | 8.4 |
| Liquid | 650 | 9.9 |
| Liquid | 660 | 10.0 |
| Liquid | 675 | 10.0 |

The source places a double-dagger on the `Liquid` phase label rather than on
each of the three liquid values.

#### Table 3.12 source notes

- `*` From A. E. Kay and R. G. Loasby, *Phil. Mag.* **9**, 43 (1964).
- `†` Value reported by Dean, Kay, and Loasby (source reference 29).
- `‡` Values for the liquid reported by Loasby (source reference 31).

The supplied screenshot does not include the full bibliographic entries for
source references 29 and 31, so this record does not attempt to reconstruct
them.

## What the source observations establish

The tables identify seven phase regions, in sequence:

\[
\alpha,\ \beta,\ \gamma,\ \delta,\ \delta',\ \epsilon,\ L.
\]

They report six successive transformation temperatures, six transformation
enthalpies with printed uncertainties, six transformation entropies without
printed uncertainties, and 24 discrete \(C_p\) observations.

## Modeling decisions not established by the source observations

The following are not literal results of the three source tables. The
accompanying model adopts them as explicit and separately auditable modeling
decisions where described below:

- interpolation, regression, or functional forms for \(C_p(T)\);
- extrapolation outside the temperatures of the reported observations;
- construction or normalization of enthalpy, entropy, or Gibbs-energy
  functions;
- a Standard Element Reference convention for a Pu Gibbs-energy model;
- `baseFunction` relationships or any other function dependency graph;
- reconciliation of \(\Delta H\), \(\Delta S\), and transition temperatures
  within their reported precision and uncertainty; and
- pressure dependence or parameters not present in the three source tables.

The constant-looking values within some phase blocks and the trend of other
blocks are observations about the tabulated points only. They are not encoded
as constant, linear, or other heat-capacity functions.

## Audit boundary

The table values and visible annotations have been checked against the three
supplied screenshots. The bibliographic citation was supplied by the project
owner. A later source audit should verify the Handbook volume and page
locations and recover the complete references numbered 29 and 31 before this
record is described as fully primary-source-audited.

## Handbook-derived thermodynamic model

The accompanying JSON contains an executable, assumption-dependent
**Wick-1967 Handbook-derived Pu model**. The model is an OBGEL construction
from the historical observations above, and its encoded implementation has
been verified as described below. It is not a CALPHAD assessment, an SGTE
unary description, or a modern recommended Pu reference. The literal source
transcription and provenance remain separately identified within the same
artifact.

### Units and reference convention

All model temperatures use kelvin,

\[
T_{\mathrm K}=T_{^\circ\mathrm C}+273.15.
\]

The source energy unit is converted using

\[
1\ \mathrm{cal/g\!\!-\!atom}=4.184\ \mathrm{J/mol\ of\ atoms}.
\]

The final Gibbs-energy functions therefore evaluate in J/mol for (T) in K.
Alpha-Pu supplies an arbitrary common zero,

\[
H_\alpha(298.15\ \mathrm K)=0,
\qquad
S_\alpha(298.15\ \mathrm K)=0.
\]

This normalization relates the seven branches; it is not an absolute
thermodynamic datum and is not a Standard Element Reference convention.

### Heat-capacity models and equilibrium-interval extrapolation

Ordinary least-squares lines were fitted to the alpha, beta, gamma, and liquid
observations after conversion of the temperature coordinate to kelvin. The
sparse delta, delta-prime, and epsilon observations use constant values. With
(C_p) in cal/(g-atom K), the adopted models are:

\[
\begin{aligned}
C_{p,\alpha}(T)&=5.277847142857144+0.01054285714285714T,\\
C_{p,\beta}(T)&=5.9806938095238+0.005342857142857166T,\\
C_{p,\gamma}(T)&=5.13858+0.0068T,\\
C_{p,\delta}(T)&=9.0,\\
C_{p,\delta'}(T)&=13.2,\\
C_{p,\epsilon}(T)&=8.4,\\
C_{p,L}(T)&=6.5226052631579075+0.0036842105263157764T.
\end{aligned}
\]

These deliberately simple representations avoid adding curvature unsupported
by the sparse source data. Each is used throughout its full equilibrium phase
interval, so parts of every interval are extrapolations:

| Phase | Measured (C_p) range (K) | Equilibrium model interval (K) | Explicit extrapolation |
|---|---:|---:|---|
| \(\alpha\) | 260.15–340.15 | 260.15–388.15 | 340.15–388.15 K |
| \(\beta\) | 413.15–463.15 | 388.15–458.15 | 388.15–413.15 K; observations from 458.15–463.15 K lie above the adopted interval |
| \(\gamma\) | 503.15–543.15 | 458.15–583.15 | 458.15–503.15 and 543.15–583.15 K |
| \(\delta\) | 600.15–700.15 | 583.15–725.15 | 583.15–600.15 and 700.15–725.15 K |
| \(\delta'\) | one point at 728.15 | 725.15–753.15 | the single value is assumed constant across the interval |
| \(\epsilon\) | 773.15–873.15 | 753.15–913.15 | 753.15–773.15 and 873.15–913.15 K |
| liquid | 923.15–948.15 | 913.15–948.15 | 913.15–923.15 K |

No broad, scientifically validated metastable ranges are asserted. The
alpha model expression is used only on its function-level validity interval.
An explicit linear-tangent segment supplies its value above that interval
within `systemValidity`, both as a candidate phase and as the reader's single
root dependency. That segment is a mathematical extension, not a claim that
alpha is physically supported there.

### System validity, model validity, and linear-tangent extensions

The unary model's `systemValidity` is 260.15–948.15 K: this is the complete
temperature domain over which the Pu dataset claims to provide a usable model.
Each phase function separately retains a function-level `validity` interval.
That interval records where the phase's underlying thermodynamic construction
is physically supported; it is not a statement that the phase is stable
throughout that interval. The intervals on `temperatureSegments` instead state
where the supplied mathematical expressions are to be evaluated.

To permit all seven candidate phases to be compared throughout
`systemValidity`, the JSON explicitly supplies first-order Taylor extensions
about the nearest model-validity endpoint. For an upper endpoint
\(T_{\max}\), the convention is

\[
G_{\mathrm{ext}}(T)=G(T_{\max})+
\left.\frac{dG}{dT}\right|_{T_{\max}^{-}}(T-T_{\max}),
\qquad T>T_{\max}.
\]

For a lower endpoint \(T_{\min}\), the convention is

\[
G_{\mathrm{ext}}(T)=G(T_{\min})+
\left.\frac{dG}{dT}\right|_{T_{\min}^{+}}(T-T_{\min}),
\qquad T<T_{\min}.
\]

These extension expressions are encoded as ordinary temperature segments and
are part of this dataset's executable mathematical representation inside
`systemValidity`. They are assumptions for metastable-branch comparisons, not
assertions that an extended branch describes a physically realizable or
quantitatively reliable metastable phase. They do not enlarge the underlying
function's model-validity interval.

The tangent construction preserves both \(G\) and \(dG/dT\) at the endpoint.
Because the extension is linear, however,

\[
\frac{d^2G_{\mathrm{ext}}}{dT^2}=0,
\qquad
C_p=-T\frac{d^2G_{\mathrm{ext}}}{dT^2}=0
\]

throughout the extension region. It therefore must not be described as an
extrapolation of the fitted or observed \(C_p\) model. An extension must also
never be used to establish or validate a source transition when that
transition lies outside the underlying model-validity ranges of the functions
being compared.

No extension beyond 260.15–948.15 K is canonical OBGEL data. Any
outside-system extrapolation is a consumer-level operation and must be made
explicit by that consumer rather than inferred or silently supplied by a
reader.

### Thermodynamic integration and phase stitching

For (C_p(T)=a+bT), each branch is constructed from

\[
H(T)=H(T_0)+a(T-T_0)+\frac{b}{2}(T^2-T_0^2),
\]

\[
S(T)=S(T_0)+a\ln\!\left(\frac{T}{T_0}\right)+b(T-T_0),
\]

and

\[
G(T)=H(T)-TS(T).
\]

At each transition (i\rightarrow j), Wick's measured transition temperature
and measured enthalpy are the stitching constraints:

\[
H_j(T_t)=H_i(T_t)+\Delta H_t,
\qquad
S_j(T_t)=S_i(T_t)+\frac{\Delta H_t}{T_t}.
\]

Consequently (G_i(T_t)=G_j(T_t)) by construction. Wick's reported
\(\Delta S\) is not used as a model constraint; it remains an independent
validation observation.

### Derived entropy comparison

| Transition | Derived \(\Delta H/T_t\) | Wick \(\Delta S\) | Difference |
|---|---:|---:|---:|
| \(\alpha\rightarrow\beta\) | 2.31869123 | 2.28 | +0.03869123 |
| \(\beta\rightarrow\gamma\) | 0.34923060 | 0.33 | +0.01923060 |
| \(\gamma\rightarrow\delta\) | 0.25379405 | 0.25 | +0.00379405 |
| \(\delta\rightarrow\delta'\) | 0.01379025 | 0.01 | +0.00379025 |
| \(\delta'\rightarrow\epsilon\) | 0.58952400 | 0.59 | -0.00047600 |
| \(\epsilon\rightarrow L\) | 0.74029458 | 0.74 | +0.00029458 |

All entries are in cal/(g-atom K). The absolute differences are small relative
to the historical enthalpy uncertainties and tabulated precision. The
delta-to-delta-prime discrepancy is large only as a percentage because both
reported quantities are exceptionally small: \(\Delta H=10\pm10\)
cal/g-atom and \(\Delta S=0.01\) cal/(g-atom K). The discrepancies are
documented rather than silently reconciled.

### JSON function structure and verification meaning

The function keys are the semantic phase names `alpha`, `beta`, `gamma`,
`delta`, `deltaPrime`, `epsilon`, and `liquid`. Alpha is the sole root. Each
other function has a function-level `baseFunction` naming alpha and stores the
explicit phase-minus-alpha Gibbs-energy terms. The dataset-level
`systemValidity` is distinct from each function-level `validity` interval.
Every `temperatureSegments` value and every `terms` value is an array, uses
the established basis vocabulary, and declares both endpoint-inclusion flags.
Within `systemValidity`, the model expressions and explicit tangent-extension
expressions form a complete evaluation domain for every phase.

The six transition temperatures recorded under derived verification are
recovered roots of adjacent encoded Gibbs energies. They verify the algebra,
units, coefficients, and reader representation; they are not independent
predictions because those temperatures were construction constraints.

### Unary-reader stress-test diagnostics

The completed Pu stress test exercised all seven Gibbs-energy branches through
the same generic unary reader used for Pb, Bi, and Mg. The reader recovered all
six construction transitions on the stable envelope at 388.15, 458.15,
583.15, 725.15, 753.15, and 913.15 K. These values confirm that the measured
transition temperatures and measured \(\Delta H\) stitching constraints were
encoded consistently; they are not independent predictions of the model.

All \(\binom{7}{2}=21\) phase pairs were also searched numerically over
`systemValidity`. In the current model every pair yielded exactly one crossing.
Six crossings are the stable-envelope transitions, while the other 15 are
metastable crossings and have `extension-derived` status. Their numerical root
residuals were essentially at machine precision: the largest observed absolute
residual was approximately \(5.82\times10^{-11}\) in the model's Gibbs-energy
units.

The 15 metastable crossing locations are properties of the Wick-derived model
*plus the adopted tangent-extension convention*. They are not Wick source
observations, experimentally established metastable transitions, or physical
predictions that should be attributed to the 1967 Handbook data alone. Their
precision documents numerical reproducibility, not physical accuracy.

A diagnostic plot of the seven branches and all pairwise crossings showed an
orderly structure, with no obvious repeated crossings, branch turnarounds, or
other pathological behavior introduced by the current extensions. This is a
useful mathematical diagnostic of the construction, but it does not establish
physical validity for the extended branches. The executable searches, residual
checks, and plot remain in the Mathematica unary-reader development artifacts
rather than being duplicated here.

### Audit status

The Wick table transcription is audited against the supplied screenshots. The
assumption-dependent model implementation is verified: the generic reader
recovers all six construction transitions, all 21 phase-pair crossings were
checked, and the largest observed absolute root residual was approximately
\(5.82\times10^{-11}\) J/mol. This verifies the encoding and numerical
reproducibility of the adopted construction; it does not independently
validate the Cp fits and extrapolations, stitching assumptions, arbitrary
reference normalization, or tangent-extension physics.

The Handbook volume/page locations and complete source references 29 and 31
still require bibliographic audit, and the model has not been compared with or
substituted for a modern assessed Pu unary description. The 15
`extension-derived` metastable crossings remain mathematical consequences of
the adopted tangent extensions, not experimentally validated transitions.
