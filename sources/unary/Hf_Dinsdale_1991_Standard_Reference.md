# Hf Dinsdale-1991 Standard Reference

## Purpose and version policy

This record documents the Hf unary model promoted to
`data/unary/hf-standard-reference.json`. Its exact reviewed pre-promotion
candidate is retained at
`working/unary-batch-0.2.0/promoted-candidates/hf-dinsdale-1991-standard-reference-candidate.json`.
The model is explicitly pinned to A. T. Dinsdale, “SGTE data for pure
elements,” *CALPHAD* 15(4) (1991) 317-425,
DOI 10.1016/0364-5916(91)90030-N. It is not an SGTE Unary Database v5 Hf
model.

The SGTE v5.0 header (2 June 2009) states `Revised data for Hf HCP_A3,
BCC_A2, FCC_A1`. That later database also contains 3000-3001 K continuation
segments. This candidate neither substitutes nor blends those later functions.
The version identifier `hf-unary-dinsdale-1991` is carried in the JSON so a
future newer Hf assessment can coexist without being mistaken for this model.

## Direct source audit

Dinsdale's transition table on p. 323 gives the ambient-pressure Hf sequence

\[
\mathrm{HCP\_A3}\xrightarrow{2016\ \mathrm{K}}\mathrm{BCC\_A2}
\xrightarrow{2506\ \mathrm{K}}\mathrm{LIQUID}.
\]

The Hf entry on pp. 357-358 designates its source as “N Saunders and A T
Dinsdale, Unpublished work.” It prints four relevant phase models: HCP_A3,
BCC_A2, LIQUID, and FCC_A1. FCC_A1 is retained as a metastable phase. No
magnetic term, pressure term, or other separate physical contribution is
printed in the Hf entry.

The source expressions use strict inequalities. OBGEL includes their finite
limiting values at 298.15 K and 3000 K, following the established endpoint
convention, and supplies no value outside that interval. No 3000-3001 K v5
continuation is included. Therefore `systemValidity` and every phase-model
validity are 298.15-3000 K with basis `sourceLimited`; no extension segment is
required.

## Model-defining Dinsdale-1991 functions

All energies below are in J/mol and are relative to
\(H_{\mathrm{Hf}}^{\mathrm{SER}}\). The logarithm is natural.

### HCP_A3 reference function

\[
G_{\mathrm{hcp}}-H^{\mathrm{SER}}_{\mathrm{Hf}}=
\begin{cases}
-6987.297+110.744026T-22.7075T\ln T-4.146145\times10^{-3}T^2
-4.77\times10^{-10}T^3-22590T^{-1}, & 298.15<T<2506,\\
-1446776.329+6193.609991T-787.5363829T\ln T
+0.1735215T^2-7.575759\times10^{-6}T^3+501742495T^{-1},
&2506<T<3000.
\end{cases}
\]

### BCC_A2 relative to HCP_A3

\[
G_{\mathrm{bcc}}-G_{\mathrm{hcp}}=
\begin{cases}
12358-6.908T-0.192T\ln T-6.046\times10^{-5}T^2
+8.724\times10^{-7}T^3-1.446\times10^{-10}T^4,
&298.15<T<2506,\\
3359233.1-14817.815721T+1875.1505076T\ln T
-0.460378565T^2+2.1003588\times10^{-5}T^3-1111827586T^{-1},
&2506<T<3000.
\end{cases}
\]

The final inverse-temperature coefficient is also obtained exactly by
subtracting the source-printed absolute HCP_A3 expression from the
source-printed absolute BCC_A2 expression:
\(-610085091-501742495=-1111827586\). This guards against OCR corruption of
the printed lattice-stability table.

### LIQUID relative to HCP_A3

\[
G_{\mathrm{liquid}}-G_{\mathrm{hcp}}=
\begin{cases}
27402.256-10.953093T,&298.15<T<1000,\\
56718.796-260.661416T+34.824312T\ln T-0.017115876T^2
+1.376943\times10^{-6}T^3-4427109T^{-1},&1000<T<2506,\\
1442529.112-5928.139468T+743.5363829T\ln T-0.1735215T^2
+7.575759\times10^{-6}T^3-501742495T^{-1},&2506<T<3000.
\end{cases}
\]

### FCC_A1 relative to HCP_A3

\[
G_{\mathrm{fcc}}-G_{\mathrm{hcp}}=10000-2.2T,
\qquad 298.15<T<3000.
\]

## OBGEL representation

The phase-identity keys are `hcp`, `bcc`, `liquid`, and `fcc`. The source
designations are retained separately. `gHcp` is the sole root function;
`gBcc`, `gLiquid`, and `gFcc` use `baseFunction: "gHcp"` and contain the
source-printed lattice-stability terms. This is analytic identity, not fitting
or dependency flattening, and is directly supported by the current generic
reader's single-root model.

The Dinsdale absolute BCC_A2, LIQUID, and FCC_A1 expressions are independent
crosschecks. Numerical validation must show equality between each encoded
base-function sum and its corresponding absolute expression throughout every
source segment.

## Provenance boundary

The SGTE v5 TDB is used only to document the existence of a later revision and
to identify the v5 range difference. Its Hf coefficients are not a source for
this candidate. A future v5- or newer-assessment Hf object must use a distinct
model identifier and its own source record rather than changing this version
pin in place.

## Independent unchanged-reader validation and promotion

The project owner independently loaded the version-pinned candidate with the
unchanged generic Mathematica unary reader and reported continuous
Gibbs-energy curves. The stable lower envelope was

\[
\mathrm{hcp}\xrightarrow{2016.03\ \mathrm{K}}\mathrm{bcc}
\xrightarrow{2506.00\ \mathrm{K}}\mathrm{liquid}.
\]

The reported pairwise equal-Gibbs-energy crossings also included
`fcc <-> liquid` at 1951.42 K and `hcp <-> liquid` at 2419.63 K. Both lie
within `systemValidity` and are retained as legitimate metastable crossings:
another phase is lower at each temperature, so neither is a stable-envelope
transition. The earlier description of the bcc-liquid result as metastable was
a transcription error; it is the equilibrium lower-envelope transition at
2506.00 K.

The analytic expressions also have pairwise roots for `bcc <-> fcc` at
-5310.28 K and `fcc <-> hcp` at 4545.45 K. These temperatures lie outside the
298.15-3000 K `systemValidity` interval. They are therefore rejected and are
not OBGEL thermodynamic results. This applies generally: a mathematical root
obtained by analytic extrapolation outside `systemValidity` must be excluded
regardless of whether a root finder can evaluate it.

Following this validation, the Hf object was promoted without changing any
function coefficient, breakpoint, basis term, dependency, system-validity
bound, or source-provenance field. Zr remains a separate review-required case.
