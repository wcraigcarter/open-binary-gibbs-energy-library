# Unfinished cases and deferred work

Last reviewed: 2026-09-14.

This is a living project-control record, not scientific source documentation.
Update status, reason, next action, and evidence links when work resumes or closes.
Keep resolved entries visible with their closure evidence; historical audit flags
must not override newer validation. Inclusion does not authorize implementation,
coefficient changes, promotion, or changes to the owner's notebooks/CTT.

Evidence links describe the current local checkout. Some targets remain
uncommitted or in ignored working directories and may be unavailable in a fresh
clone; this documentation checkpoint does not publish those supporting artifacts.

## Systems and unary follow-ups

| Case | Current status | Blocker or reason | Next action and evidence |
|---|---|---|---|
| Ni-Re | **REVIEW REQUIRED / deferred**; no binary candidate or validation | Published assessment uses Re unary functions materially different from canonical Re: liquid-HCP difference mismatch about **12.39 kJ/mol** near the peritectic (12386.733015 J/mol at 1816.75 K in the author-database comparison). Assessment also uses solution magnetism unsupported by the current binary expression schema. | First define a transparent assessment-reference compatibility/correction mechanism and supported solution-magnetism representation; then validate source reproduction before promotion. Neither blocker is being fixed here. Preserve the distinction between the published article and the later author database. [Audit](audits/ni-re-source-compatibility.md). |
| Mg-Pb | Deferred / unfinished; not promoted | Exact Mg2Pb line-compound/fixed-composition treatment and complete regression remain unfinished. Pb HCP availability and Mg high-temperature source-version differences must be reconciled against current canonical objects. | Resolve prerequisites, preserve the compound's complete formation-reference polynomial without double-counting unary contributions, then establish full regression. [Paused audit](audits/mg-pb-unary-integration-deferred.md). |
| Cu-Ni | Staged; assessed FCC+liquid lens **preliminarily independently validated**; full CTT regression and promotion pending | Reader support for unary endpoint phases/line compounds is incomplete. Six endpoint objects extend the two-solution subset. Optional BCC/HCP solutions remain deferred; HCP interaction evidence exists but is not validated for this scope. | After owner-directed reader work, run full candidate-set CTT regression; retain source/version limitations and review optional solutions separately. [Current framework status](../working/binary/cu-ni/framework-status.md) supersedes older pending-user-test notes. |
| H2O-NaCl | Deferred | Fixed-composition, electrolyte, and compound handling are not ready for the intended binary. This disposition is recorded from the owner's 2026-09-14 instruction, not a new source audit. | Revisit model scope and source selection once these representations and their evaluators are ready. Keep pure-substance records separate from binary readiness. |
| Cu-Co | Future advanced teaching candidate / deferred | Likely magnetic and metastable complications require source/model audit; no binary has been built. | Audit the assessment and relevant magnetic/metastable behavior before choosing teaching scope. [Planning record](../future-directions.md). |
| 3He-4He | **Deferred / future advanced source-schema audit** | Preliminary disposition from the owner's handoff, not a completed source audit: modern Helmholtz-EOS sources appear suitable for a fixed-pressure reduced G(x,T) treatment above the low-temperature quantum region. The low-temperature miscibility/superfluid problem may require a generalized binary free-energy expression beyond the current Redlich-Kister-style vocabulary. Source validity ranges and schema compatibility remain to be established. | Perform a focused audit of authoritative NIST/AIP sources and the source/schema fit before implementation, distinguishing the fixed-pressure fluid treatment from low-temperature quantum behavior. No construction, coefficients, or models are authorized by this backlog entry. |
| Zr unary | REVIEW REQUIRED for promotion; complete pressure-reduced Dinsdale-1991 candidate passes automated gates | Earlier OMEGA/pressure-completeness concern has been resolved in staging; independent unchanged-reader validation remains outstanding. | Obtain the owner's independent reader result, then review promotion without coefficient tuning. [Current staging status](../working/unary-batch-0.2.0/README.md); older batch-summary review wording is historical. |
| Ni unary source caveats | Canonical and user validated; source questions remain open | Promotion retained two documented source discrepancies; stable-envelope validation does not resolve them. | Resolve the source interpretations explicitly, preserving the validated functions unless a separately authorized revision is justified. [Source caveats and promotion](../sources/unary/Ni_Dinsdale_1991_Staged_Source_Model.md). |
| Mg unary provenance | Source follow-up pending | Source record labels extraction provisional pending direct primary-source coefficient verification; Mg-Pb audit also flags high-temperature version differences. | Audit provenance against current canonical data and record the outcome before resuming Mg-Pb. [Source record](../sources/unary/Mg_Standard_Reference.md). |
| Pb-Bi legacy staging | Historical pending flags; current source-audited package exists | `working/OLDER_pb-ni` retains pending direct-audit notes, while `working/pb-bi` describes the later source-audited package. Those old flags alone do not establish an active scientific blocker. | Reconcile the historical checklist with the current provenance record before reusing legacy material; do not reopen resolved findings merely from old notes. [Current package](../working/pb-bi/README.md). |

## Architectural and project tasks

| Task | Current status | Blocker or reason | Next action |
|---|---|---|---|
| Assessment-reference compatibility/correction | Deferred; blocks Ni-Re | A shared reference shift cancels from liquid-HCP differences; RK terms vanish at pure endpoints. Silent canonical substitution changes the assessed model. | Specify explicit source-version provenance and correction semantics, including endpoint policy and validation. Preserve canonical Re. |
| Binary solution magnetism / additive contributions | Deferred; blocks Ni-Re | Current expression schema lacks executable composition-dependent solution magnetism. Weighted magnetic unaries do not generally reproduce it. Fe's expanded unary terms are not a solution-magnetism implementation. | Design and validate an explicit contribution model against a documented assessment. See [future directions](../future-directions.md). |
| Exact fixed-composition and endpoint evaluation | Schema/framework work exists; consumer implementation and regression unfinished | Full CTT consumption of endpoint-only states and exact line compounds remains pending; electrolyte/compound semantics need additional work. | Agree scope with owner, then implement only when requested; test reference semantics and full equilibrium candidate sets. See [integration contract](binary-unary-integration.md). |
| Formal unary JSON Schema | Missing; convention checks currently used | No dedicated unary schema exists; numerical/convention passes must not be called formal unary-schema validation. | Define a versioned schema and migration/validation plan when prioritized. [Re validation](../working/unary-re/canonical-validation.json). |
| Curated collection and review workflow | Deferred project work | Verified systems, curator review, and contribution policy need coordinated development. | Select the next source-compatible system and establish review criteria. [Future directions](../future-directions.md). |
| Licensing, citation, publication | Deferred project work | Separate code/data/bibliography licensing, DOI, and publication readiness remain planning items. | Resolve licensing and citation policy; prepare publication when the collection has sufficient substance. [Future directions](../future-directions.md). |
| Additional readers, validation CI, generated documentation | Deferred project work | Prioritization and demonstrated need; no implementation commitment. | Prioritize against real consumer requirements, then scope readers, CI checks, and MyST/GitHub Pages separately. [Future directions](../future-directions.md). |

## Closed bookkeeping: Re

**Canonical and validated**, at `data/unary/re-standard-reference.json`.
Independent user result: HCP -> liquid approximately **3459 K**. Computed root:
**3459.000741 K** (not the precision of the user observation). Dinsdale's printed
DeltaCp is **7.4703 J/(mol K)**; the earlier discrepancy was an audit attribution
error, not a source inconsistency. No coefficient correction is needed.

Canonical status, source documentation, promotion supplement, and the saved
16-gate validation already agree. No remaining Re promotion/status change was
needed in this review. Canonical availability is in the working tree; it does
not imply a commit or publication. See [promotion record](audits/re-promotion-ni-re-status.json)
and [validation evidence](../working/unary-re/canonical-validation.json).
