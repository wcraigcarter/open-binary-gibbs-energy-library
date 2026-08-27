# Working notes for Development of Pb-Bi Data and Reader

**Observation 1**

Candidate packages should contain the complete directory structure expected of accepted systems, even if some generated artifacts are placeholders awaiting verification.

**Observation 2**

`compositionVariables` should be defined at the system level in `system.json`, rather than independently in each phase.

This allows the system composition convention to be defined once and shared consistently by all phase models.

**Observation 3**

Applications frequently need the common temperature interval over which all phase models are simultaneously valid. The system should therefore make the thermodynamic validity interval available explicitly at the system level. The interval may initially be derived from the phase-model validity intervals, but exposing it at the system level avoids repeated inference and gives applications such as CTT convenient access to the system's intended range.

**Observation 4**

The Pb-Bi reference functions begin at 298.15 K. Because the current `Piecewise` implementation returns zero outside its defined intervals, evaluating the model below 298.15 K creates an artificial discontinuity. The reader should eventually distinguish “outside model validity” from “zero-valued contribution.”

**Observation 5**

Visual debugging is a useful validation technique for thermodynamic models. Unexpected qualitative features in plotted G(T,x) curves can reveal implementation or validity-range problems that may not be apparent from symbolic inspection alone.

**Observation 6**

Downstream numerical tools may evaluate phase Gibbs-energy functions at the composition endpoints x=0 and x=1. The OBGEL ideal-mixing contribution must therefore have explicit endpoint behavior rather than relying on numerical algorithms to avoid evaluating x log x at zero.

**Implication:** The OBGEL reader should produce numerically well-defined Gibbs-energy functions at both pure-component endpoints.

**Observation 7**

The Common Tangents Tool expects functions of the form `f[T][X]`, which is compatible with the OBGEL function structure. No OBGEL API change appears necessary; a thin CTT-specific wrapper is sufficient.

**Observation 8**

Unary Gibbs-energy contributions are phase-specific. In a substitutional phase model, the unary Gibbs-energy contributions must correspond to the phase being modeled; they cannot be assumed to be the stable elemental Gibbs-energy functions. Metastable unary functions may be required, for example for liquid Pb and Bi or for Pb represented on the rhombohedral lattice.

**Observation 9**

The initial Pb-Bi liquid candidate incorrectly used the stable Pb FCC and Bi A7 unary Gibbs-energy functions. This caused the liquid Gibbs energy to coincide with the stable elemental phases at the pure-component endpoints. The thermodynamic assessment uses metastable pure-liquid unary Gibbs-energy functions for Pb and Bi. The candidate liquid data are therefore being revised to represent those phase-specific unary functions.

**Observation 10**
Be sure that piecewise functions for the free-energy curves return real, well-defined values for all allowable temperatures and compositions 0\leq X\leq1. In particular, each piecewise branch must have a valid value at the edges of its declared temperature domain.