# Schema Changelog

This history is independent of the repository release history in
[`../CHANGELOG.md`](../CHANGELOG.md). Each entry names the affected schema
family.

## Unary standard-reference schema 0.2.0 — 2026-09-05

The unary family moves from the development label `0.1-development` to the
machine-sortable pre-1.0 version `0.2.0`.

### Contract changes

- Require dataset-level `systemValidity`, including an explicit `basis` and
  provenance-aware `rationale`, as the authoritative usable temperature domain.
- Distinguish dataset-level system validity, function-level model validity, and
  temperature-segment evaluation intervals. Readers must not reconstruct the
  system domain by intersecting phase-model validity intervals.
- Generalize unary identity to cover elements and fixed-composition pure
  substances without changing `objectType`.
- Add fixed `systemConditions`, including explicit pressure semantics for
  pure-substance unary objects.
- Use physical phase-identity keys for functions and direction-neutral phase
  identities in transition verification metadata.
- Permit explicit metastable tangent-extension segments using the ordinary
  temperature basis, and distinguish extension-dependent results with
  `extension-derived` provenance.
- Record intentional dataset scope explicitly when OBGEL represents only part
  of a broader source or model domain.
- Clarify verification metadata as derived and non-model-defining, preserving
  separate source and computed values and their provenance.

### Demonstrated instances

- H2O and NaCl demonstrate fixed-compound unary objects and explicit pressure
  conditions.
- Fe demonstrates one re-entrant `bcc` phase identity with the stable sequence
  `bcc` to `fcc` to `bcc` to `liquid`. Its Hillert-Jarl/Inden magnetic
  contribution is analytically expanded into the existing temperature basis for
  unchanged-reader compatibility while its physical parameters and provenance
  remain explicit. The Curie point is an internal magnetic critical point, not a
  crystallographic envelope transition.

### Compatibility and migration

This release is breaking relative to the earliest unary development contract:
`systemValidity` is now required and the meanings of the three validity layers
are authoritative. A reader must take the dataset range from `systemValidity`
and honor each segment's explicit endpoint-inclusion fields.

Current canonical unary objects under `data/unary/` migrate together to `0.2.0`.
The superseded, non-executable H2O planning scaffold under `sources/unary/` and
the Pb/Bi development copies under `working/unary/` intentionally retain
`0.1-development` as historical artifacts. Binary system and phase-model objects
remain on their independent `1.1` schema family. The repository release remains
`0.1.0`.

## Unary standard-reference schema 0.1-development

Initial developmental unary exemplars. This label preceded an explicit
schema-family versioning policy and is retained only on identified historical or
superseded artifacts.
