# NaCl Pure-Substance Unary Source and Model Record

## Purpose and status

This record documents the scientific source, analytic conversion, scope, and
verification of the fixed-compound unary model for pure NaCl. The executable
canonical object is `data/unary/nacl-standard-reference.json`.

The model contains two phase-identity keys, `rockSalt` and `liquid`. The first
name records the known crystal structure rather than using the less informative
generic key `solid`. No vapor function is present.

## Unary identity and boundary

NaCl is represented as a pure substance of fixed 1:1 composition: a
**pure-substance unary** and, more specifically, a **fixed-compound unary**.
The object does not model Na-Cl reaction thermodynamics, decomposition,
association, dissociation, or gas-phase speciation.

The canonical system pressure is

\[
P=101325\ \mathrm{Pa}.
\]

This is the thermodynamic pressure of pure NaCl. It is not the total pressure
of an external gas mixture and must not be reinterpreted as an independently
specified NaCl partial pressure in such a mixture. External atmospheres and
chemical-reaction/speciation models require a different object.

NIST-JANAF states its tabulated standard-state pressure as 0.1 MPa, not 1 atm.
The canonical object therefore preserves 100000 Pa as the source reference
condition while adopting the condensed-phase functions at the requested
101325 Pa system pressure without a pressure correction. This is an explicit
model approximation. No molar-volume data or \(P\Delta V\) correction was
introduced silently.

## System scope and validity semantics

The OBGEL object is defined on

\[
298.15\ \mathrm{K}\leq T\leq1700\ \mathrm{K}.
\]

The two bounds have different rationales. The lower bound is source/model
motivated: it is the enthalpy reference temperature and lies at the beginning
of the published solid Shomate range. The upper bound is an intentional
dataset-scope choice inside the published liquid range. It stops before the
normal boiling region so that vapor-phase NaCl chemistry and speciation remain
outside this fixed-compound unary object.

The current schema provides one scalar `systemValidity.basis`, so the object
uses `intentionalDatasetScope` and records the mixed rationale explicitly.
A future per-bound basis such as separate minimum- and maximum-bound provenance
would be cleaner if this pattern recurs, but this dataset does not redesign the
schema or introduce an ad hoc basis value.

Source validity, function-level validity, and encoded evaluation segments are
distinct:

- NIST solid Shomate source validity is 298–1073 K.
- NIST liquid Shomate source validity is 1074–2500 K.
- Source-converted segments are clipped to the 298.15–1700 K system domain.
- Explicit endpoint-tangent segments make both candidate functions evaluable
  throughout the common system domain.

Nothing in the object authorizes extrapolation beyond `systemValidity`.

## Primary thermochemical source

The primary electronic source is the NIST Chemistry WebBook, SRD 69,
*sodium chloride, condensed phase thermochemistry data*:

https://webbook.nist.gov/cgi/cbook.cgi?ID=C7647145&Mask=E

The WebBook identifies the underlying compilation as M. W. Chase, Jr.,
*NIST-JANAF Thermochemical Tables, Fourth Edition*, Journal of Physical and
Chemical Reference Data, Monograph 9 (1998), with the NaCl data last reviewed
in September 1964.

The authoritative NIST-JANAF crystal-liquid table is:

https://janaf.nist.gov/tables/Cl-054.html

It marks the crystal-liquid transition at 1073.800 K and the standard-state
pressure as 0.1 MPa.

### Shomate equations and units

NIST gives, with \(t=T/1000\),

\[
C_p^\circ=A+Bt+Ct^2+Dt^3+E/t^2,
\]

\[
H^\circ-H^\circ_{298.15}
=At+\frac{B}{2}t^2+\frac{C}{3}t^3+\frac{D}{4}t^4-\frac{E}{t}+F-H,
\]

and

\[
S^\circ=A\ln t+Bt+\frac{C}{2}t^2+\frac{D}{3}t^3-\frac{E}{2t^2}+G.
\]

Here \(C_p\) and \(S\) are in J mol\(^{-1}\) K\(^{-1}\), while the enthalpy
expression is in kJ mol\(^{-1}\).

The coefficients independently transcribed from NIST are:

| coefficient | rock salt, 298–1073 K | liquid, 1074–2500 K |
|---|---:|---:|
| A | 50.72389 | -42.44780 |
| B | 6.672267 | 113.5260 |
| C | -2.517167 | -43.64660 |
| D | 10.15934 | 5.896630 |
| E | -0.200675 | 39.13860 |
| F | -427.2115 | -305.5610 |
| G | 130.3973 | 91.06390 |
| H | -411.1203 | -385.9230 |

NIST also reports at 298.15 K
\(\Delta_f H^\circ_{\mathrm{solid}}=-411.12\) kJ/mol and
\(S^\circ_{\mathrm{solid}}=72.11\) J/(mol K). Direct Shomate evaluation gives
-411.120713 kJ/mol and 72.109299 J/(mol K), consistent with the displayed
rounding.

## Analytic conversion to the OBGEL basis

The encoded quantity is

\[
G(T)=H(T)-T S(T)
\]

in J/mol. Adding the NIST formation-enthalpy anchor to its reported
\(H-H_{298.15}\) expression cancels the Shomate parameter \(H\), leaving the
absolute enthalpy-form expression through \(F\). Algebraic collection gives

\[
\begin{aligned}
G(T)={}&1000F
+\left[A(1+\ln1000)-G\right]T
-A\,T\ln T\\
&-\frac{B}{2000}T^2
-\frac{C}{6000000}T^3
-\frac{D}{12000000000}T^4
-500000E\,T^{-1}.
\end{aligned}
\]

This maps exactly to `constant`, `temperature`,
`temperatureLogTemperature`, and `temperaturePower` with exponents 2, 3, 4,
and -1. It is an analytic conversion, not a numerical fit.

The resulting source-segment coefficients, in the canonical JSON order, are:

| basis | rock salt | liquid |
|---|---:|---:|
| constant | -427211.5 | -305561.0 |
| temperature | 270.7148089180092 | -426.73071453117797 |
| temperatureLogTemperature | -50.72389 | 42.4478 |
| temperaturePower, 2 | -0.0033361335 | -0.056763 |
| temperaturePower, 3 | 4.195278333333334e-7 | 7.274433333333334e-6 |
| temperaturePower, 4 | -8.466116666666667e-10 | -4.913858333333334e-10 |
| temperaturePower, -1 | 100337.5 | -19569300.0 |

## Common-domain endpoint-tangent extensions

The source intervals leave a 1 K gap around fusion. They also do not make both
candidate phases evaluable across the full system domain. The canonical model
therefore uses the established first-order tangent convention

\[
G_{\mathrm{ext}}(T)=G(T_b)+G'(T_b)(T-T_b).
\]

This preserves \(G\) and \(dG/dT\) at the attachment and gives C1 continuity.
The linear extension has zero mathematical heat capacity; that is a consequence
of the extension, not a physical thermodynamic claim.

The explicit extensions are:

| function | attachment | extension interval within systemValidity | constant (J/mol) | temperature coefficient (J/(mol K)) |
|---|---:|---:|---:|---:|
| `rockSalt` | 1073 K | (1073, 1700] K | -366426.6058768064 | -143.9522104487952 |
| `liquid` | 1074 K | [298.15, 1074) K | -338179.32115180255 | -170.25730078464454 |

At 1073 K the rock-salt source function gives
\(G=-520887.327688364\) J/mol and
\(dG/dT=-143.952210448795\) J/(mol K). At 1074 K the liquid source
function gives \(G=-521035.662194511\) J/mol and
\(dG/dT=-170.257300784645\) J/(mol K). These values determine the tangent
coefficients; no transition temperature is used in their construction.

Both branches are consequently defined in the 1073–1074 K source gap. The
crossing can emerge from the functions rather than being hard-coded.

## Verification

Direct evaluation of the original Shomate \(H(T)-TS(T)\) expressions was
compared with the encoded basis sums at three temperatures per source segment.
The largest absolute differences were
\(5.82\times10^{-11}\) J/mol for rock salt and
\(1.16\times10^{-10}\) J/mol for liquid, at ordinary floating-point precision.

At the two tangent attachments, Mathematica-evaluated floating-point
discontinuities are at most \(1.75\times10^{-10}\) J/mol in \(G\) and
\(5.68\times10^{-14}\) J/(mol K) in \(dG/dT\). The tangent construction is
analytically C1; these residuals are roundoff.

The unchanged generic Mathematica unary reader identifies the stable-envelope
crossing as

\[
T_{\mathrm{melting}}=1073.83\ \mathrm{K}.
\]

At higher numerical precision, solving the encoded equality gives

\[
G_{\mathtt{rockSalt}}(T)=G_{\mathtt{liquid}}(T)
\quad\Longrightarrow\quad
T=1073.8334050314\ \mathrm{K}.
\]

The common value is -521007.298184834 J/mol. The reader result is a derived,
non-model-defining verification result. The crossing is in the 1 K source gap,
where both branches use endpoint tangents, so it is correctly classified as
`extension-derived` rather than as a source observation. At the reader's
reported precision it differs by +0.03 K from the authoritative NIST-JANAF
1073.800 K crystal-liquid transition; using the underlying analytical root,
the difference is +0.033405 K.

The transition temperature was not inserted as a coefficient, energy shift,
or explicit stitching constraint. Even so, this result is not described as an
independent prediction: it depends on the adopted source functions, their
published intervals bracketing fusion, and the deliberate endpoint-tangent
extension construction. The source value is at 0.1 MPa; the canonical system
pressure is 101325 Pa, as qualified above.

JSON syntax, common-domain segment coverage, endpoint inclusion, allowed basis
vocabulary, analytic equivalence, C1 continuity, and the crossing were all
checked, including successful evaluation with the unchanged generic reader.
The repository currently has no formal JSON Schema for
the developmental unary object shape, so schema validation means conformance
to the documented unary conventions and comparison with existing canonical
unary objects rather than validation against a dedicated unary schema file.

## Deliberate exclusions

The liquid NIST Shomate expression remains source-valid to 2500 K, but the
canonical OBGEL object stops at 1700 K by design. It contains no vapor function
and makes no statement about molecular NaCl vapor, associated gas species,
dissociation products, decomposition, or equilibrium vapor composition. This
is the same library boundary that keeps reaction and speciation thermodynamics
outside a fixed-compound unary representation.
