# Schema Versioning Policy

## Scope

Each OBGEL schema family is versioned independently. A `schemaVersion` identifies
the grammar and semantics required to interpret an object; it is not the
repository release number and does not identify a scientific revision of an
individual dataset. Improving coefficients, provenance, or verification without
changing the contract does not by itself change `schemaVersion`.

The current families are:

- the unary standard-reference family, currently `0.2.0`; and
- the binary system and phase-model family, currently `1.1`.

Canonical objects in one family that conform to the same current contract should
carry the same version. A historical or superseded artifact may retain an older
version when preserving its original development context is intentional; it must
not be presented as a current canonical object.

## Version numbers

New schema versions use `MAJOR.MINOR.PATCH` numbers.

Before `1.0.0`, the schema is explicitly developmental and incompatible changes
may still occur:

- increment `MINOR` for a breaking contract change, including removing or
  requiring a field, changing a field's meaning, or requiring reader migration;
- increment `PATCH` for a backward-compatible addition, correction, or
  clarification.

At and after `1.0.0`:

- increment `MAJOR` for an incompatible contract change;
- increment `MINOR` for a backward-compatible addition; and
- increment `PATCH` for a backward-compatible correction or clarification.

Moving from a pre-1.0 family to `1.0.0` declares that family stable enough for a
public compatibility commitment. Pre-1.0 versions do not remove the obligation
to document changes and migrations.

## Change procedure

For every schema-version change:

1. identify the affected schema family and assess reader and data compatibility;
2. update all current canonical objects in that family together;
3. update the prose contract and formal JSON Schema when one exists;
4. add a dated entry to `schemas/CHANGELOG.md`, including migration guidance;
5. validate syntax, structural conventions, version consistency, and affected
   readers before release; and
6. leave other schema families, repository release metadata, and intentionally
   historical artifacts unchanged unless their contracts also change.

When a formal schema exists, its accepted version should be constrained rather
than accepting an arbitrary string. The unary family does not yet have a formal
JSON Schema; its current enforceable contract is the canonical exemplars plus
`docs/schema-conventions.md`.
