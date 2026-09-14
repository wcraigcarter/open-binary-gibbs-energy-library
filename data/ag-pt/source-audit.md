# Ag-Pt: Karakaya-Thompson 1987 validated source model

Status: implementation-validated and promoted on 2026-09-14 after quantitative owner-reader agreement, qualitative CTT confirmation, and explicit owner authorization.

Load `system.json` through the existing binary reader. Composition is **xPt**, not xAg. The two phase identifiers are `liquid` and `fcc-a1`; the same FCC function has the Ag-rich and Pt-rich tangent contacts.

## Scope and reference convention

The full source PDF is available at `sources/binary/Karakaya=Thompson-1987-Ag-Pt.pdf` in the repository. Table 5 (p.337) supplies all coefficients and the original liquid-referenced unary functions. Table 6 (p.340) supplies calculated boundary comparisons. All energies are J/mol of atoms and temperatures are K. Natural logarithms are used.

This is a faithful transcription of the source liquid/FCC equations, using the existing embedded-endpoint schema 1.1. It is explicitly separate from canonical SGTE unary integration and the full unary phase-inventory framework. The owner authorized preserving the original assessment after the compatibility audit. No canonical Ag/Pt endpoint data are mixed into it. Both pure-liquid reference functions equal zero. Consequently the energies have a common composition-affine pure-liquid baseline removed; they are not absolute SER Gibbs energies or mixing energies relative to each phase's own endpoints. Their common-tangent equilibria are well defined. Absolute entropy and heat capacity cannot be inferred without restoring a physical baseline.

Use window: 1238.15–2100 K (965–1826.85 C). The source discusses the modeled phase boundaries above 965 C. The upper bound is an intentional teaching limit, not a published validity limit. Lower-temperature ordered/intermediate phases and gas are excluded. Pt has now been promoted separately; its SGTE FCC–liquid difference is incompatible with an unchanged substitution into this 1987 assessment.

## Algebraic representation

Let x=xPt and z=xAg-xPt=1-2x. The RK contribution is x(1-x) times the following polynomial in z:

- Liquid: 20689.75 - 7717 z - 4676.5 z^2 + 1180 z^3 + 1743.75 z^4.
- FCC: 5108.5 + 10.6 T - 7077.5 z - 4250 z^2.

These are exact algebraic transformations of Table 5, not fitted coefficients. The source solid excess entropy is -10.6 xAg xPt. R=8.314 J/(mol K) is an explicitly chosen rounded reference constant; the source does not specify its precision.

## Validation and qualifications

All three files pass the current Draft 2020-12 schemas. Evaluation through the unchanged working-copy binary reader agrees with independently transcribed source equations to 3.64e-12 J/mol on the comparison grid. Pure endpoints recover the source functions to 5.83e-11 J/mol.

The reader-derived peritectic is 1459.321504 K (1186.171504 C), with xPt = 0.200761004 (liquid), 0.405323838 (Ag-rich FCC), and 0.779669128 (Pt-rich FCC). A supporting-line check at 9999 interior compositions passes. This is a sampled stability check, not a formal global proof.

Twenty Table 6 two-phase rows were checked over the selected temperature scope, separately from the three-phase invariant. The largest composition discrepancy is 0.00291044 mole fraction (0.291044 atomic-percent Pt), on the Ag-rich FCC boundary at 1100 C: printed 0.194 versus calculated 0.19108956. At 1750 C the liquid value is printed 0.981 versus calculated 0.97882291. The diagnostic 0.002 mole-fraction comparison threshold therefore fails. These differences exceed simple final-digit rounding of the table; their cause is unresolved. The coefficients have not been adjusted to remove them. The source also reports disagreement with experimental Ag-rich solidus data; that experimental limitation is distinct from this internal Table 5/Table 6 discrepancy.

Implementation checks pass; exact reproduction of all tabulated boundary values is not claimed. The validation script intentionally returns failure when the Table 6 tolerance is exceeded. See `validation-diagnostics.json` for individual comparisons, owner observations, and the exact reader and source PDF hashes. Local diagnostic scripts are retained under `working/binary/ag-pt/`.

## User check

Run `user-reader-check.wl` after loading your existing binary reader. It loads this system, creates `agPtLiquid` and `agPtFcc` functions (arguments temperature, xPt), and reports the three common-tangent contacts. It does not modify the reader or CTT. Use these same two functions in CTT; do not create separate Ag-rich and Pt-rich FCC models.

The source-specific model was promoted without changing any Gibbs-energy coefficients. Validation does not assert exact agreement with all Table 6 values or canonical SGTE unary compatibility.
