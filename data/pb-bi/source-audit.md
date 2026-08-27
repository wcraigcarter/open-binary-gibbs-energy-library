# Pb–Bi Yoon–Lee Source Audit

This audit records the direct comparison of the current OBGEL Pb–Bi model with the supplied Yoon–Lee (1998) paper.

## Model definition

Yoon and Lee use an ordinary substitutional solution model for all phases and explicitly define x_i as mole fractions (p. 169). Their Pb–Bi phase parameters are listed in Table 1 (p. 170), and the elemental GHSER functions are given immediately afterward (p. 171).

## Phase-by-phase results

### Liquid

Yoon–Lee: Pb and Bi metastable liquid unary functions plus

    L0(T) = -4807.37 - 1.25 T

The current liquid JSON uses the corresponding metastable liquid unary functions and this interaction parameter. Small last-digit differences in earlier candidate elemental coefficients were identified and the source-printed values are used in the source-audited data where applicable.

### FCC A1

Yoon–Lee Table 1 gives

    G_Bi^FCC = GHSERBI + 9900 - 12.5 T
    G_Pb^FCC = GHSERPB
    L0(T) = -5208.18 + 0.575 T

The corrected OBGEL FCC JSON now contains the complete GHSERBI contribution for Bi.

### HCP A3 / epsilon

Yoon–Lee Table 1 gives

    G_Bi^HCP = GHSERBI + 9900 - 11.8 T
    G_Pb^HCP = GHSERPB + 300 + T
    L0(T) = -7388.9 - 0.68 T
    L1(T) = 2.86 T

The corrected OBGEL HCP JSON now contains the complete GHSERBI contribution for Bi.

### Rhombohedral A7

Yoon–Lee gives

    G_Bi^A7 = GHSERBI
    G_Pb^A7 = GHSERPB + 15000

with no Pb–Bi Redlich–Kister term listed. The OBGEL rhombohedral JSON contains the full Bi GHSER function.

## Critical transcription error identified

The initial FCC and HCP JSON files contained only the phase-specific Bi offsets (9900 - 12.5 T and 9900 - 11.8 T) and omitted GHSERBI(T). The resulting phase Gibbs-energy error was

    Delta G = x_Bi GHSERBI(T).

At T = 400 K and x_Bi = 0.4 this accounts for approximately 9.24 kJ/mol, matching the discrepancy observed during independent debugging. Restoring x_Bi GHSERBI(T) brought the independently reconstructed HCP expression to within a few J/mol of the OBGEL-derived function, with the remaining difference attributable to last-digit elemental-function coefficients.

## Invariant validation targets

Yoon and Lee Table 2 reports a peritectic L + FCC -> epsilon at 185.1 °C and a eutectic L -> Bi + epsilon at 125.6 °C. These values should be reproduced by an independent numerical implementation of the source-derived JSON.
