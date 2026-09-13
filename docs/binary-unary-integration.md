# Binary use of canonical unary data

## Thermodynamic separation of responsibilities

For a substitutional binary phase \(\phi\), OBGEL represents

\[
G_m^\phi(T,x)=
x_A G_A^{\phi,0}(T)+x_B G_B^{\phi,0}(T)
+G_{\mathrm{ideal}}(T,x)+G_{\mathrm{excess}}^\phi(T,x).
\]

The canonical unary objects supply the two structural end-member functions
\(G_i^{\phi,0}\). The binary phase object supplies the composition model,
ideal-mixing choice, and binary interaction parameters. Consuming canonical
unary data must not change the ideal or excess contributions.

The end member is selected by structural phase identity, not by whichever unary
phase happens to be stable at the evaluation temperature. An FCC solution uses
the FCC unary function for both components, including a metastable FCC branch
for a component whose stable unary structure is not FCC. The phase JSON records
both the exact unary function key and a human-auditable structural phase name.

## Data interface

The binary system object declares its pinned unary inputs:

```json
"unaryDataSources": [
  {
    "component": "Cu",
    "file": "../unary/cu-standard-reference.json",
    "schemaVersion": "0.2.0",
    "identitySymbol": "Cu"
  }
]
```

Each solution phase then maps its end members explicitly:

```json
"unaryEndmemberReferences": [
  {
    "component": "Cu",
    "function": "fcc",
    "structuralPhase": "FCC-A1"
  }
]
```

The reader verifies the declared unary schema version and material identity,
then resolves the exact function key. It does not infer a function from words
such as `stable`, from the unary stability envelope, or from component order.

Redlich-Kister order is a separate binary concern. The ordered pair in
`redlichKisterComponentOrder` defines

\[
(x_{\mathrm{first}}-x_{\mathrm{second}})^k.
\]

This order is explicit because changing the plotting or independent composition
coordinate must not reverse odd-order terms.

## Validity

The effective evaluation range for a binary solution phase is the intersection
of:

- the binary system validity range;
- the binary phase validity range; and
- every referenced unary object's `systemValidity`.

Within that intersection, a reader must also find an explicitly supplied
temperature segment for every referenced unary function. Unary function-level
`validity` remains model-validity metadata: it is not substituted for unary
`systemValidity`, and it does not exclude an explicit metastable extension
segment supplied within the unary system domain.

No binary system may silently extend a canonical unary function beyond its
declared domain. A broader binary assessment therefore requires either a unary
model with adequate declared coverage or a separately documented,
non-canonical extrapolation chosen by the consumer.

## Compatibility and migration

During migration, a phase may retain `referenceStateContributions` beside
`unaryEndmemberReferences`. The canonical-aware reader prefers the unary
references; a legacy reader continues to use the embedded expressions. The
embedded representation is a regression baseline, not a second source of
truth, and should be removed only in a later explicitly versioned migration
after downstream readers have adopted the canonical interface.

`examples/mathematica/Binary-reference-reader.wl` implements this precedence.
It does not modify or depend on changes to the user's unary teaching reader.

## Symbolic Mathematica interface

The binary reader constructs symbolic `Piecewise` expressions before numerical
evaluation. This permits direct use by symbolic consumers such as the Common
Tangents Tool. The preferred interface is:

```wl
gLiquid = binaryMolarGibbsFreeEnergyFunction[binaryModel]["liquid"];
gFcc = binaryMolarGibbsFreeEnergyFunction[binaryModel]["fcc-a1"];
```

Each result has the form:

```wl
Function[{temperature}, Function[{moleFraction}, expression]]
```

The expression contains the expanded unary, ideal-mixing, and excess terms; it
does not retain a call to `binaryMolarGibbsFreeEnergy`. Consequently it can be
differentiated symbolically or passed directly to CTT. Calls such as
`gLiquid[1053.][0.4]` continue to evaluate numerically from the same expression.

Stoichiometric compounds require a separate composition model. If a compound
polynomial is already expressed relative to weighted elemental SER enthalpies,
canonical unary Gibbs functions must not be added to it. The compound model
must state its reference convention and exact fixed composition directly.

## Querying phase provenance

The distributed reader exposes quiet associations keyed by the existing phase
identifiers (`fcc-a1` is FCC):

```wl
reference = binaryLoadSystemModel["/path/to/data/cu-ag/system.json"];
reference["Provenance Summary"]
reference["Phase Metadata"]["bcc"]
reference["Phase Metadata"]["liquid"]["references"]
```

The summary reports liquid and FCC as `assessed`, with the assessment source
record, and BCC and HCP as `constructed`, with the legacy teaching assumption.
Detailed metadata includes intended uses, canonical unary provenance, binary
interaction provenance, full reference citations, and RK terms with their
`parameterOrigin`. Missing model provenance in older binaries is `unspecified`;
it is never inferred from stability or phase inventory membership.

These queries do not change phase selection or emit evaluation/plotting warnings.
The distributed reader has no constrained-equilibrium selection operation;
consumers can display the metadata when presenting their own phase selectors.
