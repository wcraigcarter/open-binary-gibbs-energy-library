# Tools

Validation, generation, and maintenance utilities belong here. Tools should operate on the canonical data rather than embedding alloy-specific thermodynamic parameters.

## Unary batch pipeline

`unary-batch-pipeline.wl` extracts selected SGTE unary functions, flattens
their dependencies into the schema-0.2.0 basis, writes candidates only under
`working/unary-batch-0.2.0/`, and runs structural, numerical, envelope,
transition, continuity, provenance, and regression gates. It never promotes,
commits, or pushes generated candidates.

The first completed promotion is recorded in the staging reports and retains
the exact pre-promotion JSON under `promoted-candidates/`. The pipeline's Zn
configuration records the reviewed distinction between canonical phase key
`hcp` and Dinsdale's verbatim source designation `HCP_A3 (Zn non ideal)`.

## Cu-Ag canonical-unary regression

`cu-ag-unary-regression.wl` compares the canonical Cu/Ag structural end-member
path against the unchanged embedded Cu-Ag endpoint expressions. It checks phase
energies, eutectic common-tangent conditions, representative FCC/FCC and
FCC/liquid boundaries, topology, effective validity, and numerical residuals.

## Cu-Ag constructed candidate regression

`cu-ag-candidate-regression.wl` checks BCC/HCP canonical assembly, historical energy
and derivative differences, candidate non-intrusion, and selected constrained common
tangents. It writes `docs/audits/cu-ag-candidate-regression.json`. Its historical
formulas live separately under `docs/audits/` and are not canonical binary parameters.
