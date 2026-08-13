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
