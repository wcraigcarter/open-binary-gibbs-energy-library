# H2O Pure-Substance Unary Source and Model Record

## Purpose and status

This record establishes the scope, terminology, pressure convention, primary
authorities, and reduction history for the fixed-compound unary model of pure
H2O. The executable canonical model is
`data/unary/h2o-standard-reference.json`. The companion
`h2o-pure-substance-unary-scaffold.json` remains the earlier, non-executable
source/model-planning record.

The selected reduced OBGEL Gibbs-energy fits and residual diagnostics were
generated under `working/h2o-reduced-model/` and reviewed before promotion.
The canonical JSON preserves the fit domains, source/model qualifications,
vapor spinodal, explicit comparison-only extensions, and derived verification
values. The generated samples and plots remain development/audit artifacts,
not independent canonical thermodynamic data.

## Unary identity

H2O is a pure substance of fixed composition. It is therefore represented by
the existing unary architecture and described as a **pure-substance unary** or
**fixed-compound unary**, rather than as a unary element. Identity metadata
distinguishes water from an element; a new incompatible object type is not
needed for the model.

The same terminology is intended to apply to a future fixed-composition NaCl
unary object.

## Fixed pressure and model boundary

The canonical functions are

\[
G_i(T;P=101325\ \mathrm{Pa})
\]

for pure H2O. `systemConditions.pressure` is the thermodynamic pressure of the
pure substance. For a pure H2O vapor this pressure is also the total pressure
and \(p_{\mathrm{H_2O}}\).

An external atmosphere containing inert or other gas species is not part of
this unary model. In such an atmosphere, total mechanical pressure and
\(p_{\mathrm{H_2O}}\) can differ and a mixture model is required. Chemical
reactions, dissociation, and externally imposed chemical environments are
also outside scope.

## Deliberately reduced OBGEL scope

The OBGEL object has

\[
250\ \mathrm{K}\leq T\leq500\ \mathrm{K}
\]

with `systemValidity.basis` equal to `intentionalDatasetScope`. This interval
is chosen to provide a compact 1-atm representation containing the familiar
Ice Ih, liquid-water, and water-vapor regimes. The two bounds are not claimed
limits of the IAPWS formulations, which cover broader domains.

Phase-level model validity and the evaluation intervals of
`temperatureSegments` remain distinct. Source-formulation-derived metastable
states are distinguished from OBGEL mathematical extensions. Nothing in the
canonical object authorizes implicit extrapolation beyond 250–500 K.

## Source hierarchy

### Fluid phases: primary authority

IAPWS R6-95(2018), *Revised Release on the IAPWS Formulation 1995 for the
Thermodynamic Properties of Ordinary Water Substance for General and
Scientific Use*, is the primary authority for liquid water and water vapor.
IAPWS-95 is a Helmholtz-energy formulation in temperature and density and is
recommended for fluid phases, including vapor-liquid equilibrium. IAPWS
states that it is valid throughout the stable fluid region from the melting
curve to 1273 K at pressures up to 1000 MPa.

IAPWS also states that the formulation behaves reasonably when extrapolated
into several metastable regions, with important qualifications. Available
subcooled-liquid data are only in fair agreement and a separate IAPWS guideline
better represents that region. For subcooled vapor there are no experimental
property data; IAPWS recommends the main equation only close to saturation and
points to the auxiliary gas equation in the underlying Wagner-Pruss paper for
states farther away.

- Release page: https://www.iapws.org/relguide/IAPWS-95.html
- Release PDF: https://iapws.org/relguide/IAPWS95-2018.pdf

### Low-temperature vapor clarification

IAPWS G9-12 extends the ideal-gas part used by IAPWS-95 from its original 130 K
lower limit down to 50 K. It is relevant to sufficiently low-density vapor
calculations below 130 K, but it is not activated anywhere in the adopted
250–500 K scope and does not guarantee that a fixed-pressure vapor-density root
exists.

- Guideline page: https://iapws.org/technical-guidance/release/LowT

### Ice Ih: primary authority

IAPWS R10-06(2009), *Revised Release on the Equation of State 2006 for H2O Ice
Ih*, is the primary authority for Ice Ih. It supplies Gibbs energy as a
function of temperature and pressure and is intended for solid-vapor and
solid-liquid equilibrium calculations in conjunction with IAPWS-95. IAPWS
states that it is valid throughout the stable region of Ice Ih.

- Release page: https://www.iapws.org/relguide/Ice-2009.html

### Phase-boundary check

IAPWS R14-08(2011), *Revised Release on the Pressure along the Melting and
Sublimation Curves of Ordinary Water Substance*, is an appropriate
reference-quality corroboration for Ice Ih melting and sublimation behavior.

- Release page: https://www.iapws.org/relguide/MeltSub.html

### Secondary corroboration

The NIST Chemistry WebBook may be used for convenient thermochemical values
and independent checks where its stated conditions and ranges match the task.
It is not a substitute for IAPWS-95 or the IAPWS Ice Ih formulation in the
model construction.

- Water entry: https://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Mask=1

## Development method and current findings

`working/h2o-reduced-model/develop_h2o_reduced_model.py` evaluates the two
source formulations at 101325 Pa, converts mass-specific values to the molar
J/mol basis, verifies its implementation adapter against published IAPWS test
values, and writes source samples and fit diagnostics. It first fits the
curvature-bearing coefficients against \(C_p=-T d^2G/dT^2\), then fits the
constant and linear integration terms against \(G\). Both maximum and RMS
residuals are reported.

The initial basis was

\[
G=a+bT+cT\ln T+dT^2+eT^3.
\]

Development-only residual targets were used to decide whether additional basis
terms were worth testing. The selected Ice Ih and stable-vapor fits retain the
five-term basis. The selected liquid fit adds `T^-1` and `T^-2`, the smallest
tested basis meeting both development targets. These targets are recorded in
the canonical model as construction metadata, not as repository-wide
acceptance criteria.

The fixed-pressure root analysis found a scientifically important limitation:
at 101325 Pa, the mechanically stable low-density IAPWS-95 vapor root ends at a
spinodal near 326.41 K. The requested 250 K-to-spinodal vapor interval is
therefore recorded as unsupported by the source formulation; canonical values
there are explicitly identified as a mathematical tangent extension. The
metastable-root interval above the spinodal is sampled with an explicit source
caution, but its divergent near-spinodal heat capacity prevents a useful
single compact fit. The selected vapor fit is consequently limited
to the stable branch from the source-derived 1-atm boiling point to 500 K.

No source transition to the auxiliary Wagner-Pruss gas equation and no forced
melting or boiling constraint was introduced. For complete three-phase reader
comparison over `systemValidity`, the canonical model uses explicit
first-order endpoint-tangent extensions for Ice Ih above its adopted validity
endpoint and vapor below its adopted stable-branch validity endpoint. These are
OBGEL mathematical constructions, not IAPWS states. In particular, the vapor
extension neither hides nor passes through the spinodal as a physically valid
metastable vapor branch.

## Canonical promotion decision

The fits were promoted because all three selected source-domain reductions meet
the stated development targets for both Gibbs energy and heat capacity. The
canonical JSON records the complete residual summaries. It also records the
source-formulation melting and boiling boundaries separately from the encoded
crossings, which were not imposed during fitting.

The adopted function-level validity intervals are 250 K through the
source-derived 1-atm melting boundary for Ice Ih, 250–500 K for the IAPWS-95
liquid-root reduction (with its subcooled and superheated source cautions), and
the source-derived 1-atm boiling boundary through 500 K for the stable-vapor
reduction. The temperature segments cover 250–500 K through the explicit
extensions described above.

The resulting Ice-Ih/liquid and liquid/vapor envelope crossings differ from
the source-formulation boundaries by only millikelvin, but both lie just inside
an extension segment and are therefore correctly labeled `extension-derived`.
The Ice-Ih/vapor tangent-extension crossing is also labeled
`extension-derived` and is not presented as a physical metastable equilibrium.

## Completed generic-reader validation

The unchanged generic Mathematica unary reader successfully evaluated the
fixed-compound H2O model at 101325 Pa over its intentional 250–500 K system
scope. It consumed the phase-identity function keys `iceIh`, `liquid`, and
`vapor` without any reader modification and recovered, to the reader's
reported precision:

- Ice Ih–liquid at 273.156 K;
- liquid–vapor at 373.122 K; and
- the pairwise Ice Ih–vapor crossing at 350.882 K.

The first two crossings change the minimum-Gibbs-energy phase and are therefore
stable-envelope equilibrium transitions. They closely reproduce the IAPWS
melting and boiling reference boundaries used to assess the reduction, so they
are implementation/reduction checks rather than independent predictions of
those physical reference transitions. Their encoded roots fall just inside the
comparison-only tangent segments and retain the canonical
`extension-derived` classification.

The 350.882 K result is different. It is a pairwise equality,

\[
G_{\mathrm{iceIh}}=G_{\mathrm{vapor}},
\]

but the liquid Gibbs energy is lower at the same temperature. It is therefore
not an equilibrium transition. Because both equal branches are the explicit
tangent extensions there, the crossing is an `extension-derived` property of
the reduced model, not an IAPWS metastable Ice Ih–vapor equilibrium or an
experimentally validated phase boundary.

This no-change reader result validates two intended conventions at once:
function keys identify phases rather than pre-declaring stability, and phase
stability is determined by the lower envelope of all candidate Gibbs-energy
branches.
