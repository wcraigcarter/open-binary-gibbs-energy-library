# OBGEL Schema Conventions

This document defines conventions that OBGEL data readers may rely upon. It is a living schema contract and should grow only as conventions are explicitly decided.

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

Temperature validity is explicit. Temperature segments declare the domains in which they are valid, and a value outside those domains is distinct from a function value of zero.

Endpoint inclusion is data, not reader policy. Each temperature segment carries `minimumTemperature`, `minimumInclusive`, `maximumTemperature`, and `maximumInclusive`. Readers must honor these four fields when constructing the segment's validity interval and must not impose a universal half-open interval convention.
