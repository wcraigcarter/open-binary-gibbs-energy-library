# Pb-Bi Model Provenance

## Primary source

S. W. Yoon and H. M. Lee, “A Thermodynamic Study of Phase Equilibria in the Sn-Bi-Pb Solder System,” *Calphad* 22 (1998), 167–178. DOI: 10.1016/S0364-5916(98)00022-4.

Yoon and Lee state that an ordinary substitutional solution model is applied to all phases and that the composition variables are mole fractions. Their Table 1 gives the Bi–Pb phase parameters; their Table 2 reports the calculated Bi–Pb peritectic and eutectic.

## Pb-Bi phase models

| Phase | Yoon–Lee unary/reference terms | Yoon–Lee Pb–Bi interaction | OBGEL status |
|---|---|---|---|
| Liquid | metastable GLIQBi and GLIQPb functions | L0 = -4807.37 - 1.25 T | Source-audited; liquid reference functions corrected during development |
| FCC A1 | Bi: GHSERBI + 9900 - 12.5 T; Pb: GHSERPB | L0 = -5208.18 + 0.575 T | Source-audited; Bi GHSER term restored explicitly |
| HCP A3 / epsilon | Bi: GHSERBI + 9900 - 11.8 T; Pb: GHSERPB + 300 + T | L0 = -7388.9 - 0.68 T; L1 = 2.86 T | Source-audited; Bi GHSER term restored explicitly |
| Rhombohedral A7 | Bi: GHSERBI; Pb: GHSERPB + 15000 | no Bi–Pb excess term listed | Source-audited |

## Critical data correction

The first Pb–Bi candidate omitted GHSERBI(T) from the Bi unary reference contributions for FCC A1 and HCP A3. Yoon and Lee Table 1 explicitly includes these terms. Their omission produces a composition-dependent Gibbs-energy error xBi GHSERBI(T), not a constant phase offset. The corrected JSON phase models now include the full GHSERBI piecewise function plus the appropriate phase-specific lattice-stability contribution.

## Elemental functions

The GHSERBI and GHSERPB functions in the paper are reproduced as piecewise temperature functions. The OBGEL implementation preserves the complete functions required over the common Pb–Bi phase-model range. Small last-digit differences in earlier candidate files were identified during the audit; the source-printed coefficients are now used where the source audit requires them.

## Composition metadata

The independent composition variable is xBi, the mole fraction of Bi. The current reference reader expects `compositionVariables` in each phase JSON, so the distribution retains that metadata there for compatibility. This is a current implementation decision; Observation 2 records the earlier schema-design proposal to place composition variables in `system.json` and should be revisited before a future schema revision.

## Validation targets

Yoon and Lee report for the Bi–Pb binary system: peritectic L + FCC -> epsilon at 185.1 °C and eutectic L -> Bi + epsilon at 125.6 °C, with compositions reported in at% Pb. These correspond to approximately 458.25 K and 398.75 K.

Independent reconstruction directly from the published Table 1 equations reproduces the two invariants to numerical precision.

## Implementation lessons

The accompanying `implementation-observations.md` records the implementation observations accumulated during development, including piecewise-domain boundary behavior, composition endpoints, metastable liquid reference states, explicit composition metadata, and preservation of complete unary reference contributions.
