# OBGEL Schema Conventions

This document defines conventions that OBGEL data readers may rely upon. It is a living schema contract and should grow only as conventions are explicitly decided.

Schema-family versions and compatibility rules are defined in
[`../schemas/VERSIONING.md`](../schemas/VERSIONING.md). Schema changes are
recorded in [`../schemas/CHANGELOG.md`](../schemas/CHANGELOG.md).

## Collections

Fields that represent collections are always JSON arrays, regardless of cardinality. Zero items are represented by an empty array where permitted, one item by an array containing one value, and multiple items by a longer array.

In particular, both `temperatureSegments` and `terms` are always arrays. A collection with one temperature segment or one term uses an array of length one, not a bare object. Where an empty collection is permitted, it is represented by `[]`.

## Temperature Basis Terms

OBGEL uses one mathematical basis-term representation throughout unary reference functions, binary reference-state contributions, temperature-dependent Redlich-Kister coefficients, and other temperature-dependent functions. Each term is an object with a `basis` from the controlled vocabulary and a numerical `coefficient`:

- `constant` represents \(1\);
- `temperature` represents \(T\);
- `temperatureLogTemperature` represents \(T \ln T\), where `ln` is the natural logarithm;
- `temperaturePower` represents \(T^n\) and requires an `exponent` field containing \(n\).

Thus every term has the value `coefficient * basis(T)`. The `exponent` field is used only with `temperaturePower`; it is not supplied for the other basis types. Positive, zero, and negative exponents are permitted. Although `temperaturePower` with exponent zero is mathematically valid, `constant` is the preferred canonical representation of a constant term.

For example:

```json
{
  "basis": "temperaturePower",
  "coefficient": -0.00365895,
  "exponent": 2
}
```

Readers should implement this vocabulary once and apply it consistently wherever OBGEL data contains temperature-dependent terms. Alternate spellings or expression fragments such as `1`, `T`, `T*ln(T)`, or `T^3` are not basis identifiers.

## Function Dependencies and Reference Semantics

`baseFunction` denotes mathematical dependency only. Its presence or absence must not be interpreted as a statement about phase stability or reference-state semantics.

When a phase's molar Gibbs-energy function is defined relative to a reference function, the enclosing function object includes a `baseFunction` naming that reference. `baseFunction` is specified once at the function level; individual temperature segments contain only segment-specific information and do not repeat the reference-function dependency. The `terms` field retains the common basis-term representation described above.

Standard reference semantics are expressed through explicit metadata. Readers must not infer that a function is the standard reference from the absence of `baseFunction`.

## Temperature Validity

Temperature validity is explicit and has three distinct levels.

`systemValidity` is a required property of each canonical unary dataset as a whole. It declares the overall temperature domain over which the encoded OBGEL object claims usability, even when that interval happens to equal every function-level validity interval. It does not, by itself, claim that an underlying source or authoritative formulation ceases to be valid at either bound.

In addition to `minimumTemperature`, `maximumTemperature`, and `unit`, `systemValidity` records why its bounds exist:

- `basis` is a controlled string. Its initial vocabulary is `sourceLimited`, when the adopted source supplies or limits the represented interval; `modelLimited`, when the adopted OBGEL construction limits the usable interval; and `intentionalDatasetScope`, when OBGEL deliberately represents only part of a broader source/model domain.
- `rationale` is a human-readable provenance statement that identifies the applicable source, construction choice, or scope decision and records material audit qualifications. It must not imply a stronger provenance claim than the source record supports.

`basis` is presently singular. If independent constraints jointly determine a future interval, the rationale must record that fact and the schema should be extended deliberately; ad hoc strings or an unannounced scalar-or-array union are not permitted.

Canonical OBGEL data do not implicitly extrapolate beyond `systemValidity`. A consumer may extrapolate beyond it for a particular analysis, but that operation is outside the canonical model and must be requested and identified explicitly.

The function-level `validity` field declares the range over which that phase's underlying thermodynamic model is physically supported by the adopted construction. It is model validity, not a claim that the phase is stable throughout the interval and not necessarily the complete range over which the function can be evaluated.

`temperatureSegments` declare the intervals over which the supplied mathematical expressions are evaluated. When comparison of all candidate phases across `systemValidity` requires values outside an individual function's model-validity interval, the JSON may encode explicit metastable-extension expressions as ordinary temperature segments within `systemValidity`. Such segments are mathematical assumptions used to make the comparison well-defined; they do not assert that the extended phase is physically realizable or that the underlying fitted thermodynamic model is valid there. Extension segments do not enlarge either the function-level model validity or `systemValidity`.

Readers must therefore use `systemValidity` for the dataset's usable temperature domain, use each function's `validity` as model-validity metadata, and evaluate the expressions supplied by `temperatureSegments` only on their declared intervals. They must not infer the system range by intersecting function-level validity ranges, and they must not silently manufacture expressions outside `systemValidity`.

Temperature segments declare evaluation domains, and a value outside those domains is distinct from a function value of zero.

When an explicit metastable extension uses the first-order tangent convention at an attachment temperature \(T_b\),

\[
G_{\mathrm{ext}}(T)=G(T_b)+G'(T_b)(T-T_b).
\]

This construction preserves both \(G\) and \(dG/dT\) at \(T_b\). Because the extension is linear, it has \(d^2G_{\mathrm{ext}}/dT^2=0\) and therefore implies \(C_p=-T\,d^2G_{\mathrm{ext}}/dT^2=0\) in the extension interval. That consequence belongs to the mathematical construction; it is not a physical heat-capacity claim or evidence for physical metastability.

The provenance or status category `extension-derived` identifies a computed quantity whose value depends on an explicit extension assumption. Examples include crossings between branches when one or both branches are evaluated on tangent-extension segments. Such a quantity may be numerically reproducible from the encoded model, but it must remain distinguishable from a source observation, a model-derived quantity that does not depend on the extension, and a construction constraint.

Endpoint inclusion is data, not reader policy. Each temperature segment carries `minimumTemperature`, `minimumInclusive`, `maximumTemperature`, and `maximumInclusive`. Readers must honor these four fields when constructing the segment's validity interval and must not impose a universal half-open interval convention.

## Unary Identity and Fixed Conditions

A unary object describes one pure substance of fixed overall composition. The substance may be an element, such as Pb, or a fixed-composition compound, such as H2O or NaCl. The preferred descriptive terms are **pure-substance unary** and, for the latter case, **fixed-compound unary**. These do not require a new `objectType`: the existing unary object can distinguish them through identity metadata while retaining the same function, validity, and reader conventions.

When a unary model is evaluated at a fixed pressure, `systemConditions.pressure` records that thermodynamic pressure explicitly. For a pure-substance unary object, pressure is the thermodynamic pressure of the pure substance. For a pure vapor it is therefore also the vapor species' partial pressure (for pure H2O vapor, `p_H2O`). A multicomponent or inert-gas atmosphere would separate total pressure from species partial pressure and lies outside that unary object. Chemical reactions, dissociation, oxidation, and other externally imposed chemical environments likewise require a different model and must not be inferred from the unary pressure condition.

## Phase Identity and Source Qualifications

Function keys and other canonical phase identifiers describe phase or structure
identity. Source-specific thermodynamic or model qualifications do not create a
new phase identifier merely because the source prints the qualification beside
the phase name. Those qualifications belong in source/model provenance
metadata, where the source wording can be preserved without changing the
canonical identity.

For Zn, for example, Dinsdale's exact designation
`HCP_A3 (Zn non ideal)` is retained as `sourcePhaseDesignation` and in the
source-to-repository mapping, while the canonical function key remains `hcp`.
This records both facts: the modeled structure is HCP, and the source applies a
specific thermodynamic qualification to its Zn reference treatment.

## Verification Metadata

Verification metadata records derived checks on a thermodynamic model. It is non-model-defining: coefficients, basis terms, dependencies, validity intervals, and other model data must be sufficient to evaluate the model without consulting verification results. Conversely, every computed verification result must be reproducible from the underlying model data.

Status vocabulary must preserve independent evidence axes. `source-transcription-audited` means that literal values and visible annotations were checked against the available source reproduction; it does not imply that every bibliographic location or cited subordinate reference was independently recovered. `assumption-dependent` identifies a model whose construction choices are explicit but not established uniquely by the source observations. `implementation-verified` means that the encoded representation passed the stated structural and numerical checks; it validates the implementation of the adopted construction, not the physical truth of its assumptions. These categories may be combined, but none substitutes for the others.

When a literature or other source value and a value computed from the encoded model are both available, they are recorded separately as `sourceValue` and `computedValue`. This preserves the distinction between what a source reports and what the OBGEL representation produces. Provenance and audit status must be explicit for each value, and only information that has actually been checked may be marked as validated or audited.

Equilibrium transition identity is direction-neutral and describes the stable phases immediately on either side of the transition temperature:

```json
{
  "transition": {
    "lowTemperaturePhase": "stableReference",
    "highTemperaturePhase": "metastableLiquidReference"
  }
}
```

The phase identifiers are keys from the model's `functions` object. Transition identity does not use `from` and `to`, which imply a heating or cooling direction, and does not rely on a process-dependent label such as `melting`. The structure therefore applies equally to solid-solid and solid-liquid transitions and does not imply a kinetic path.

A computed verification value documents the physical or mathematical condition and a language-independent method, for example `numerical root of equal Gibbs energies`. It must not require a particular programming language, library, or software routine. Implementation-specific details may be retained in a separate audit trail, but they are not the verification method or part of the thermodynamic model.
