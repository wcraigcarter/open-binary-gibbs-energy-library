# Design Philosophy

The Open Binary Gibbs Energy Library (OBGEL) is intended to be a **scientific reference library**: an open, curated collection of thermodynamic models chosen for their value in teaching, numerical experimentation, and computational thermodynamics.

It is not a replacement for industrial CALPHAD databases and it is not a phase-diagram visualization application.

## Fundamental object

The Gibbs free energy is the fundamental thermodynamic object. Phase diagrams, common tangents, chemical potentials, convex hulls, and phase equilibria are derived consequences of the thermodynamic models.

Accordingly, OBGEL stores **thermodynamic phase models**, not phase diagrams.

A visualization application may consume OBGEL, but OBGEL does not depend on any particular visualization or user interface.

The intended conceptual chain is:

\[
g(x,T)
\longrightarrow
\mu_i
\longrightarrow
\text{common tangent / convex envelope}
\longrightarrow
\text{phase equilibrium}.
\]

## Provenance before breadth

The library favors a small number of carefully verified, well-documented models over a large collection with uncertain provenance. Whenever possible, a model is traced to the original published thermodynamic assessment.

The goal is not completeness. The goal is clarity, reproducibility, provenance, and pedagogical value.

Every proposed addition should answer:

1. **Why is this system useful to include?**
2. **What thermodynamic concept does it help illustrate?**

## Canonical data and derived representations

The machine-readable JSON representation is the canonical source of truth.

Language-specific readers, TeX equations, PDFs, documentation pages, and other renderings are derived representations. They may be regenerated from the canonical data but do not independently define the thermodynamic model.

This permits one model to support several uses:

- numerical evaluation in Mathematica or another language,
- symbolic differentiation and chemical-potential calculations,
- interactive visualization,
- direct inspection of the mathematical equation,
- printable teaching material,
- future readers in other programming languages.

## Scientific identity and software identity

A thermodynamic phase has a stable machine-readable identifier and a human-facing display name. The identifier is intended to remain stable even when the preferred display name changes.

If a natural or literature-established phase name is unavailable, OBGEL may use a clearly marked best-guess placeholder rather than forcing an application-specific name into the scientific data model.

Applications remain free to override display names for pedagogical or visualization purposes.

## Composition is part of the model definition

The schema does not assume that every thermodynamic model uses a single mole-fraction coordinate. Composition variables are explicitly described by quantity, role, units when applicable, and component association when meaningful.

This allows simple substitutional-binary alloy models to remain simple while leaving room for systems involving molality, site fractions, compounds, or other coordinates.

## Descriptive software names

Scientific quantities and public interfaces should favor descriptive names over abbreviations when the additional characters improve clarity. Algorithmic variables may use concise geometric names when those names accurately describe their role. For example, `chemicalPotential` is scientifically explicit, while `muLeft` and `muRight` are appropriate when referring to the left and right tangent constructions.

Local mathematical variables such as `x`, `T`, and `g` may remain conventional when their scope is small and their meaning is unambiguous.

## Separation of projects

OBGEL and the Phase Diagram Tool are independent but related projects.

OBGEL provides documented thermodynamic models and reference implementations. The Phase Diagram Tool provides visualization and teaching applications, including free-energy curves, lower convex hulls, common tangents, and phase-diagram construction.

The intended dependency direction is:

```text
Open Binary Gibbs Energy Library
              |
              v
      Phase Diagram Tool
              |
              v
        MyST textbook
```

The thermodynamic library remains usable without the visualization tool.

## Teaching as a design criterion

OBGEL is deliberately pedagogical. When several technically valid representations are possible, the preferred representation should make the underlying thermodynamics easier to inspect, differentiate, reproduce, and discuss.

The library is not organized merely as a catalog of alloy systems. It is a collection of thermodynamic ideas illustrated by carefully chosen binary systems.

Examples should therefore be selected to demonstrate distinct concepts such as positive or negative deviations from ideality, eutectic behavior, miscibility gaps, ordering, compound formation, spinodal instability, or other important features of phase equilibria.

## Stewardship and future contribution

OBGEL is intended to be a long-lived scientific reference rather than a fixed dataset. Future contributors are encouraged to add carefully documented thermodynamic models, refine metadata, correct errors, and extend the scope of the collection while preserving the project's guiding principles:

- openness,
- provenance,
- transparency,
- pedagogical value,
- and scientific reproducibility.

Every contribution should make the library more understandable, not merely larger.
