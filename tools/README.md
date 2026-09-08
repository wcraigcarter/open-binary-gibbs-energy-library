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
