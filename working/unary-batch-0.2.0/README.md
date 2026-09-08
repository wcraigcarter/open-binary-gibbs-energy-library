# Unary batch 0.2.0 staging area

This directory preserves the audit trail for the first conservative OBGEL
batch-element unary run and its completed first promotion. Ag, Al, Au, Cd, Cu,
Mo, Nb, Ta, Ti, V, W, and Zn were independently validated with the unchanged
generic Mathematica reader and promoted to `data/unary/`. The original Hf
review flag was subsequently resolved by a separately version-pinned
Dinsdale-1991 candidate. It passed the automated gates and the project owner's
independent unchanged-reader validation, and was promoted without coefficient
changes. Zr remains review-required and was not changed or promoted.

## Layout

- `candidates/` is empty after promotion so no promoted file can be mistaken
  for an unreviewed candidate.
- `promoted-candidates/` retains the exact pre-promotion candidate JSON files
  for coefficient and provenance comparison.
- `diagnostics/` contains the initial machine-readable result per requested
  element and `hf-dinsdale-1991-validation.json`, the later Hf resolution.
- `reports/batch-report.json` is the complete machine-readable batch report.
- `reports/batch-summary.md` is the human-readable report.
- `reports/unchanged-reader-validation.txt` preserves the first-batch user
  validation; the Hf validation is recorded in the Hf source record,
  candidate/canonical metadata, diagnostics, and batch reports.
- `reports/promotion-validation.json` records the final schema, coefficient,
  provenance, disposition, and artifact checks for every promoted file.
- `source-extraction-and-model.md` records source selection, extraction,
  flattening, validity, and review policy.

## Reproduction

Download the official SGTE Unary Database v5.0 `unary50.tdb` from the SGTE
Pure Element Database page, then run:

```text
wolframscript -file tools/unary-batch-pipeline.wl /absolute/path/unary50.tdb
```

The exact input used for this run had SHA-256
`8e38dcefbeaad1f8ed83ed1f8ccceb0e1701fb584f1bf3798f217488253d4b3f`.
The batch report records the runtime path and hash. A differing hash is a new
source revision and must not silently reproduce the same provenance claim. A
pipeline rerun creates a new staging run and must not be treated as a replay of
the completed human promotion decision.

The Wolfram runtime currently prints warnings when its optional local
`WolframScript.conf` file is absent. Those warnings do not affect evaluation;
the process completes successfully and writes valid JSON.
