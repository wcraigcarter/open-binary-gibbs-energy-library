# Working notes for Development of Pb-Bi Data and Reader

**Observation 1**
Candidate packages should contain the complete directory structure expected of accepted systems, even if some generated artifacts are placeholders awaiting verification.

**Observation 2**
compositionVariables should be in system.json and not the individual phases

**Observation 3**
Applications frequently need the common temperature interval over which all phase models are simultaneously valid. Determine whether this should be derived automatically from the phase models or stored explicitly for convenience.

**Observation 4**
The Pb–Bi reference functions begin at 298.15 K. Because the current Piecewise implementation returns zero outside its defined intervals, evaluating the model below 298.15 K creates an artificial discontinuity. The reader should eventually distinguish “outside model validity” from “zero-valued contribution.”

**Observation 5**
Visual debugging is a useful validation technique for thermodynamic models. Unexpected qualitative features in plotted G(T,x) curves can reveal implementation or validity-range problems that may not be apparent from symbolic inspection alone.

**Observation 6**
Downstream numerical tools may evaluate phase Gibbs-energy functions at the composition endpoints x=0 and x=1. The OBGEL ideal-mixing contribution must therefore have explicit endpoint behavior rather than relying on numerical algorithms to avoid evaluating x ln x at zero.

**Observation 7**
The Common Tangents Tool expects functions of the form f[T][X], which is compatible with the OBGEL function structure. No OBGEL API change appears necessary; a thin CTT-specific wrapper is sufficient.

**Observation 8**
The candidate liquid model initially referenced the stable elemental phases (Bi A7 and Pb FCC), causing the liquid Gibbs-energy curve to become spuriously low over the binary composition range. The assessment distinguishes metastable pure-liquid unary Gibbs energies from stable SER functions.

**Observation 9**
It would be convenient if the CTT had easy access to the entire temperature range available for a given system.

**Observation 10**
Liquid unary reference states: the Pb–Bi liquid candidate initially used stable Pb FCC and Bi A7 Gibbs-energy functions as its unary reference contributions. The CALPHAD assessment instead uses metastable pure-liquid unary Gibbs-energy functions (GLIQPB, GLIQBI).

**Observation 11**
The liquid phase requires phase-specific unary Gibbs-energy functions for Pb and Bi. Using the stable Pb FCC and Bi A7 functions as the liquid unary contributions causes the liquid Gibbs energy to coincide with the stable pure-component phases at the composition endpoints.

**Observation 12**
Piecewise functions for the free-energy curves must return real, well-defined values for all allowable temperatures and compositions 0 <= X <= 1. In particular, each branch must have a valid value at the edges of its declared temperature domain.

**Observation 13**
When a phase reference contribution is assembled from an elemental SER function plus a phase-specific lattice-stability term, the canonical JSON representation must preserve the complete unary Gibbs-energy contribution; omitting the elemental SER term changes the phase Gibbs-energy surface by a composition-dependent amount and can alter phase equilibria.

**Observation 14**
OBGEL phases must identify whether their composition is continuous or constrained. In particular, a stoichiometric line compound must be identified explicitly and must provide its fixed composition. CTT must treat a line compound as a fixed-composition Gibbs-energy point rather than as a continuous G(T,x) curve.



**Observation 15**
It will be useful to constuct a list of Unary phase reference free energies and then use those to enforce consistency between binary systems.

