# Unary Reference Reader Development Notes

## Purpose and status

These notes record the evolving design of the Mathematica unary-reference reader. The reader is a development exemplar: it demonstrates how canonical OBGEL unary JSON is interpreted, provides visual and numerical checks, and may eventually inform common reader/package functions. It is not yet a frozen schema or package interface.

Repository-wide conclusions belong in the durable documentation under `docs/` or in `implementation-observations.md`. This file is for design choices and open questions specific to the unary reader.

## Current artifacts

- `working/unary/Pb_Standard_Reference.json` is the canonical machine-readable development exemplar used by the reader.
- `examples/mathematica/Unary-reference-reader.nb` is the executable and visual development exemplar.
- `examples/mathematica/Unary-reference-reader.wl` is the plain-text export used for code review and diffs.

The notebook derives the repository root from its location with:

```mathematica
ParentDirectory[ParentDirectory[NotebookDirectory[]]]
```

This remains valid while the notebook is stored in `examples/mathematica/`.

## Current reader architecture

The current flow is:

```text
canonical unary JSON
    -> imported associations
    -> temperature-basis expressions
    -> piecewise expressions over explicit validity intervals
    -> base-function dependency resolution
    -> Function[{T}, ...] objects
    -> common valid-temperature range plus phase-function association
    -> separately computed stability envelope and transition data
```

The imported JSON remains source data. The reader constructs derived Wolfram Language expressions and functions without modifying the imported association.

The temperature basis vocabulary is interpreted through a single association of basis functions. Each temperature segment is converted to an expression from its `terms`, and its interval is constructed from the explicit minimum/maximum temperatures and endpoint-inclusion flags stored in the JSON.

## `baseFunction` handling

The current implementation deliberately separates expression construction from dependency resolution.

First, `molarGibbsReferenceFunction` constructs a piecewise expression for each JSON function. A derived function retains its string-valued `baseFunction` identifier as an additive dependency. Then `molarGibbsReference` identifies the root function, obtains its name and expression, replaces that identifier in the derived expressions, and only afterward wraps the resolved expressions in `Function[{T}, ...]` objects.

This is rule-based symbolic dependency resolution rather than recursive construction of self-referential function associations.

### Current assumption

The implementation assumes that all derived unary phase-reference functions depend directly on one root reference function. The root is currently identified as the function with no `baseFunction` field.

This assumption is an implementation limitation, not an OBGEL schema rule. In particular, absence of `baseFunction` must not be used generally to infer stability or standard-reference semantics; those meanings belong in explicit metadata.

The single-root approach is appropriate for the Pb development exemplar and should remain in place until an actual unary dataset demonstrates that more general dependency handling is needed.

### Possible future generalization

If future unary data contain chained or multiple dependencies, for example `A -> B -> C`, generalize the current substitution step into dependency-graph resolution:

1. Construct all functions as symbolic expressions containing explicit dependency placeholders.
2. Repeatedly resolve dependency identifiers until each expression is fully expanded.
3. Detect missing dependencies and cycles rather than allowing unresolved expressions.
4. Construct `Function[{T}, ...]` objects only after resolution is complete.

This preserves the useful separation already present in the reader and avoids requiring an association to self-reference. The generalization should be implemented only when supported by a concrete dataset and tests.

## `molarGibbsReference` result

`molarGibbsReference` returns an association with two entries:

- `"Valid Temperature Range"` is the common range over which all returned phase functions are valid. Its lower bound is the greatest minimum temperature among the JSON functions, and its upper bound is the least maximum temperature.
- `"functions"` is an association of phase/reference identifiers to unary `G(T)` functions. It preserves the stable-reference, liquid, and other metastable branches rather than discarding functions that do not lie on the stable envelope.

Keeping the common range alongside the individual functions supports:

- inspection of metastable phase functions;
- transition-temperature calculations from function crossings;
- visual debugging around breakpoints and crossings; and
- later uses in teaching or nucleation calculations where metastable functions matter.

## `stabilityEnvelope` result

`stabilityEnvelope` operates on the association returned by `molarGibbsReference`. It identifies the minimum-energy phase on a temperature grid over the common valid range, refines each detected phase crossing numerically, and returns an association containing:

- `"Stable Phase at Temperature"`, a callable zero-order interpolation that returns the identifier of the stable phase at a supplied temperature; and
- `"Transitions"`, a list of transition associations.

Each transition association contains `"Transition Temperature"` and a nested `"Phases"` association. The latter records the phase identifiers under `"Low Temperature"` and `"High Temperature"`.

The envelope is intentionally a pure-element stability result rather than a common-tangent or multiphase-mixture calculation.

## Pb and Bi validation

The same reader and stability-envelope functions operate unchanged on the canonical Pb and Bi unary JSON files.

- Pb reproduces the stable-reference-to-liquid transition at 600.612 K.
- Bi reproduces the stable-reference-to-liquid transition at 544.52 K.
- The additional metastable Bi FCC-A1 and HCP-A3 branches remain available in the phase-function association but do not enter the stable envelope.

## JSON/function separation

The JSON stores identifiers, metadata, coefficients, basis terms, validity intervals, and dependencies. It does not store executable Mathematica functions. The reader is responsible for translating that canonical representation into Wolfram Language expressions and functions.

This separation should be retained: canonical OBGEL JSON is the thermodynamic data representation, while Mathematica functions, plots, and notebook outputs are derived representations.

## Validation direction

The notebook now exercises both Pb and Bi through the same reader. The next strong architectural test should use a unary dataset whose dependencies or phase topology differ materially from these two examples. Until such a dataset requires it, the single-root implementation should remain in place and chained or general dependency resolution should remain deferred future work.
