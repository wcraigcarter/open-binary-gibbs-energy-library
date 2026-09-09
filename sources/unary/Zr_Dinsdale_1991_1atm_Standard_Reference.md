# Zr Dinsdale-1991 fixed-1-atm standard reference

## Purpose and authority

This record documents the source audit and fixed-pressure reduction used for
the staged schema-0.2.0 candidate
`working/unary-batch-0.2.0/candidates/zr-dinsdale-1991-1atm-standard-reference-candidate.json`.
The primary authority is A. T. Dinsdale, “SGTE data for pure elements,”
*CALPHAD* 15(4) (1991) 317-425,
DOI 10.1016/0364-5916(91)90030-N. The model identifier is
`zr-unary-dinsdale-1991-p101325-pa`.

No SGTE Unary Database v5 coefficient is model-defining here. The complete
phase set and coefficients were transcribed from Dinsdale pp. 423-425; the
transition comparison uses p. 325; and the pressure treatment uses the general
model on pp. 319-320.

## Complete audited phase set

Dinsdale prints five Zr phases. All five are retained:

| Canonical key | Exact source designation | Source designation printed by Dinsdale |
|---|---|---|
| `hcp` | `HCP_A3` | A Fernandez Guillermet, *High Temp. - High Press.* 19 (1987) 119-60 |
| `omega` | `OMEGA` | same Fernandez Guillermet assessment |
| `bcc` | `BCC_A2` | same Fernandez Guillermet assessment |
| `liquid` | `LIQUID` | same Fernandez Guillermet assessment |
| `fcc` | `FCC_A1` | “Saunders et al.” |

OMEGA is retained as a scientifically meaningful pressure-relevant metastable
branch. FCC_A1 is also retained because Dinsdale explicitly supplies it.

## Dinsdale pressure model

For condensed phases, Dinsdale writes a Murnaghan pressure contribution

\[
G_{\rm pres}(T,P)=
\frac{A\exp\!\left(a_0T+a_1T^2/2+a_2T^3/3+a_3T^{-1}\right)}
{(K_0+K_1T+K_2T^2)(n-1)}
\left(\left[1+nP(K_0+K_1T+K_2T^2)\right]^{1-1/n}-1\right).
\]

The parameters describe the material at zero pressure: $A$ is the molar
volume at 0 K and 0 Pa, the $a_i$ describe zero-pressure thermal expansion,
and the $K_i$ describe zero-pressure compressibility. Thus $P$ is in Pa,
$A$ is in m^3/mol, $a_0$ is in K^-1, $a_1$ is in K^-2, $K_0$ is in
Pa^-1, $K_1$ is in Pa^-1 K^-1, and $n$ is dimensionless. Dinsdale does not
use 1 atm as the zero of this term: $G_{\rm pres}=0$ at $P=0$.

Dinsdale explicitly states that, for typical compressibilities and pressures
of order $10^5$ Pa or smaller, the expression reduces to

\[
G_{\rm pres}=AP\left(1+a_0T+\frac{a_1T^2}{2}
+\frac{a_2T^3}{3}+a_3T^{-1}\right).
\]

The canonical unary uses this source-authorized low-pressure form at exactly
$P=101325$ Pa. The pressure contribution is therefore retained, not dropped.
For Zr only $a_0$ is printed except for HCP_A3, which also has $a_1$.
The FCC_A1 absolute and relative functions establish the same pressure model
as HCP_A3, so the differential FCC-minus-HCP pressure term cancels exactly.

| Phase | $A$ (m^3/mol) | $a_0$ (K^-1) | $a_1$ (K^-2) | $K_0$ (Pa^-1) | $K_1$ (Pa^-1 K^-1) | $n$ |
|---|---:|---:|---:|---:|---:|---:|
| HCP_A3 | 13.9567e-6 | 12.443e-6 | 14.76e-9 | 1.0063e-11 | 1.573e-15 | 3.006 |
| BCC_A2 | 13.7141e-6 | 3.0381e-5 | 0 | 1.0063e-11 | 1.573e-15 | 3.006 |
| OMEGA | 1.37115e-5 | 3.0381e-5 | 0 | 1.0063e-11 | 1.573e-15 | 3.006 |
| LIQUID | 1.44092e-5 | 3.0381e-5 | 0 | 1.0063e-11 | 1.573e-15 | 3.006 |
| FCC_A1 | same as HCP_A3 | same | same | same | same | same |

At 101325 Pa the reduced pressure coefficients
$AP+(APa_0)T+(APa_1/2)T^2$ are:

| Phase | constant (J/mol) | coefficient of T (J/mol/K) | coefficient of T2 (J/mol/K2) |
|---|---:|---:|---:|
| HCP_A3 and FCC_A1 | 1.4141626275 | 1.75964255739825e-5 | 1.043652019095e-8 |
| BCC_A2 | 1.3895811825 | 4.22168659055325e-5 | 0 |
| OMEGA | 1.3893177375 | 4.22088621829875e-5 | 0 |
| LIQUID | 1.46001219 | 4.435663034439e-5 | 0 |

Across 298.15-4000 K the retained low-pressure expression differs from the
full Murnaghan expression by at most 0.02109 J/mol; the full pressure
contribution itself reaches only 1.673 J/mol. This is an audited use of
Dinsdale's stated low-pressure reduction, not an assertion that the pressure
term is exactly zero.

## Source-printed zero-pressure thermal functions

All expressions are in J/mol relative to $H_{\rm Zr}^{\rm SER}$, before the
phase-specific $G_{\rm pres}$ term is added. Logarithms are natural.

### HCP_A3

\[
G^0_{\rm hcp}=
\begin{cases}
-7827.595+125.64905T-24.1618T\ln T-4.37791\times10^{-3}T^2
+34971T^{-1},&130<T<2128,\\
-26085.921+262.724183T-42.144T\ln T
-1.342895\times10^{31}T^{-9},&2128<T<4000.
\end{cases}
\]

### BCC_A2

\[
G^0_{\rm bcc}=
\begin{cases}
-525.539+124.9457T-25.607406T\ln T-3.40084\times10^{-4}T^2
-9.7289735\times10^{-9}T^3-7.6142894\times10^{-11}T^4
+25233T^{-1},&298.15<T<2128,\\
-30705.955+264.284163T-42.144T\ln T
+1.276058\times10^{32}T^{-9},&2128<T<4000.
\end{cases}
\]

### OMEGA

\[
G^0_{\rm omega}=
\begin{cases}
-8878.082+144.432234T-26.8556T\ln T-2.7994455\times10^{-3}T^2
+38376T^{-1},&298.15<T<2128,\\
-29500.524+265.290858T-42.144T\ln T
+7.17444982\times10^{31}T^{-9},&2128<T<4000.
\end{cases}
\]

### LIQUID

\[
G^0_{\rm liquid}=
\begin{cases}
10320.095+116.568238T-24.1618T\ln T-4.37791\times10^{-3}T^2
+34971T^{-1}+1.6275\times10^{-22}T^7,&298.15<T<2128,\\
-8281.26+253.812609T-42.144T\ln T,&2128<T<4000.
\end{cases}
\]

### FCC_A1

\[
G^0_{\rm fcc}=
\begin{cases}
-227.595+124.74905T-24.1618T\ln T-4.37791\times10^{-3}T^2
+34971T^{-1},&298.15<T<2128,\\
-18485.921+261.824183T-42.144T\ln T
-1.342895\times10^{31}T^{-9},&2128<T<4000.
\end{cases}
\]

Dinsdale also prints $G_{\rm fcc}-G_{\rm hcp}=7600-0.9T$, which is exactly
consistent with the absolute expressions and confirms cancellation of their
identical pressure terms.

## Relative-table discrepancies and encoded construction

The printed Zr-relative-to-HCP table is slightly rounded or inconsistent with
the printed absolute functions in two inverse-temperature coefficients:

- BCC_A2 prints $-9737T^{-1}$, whereas direct subtraction of the absolute
  coefficients gives $25233-34971=-9738$.
- OMEGA prints $+3406T^{-1}$, whereas direct subtraction gives
  $38376-34971=3405$.

Its high-temperature BCC and OMEGA inverse-power coefficients are also printed
with fewer significant digits than the absolute-function differences. The
candidate therefore uses one HCP root and analytically subtracts the printed
absolute G-HSER functions, including the phase-specific fixed-pressure terms.
This preserves exact equality to the audited absolute source model rather than
silently choosing one side of the source discrepancy. The discrepancies remain
visible here and in phase metadata.

## Validity and endpoint policy

HCP_A3 is printed for 130-4000 K. All other retained phases begin at 298.15 K,
so the common `systemValidity` is 298.15-4000 K. The 2128 K breakpoint is
preserved. OBGEL includes finite limiting values at the system endpoints and
uses lower-inclusive, upper-exclusive internal segments with the final segment
upper-inclusive. No mathematical extension is used.

Pairwise roots are searched and reported only inside this `systemValidity`.
Analytic roots outside it are non-results under the rule established during the
Hf review.

## Derived validation results

The independent Wolfram Language validator recovers the stable sequence

\[
\mathrm{hcp}\xrightarrow{1138.99415675\ \mathrm{K}}\mathrm{bcc}
\xrightarrow{2127.86293875\ \mathrm{K}}\mathrm{liquid}.
\]

Dinsdale's transition table gives 1139.45 K and 2127.85 K. The encoded roots
are respectively 0.456 K and 0.013 K away. These are consequences of the
printed functions, not imposed construction constraints.

OMEGA never reaches the 1-atm lower envelope. Its smallest margin above HCP is
125.375 J/mol at 298.15 K, and it is 800.338 J/mol above HCP at the HCP-BCC
transition. OMEGA lies below BCC at low temperature, then crosses BCC
metastably at 970.281 K; HCP is lower than both phases there.

All in-domain pairwise crossings are recorded in the machine-readable
diagnostic. C0 residuals at 2128 K are at most 0.063 J/mol and C1 residuals are
at most 7.2e-5 J/mol/K. No source coefficient was adjusted to remove
printed-coefficient rounding residuals.

The staged candidate is ready for the project owner's independent test with the
unchanged generic Mathematica reader. It has not been promoted, committed, or
pushed.
