# Codex Handoff — OBGEL + Common Tangents Tool

## Purpose

This document gives Codex the technical context needed to continue implementation work on the Open Binary Gibbs Free Energy Library (OBGEL) and the Common Tangents Tool (CTT) without access to the original development conversation.

Treat the current repositories as authoritative for implementation state. This document records the scientific and architectural context behind that state.

---

## 1. Original Pb–Bi problem

During development of the Pb–Bi dataset, the molar Gibbs-energy curves produced from OBGEL disagreed with the expected Pb–Bi phase-diagram topology.

The most important symptom was that the liquid Gibbs-energy curve was spuriously low at low temperature. CTT consequently failed to show the expected invariant topology.

The debugging considered possible errors in:

- CTT common-tangent/convex-hull calculations;
- OBGEL JSON-to-function conversion;
- mole-fraction versus weight-fraction interpretation;
- molar normalization;
- sublattice-to-binary reduction;
- affine transformations used by CTT;
- unary/reference-state functions and lattice-stability terms;
- transcription errors in published thermodynamic data.

---

## 2. What was established

### Composition and units

Pb–Bi binary models use mole fraction:

    x = xBi
    xPb = 1 - xBi

The Gibbs energies are molar Gibbs free energies, normally in J/mol, with temperature in kelvin.

The conventional binary substitutional/Redlich–Kister form is used.

### The main error

The initial Pb–Bi liquid model used stable elemental reference functions for Pb and Bi instead of the appropriate metastable pure-liquid unary functions.

This made the liquid Gibbs energy coincide with stable elemental solid Gibbs energies at the pure-component endpoints and made the liquid artificially low over the binary range.

After correcting the liquid unary functions:

- the canonical OBGEL evaluation and CTT agreed;
- the anomalous liquid behavior disappeared;
- the expected Pb–Bi invariant topology appeared.

This established an important rule:

    phase identity != stable elemental reference state

Unary contributions must be phase-specific. Metastable unary functions are required when the phase model uses a metastable elemental state (for example, liquid Pb/Bi or Pb on another lattice).

### HCP/sublattice reduction

The Pb–Bi HCP/epsilon representation can be reduced from its fixed-vacancy sublattice construction to an ordinary binary molar Gibbs-energy function. The fixed vacancy occupancy introduces no additional composition degree of freedom or configurational entropy term in this reduction.

### CTT affine transformation

CTT uses numerical transformations for Gibbs-energy handling. No evidence was found that the affine transformation was responsible for the Pb–Bi discrepancy. Do not compensate for thermodynamic errors by altering the CTT affine transformation.

### Sensitivity experiment

Changing the HCP Gibbs energy by a constant moved the calculated invariant strongly:

    ΔG_HCP = 0       -> T_eut ≈ 306 K, xBi ≈ 0.345
    ΔG_HCP = +100    -> T_eut ≈ 303 K, xBi ≈ 0.338
    ΔG_HCP = -1000   -> T_eut ≈ 339 K, xBi ≈ 0.415
    ΔG_HCP = -3000   -> T_eut ≈ 391 K, xBi ≈ 0.532

These were diagnostic perturbations only and are NOT canonical data corrections.

---

## 3. Pb–Bi verification state

The corrected Pb–Bi OBGEL/CTT implementation was independently checked in a fresh state.

Current CTT behavior verified by the user:

- Pb-rich invariant: approximately T = 458 K, xBi = 0.278, involving Liquid + FCC -> HCP.
- Bi-rich eutectic: approximately T = 400 K, xBi = 0.55, involving Liquid -> HCP + Rhombohedral.

The exact numerical details should be re-established from the current repository rather than assumed from this document.

The original Yoon–Lee paper was eventually obtained and used for source examination. The current provenance record should remain explicit about which values have direct primary-source confirmation and which are derived/secondary.

Taskinen's Pb–Bi assessment was used as an independent topology cross-check, not as a replacement for Yoon–Lee.

---

## 4. Units, normalization, reference states, data interpretation

### Established

**Gibbs-energy units:** molar Gibbs free energy, normally J/mol.

**Temperature:** absolute temperature in kelvin.

**Composition:** binary substitutional models use mole fraction. Pb–Bi uses xBi. Cu–Ag's reference reader also declares its independent mole-fraction component rather than relying on component ordering.

**Ideal mixing:**

    R T [x Log[x] + (1 - x) Log[1 - x]]

The implementation must explicitly handle x = 0 and x = 1.

**Redlich–Kister:** conventional binary form is used; pay attention to the declared independent component and the sign convention of odd-order terms.

**Reference states:** phase-specific. A liquid may require metastable pure-liquid unary functions; a metastable solid solution may require a metastable lattice function.

**Canonical data:** OBGEL JSON is the canonical machine-readable thermodynamic representation. Mathematica functions, rendered equations, PDFs, plots, and CTT objects are derived representations, not independent thermodynamic sources.

### CTT affine transformations

Internal numerical transformations must preserve equilibrium/common-tangent geometry. They are not thermodynamic corrections.

---

## 5. OBGEL architecture and changes

### Canonical JSON

The JSON is the canonical, self-contained thermodynamic representation.

### Provenance workflow

    Primary published assessment
        -> source extraction
        -> canonical OBGEL JSON
        -> reader / derived representations
        -> independent numerical validation
        -> CTT validation

Discrepancies must be documented, not silently corrected.

### System-level composition

The binary composition convention should be declared once at system level in `system.json`. Inspect the current repository before changing existing readers because compatibility work may have retained older representations.

### System-level temperature validity

The system should expose the intended common temperature interval. Outside model validity must not silently mean a zero Gibbs-energy contribution.

### Ideal-mixing endpoints

The reader must explicitly define x Log[x] at x = 0 and x = 1 so numerical tools can safely evaluate pure endpoints.

### Piecewise functions

Preferred generated Mathematica convention:

    lower <= temperature < upper

for every segment except the final one, whose upper endpoint may be closed.

Every breakpoint should also be checked for continuity.

---

## 6. Composition models

A phase must explicitly identify how composition is modeled.

Initial vocabulary:

- `Substitutional Solution`
- `Line Compound`
- `Ordered Solution`
- `Sublattice Solution`

Only the first two require implementation for the immediate Mg–Pb task. Expand the list only when a real dataset requires it.

### Line compound

A line compound has fixed composition rather than a continuous composition coordinate.

For Mg2Pb:

    xPb = 1/3

The canonical representation should carry the fixed composition explicitly, preferably as an exact rational value.

Do NOT encode a delta-function or narrow-Gaussian approximation in canonical OBGEL JSON. If CTT uses such a numerical approximation internally, that is strictly a CTT implementation detail.

---

## 7. Unary reference library

Reusable unary-reference documents are being established:

    sources/
        unary/
            Mg_Standard_Reference.md
            Pb_Standard_Reference.md
            Bi_Standard_Reference.md
            ...

        assessments/
            Mg-Pb_Zhang_2014_Set1.md
            Pb-Bi_Yoon-Lee_1998.md
            ...

Binary JSON remains self-contained for portability, but should carry enough provenance to identify the unary/reference version used to construct it.

Eventually a validator should compare unary functions embedded in binary JSON against the current unary reference and report matching reference, numerical differences, or different reference/version. It must not silently rewrite historical assessments.

### Naming conventions

Use descriptive lower-camel-case Wolfram Language names rather than SGTE abbreviations as the public programming interface.

Preferred examples:

    gReferenceMg[temperature]
    gLiquidReferenceMg[temperature]
    gReferencePb[temperature]
    gLiquidReferencePb[temperature]

    redlichKister0LiquidMgPb[temperature]
    redlichKister1LiquidMgPb[temperature]

Retain SGTE names in comments and provenance, e.g.:

    (* SGTE: GHSERMG *)

Use explicit variables such as `temperature` and `moleFractionPb`.

For multiline Mathematica definitions, parenthesize the RHS so code can be copied directly into Mathematica.

---

## 8. implementation-observations.md

This document is a durable engineering/scientific record of lessons discovered during development. It is not disposable scratch material.

Important observations include:

- candidate systems should have complete expected directory structure;
- composition convention belongs at system level;
- common system temperature range should be readily available;
- outside-validity behavior must not masquerade as zero;
- visual inspection of Gibbs-energy curves is an important debugging tool;
- ideal-mixing endpoints need explicit handling;
- CTT can consume `f[temperature][composition]` functions;
- unary/reference Gibbs energies are phase-specific;
- metastable unary functions may be required;
- piecewise functions need defined values at domain edges;
- piecewise breakpoints should be checked for continuity;
- line compounds must be explicitly identified by a composition model and fixed composition;
- a reusable unary reference library is needed to improve consistency across binary systems.

Do not renumber observations casually; the numbering has evolved during development.

---

## 9. Mg–Pb task

### Source and model choice

Use Zhang et al. (2014), DOI 10.2298/JMMB130824017Z.

Use **Set 1 only**, which is the substitutional-solution liquid model. Set 2 is the associate-liquid model and is out of scope for the first implementation.

The authors report that the associate model better describes the short-range-ordered liquid; this is a scientific caveat, not a reason to switch models for the current task.

### Expected phases

    liquid
    hcp-a3
    fcc-a1
    mg2pb

where Mg2Pb is the line compound.

### Published validation targets

For Set 1, Zhang Table 3 reports approximately:

- Liquid = Mg2Pb: xPb = 33.33 at.%, T ≈ 824.1 K.
- Liquid = Mg2Pb + (Mg): liquid ≈ 16.51 at.% Pb, HCP ≈ 8.71 at.% Pb, T ≈ 732 K.
- Liquid = Mg2Pb + (Pb): liquid ≈ 80.7 at.% Pb, FCC ≈ 94.66 at.% Pb, T ≈ 517.29 K.

Acceptance must check both topology and numerical temperatures/compositions.

### Set-1 parameters extracted from Table 2

Liquid:

    redlichKister0LiquidMgPb[temperature_] := (
        -32873.29 + 4.45 temperature
    );

    redlichKister1LiquidMgPb[temperature_] := (
        -19584.57 + 11.45 temperature
    );

HCP-A3:

    redlichKister0HcpMgPb[temperature_] := (
        -4679.16 - 20.33 temperature
    );

    redlichKister1HcpMgPb[temperature_] := (
        -9549.62
    );

FCC-A1:

    redlichKister0FccMgPb[temperature_] := (
        -10419.65 - 3.28 temperature
    );

No higher FCC Redlich–Kister term is listed for Set 1.

Mg2Pb is stoichiometric, with xPb = 1/3. Its exact Eq. (8) representation must be taken from the audited source-extraction document rather than guessed from memory.

---

## 10. Immediate CTT implementation requirement

CTT must accept phase functions together with explicit composition-model metadata.

Preferred conceptual representation:

    <|
        "Function" -> phaseFunction,
        "Composition Model" -> "Substitutional Solution"
    |>

For Mg2Pb:

    <|
        "Function" -> lineCompoundFunction,
        "Composition Model" -> "Line Compound",
        "Composition" -> 1/3
    |>

Preserve the existing common-tangent logic for ordinary solution phases.

For a solution phase tangent to a line compound at fixed composition `xLineCompound`, use the single scalar condition

    gSolution'[xSolution] ==
        (gLineCompound - gSolution[xSolution]) /
        (xLineCompound - xSolution)

At fixed temperature, the only unknown is the solution composition.

The line-compound composition must be explicitly included in the numerical composition set / hull construction so that it cannot disappear merely because the ordinary grid misses x = 1/3.

The user already has a CTT-specific implementation strategy for this; do not redesign it unnecessarily.

---

## 11. Verification and uncertainty

Verified:

- Cu–Ag is an established exemplar; current reference-reader/CTT behavior is consistent with the intended substitutional model.
- Corrected Pb–Bi data reproduce the intended invariant topology in CTT.
- The Pb–Bi problem was traced primarily to phase-specific unary reference construction, not to the CTT affine transformation.

Still requiring care:

- Historical assessments must remain reproducible and self-contained.
- Do not replace an assessment's unary functions automatically with a newer unary reference.
- Every unary reference needs explicit source/version provenance.
- Piecewise functions need domain-edge and continuity checks.
- The unary-consistency validator is future work.
- Mg–Pb has not yet been accepted into `data/`.

---

## 12. Implementation acceptance criteria

1. Confirm/document the composition-model vocabulary in the OBGEL schema/documentation.
2. Implement `Line Compound` handling in CTT without breaking ordinary substitutional phases.
3. Represent Mg2Pb as fixed xPb = 1/3.
4. Ensure CTT includes xPb = 1/3 regardless of composition-grid spacing.
5. Compute line-compound/solution common tangents with the single-equation formulation.
6. Complete and audit the Mg/Pb unary reference source documents.
7. Complete the Zhang Set-1 Mg–Pb source extraction.
8. Generate self-contained Mg–Pb JSON.
9. Build/use a Mathematica reader for the Mg–Pb JSON.
10. Verify the three Zhang Table-3 invariant targets.
11. Re-run existing Cu–Ag and Pb–Bi validation to ensure no regression.

Do not consider Mg–Pb accepted until numerical and topological validation succeeds.

---

## Working principle

Do not tune thermodynamic constants to make CTT reproduce an expected diagram.

When a discrepancy appears, determine which layer introduced it:

    source -> extraction -> JSON -> reader -> numerical validation -> CTT

Preserve source-specific assessments even when a newer unary reference exists. Record discrepancies explicitly rather than silently correcting them.
