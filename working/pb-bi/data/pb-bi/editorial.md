# Pb–Bi

## Why this system?

Pb–Bi is the second OBGEL exemplar because it extends the Cu–Ag example from a simple binary eutectic construction to a system containing four available phase models and both a peritectic and a eutectic invariant.

## Assessment and primary source

The present OBGEL Pb–Bi model is based on S. W. Yoon and H. M. Lee (1998), “A Thermodynamic Study of Phase Equilibria in the Sn-Bi-Pb Solder System,” *Calphad* 22(2), 167–178, DOI 10.1016/S0364-5916(98)00022-4.

Yoon and Lee state that an ordinary substitutional solution model was applied to all phases and that the composition variables are mole fractions. Their Table 1 directly specifies the Pb–Bi unary/reference terms and Redlich–Kister parameters used for liquid, FCC A1, HCP A3 (epsilon), and rhombohedral Bi.

The open NIST solder database was used during the initial transcription/development process. The original Yoon–Lee paper has now been obtained and serves as the primary source for the present source audit.

## Phase inventory

- Liquid
- FCC A1 (Pb-rich solid solution)
- HCP A3 (epsilon Pb)
- Rhombohedral A7 (Bi-rich solid solution)

## Source-audit corrections

The initial candidate omitted the GHSERBI(T) part of the Bi unary reference contribution in the FCC A1 and HCP A3 phase JSON files. Yoon–Lee Table 1 explicitly gives:

    G_Bi^FCC = GHSERBI + 9900 - 12.5 T
    G_Bi^HCP = GHSERBI + 9900 - 11.8 T

The corrected JSON files now contain the complete Bi unary Gibbs-energy functions. This is a composition-dependent correction, not a constant vertical shift of an entire phase. The liquid reference functions are likewise phase-specific metastable pure-liquid functions (GLIQBI and GLIQPB), rather than the stable A7 Bi and FCC Pb functions.

## Validation targets

Yoon and Lee report the calculated Bi–Pb peritectic at 185.1 °C and the eutectic at 125.6 °C, with compositions tabulated in at% Pb. These are the primary phase-equilibrium targets for numerical validation of the OBGEL implementation.

## Candidate status

The Pb–Bi thermodynamic expressions are now source-audited against the supplied 1998 Yoon–Lee paper. Numerical validation should be performed using an independent implementation/CTT workflow. Any future discrepancy should be documented rather than silently altering the source-derived data.
