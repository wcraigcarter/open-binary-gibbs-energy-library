# Ni–Re source compatibility audit — REVIEW REQUIRED / deferred

**Disposition (2026-09-14): parked.** Both blockers below remain unresolved.
Resumption requires a transparent assessment-reference compatibility/correction
mechanism and supported binary solution magnetism. Neither is implemented here.
Track next actions in the [living backlog](../unfinished-cases-backlog.md).

Re was promoted first. Both canonical dependencies exist, with FCC/HCP/liquid
structural functions available. Resumption has now reached a new source/schema
compatibility gate. No executable Ni–Re system or phase JSON has been staged.

## Exact source and coefficients

K. Yaqoob and J.-M. Joubert, “Experimental determination and thermodynamic modeling
of the Ni–Re binary system,” *Journal of Solid State Chemistry* 196 (2012), 320–325,
[DOI](https://doi.org/10.1016/j.jssc.2012.06.036).
The published paper is reproduced in the author's
[HAL thesis](https://theses.hal.science/tel-00805384/document), printed thesis
pp.103–108. Article p.324 / thesis p.107 was visually inspected for equations
and Table 3. Annex III is a later Mo–Ni–Re TDB dated 2012-11-19, not asserted
to be a byte-identical standalone Ni–Re assessment database. Its Ni–Re interactions
retain the article values at higher precision, attributed to REF9; the article
explicitly specifies Pure4 unary inputs.

G = xNi GNi(nonmagnetic) + xRe GRe(nonmagnetic) + RT Σ x ln(x)
+ xNi xRe L0(T) + ΔGmag(solution).
There are three assessed solution phases: FCC, HCP and liquid. Only RK order
zero is used, so component-order sign is immaterial; preserve {Ni,Re} explicitly.

| Phase | Article Table 3, J/mol | Author thesis Annex III, J/mol |
|---|---|---|
| Liquid | 21480.3 | 21480.3504 |
| FCC | 5054.5 + 8.29 T | 5054.48711 + 8.28748232 T |
| HCP | 9968.6 + 7.60 T | 9968.56426 + 7.59954301 T |

No values have been refitted. The thesis is corroborating source evidence,
not license to blend two versions silently.

## Blocking endpoint mismatch

Annex III printed p.211 defines GHSERRE; pp.219–220 define Re FCC and liquid.
These are different from the canonical Dinsdale-1991 equations. Direct visual
inspection of the database pages confirmed the extracted coefficients.
At 1816.75 K (the assessed peritectic temperature reported in the later comparison):

| Re quantity | J/mol |
|---|---:|
| Canonical G(liquid) − G(HCP) | 24679.648717 |
| Author database G(liquid) − G(HCP) | 12292.915702 |
| Canonical minus author database | 12386.733015 |

At 1473.15, 1773.15 and 1873.15 K this difference is respectively
14298.832988, 12645.698362 and 12043.641219 J/mol.
The Mathematica audit also differentiates the discrepancy: at 1816.75 K the
entropy difference is 6.001218 J/(mol K) and Cp difference is 5.201784 J/(mol K).
These numbers are diagnostics of source incompatibility, not binary validation.

A shared energy-reference shift cancels from G(liquid)−G(HCP), so it cannot
explain this mismatch. RK excess terms vanish at pure endpoints, so they cannot
repair it while preserving exact canonical endpoint recovery. Merely attaching
unchanged assessed L0 coefficients to canonical Re would create a changed model;
its agreement with the assessment cannot be assumed. A faithful version requires
an explicit unary-version/model policy decision, not an undisclosed replacement
of the just-validated canonical Re.

## Blocking magnetic representation issue

The article explicitly adds solution magnetism to nonmagnetic endpoints.
The author's database supplies FCC magnetic type (-3, p=0.28), Ni TC=633 K,
and BMAGN=0.52. Its HCP entry carries a magnetic type but the inspected HCP
parameter block has no TC/BMAGN entries, unlike the canonical Ni HCP function.
This is an additional source compatibility concern requiring explicit treatment.

The current phase schema's expressionModel permits unary references, ideal mixing,
and RK terms only (`additionalProperties:false`). Selecting customStructuredModel
does not add a general expression evaluator. There is no executable solution-magnetic
contribution field. Interpolating complete magnetic unary Gibbs functions is not
identical to evaluating composition-dependent solution magnetism; being above Curie
temperature does not make its high-temperature tail exactly zero. Omitting it or
approximating it would need a separately disclosed model decision and validation.
No schema or reader change was made.

## Scope, union inventory and validation status

Intended scope remains the high-temperature disordered FCC/HCP/liquid peritectic.
The 2012 model contains no Ni4Re or other ordered binary compound.
[Zhu and van de Walle (2021)](https://doi.org/10.1007/s11669-021-00884-y)
predict ordered Ni4Re and NiRe3 below the high-temperature experimental range;
this is separate physics, not evidence that the selected three-phase assessment
already includes those compounds. A future dataset must record this as
intentionalDatasetScope; no low-temperature completeness claim is made here.

The common canonical unary interval is 298.15–3000 K. This is an upper bound
on potential binary validity, not an approved binary systemValidity. The article
uses solvus data down to 990°C; the proposed lecture window still needs approval
through source-compatible model validation. Re melting at 3459 K is outside the
common unary interval and cannot be a whole-binary endpoint temperature test.

Union inventory: six continuous structural endpoint references (Ni/Re × FCC/HCP/liquid)
and four remaining endpoint-only states: Ni BCC, CUB_A13, BCC_A12; Re BCC.
No BCC solution was manufactured. Fixed endpoint phases are not asserted to be
irrelevant to equilibrium until an accepted binary is tested.

The full requested binary suite (serialized G and derivatives, endpoint recovery,
common tangents, lower envelope, invariant/all three compositions, boundaries,
no spurious intrusion, schema and provenance) was **not run for an accepted model**,
because construction stopped at the preceding source/schema gate. No peritectic
computed with a hybrid model is certified, and no CTT candidate is offered.

## Reference values, not expected CTT results

[Boettinger et al., Solidification of Ni–Re Peritectic Alloys (2020), Table I](https://pmc.ncbi.nlm.nih.gov/articles/PMC7552818/)
reports the 2012 assessment at 1543.6°C (1816.75 K), with Re **mass fractions**
liquid 0.291, FCC 0.427, HCP 0.834. These are source benchmarks, not mole fractions
or outputs validated here. Their experiment gives 1561.1 ± 3.4°C, with Re mass
fractions 0.283 ± 0.036, 0.436 ± 0.026 and 0.828 ± 0.037 respectively.
Do not demand that a historical assessment reproduce the newer experimental
central temperature exactly. Source boundary data and these invariant benchmarks
must be compared after model compatibility is resolved.

## Files and next dependency

`working/binary/ni-re/audit-compatibility.wl` evaluates canonical JSON and the
explicitly identified source differences. `source-compatibility.json` retains
parameters, source comparison, union inventory and stop status.
Next required work is an explicit source-compatible unary-version policy and
solution-magnetic representation decision. Neither is silently implemented in
the source audit. That audit made no CTT, notebook, interface, teaching-document,
commit or push changes. A subsequent documentation-only checkpoint records this
disposition; it does not publish the uncommitted canonical dependencies or local
working evidence.
