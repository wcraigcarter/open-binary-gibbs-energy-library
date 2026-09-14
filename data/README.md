# Data

Each binary system is represented by a self-contained directory.

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

`system.json` records system-level identity and the phase-model files belonging to the system. Each file in `phases/` contains one phase Gibbs-energy model. Files in `rendered/` are generated from the canonical phase-model JSON and are not independent sources of thermodynamic data.

## Validated source-specific assessments

- [Ag-Pt](ag-pt/README.md): Karakaya–Thompson (1987) liquid/FCC model, original unary references, 1238.15–2100 K. Implementation validated with documented Table 6 discrepancies and deferred low-temperature phases.
