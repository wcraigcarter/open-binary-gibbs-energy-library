# Iron Standard Reference Extraction

## Purpose and status

This record documents the primary-source extraction and reader-compatible
construction of `data/unary/fe-standard-reference.json`. The JSON is the
canonical machine-readable model; this document records the source equations,
physical interpretation, transformation constraints, and derived
implementation checks.

The retained coefficients and Fe-specific magnetic parameters were audited
directly against A. T. Dinsdale, “SGTE data for pure elements,” *CALPHAD* 15
(1991) 317–425, DOI 10.1016/0364-5916(91)90030-N. The general magnetic model
is printed on pages 320–321, the SGTE Fe transformation data on page 323, and
the Fe functions on pages 351–353.

## Identity, conditions, and scope

- Element: iron (Fe)
- Standard Element Reference phase: BCC-A2
- Reference conditions: 298.15 K and 1 bar
- Energy reference: \(H^{\mathrm{SER}}_{\mathrm{Fe}}\)
- Temperature unit: K
- Molar Gibbs-energy unit: J/mol
- Canonical system validity: 298.15–6000 K
- Candidate phase keys: `bcc`, `fcc`, `hcp`, and `liquid`

Dinsdale prints a common 298.15–6000 K range for the four retained
temperature-only phase functions. The source inequalities are open; the
canonical representation includes the finite limiting values at 298.15 and
6000 K and supplies no value outside that closed interval.

The source also supplies pressure terms. This immediate unary test fixes the
ambient-pressure context at 1 bar and omits \(G_{\mathrm{pres}}\), following
Dinsdale's statement that the pressure contribution can be ignored at low or
moderate pressure. This is a temperature-only ambient-pressure test, not a
high-pressure Fe model.

HCP-A3 is retained. Dinsdale explicitly provides its Fe function, and its
presence is a useful negative envelope test: at 1 bar it must remain above the
stable lower envelope even though HCP Fe is relevant at high pressure.

## Phase identity and the Curie point

BCC-A2 is one crystallographic phase function across the full interval. The
1043 K Curie point changes the branch of the magnetic contribution within that
function; it does not create separate ferromagnetic and paramagnetic phase
keys. The expected equilibrium topology is therefore

\[
\mathrm{bcc}\rightarrow\mathrm{fcc}\rightarrow\mathrm{bcc}
\rightarrow\mathrm{liquid}.
\]

The source also assigns FCC-A1 a Néel temperature of 67 K. That critical point
lies below this dataset's 298.15 K lower bound, so only the high-temperature
magnetic branch is required for FCC inside `systemValidity`.

## Dinsdale Fe functions

Pressure terms are omitted below as described above.

### BCC-A2

Source magnetic parameters:

- \(T_C=1043\ \mathrm{K}\)
- \(\beta_0=2.22\)
- \(p=0.40\)
- source-printed \(D=1.55828482\); recomputed
  \(D=1.5582848200312989\) from the source normalization formula

The source expression is

\[
G_{\mathrm{bcc}}-H^{\mathrm{SER}}_{\mathrm{Fe}}=
\begin{cases}
1225.7+124.134T-23.5143T\ln T-0.00439752T^2
-5.89269\times10^{-8}T^3+77358.5T^{-1}+G_{\mathrm{mag,bcc}},
&298.15<T<1811,\\
-25383.581+299.31255T-46T\ln T
+2.2960305\times10^{31}T^{-9}+G_{\mathrm{mag,bcc}},
&1811<T<6000.
\end{cases}
\]

### FCC-A1

Source magnetic parameters:

- \(T_N=67\ \mathrm{K}\)
- \(\beta_0=0.7\)
- \(p=0.28\)
- source-printed \(D=2.342456517\); recomputed
  \(D=2.342456516879052\) from the source normalization formula

The source expression is

\[
G_{\mathrm{fcc}}-H^{\mathrm{SER}}_{\mathrm{Fe}}=
\begin{cases}
-236.7+132.416T-24.6643T\ln T-0.00375752T^2
-5.89269\times10^{-8}T^3+77358.5T^{-1}+G_{\mathrm{mag,fcc}},
&298.15<T<1811,\\
-27097.396+300.25256T-46T\ln T
+2.78854\times10^{31}T^{-9}+G_{\mathrm{mag,fcc}},
&1811<T<6000.
\end{cases}
\]

### HCP-A3

No magnetic contribution is assigned in the Dinsdale Fe entry:

\[
G_{\mathrm{hcp}}-H^{\mathrm{SER}}_{\mathrm{Fe}}=
\begin{cases}
-2480.08+136.725T-24.6643T\ln T-0.00375752T^2
-5.89269\times10^{-8}T^3+77358.5T^{-1},
&298.15<T<1811,\\
-29340.78+304.56206T-46T\ln T
+2.78854\times10^{31}T^{-9},
&1811<T<6000.
\end{cases}
\]

### Liquid

No magnetic contribution is assigned:

\[
G_{\mathrm{liquid}}-H^{\mathrm{SER}}_{\mathrm{Fe}}=
\begin{cases}
13265.87+117.57557T-23.5143T\ln T-0.00439752T^2
-5.89269\times10^{-8}T^3+77358.5T^{-1}
-3.6751551\times10^{-21}T^7,
&298.15<T<1811,\\
-10838.83+291.302T-46T\ln T,
&1811<T<6000.
\end{cases}
\]

## Magnetic model and analytical expansion

Dinsdale attributes the magnetic model to Hillert and Jarl, following Inden:

\[
G_{\mathrm{mag}}=RT\ln(\beta_0+1)g(\tau),
\qquad \tau=\frac{T}{T^*}.
\]

Here \(T^*\) is \(T_C\) for ferromagnetism or \(T_N\) for
antiferromagnetism. The source gives

\[
g(\tau)=1-\frac{
\dfrac{79}{140p}\tau^{-1}
+\dfrac{474}{497}\left(\dfrac1p-1\right)
\left(\dfrac{\tau^3}{6}+\dfrac{\tau^9}{135}
+\dfrac{\tau^{15}}{600}\right)}{D},\qquad \tau\leq1,
\]

\[
g(\tau)=-\frac{
\dfrac{\tau^{-5}}{10}+\dfrac{\tau^{-15}}{315}
+\dfrac{\tau^{-25}}{1500}}{D},\qquad \tau>1,
\]

with

\[
D=\frac{518}{1125}+\frac{11692}{15975}\left(\frac1p-1\right).
\]

The source leaves \(R\) symbolic. The executable expansion records
\(R=8.31451\ \mathrm{J\,mol^{-1}\,K^{-1}}\) explicitly as the numerical
implementation convention; it is not represented as an Fe-specific value
printed by Dinsdale.

Multiplication by \(T\) makes the magnetic model exactly representable by the
existing OBGEL basis. Below a magnetic critical temperature the contribution
contains constant, \(T\), \(T^4\), \(T^{10}\), and \(T^{16}\) terms. Above it,
the contribution contains \(T^{-4}\), \(T^{-14}\), and \(T^{-24}\) terms.

For BCC the expanded branches are

\[
G_{\mathrm{mag,bcc}}^{\tau\leq1}=
-9180.563933511205+9.722833007844594T
-1.3111579814807738\times10^{-9}T^4
-4.5265430418603135\times10^{-29}T^{10}
-7.911217451179016\times10^{-48}T^{16},
\]

\[
G_{\mathrm{mag,bcc}}^{\tau>1}=
-7.701361841501686\times10^{14}T^{-4}
-3.7247751332730464\times10^{43}T^{-14}
-1.1916876491777889\times10^{73}T^{-24}.
\]

For FCC, only the \(\tau>1\) branch occurs in the modeled range:

\[
G_{\mathrm{mag,fcc}}=
-2.5429013017053\times10^8T^{-4}
-1.4715227384102559\times10^{25}T^{-14}
-5.632929283446668\times10^{42}T^{-24}.
\]

These coefficients are added directly to the applicable source phase
polynomial in the JSON. No reader change, special magnetic evaluator, or phase
splitting is required.

## Source constraints, derived roots, and unchanged-reader validation

Dinsdale's SGTE transition table reports these authoritative constraints:

| Low-temperature phase | High-temperature phase | Source temperature (K) |
|---|---|---:|
| BCC-A2 | FCC-A1 | 1184.80 |
| FCC-A1 | BCC-A2 | 1667.50 |
| BCC-A2 | liquid | 1811.00 |

Numerical roots of the encoded Gibbs-energy equalities are derived checks of
the audited SGTE functions:

| Low-temperature phase | High-temperature phase | Computed temperature (K) | Computed minus source (K) |
|---|---|---:|---:|
| `bcc` | `fcc` | 1184.8145692964 | +0.0145692964 |
| `fcc` | `bcc` | 1667.4686799589 | -0.0313200411 |
| `bcc` | `liquid` | 1810.9548255026 | -0.0451744974 |

The differences are consistent with the precision of the printed
coefficients. The 1810.9548 K equality lies just below the 1811 K polynomial
boundary and is evaluated with the lower source branches.

The unchanged generic Mathematica reader then recovered the stable lower
envelope with the following reported transition temperatures:

| Stable-envelope transition | Unchanged-reader result (K) | Audited source value (K) | Reader minus source (K) |
|---|---:|---:|---:|
| `bcc` to `fcc` | 1184 | 1184.80 | -0.80 |
| `fcc` to `bcc` | 1667.47 | 1667.50 | -0.03 |
| `bcc` to `liquid` | 1810.95 | 1811.00 | -0.05 |

These reader-reported values are implementation-validation results derived
from the encoded functions. The Dinsdale/SGTE values are audited source
constraints used in the assessment, so neither the higher-precision equality
roots nor the unchanged-reader results are independent thermodynamic
predictions. The first reader value is retained exactly as reported, without
implying more precision than the completed run supplied.

The recovered lower envelope over all four candidates is

\[
\boxed{\mathrm{bcc}\rightarrow\mathrm{fcc}\rightarrow
\mathrm{bcc}\rightarrow\mathrm{liquid}}.
\]

HCP is never the minimum at 1 bar. The BCC Curie point at 1043 K is recorded
separately as a magnetic critical point. The re-entrant result preserves one
`bcc` phase identity: the same BCC Gibbs function is stable below the FCC
region and becomes stable again above it. The Curie transition remains an
internal magnetic-ordering contribution to that single function. BCC is
stable immediately below and above 1043 K, so the reader correctly does not
report the Curie point as a crystallographic stable-envelope transition.

## Continuity audit

At 1043 K, the two expanded BCC magnetic branches agree to
\(3.4\times10^{-13}\) J/mol in value and \(1.8\times10^{-15}\) J/(mol K) in
first derivative. Thus the magnetic representation is C0/C1 continuous to
numerical precision.

At the 1811 K printed-polynomial boundary, upper-minus-lower residuals are:

| Phase | C0 residual (J/mol) | C1 residual (J/(mol K)) |
|---|---:|---:|
| BCC | -0.0063987872 | -0.00000356340 |
| FCC | -0.0033581004 | -0.00000194499 |
| HCP | +0.8981418996 | +0.00049805501 |
| liquid | +0.0138902395 | +0.00000274826 |

These source-rounding residuals are preserved and documented. No source
coefficient was adjusted to force exact continuity.

## Validity and extension semantics

Each phase's source model covers the complete `systemValidity` range. No
metastable tangent extension or other mathematical extension is used. The
presence of a phase function across the interval permits Gibbs-energy
comparison; it does not assert that the phase is stable or experimentally
realizable throughout that interval. The canonical object supplies no
extrapolation beyond 298.15–6000 K.

## Schema-development note

Fe demonstrates an additive physical contribution that the current generic
reader cannot yet represent as a named first-class object. For this test the
Hillert–Jarl/Inden magnetic contribution is expanded into ordinary OBGEL
basis terms for compatibility with the unchanged reader, while its physical
parameters, unexpanded relationship, and source provenance remain explicit.
A future first-class `contributions` mechanism could retain such additive
models directly and compose them at read time; that is deferred architecture,
not a requirement of the current Fe exemplar.
