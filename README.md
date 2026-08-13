# Open Binary Gibbs Energy Library

*Version 0.1.0 — First Public Preview*

*An open, curated collection of empirical Gibbs free-energy models for binary alloys, intended for teaching, numerical experimentation, and computational thermodynamics.*

## Purpose

The Open Binary Gibbs Energy Library (OBGEL) collects documented, reproducible thermodynamic models for binary systems. The emphasis is on explicit molar Gibbs free-energy expressions that can be evaluated, differentiated, and used to construct phase equilibria computationally.

OBGEL is intended primarily for teaching, numerical experimentation, and open scientific software. It is not intended to replace comprehensive industrial CALPHAD databases.

## Design philosophy

OBGEL is guided by provenance, transparency, reproducibility, and pedagogical value. The Gibbs free energy is treated as the fundamental thermodynamic object; phase diagrams and common-tangent constructions are derived consequences of the underlying phase models.

See [Design Philosophy](design-philosophy.md) for the project's principles and [Project Notebook](project-notebook.md) for the reasoning behind important design decisions.

## Canonical data and human-readable equations

The machine-readable JSON representation is the canonical source of truth. TeX equations, PDF model sheets, documentation pages, and language-specific readers are derived representations.

This allows one model to support several uses:

- numerical evaluation in Mathematica or another language,
- symbolic differentiation and chemical-potential calculations,
- interactive visualization,
- direct inspection of the mathematical equation,
- printable teaching material,
- future readers in other programming languages.

The initial information model is documented in [`schemas/`](schemas/).

## Repository organization

```text
open-binary-gibbs-energy-library/
├── README.md
├── design-philosophy.md
├── project-notebook.md
├── contributing.md
├── CHANGELOG.md
├── VERSION
├── bibliography/
├── data/
├── docs/
├── examples/
├── mathematica/
├── schemas/
├── tools/
└── scratch/
```

### Data organization

Each binary system is a self-contained directory under `data/`. System-level metadata is separate from phase-level thermodynamic models, while generated human-readable representations live in `rendered/`:

```text
data/
└── cu-ag/
    ├── system.json
    ├── phases/
    │   └── liquid.json
    ├── rendered/
    │   ├── liquid.tex
    │   └── liquid.pdf
    ├── bibliography.bib
    └── notes.md
```

The JSON phase model is authoritative. The TeX and PDF files are generated views of that model.

## Related project

The [Phase Diagram Tool](https://github.com/wcraigcarter/Phase_Diagram_Tool) is a separate but related project that uses Gibbs free-energy models to visualize free-energy curves, lower convex hulls, common tangents, and phase-diagram construction. The intended dependency direction is one-way: the visualization tool may consume OBGEL, while OBGEL remains independent of the visualization application.

## Version and release status

**Version:** `v0.1.0`  
**Release:** **First Public Preview**

This release establishes the initial repository architecture, design philosophy, project notebook, information model, and provenance conventions. It does not yet attempt broad dataset coverage.

See [`CHANGELOG.md`](CHANGELOG.md) for the release history.

## Scope

OBGEL is intentionally curated rather than comprehensive. Its purpose is to provide transparent thermodynamic models that make important ideas in phase equilibria easier to inspect, compute, teach, and reproduce.

Every addition should answer two questions:

1. **Why is this system useful to include?**
2. **What thermodynamic concept does it help illustrate?**

Quality, provenance, and clarity are valued above completeness.

## License

The licensing model for source code, curated data, and bibliographic material has not yet been finalized. This is an intentional open question recorded in the Project Notebook and should be resolved before the first broader public dataset release.
