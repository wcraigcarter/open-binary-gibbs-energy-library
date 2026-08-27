# Pb-Bi Model Provenance — Working Record

## Purpose

This document records the current provenance of the Pb-Bi thermodynamic models in the
Open Binary Gibbs Energy Library (OBGEL).

This is a **provisional provenance record**. It is intentionally written so that it can
be updated after the original Yoon–Lee paper is inspected. Values or source assignments
marked **Pending** should not be treated as verified against the 1998 paper.

The primary object being documented is the thermodynamic Gibbs-energy model represented
by the OBGEL JSON files. Derived Mathematica expressions, CTT functions, plots, and
other representations are not independent thermodynamic sources.

## Composition convention

The Pb-Bi OBGEL models use mole fraction:

    x = x_Bi
    x_Pb = 1 - x_Bi

The binary Gibbs-energy models use the conventional substitutional/Redlich–Kister
mole-fraction form. The Taskinen Pb-Bi report likewise formulates its excess Gibbs
energies using x_Bi x_Pb and (x_Pb - x_Bi), supporting the mole-fraction convention.

## Phase inventory

| OBGEL phase | Physical phase | Current model form | Current provenance status |
|---|---|---|---|
| `liquid` | Liquid | Binary substitutional solution; ideal mixing + Redlich–Kister excess + phase-specific unary liquid functions | **Pending direct audit against Yoon–Lee 1998** |
| `fcc-a1` | Pb-rich FCC/A1 solid solution | Binary substitutional solution; ideal mixing + Redlich–Kister excess + unary functions | **Pending direct audit against Yoon–Lee 1998** |
| `hcp-a3` | ε-Pb / HCP-A3 solid solution | Binary substitutional solution; ideal mixing + Redlich–Kister excess + phase-specific unary functions | **Pending direct audit against Yoon–Lee 1998** |
| `rhombo-a7` | Bi-rich rhombohedral/A7 solid solution | Binary substitutional solution; ideal mixing; no current Redlich–Kister excess term | **Pending direct audit against Yoon–Lee 1998** |

## Current OBGEL numerical model

The following values are taken from the current OBGEL JSON-derived Mathematica
expressions used during the Pb-Bi/CTT investigation.

### Liquid

Current binary excess term:

    L0(T) = -4807.37 - 1.25 T

No higher Redlich–Kister term is currently present.

The unary liquid Gibbs-energy functions have been revised during the present
investigation to use phase-specific metastable liquid functions for Pb and Bi.

The initial candidate incorrectly used stable Pb-FCC and Bi-rhombohedral unary
functions. That error produced an artificially low liquid Gibbs-energy curve.

**Status:** The corrected liquid functions have been validated internally by agreement
between the canonical OBGEL viewer and CTT, but their direct correspondence to the
original Yoon–Lee 1998 source remains **Pending**.

### FCC-A1

Current model includes the Pb/Bi unary functions plus a Redlich–Kister description.
The exact coefficient provenance requires direct comparison with the original
assessment.

**Status:** Pending direct audit against Yoon–Lee 1998.

### HCP-A3 / ε-Pb

Current excess parameters:

    L0(T) = -7388.9 - 0.68 T
    L1(T) = 2.86 T

The current unary construction is equivalent to:

    G_HCP,Pb = G_SER,Pb + 300 + T

and

    G_HCP,Bi = G_SER,Bi + 9900 - 11.8 T

within the current OBGEL representation.

The present HCP expression is mathematically compatible with reducing the fixed-vacancy
sublattice description (Pb,Bi)1(Va)0.5 to an ordinary binary molar Gibbs-energy
function: the vacancy sublattice has fixed occupancy and contributes no composition
variable or configurational entropy term.

**Status:** The functional form and coefficients agree with later database/compilation
representations examined during development. Direct correspondence to the original
Yoon–Lee 1998 unary/reference construction remains **Pending**.

### Rhombohedral-A7

Current model:

    G_A7(T,x) =
        (1-x) G_Pb,A7(T)
        + x G_Bi,A7(T)
        + R T [x ln x + (1-x) ln(1-x)]

with no current Redlich–Kister excess term.

The current Pb-in-A7 function differs from the current Pb FCC/SER function by
approximately 15000 J/mol in the constant term.

**Status:** Appears internally consistent with the phase/reference-state construction
used in the current candidate, but direct correspondence to Yoon–Lee 1998 remains
**Pending**.

## Independent comparison source: Taskinen (1989)

An independently authored Pb-Bi assessment is available as:

P. Taskinen, *The Phase Equilibria and Solution Thermodynamics of Bismuth-Lead Alloys*,
Report TKK-V-B46, Helsinki University of Technology, 1989.

Taskinen's report is an **independent comparison assessment**, not the presumed
provenance source of the current OBGEL Pb-Bi model.

The report describes the use of lattice-stability functions for Bi and Pb and gives an
optimized set of phase excess-Gibbs parameters. Its optimized binary excess terms are
different from the current OBGEL terms.

For example, Taskinen reports the following optimized excess terms (J/mol), in the
notation used in the report:

    liquid:
        G^ex = x_Bi x_Pb [ -4289.0 - 1.293 T
                            + 285.1 (x_Pb - x_Bi) ]

    fcc:
        G^ex = x_Bi x_Pb [ -3561.2 - 2.915 T
                            + 581.0 (x_Pb - x_Bi) ]

    epsilon/HCP:
        G^ex = x_Bi x_Pb [ -6269.9 - 3.2607 T
                            - 145.2 (x_Pb - x_Bi) ]

    rhombohedral:
        G^ex = x_Bi x_Pb [ 25132.4 ]

These values demonstrate that Taskinen's assessment is not the same parameterization as
the current OBGEL candidate. It should therefore be used as an independent scientific
cross-check, not as a replacement for the Yoon–Lee source.

Taskinen's reported invariant diagram contains a Pb-rich peritectic involving
FCC Pb-rich solid, ε/HCP Pb, and liquid, as well as the Bi-rich eutectic. This makes
the report particularly useful for checking phase topology.

## Current scientific investigation

The present OBGEL/CTT model has revealed the following behavior:

1. The original candidate liquid unary functions were too low because stable elemental
   reference functions were used instead of the appropriate metastable pure-liquid
   functions.

2. After correcting the liquid unary functions, the OBGEL canonical viewer and CTT
   produce identical liquid free-energy behavior.

3. With the current HCP, liquid, and rhombohedral models and FCC excluded, CTT finds
   an HCP-liquid-A7 invariant near 306 K.

4. At 399 K, the current HCP-liquid-A7 system gives two separate pairwise common
   tangents rather than one three-phase common tangent.

5. As a sensitivity experiment, adding a constant to the HCP Gibbs energy moves the
   calculated invariant strongly:

       ΔG_HCP = 0       -> T_eut ≈ 306 K, x_Bi ≈ 0.345
       ΔG_HCP = +100    -> T_eut ≈ 303 K, x_Bi ≈ 0.338
       ΔG_HCP = -1000   -> T_eut ≈ 339 K, x_Bi ≈ 0.415
       ΔG_HCP = -3000   -> T_eut ≈ 391 K, x_Bi ≈ 0.532

   Including FCC with the -3000 J/mol HCP perturbation causes FCC to disappear from
   the equilibrium phase diagram.

These are **diagnostic calculations**, not proposed changes to the canonical OBGEL data.

## What remains to be established

The original Yoon–Lee paper is the intended primary source for the present Pb-Bi
candidate, but a scan of the 1998 paper is not yet available.

The following questions therefore remain open:

1. Are the current unary/reference Gibbs-energy functions exactly those used by
   Yoon and Lee in 1998?

2. Are the current HCP coefficients

       L0 = -7388.9 - 0.68 T
       L1 = 2.86 T

   exactly the coefficients in the 1998 assessment?

3. Are the current liquid coefficients and metastable liquid unary functions exactly
   those used in 1998?

4. Are any current OBGEL values taken from a later TDB/database representation that
   incorporates a subsequent reassessment or correction?

5. Does the original Yoon–Lee paper contain a transcription or typographical error,
   or is the apparent discrepancy instead caused by our transcription/reduction of the
   published model?

6. Can every numerical coefficient in each OBGEL JSON file be traced to an equation,
   table, or explicitly documented reference in the original source?

## Source hierarchy

For this system, provenance should be treated in the following order:

1. **Primary source:** Yoon and Lee (1998), when the original paper becomes available.
2. **Secondary/independent assessments:** Taskinen (1989) and later CALPHAD/TDB
   implementations, used for comparison and error detection.
3. **OBGEL JSON:** canonical machine-readable representation of the selected assessment.
4. **Mathematica reader / CTT:** derived computational representations used for validation.

A secondary source that agrees with an OBGEL expression does not by itself establish
that the expression is the one used in the intended primary assessment.

## Intended future revision

When the Yoon–Lee scan becomes available, this document should be revised to replace
the **Pending** entries with explicit provenance wherever possible:

    source -> page -> equation/table -> JSON field -> coefficient

Any discrepancy should be recorded explicitly rather than silently corrected.

