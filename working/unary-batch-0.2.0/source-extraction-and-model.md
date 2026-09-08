# Source extraction and model construction

## Source boundary

The coefficient source consumed by the pipeline is the official
[SGTE Unary Database v5.0](https://www.sgte.net/en/free-pure-elements-database),
dated 2 June 2009. SGTE identifies A. T. Dinsdale, “SGTE data for pure
elements,” *CALPHAD* 15 (1991) 317-425,
DOI 10.1016/0364-5916(91)90030-N, as its reference.

The Dinsdale paper is also used directly for the phase set, printed validity
scope, transition table, and page-level audit locations. The report keeps the
1991 transition values separate from temperatures recovered from the encoded
functions. It does not describe a recovered value as an independent physical
prediction.

The database and paper are not assumed to be numerically identical. The SGTE
v5 header explicitly lists later revisions and added phases. Two conservative
stops were enforced in the initial run:

- Hf was initially review-required because SGTE v5 explicitly revises its HCP-A3,
  BCC-A2, and FCC-A1 data. The pipeline will not represent those coefficients
  as a literal Dinsdale-1991 transcription.
- Zr is review-required because Dinsdale includes OMEGA and pressure terms,
  while the standard-function route used by the first parser does not expose
  a complete OMEGA function. No incomplete Zr candidate is emitted.

### Subsequent Hf resolution

The first-run Hf stop remains preserved in the original report. It was later
resolved by directly transcribing the Hf functions printed on Dinsdale (1991)
pp. 357-358 into the separately identified model
`hf-unary-dinsdale-1991`. The resulting staged candidate is
`candidates/hf-dinsdale-1991-standard-reference-candidate.json`; its audit is
recorded in `sources/unary/Hf_Dinsdale_1991_Standard_Reference.md` and
`diagnostics/hf-dinsdale-1991-validation.json`. SGTE v5 is provenance context
only for that object and supplies no model-defining coefficient. The candidate
passed the automated gates and the owner's independent unchanged-reader check,
then was archived under `promoted-candidates/` and promoted to
`data/unary/hf-standard-reference.json` without coefficient changes.

Zn was initially emitted as a review-required staging candidate because of
Dinsdale's exact designation `HCP_A3 (Zn non ideal)`. Human review established
that this parenthetical wording qualifies the thermodynamic reference/model,
not the crystallographic phase identity. The promoted object therefore keeps
the canonical key `hcp` and preserves the source designation verbatim in
source/model provenance metadata.

## Extraction and dependency flattening

The Mathematica pipeline extracts each named SGTE `FUNCTION` block, including
every continuation segment and endpoint flag. It parses only the OBGEL basis
vocabulary:

\[
1,\quad T,\quad T\ln T,\quad T^n.
\]

When an SGTE function refers to `GHSER...`, the pipeline recursively resolves
that dependency and analytically expands it over the union of all source
breakpoints. This produces one self-contained function per phase and satisfies
the current reader's single-root assumptions. This is exact algebraic
flattening, not fitting. No coefficients, transition temperatures, phase
identities, or out-of-range extensions are invented.

Every emitted segment is lower-inclusive and upper-exclusive except the final
segment, which is upper-inclusive. The closed OBGEL endpoints represent finite
limiting values of the source expressions, consistent with the existing Fe
and Pb conventions. No value is supplied beyond `systemValidity`.

## Pressure and additive contributions

The batch is a fixed 1 bar, temperature-only reduction. For Mo, Dinsdale prints
an additive `Gpres` contribution. The candidate records that contribution and
its omission at ambient pressure under the same low/moderate-pressure
reduction already audited for the Fe exemplar. The directly audited Dinsdale
Hf entry prints no separate pressure contribution. Zr retains its pressure-term
diagnostic and remains review-required.

None of the emitted first-batch candidates contains a magnetic term. If a
future source function does, the pipeline must stop unless the contribution is
handled by a separately audited analytic expansion with direct and expanded
evaluation equivalence checks, as for Fe.

## Automated gates

The run checks source-function completeness, JSON round-trip syntax,
schema-0.2.0 structural requirements, segment adjacency and inclusion,
function/system validity, absence of evaluation gaps, basis support,
dependency flattening, C0/C1 boundary residuals, finite independent numerical
evaluation, lower-envelope topology, recovered transitions against Dinsdale's
table, root residuals, and provenance/status fields.

The numerical tolerances are recorded in the machine report. Source
coefficients are never changed to force a gate to pass. A failed gate becomes
a specific `REVIEW REQUIRED` reason.

## Promotion semantics

`PASS - canonical unary candidate` means that a staged candidate passed all
automated gates in this first pipeline. The first promotion additionally
required human review and successful validation with the unchanged generic
Mathematica reader. The promoted original candidates remain under
`promoted-candidates/`, while their canonical counterparts are in
`data/unary/`.

Review-required elements retain diagnostics. Hf and Zn are resolved and their
successful numerical, structural, semantic, and unchanged-reader validations
remain inspectable in the reports and archived candidate records. Zr alone
remains review-required.
