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

The model vocabulary includes canonical unary end-member references, a
backward-compatible embedded reference-state representation, an ideal mixing
term, and structured Redlich-Kister terms. The common temperature bases are
`constant`, `temperature`, `temperatureLogTemperature`, and
`temperaturePower`.

Binary phases select unary functions by explicit structural identity. The
ordered component pair for Redlich-Kister powers is also explicit, so odd-order
signs do not depend on the chosen composition coordinate. See
[`../docs/binary-unary-integration.md`](../docs/binary-unary-integration.md).

## Human-readable representations

Each phase model declares the paths of its generated TeX and PDF representations. These are derived artifacts: the JSON model remains the sole thermodynamic source of truth.
