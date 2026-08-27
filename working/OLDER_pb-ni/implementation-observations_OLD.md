* # Working notes for Development of Pb-Bi Data and Reader

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

  **Observation 6** Downstream numerical tools may evaluate phase Gibbs-energy functions at the composition endpoints x=0 and x=1. The OBGEL ideal-mixing contribution must therefore have explicit endpoint behavior rather than relying on numerical algorithms to avoid evaluating x\ln x at zero.

-Implication: The OBGEL reader should produce numerically well-defined Gibbs-energy functions at both pure-component endpoints.

  **Observation 7**
  The Common Tangents Tool expects functions of the form f[T][X], which is compatible with the OBGEL function structure. No OBGEL API change appears necessary; a thin CTT-specific wrapper is sufficient.

**Observation 8** 

  The candidate liquid model currently references the stable elemental phases (Bi A7 and Pb FCC), causing the liquid Gibbs-energy curve to coincide with the stable phase at the pure-component endpoints and to become spuriously low over the binary composition range. The assessment distinguishes metastable pure-liquid unary Gibbs energies (GLIQBi, GLIQPb) from the stable SER functions (GHSERBi, GHSERPb). The OBGEL reference-state representation must preserve this distinction.

   **Observation 9**

  It would be convenient if the CTT had easy access to the entire temperature range available for a given system.


 **Observation 10**

Liquid unary reference states: The Pb–Bi liquid candidate currently uses the stable Pb FCC and Bi A7 Gibbs-energy functions as its unary reference contributions. This causes the liquid Gibbs energy to equal the stable solid Gibbs energy at each pure-component endpoint. The CALPHAD assessment instead uses metastable pure-liquid unary Gibbs-energy functions (GLIQPB, GLIQBI). The schema therefore needs to distinguish a phase’s modeled identity from the unary reference function used in its Gibbs-energy construction.

**Observation 11**

The liquid phase requires phase-specific unary Gibbs-energy functions for Pb and Bi. Using the stable Pb FCC and Bi A7 functions as the liquid unary contributions causes the liquid Gibbs energy to coincide with the stable pure-component phases at the composition endpoints. The candidate liquid model is therefore being revised to use the metastable pure-liquid unary functions specified by the thermodynamic source.