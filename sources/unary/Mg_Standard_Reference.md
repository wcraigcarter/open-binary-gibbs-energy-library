# Magnesium Standard Reference Extraction

## Purpose and status

This record documents the source extraction used to construct
`data/unary/mg-standard-reference.json`. The JSON file is the canonical
machine-readable representation; this document records the equations,
provenance, audit limits, and derived checks in human-readable form.

The extraction is **provisional pending a direct primary-source coefficient
audit**. The values below were established in the Mg unary development
discussion as Dinsdale/SGTE functions and were corroborated with an SGTE/COST
reproduction. The repository does not yet contain a line-by-line comparison
with the Mg entry in Dinsdale (1991), so no coefficient, breakpoint, or
validity limit is marked fully primary-source-audited.

## Identity and reference state

- Element: magnesium (Mg)
- Standard Element Reference phase: HCP-A3
- Reference conditions: 298.15 K and 1 bar
- Energy reference: \(H^{\mathrm{SER}}_{\mathrm{Mg}}\), the enthalpy of Mg in
  its Standard Element Reference state
- Temperature unit: K
- Molar Gibbs-energy unit: J/mol

## Extracted functions

### Stable HCP-A3 reference

The source function identifier is `GHSERMG`. It is retained as provenance
metadata rather than used as a semantic JSON key.

\[
G_{\mathrm{HCP-A3,Mg}}(T)-H^{\mathrm{SER}}_{\mathrm{Mg}}=
\begin{cases}
-8367.34+143.675547T-26.1849782T\ln T
+0.0004858T^2-1.393669\times10^{-6}T^3+78950T^{-1},
&298.15\leq T<923,\\[4pt]
-14130.185+204.716215T-34.3088T\ln T
+1.038192\times10^{28}T^{-9},
&923\leq T\leq3000.
\end{cases}
\]

Canonical semantic key: `stableReference`  
Mathematica-facing name: `gReferenceMg`

### Metastable liquid reference

The source function identifier is `GLIQMG`. The liquid function is represented
as `gReferenceMg(T)` plus the liquid-minus-HCP-A3 lattice stability:

\[
G_{\mathrm{Liquid,Mg}}(T)-G_{\mathrm{HCP-A3,Mg}}(T)=
\begin{cases}
8202.243-8.83693T-8.0176\times10^{-20}T^7,
&298.15\leq T<923,\\[4pt]
8690.316-9.392158T-1.038192\times10^{28}T^{-9},
&923\leq T\leq3000.
\end{cases}
\]

Canonical semantic key: `metastableLiquidReference`  
Mathematica-facing name: `gLiquidReferenceMg`  
Base function: `gReferenceMg`

### Metastable FCC-A1 reference

\[
G_{\mathrm{FCC-A1,Mg}}(T)-G_{\mathrm{HCP-A3,Mg}}(T)
=2600-0.9T,
\qquad 298.15\leq T\leq3000.
\]

Canonical semantic key: `metastableFccReference`  
Mathematica-facing name: `gFccReferenceMg`  
Base function: `gReferenceMg`

### Metastable BCC-A2 reference

\[
G_{\mathrm{BCC-A2,Mg}}(T)-G_{\mathrm{HCP-A3,Mg}}(T)
=3100-2.1T,
\qquad 298.15\leq T\leq3000.
\]

Canonical semantic key: `metastableBccReference`  
Mathematica-facing name: `gBccReferenceMg`  
Base function: `gReferenceMg`

## Provenance

The intended primary authority is:

A. T. Dinsdale, “SGTE data for pure elements,” *CALPHAD* **15** (1991),
317–425, DOI: 10.1016/0364-5916(91)90030-N.

The immediate transcription record is the Mg unary development discussion,
which attributed the stable-reference and lattice-stability functions to the
Dinsdale/SGTE data and reported independent corroboration from an SGTE/COST
compilation. The exact bibliographic identity and location of that secondary
reproduction have not yet been recorded in the repository and must be added
during the direct source audit.

Source identifiers belong only to provenance metadata. The JSON function keys
describe thermodynamic meaning, and the `name` fields supply readable
Mathematica-facing identifiers.

## Verification and audit limits

All verification data are derived and non-model-defining. The model must be
evaluable entirely from the functions, segments, dependencies, and terms in
the JSON.

Numerical roots of equal Gibbs energies give three derived phase crossings:

- FCC-A1 to BCC-A2 at 416.667 K, a metastable phase crossing;
- HCP-A3 to Liquid at 923.0 K, the stable-envelope transition; and
- HCP-A3 to BCC-A2 at 1476.19 K, a metastable phase crossing.

Here “to” orders the phases by the lower-Gibbs-energy phase below and above
the crossing; it does not imply a kinetic transformation direction. The two
metastable crossings are not equilibrium transitions on the stable envelope.

The expected HCP-A3/liquid equality is approximately 923 K. Direct numerical
evaluation of the rounded lattice-stability coefficients gives two roots near
the piecewise boundary:

- low-temperature expression: 922.9999718767 K;
- high-temperature expression: 923.0001083905 K.

The roots differ by approximately 0.0001365 K because the two rounded liquid
lattice-stability expressions have a small discontinuity at 923 K. At the
boundary, the low-temperature expression extrapolates to -0.0002583 J/mol and
the active high-temperature expression evaluates to +0.0009955 J/mol. Thus
923 K is recorded only as an equality transition reproduced to the precision
of the encoded coefficients, not as a single exact root of a perfectly
continuous piecewise function.

The two stable-reference expressions differ by approximately -0.0013625 J/mol
at 923 K (upper segment minus lower-segment extrapolation), which is likewise
consistent with coefficient-rounding precision but should be checked during
the primary-source audit.

Before the entry can be promoted from provisional status, audit directly
against the Mg table in Dinsdale (1991):

1. every stable HCP-A3 coefficient and the 923 K breakpoint;
2. both liquid lattice-stability segments and their endpoint convention;
3. the FCC-A1 and BCC-A2 lattice-stability coefficients;
4. the 298.15–3000 K validity ranges; and
5. the precise source location and identity of the secondary SGTE/COST
   corroboration.
