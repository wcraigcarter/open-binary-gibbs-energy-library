# H2O reduced-model development workspace

This directory contains an auditable, development-only reduction of published
IAPWS water and Ice Ih properties to OBGEL's unary temperature basis. It does
not create or update a canonical file under `data/unary/`.

## Reproduce the results

Use Python 3.11 or newer from this directory:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python develop_h2o_reduced_model.py
```

The script writes only to `generated/` unless `--output` is supplied. The
generated files are:

- `h2o-iapws-samples.csv`: 1 K samples plus exact computed phase-boundary and
  vapor-spinodal rows, with phase-region labels;
- `h2o-fit-diagnostics.json`: provisional coefficients, residual statistics,
  implementation checks, and crossing shifts;
- `h2o-fit-residuals.png`: Gibbs and heat-capacity residuals for the selected
  candidate fits;
- `h2o-phase-envelope.png`: the selected provisional branches and crossings.

The Python `iapws` package is a numerical implementation adapter, not the
scientific authority. Before sampling, the script checks that it reproduces
published IAPWS-95 and Ice Ih verification values. The authoritative equations,
validity statements, and reference convention remain the IAPWS documents cited
in `sources/unary/H2O_Pure_Substance_Unary.md`.

## Fitting method

For a chosen set of curvature-bearing terms, the script first least-squares
fits heat capacity using

\[
C_p=-T\frac{d^2G}{dT^2}.
\]

It then determines the constant and linear-in-temperature integration terms by
least squares against molar Gibbs energy. This makes the curvature requirement
part of construction rather than merely checking it afterward. Candidate
selection uses development-only targets of 0.25 J/mol maximum absolute Gibbs
residual and 1.0 J/(mol K) maximum absolute heat-capacity residual. These are
not repository-wide standards and are not grounds for automatic canonical
promotion.

The initial five-term form is

\[
G=a+bT+cT\ln T+dT^2+eT^3.
\]

Only the liquid candidate requires added `T^-1` and `T^-2` terms to meet the
stated development targets. The stable vapor branch and Ice Ih retain the
initial five-term form.

## Important vapor-domain result

At 101325 Pa, IAPWS-95 has no mechanically stable low-density vapor root below
approximately 326.41 K. The existing root approaches a spinodal there, so its
heat capacity diverges and a compact reduction over the full mechanically
evaluable metastable interval is not useful. IAPWS also states that no
experimental property data exist for subcooled vapor and recommends its main
Helmholtz equation only close to saturation, pointing to the auxiliary gas
equation in the underlying Wagner-Pruss paper farther away.

Consequently this development pass:

- records 250 K to the 1-atm vapor spinodal as unsupported;
- samples the IAPWS-95 metastable vapor root above the spinodal with an explicit
  caution label;
- reports failed compact-fit diagnostics for that full evaluable interval; and
- selects a provisional vapor reduction only from the 1-atm boiling point to
  500 K.

IAPWS G9-12 is not a remedy for this fixed-pressure boundary. It modifies the
IAPWS-95 ideal-gas term below 130 K (extending it to 50 K), whereas the requested
temperature interval begins at 250 K.
