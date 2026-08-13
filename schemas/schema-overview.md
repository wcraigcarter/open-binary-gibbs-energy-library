# OBGEL Schema Overview

## Documents

`system.schema.json` describes system identity and the phase-model files belonging to one binary system.

`thermodynamic-phase-model.schema.json` describes one phase Gibbs-energy model and is the canonical schema for a `G(T,X)` model.

## Phase naming

Every phase has:

- `identifier`: a stable machine-readable name used by software;
- `displayName`: the default human-facing name supplied to applications;
- `displayNameStatus`: `literature`, `standard`, or `bestGuessPlaceholder`.

Applications such as the Phase Diagram Tool may override `displayName` at the final presentation stage.

## Composition

A phase explicitly declares its independent composition variables. A simple substitutional binary may use the mole fraction of one named component, but the schema also permits molality, mass fraction, site fraction, amount, and future custom coordinates.

## Thermodynamic expression

The initial model vocabulary includes an ideal mixing term plus structured Redlich-Kister terms with temperature bases `constant`, `temperature`, and `temperatureLogTemperature`. The schema is intentionally extensible through a versioned model design rather than by storing executable equation strings.

## Human-readable representations

Each phase model declares the paths of its generated TeX and PDF representations. These are derived artifacts: the JSON model remains the sole thermodynamic source of truth.
