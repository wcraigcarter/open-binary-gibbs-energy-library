# OBGEL unary batch 0.2.0 - first batch promotion report

Thirteen independently validated PASS candidates were promoted to `data/unary/`. Original staged JSON files are retained under `promoted-candidates/`; `candidates/` is empty so no promoted file can be mistaken for an unreviewed candidate.

## Outcome

- PASS and promoted: Ag, Al, Au, Cd, Cu, Hf, Mo, Nb, Ta, Ti, V, W, Zn
- REVIEW REQUIRED and not promoted: Zr

## Independent unchanged-reader validation

### Ag

- Stable-envelope transitions: fcc -> liquid at 1234.930000 K
- Canonical file: `data/unary/ag-standard-reference.json`

### Al

- Stable-envelope transitions: fcc -> liquid at 933.472726 K
- Canonical file: `data/unary/al-standard-reference.json`

### Au

- Stable-envelope transitions: fcc -> liquid at 1337.329981 K
- Canonical file: `data/unary/au-standard-reference.json`

### Cd

- Stable-envelope transitions: hcp -> liquid at 594.219045 K
- Canonical file: `data/unary/cd-standard-reference.json`

### Cu

- Stable-envelope transitions: fcc -> liquid at 1357.769970 K
- Canonical file: `data/unary/cu-standard-reference.json`

### Hf

- Continuous Gibbs-energy curves: confirmed by the project owner with the unchanged reader
- Stable-envelope transitions: hcp -> bcc at 2016.03 K; bcc -> liquid at 2506.00 K
- In-domain metastable crossings: fcc <-> liquid at 1951.42 K; hcp <-> liquid at 2419.63 K
- Rejected out-of-domain analytic roots: bcc <-> fcc at -5310.28 K; fcc <-> hcp at 4545.45 K
- Canonical file: `data/unary/hf-standard-reference.json`

### Mo

- Stable-envelope transitions: bcc -> liquid at 2896.019232 K
- Canonical file: `data/unary/mo-standard-reference.json`

### Nb

- Stable-envelope transitions: bcc -> liquid at 2749.999828 K
- Canonical file: `data/unary/nb-standard-reference.json`

### Ta

- Stable-envelope transitions: bcc -> liquid at 3289.999549 K
- Canonical file: `data/unary/ta-standard-reference.json`

### Ti

- Stable-envelope transitions: hcp -> bcc at 1154.988216 K; bcc -> liquid at 1940.984519 K
- Canonical file: `data/unary/ti-standard-reference.json`

### V

- Stable-envelope transitions: bcc -> liquid at 2182.999988 K
- Canonical file: `data/unary/v-standard-reference.json`

### W

- Stable-envelope transitions: bcc -> liquid at 3694.904945 K
- Canonical file: `data/unary/w-standard-reference.json`

### Zn

- Stable-envelope transitions: hcp -> liquid at 692.677000 K
- Canonical file: `data/unary/zn-standard-reference.json`

## Zn phase-identity decision

Zn is PASS. Its canonical function key remains `hcp`. Dinsdale's exact source designation `HCP_A3 (Zn non ideal)` is retained verbatim in source/model provenance metadata.

Phase identifiers describe phase or structure identity. Source-specific thermodynamic or model qualifications belong in metadata, not in the phase key.

## Pairwise-root domain rule

A pairwise root outside `systemValidity` is rejected as an OBGEL
thermodynamic result regardless of whether analytic extrapolation permits a
root finder to return it. The Hf bcc-fcc and fcc-hcp roots above are retained
only as rejected-root audit metadata. The Hf bcc-liquid crossing is an
equilibrium lower-envelope transition; its earlier metastable label was a user
transcription error.

## Remaining review case

- Zr: Dinsdale includes OMEGA and explicit pressure terms, while the standard-function source route omits OMEGA; phase completeness and ambient-pressure reduction require audit.

## Audit trail

- `promoted-candidates/`: exact pre-promotion candidate JSON
- `diagnostics/`: updated per-element validation and disposition records
- `reports/batch-report.json`: machine-readable automated, reader-validation, and promotion record
- `reports/unchanged-reader-validation.txt`: unchanged-reader output supplied by the user
- `source-extraction-and-model.md`: source and construction notes

Hf was promoted from its independently verified, version-pinned Dinsdale-1991
candidate. Zr was not changed or promoted.
