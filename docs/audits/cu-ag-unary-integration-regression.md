# Cu-Ag canonical-unary integration regression

**Status:** implementation regression passed; retain as a development result,
not a broad binary-schema promotion.

The regression compares the unchanged embedded Cu-Ag endpoint expressions with
the canonical schema-0.2.0 Cu and Ag unary functions selected by structural
phase identity. Ideal-mixing and Redlich-Kister terms are identical in both
paths.

## End-member mapping

Let \(x=x_{Cu}\) and \(x_{Ag}=1-x\).

| Binary phase | Old embedded Cu endpoint | Old embedded Ag endpoint | Canonical Cu function | Canonical Ag function | Ideal term | Excess term |
|---|---|---|---|---|---|---|
| Liquid | flattened `GLIQCU`, \(G_{Cu}^{L}-H_{Cu}^{SER}\) | flattened `GLIQAG`, \(G_{Ag}^{L}-H_{Ag}^{SER}\) | `functions["liquid"]` | `functions["liquid"]` | \(RT[x\ln x+(1-x)\ln(1-x)]\) | \(x(1-x)[L_0^L+L_1^L(2x-1)]\) |
| FCC-A1 | flattened `GHSERCU`, \(G_{Cu}^{fcc}-H_{Cu}^{SER}\) | flattened `GHSERAG`, \(G_{Ag}^{fcc}-H_{Ag}^{SER}\) | `functions["fcc"]` | `functions["fcc"]` | same ideal form | \(x(1-x)[L_0^{fcc}+L_1^{fcc}(2x-1)]\) |

No binary-specific lattice-stability offset is present. Cu and Ag are both FCC
SER elements, but phase selection still uses explicit structure keys. The
liquid endpoints are metastable pure-liquid functions below their melting
points, not stable-envelope lookups.

The unchanged interaction coefficients are:

- Liquid: \(L_0=17384.37-4.46438T\),
  \(L_1=-1660.74+2.31516T\).
- FCC-A1: \(L_0=36772.58-11.02847T\),
  \(L_1=4612.43-0.28869T\).

The explicit Redlich-Kister order is Cu,Ag, matching the stored Cu-first
coefficients and the factor \((2x_{Cu}-1)^k\).

## Delta-G diagnosis

The canonical and embedded endpoints share the same Dinsdale/SGTE SER reference
convention, but they are not algebraically identical. The old binary copies
round four very small high-order coefficients:

| Endpoint interval | \(G_{canonical}-G_{embedded}\), J/mol |
|---|---:|
| Cu liquid, \(T<1357.77\) K | \(+1.0\times10^{-25}T^7\) |
| Ag liquid, \(T<1234.93\) K | \(+9.5\times10^{-25}T^7\) |
| Cu FCC, \(T>1357.77\) K | \(-3.3\times10^{25}T^{-9}\) |
| Ag FCC, \(T>1234.93\) K | \(-2.27\times10^{25}T^{-9}\) |

At 1234.93 K and 1357.77 K there is an additional representation difference:
the embedded binary segments overlap inclusively and the legacy reader takes
the first branch, while schema-0.2.0 unary data assign each boundary explicitly
to one segment. The residual branch discontinuities are only millijoules per
mole but are preserved in the diagnostic.

Therefore

\[
\Delta G_{liquid}=x\,\delta G_{Cu}^{liquid}+(1-x)\,\delta G_{Ag}^{liquid},
\]

\[
\Delta G_{fcc}=x\,\delta G_{Cu}^{fcc}+(1-x)\,\delta G_{Ag}^{fcc}.
\]

These shifts are affine in composition within a phase, but they differ between
phases. They are not one common reference shift and are not algebraically
guaranteed to cancel from equilibria. No coefficient was changed to force exact
agreement.

Across the regression grid (298.15-3000 K and nine compositions including both
endpoints), the maximum absolute differences were:

- Liquid: 0.00416098 J/mol.
- FCC-A1: 0.00214060 J/mol.

Representative direct evaluations are:

| \(T\), K | \(x_{Cu}\) | \(\Delta G_{liquid}\), J/mol | \(\Delta G_{fcc}\), J/mol |
|---:|---:|---:|---:|
| 500 | 0.25 | \(+5.76\times10^{-6}\) | below \(10^{-11}\) |
| 1053 | 0.40 | \(+8.76\times10^{-4}\) | below \(2\times10^{-11}\) |
| 1234.93 | 0.50 | \(+1.43\times10^{-3}\) | \(+1.68\times10^{-4}\) |
| 1300 | 0.50 | \(+3.14\times10^{-4}\) | \(-1.07\times10^{-3}\) |
| 1600 | 0.50 | zero to numerical precision | \(-4.05\times10^{-4}\) |
| 3000 | 0.50 | zero to numerical precision | \(-1.41\times10^{-6}\) |

## Equilibrium regression

The common-tangent solver returned:

| Quantity | Embedded baseline | Canonical unary | Canonical - embedded |
|---|---:|---:|---:|
| Ag-rich FCC \(x_{Cu}\) | 0.1314370318 | 0.1314370734 | \(+4.16\times10^{-8}\) |
| Liquid \(x_{Cu}\) | 0.4028982366 | 0.4028983784 | \(+1.42\times10^{-7}\) |
| Cu-rich FCC \(x_{Cu}\) | 0.9550043071 | 0.9550042894 | \(-1.78\times10^{-8}\) |
| Eutectic temperature, K | 1053.0154875 | 1053.0155581 | \(+7.06\times10^{-5}\) |

The largest absolute canonical-root equilibrium residual was
\(2.19\times10^{-6}\) J/mol on the numerical derivative/intercept equations.
The computed eutectic remains approximately 1053.0 K and retains the previously
validated agreement with the reported 779.1 C assessment value.

Representative common-tangent boundary changes were:

| Temperature | Equilibrium | Largest \(|\Delta x_{Cu}|\) |
|---:|---|---:|
| 800 K | FCC/FCC miscibility gap | \(4.83\times10^{-13}\) |
| 1000 K | FCC/FCC miscibility gap | \(3.12\times10^{-12}\) |
| 1100 K | Ag-rich FCC/liquid and liquid/Cu-rich FCC | \(4.28\times10^{-7}\) |
| 1200 K | Ag-rich FCC/liquid and liquid/Cu-rich FCC | \(6.75\times10^{-7}\) |

The endpoint ordering and phase topology were unchanged. The automated
regression tolerances are 0.01 J/mol for phase energy, 0.001 K for the eutectic
temperature, \(10^{-6}\) in composition, and \(10^{-5}\) J/mol for root
residuals. `tools/cu-ag-unary-regression.wl` passed all gates.

## Scope decision

This result validates the Cu-Ag binary-to-unary consumption pattern. It does not
promote Mg-Pb, resolve its line compound, or establish that every binary can be
migrated without a source-version audit. Embedded endpoint expressions remain
temporarily for backward compatibility and as the independent regression
baseline.
