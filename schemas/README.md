# Schemas

The canonical machine-readable representation for OBGEL separates **system metadata** from **phase thermodynamic models**.

## Current schemas

- `system.schema.json` describes a binary system, its two components, and the phase-model files belonging to that system.
- `thermodynamic-phase-model.schema.json` describes one phase Gibbs-energy model, including phase identity, composition coordinates, temperature range, structured thermodynamic expression, provenance, and generated TeX/PDF representations.

## Design rule

The JSON thermodynamic model is the source of truth. Human-readable TeX and PDF files are generated artifacts and must not be edited independently of the model data.

## Naming and composition conventions

- Repository, directory, and file names use lowercase words separated by hyphens; spaces are avoided.
- Scientific field names are descriptive rather than abbreviated.
- Each phase has a stable machine-readable `identifier` and a human-facing `displayName`.
- `displayNameStatus` records whether the phase name comes from the literature, is a standard name, or is a best-guess placeholder.
- A composition variable explicitly declares its quantity and role. Simple substitutional-binary models may use a mole fraction of one named component, but the schema does not assume that every future model uses mole fraction.
- For the initial binary-alley application, the first component convention may be used when appropriate; the phase-model record must still make the actual composition variable explicit.
- A binary solution phase names each canonical unary structural end member
  explicitly. Readers do not select unary end members from a stable-phase
  envelope.
- `redlichKisterComponentOrder` defines the sign convention for odd powers
  independently of the declared composition coordinate.

## Versioning

Schema versions identify the grammar and semantics of an object family; they are
independent of the repository release and of scientific revisions to individual
datasets. Changes that alter field meaning or interoperability must increment the
applicable schema-family version rather than being introduced silently.

See [`VERSIONING.md`](VERSIONING.md) for the compatibility rules and
[`CHANGELOG.md`](CHANGELOG.md) for schema history and migration notes.

## Candidate-phase provenance (optional binary schema 1.1 metadata)

Phase availability and assessment status are independent. `system.phaseModels` is the
reader inventory, not an equilibrium filter. `system.phaseModelProvenance` maps each
phase identifier to `assessed` or `constructed`; this must agree with phase-file
`modelProvenance` when present. Missing metadata means unspecified, never assessed
by default. An application may select any available phase for plotting or a constrained
equilibrium. It must retain the selected phases' provenance labels.

Optional phase fields distinguish `unaryEndpointProvenance` from
`binaryInteractionProvenance` (each has status, reference identifiers, and notes),
`modelProvenance`, and `intendedUse` (`teaching`, `diagnostic`,
`constrainedEquilibrium`, `equilibrium`). An RK record may carry `parameterOrigin`
(`assessedParameter`, `legacyTeachingAssumption`, `explicitModelAssumption`);
the ideal gas-constant record may carry `parameterOrigin` (`legacyTeachingValue`,
`referenceConstant`). These annotations do not alter numerical evaluation.
Canonical unary references retain structural function identity and inherit detailed
endpoint provenance from the system's unary files. A unary reference citation must
not be read as a citation supporting an unrelated binary interaction assumption.
An empty binary provenance reference list explicitly records absence of a citation.
Numerical regression success is not validation of a constructed model as assessed
thermodynamics. Binary schema 1.1 and unary schema 0.2.0 remain distinct contracts;
these additions are optional and preserve existing reader behavior.
