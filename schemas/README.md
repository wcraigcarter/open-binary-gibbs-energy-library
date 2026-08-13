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

## Versioning

The initial schema is versioned and should be treated as a frozen design baseline. Changes that alter field meaning or interoperability should increment the schema version rather than being silently introduced.
