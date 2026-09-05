# From authoritative water equations to a small unary model

## What this exercise is—and is not

This exercise shows how a detailed thermodynamic description can be reduced to
a much smaller model for a deliberately limited purpose. We use pure water at
one fixed pressure, 101325 Pa, over 250–500 K. The detailed source equations are
IAPWS-95 for fluid water and the IAPWS Ice Ih Gibbs formulation for ordinary
hexagonal ice.

The small equations produced here are **approximations made by model
reduction**. They are not replacements for IAPWS. The reviewed reduction has
been promoted to `data/unary/h2o-pure-substance-unary.json`; generated samples,
candidate fits, and diagnostics in the development workspace remain audit
artifacts rather than separate canonical thermodynamic data.

## Why this is a unary model

A unary model describes a system with one chemical component. Here that
component is H2O. Ice, liquid water, and water vapor have different structures
and properties, but each phase still has the same overall composition: H2O.

For a binary solution, a Redlich-Kister term can describe non-ideal mixing as
the composition changes between two components. Pure H2O has no composition
axis to vary. Its H2O mole fraction is always one, so there is no Redlich-Kister
mixing contribution. The interesting competition is among phase Gibbs
energies, not among mixture compositions.

## The fixed-pressure convention

Each phase function in this exercise means

\[
G_i(T;P=101325\ \mathrm{Pa}).
\]

Pressure is held fixed while temperature changes. For the pure vapor, this
pressure is both the total pressure and the H2O partial pressure. If air or an
inert gas were present, total pressure and the H2O partial pressure could
differ. That would be a mixture problem and is outside this unary model.

The pressure is a model condition, not a claim that every phase is stable at
every sampled temperature. At 1 atm, ice is stable below melting, liquid is
stable between melting and boiling, and vapor is stable above boiling. A source
equation can sometimes evaluate a metastable continuation of a phase outside
its stable interval, but that continuation must be labeled.

## Starting from authoritative equations

IAPWS-95 expresses the specific Helmholtz energy of fluid water as a function of
temperature and density. Thermodynamic derivatives give pressure, entropy,
enthalpy, and heat capacity. At each requested temperature, the development
tool solves for the liquid or vapor density whose pressure is 101325 Pa and
then converts the mass-specific results to molar units.

The Ice Ih release takes a more direct route for this task: it gives the
specific Gibbs energy as a function of temperature and pressure. Its
temperature derivatives also give the isobaric heat capacity. The ice release
was designed for solid-fluid equilibrium calculations together with IAPWS-95,
including a mutually compatible reference convention.

These detailed equations have far more structure than a small OBGEL unary
needs. We therefore try the compact form

\[
G_{\mathrm{fit}}(T)=a+bT+cT\ln T+dT^2+eT^3.
\]

The terms belong to the existing OBGEL unary basis. If this form is not good
enough, extra allowed terms can be added—but only after the residuals show why
they are needed. In the present development pass, the liquid fit needs `T^-1`
and `T^-2` terms; the ice and stable-vapor fits do not.

## Why fitting Gibbs energy alone can mislead

A graph of Gibbs energy may look excellent even when its curvature is wrong.
That matters because heat capacity is related to the second derivative:

\[
C_p=-T\left(\frac{\partial^2G}{\partial T^2}\right)_P.
\]

Small, slowly varying errors in (G) can hide a poor second derivative. The
development tool therefore fits the curvature-bearing coefficients against
IAPWS heat capacity first and then determines the constant and linear terms
against (G). It reports both

\[
\Delta G=G_{\mathrm{fit}}-G_{\mathrm{IAPWS}}
\]

and

\[
\Delta C_p=-T\frac{d^2G_{\mathrm{fit}}}{dT^2}-C_{p,\mathrm{IAPWS}}.
\]

Maximum residuals reveal the worst local error; root-mean-square residuals
describe typical error over the sampled interval. Both are useful.

## Stable, metastable, and unsupported are different

A stable phase has the lowest Gibbs energy among the available phases at the
specified temperature and pressure. A metastable phase is a local
thermodynamic state that can persist temporarily even though another phase has
lower Gibbs energy—for example, supercooled liquid water.

IAPWS-95 says its equation behaves reasonably when extrapolated into several
metastable regions, while also giving specific cautions. It reports no
experimental property data for subcooled vapor and says the main equation is
reasonable there only close to saturation. Farther away it points to a
separate gas equation in the underlying Wagner-Pruss reference.

At 1 atm, the distinction becomes numerical as well as verbal. The IAPWS-95
low-density vapor root ends at a spinodal near 326.41 K. Below that temperature
there is no mechanically stable IAPWS-95 vapor root at 1 atm. Calling those
points “metastable vapor” would overstate what the source equation supplies, so
the development table marks them unsupported.

The IAPWS low-temperature vapor guideline does not change this result. That
guideline extends the ideal-gas part below 130 K, down to 50 K. Our interval
starts at 250 K, and the difficulty here is the 1-atm density root, not the
low-temperature ideal-gas formula.

## Source validity versus OBGEL scope

The chosen 250–500 K window is an intentional OBGEL system scope. It is not the
validity range of the IAPWS equations. Conversely, being inside the OBGEL
window does not guarantee that every phase branch is supplied by the source at
every point.

This is why the development data separately record:

- the requested system interval;
- whether a phase is stable or metastable at 1 atm;
- whether the source formulation actually supplies a mechanically stable
  branch; and
- the smaller interval, if any, used for a candidate reduced fit.

Keeping these ideas separate prevents an intentional teaching or application
scope from being mistaken for a statement about nature or source validity.

## Recovering phase transitions with the lower envelope

At any fixed temperature and pressure, the stable phase is the one with the
lowest molar Gibbs energy. If we plot all available phase functions and trace
their lower envelope, the envelope follows Ice Ih at low temperature, liquid
water at intermediate temperature, and vapor at high temperature. Crossings of
the branches identify melting and boiling.

This is a strong final check on the reduction. Small residuals in each isolated
branch are not sufficient if they move a crossing unacceptably. The development
tool therefore compares the melting and boiling temperatures obtained directly
from the source equations with those obtained from the reduced functions. It
does not force the reduced curves to cross at preset
temperatures; any shift is reported as a diagnostic.

## Sources and further reading

- IAPWS R6-95(2018), *Revised Release on the IAPWS Formulation 1995 for the
  Thermodynamic Properties of Ordinary Water Substance for General and
  Scientific Use*: <https://iapws.org/technical-guidance/release/IAPWS-95>
- IAPWS R10-06(2009), *Revised Release on the Equation of State 2006 for H2O
  Ice Ih*: <https://iapws.org/technical-guidance/release/Ice-2009>
- IAPWS R14-08(2011), *Revised Release on the Pressure along the Melting and
  Sublimation Curves of Ordinary Water Substance*:
  <https://iapws.org/technical-guidance/release/MeltSub>
- IAPWS G9-12, *Guideline on a Low-Temperature Extension of the IAPWS-95
  Formulation for Water Vapor*:
  <https://iapws.org/technical-guidance/release/LowT>

The source and model record at
`sources/unary/H2O_Pure_Substance_Unary.md` gives the repository-specific
provenance and status. The executable development exercise is under
`working/h2o-reduced-model/`.
