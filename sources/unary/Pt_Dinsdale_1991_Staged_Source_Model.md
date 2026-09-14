# Platinum unary: Dinsdale 1991 validated model

Status: canonical implementation verified and promoted on 2026-09-14 after automated checks and the owner-reported FCC → liquid reader transition at 2041.5 K. Ag-Pt binary validation is a separate issue.

Source: A. T. Dinsdale, “SGTE data for pure elements,” CALPHAD 15 (1991), 317-425, DOI [10.1016/0364-5916(91)90030-N](https://doi.org/10.1016/0364-5916(91)90030-N). Direct visual audit: transition table p.324; absolute Gibbs functions p.388; BCC/HCP functions and lattice stabilities p.389. The existing local source PDF SHA256 is recorded in the candidate. Dinsdale attributes FCC/liquid to his unpublished work and BCC/HCP to Saunders et al.

## Model

Units: T in K, G-H_SER in J/mol; natural logarithms. FCC is the SER phase at 298.15 K. Ambient pressure is represented using the repository's 1-bar convention; there is no pressure dependence. All four phases cover 298.15–4000 K. No magnetic term is present in the printed Pt description. All functions are flattened absolute G-H_SER functions; no coefficients were fitted.

FCC expressions:

- 298.15–1300 K: -7595.631 + 124.388275 T - 24.5526 T ln(T) - 0.00248297 T² - 0.000000020138 T³ + 7974/T.
- 1300–2041.5 K: -9253.174 + 161.529615 T - 30.2527 T ln(T) + 0.002321665 T² - 0.000000656946 T³ - 272106/T.
- 2041.5–4000 K: -222048.216 + 1019.358919 T - 136.192996 T ln(T) + 0.020454938 T² - 0.000000759259 T³ + 71539020/T.

Liquid expressions:

- 298.15–600 K: 12518.385 + 115.113092 T - 24.5526 T ln(T) - 0.00248297 T² - 0.000000020138 T³ + 7974/T.
- 600–2041.5 K: 19023.49 + 32.94182 T - 12.3403769 T ln(T) - 0.011551507 T² + 0.000000931516 T³ - 601426/T.
- 2041.5–4000 K: 1404.468 + 205.858962 T - 36.5 T ln(T).

BCC = FCC + 15000 - 2.4 T. HCP = FCC + 2500 + 0.1 T.

## Source precision

The model uses the absolute G-H_SER liquid/FCC expressions, rather than the separately rounded liquid-minus-FCC column on p.389. For example, subtracting the printed absolute expressions gives an inverse-temperature coefficient -609400 below 1300 K, while the relative column prints -609399. Such rounding differences are retained by this explicit source-selection rule, not fitted away. Segment intervals are lower-inclusive and upper-exclusive except for the final upper bound. Rounded source segment jumps are preserved.

## Validation

The Mathematica builder writes the candidate and then imports it independently for term-based evaluation. Ten automated checks pass: JSON round trip, phase completeness, source/JSON numerical equivalence, G and derivative continuity tolerances, stable sequence, melting, fusion entropy, fusion heat capacity and out-of-range behavior. This is not formal unary JSON Schema validation; the repository has no dedicated unary schema.

- Stable sequence on a 3001-point grid plus segment boundaries: FCC then liquid.
- Melting root: 2041.499821834243 K; energy residual 2.91e-11 J/mol.
- Printed transition temperature: 2041.50 K.
- Fusion entropy at 2041.5 K, using high-temperature branches: 10.86211628 J/(mol K); printed 10.8621.
- Fusion enthalpy: 22175.00558 J/mol; printed 22175.00.
- Fusion heat capacity: -0.83173548 J/(mol K); printed -0.8317.
- Maximum direct source/JSON residual: 1.87e-9 J/mol.
- Maximum segment G jump: 0.001794 J/mol; maximum first-derivative jump: 4.14e-6 J/(mol K).

The owner supplied the reader result FCC → liquid at 2041.5 K and explicitly authorized validation and promotion on 2026-09-14. This evidence verifies the reported melting transition; additional reader checks are not inferred. No owner notebook or reader was edited. Canonical phase functions are unchanged from the staged candidate.

The Karakaya–Thompson (1987) Ag-Pt unary comparison is complete: at 1459.15 K this Pt model gives G_fcc − G_liquid = −6241.609 J/mol versus −5558.368 J/mol in the binary paper. Thus promotion does not authorize silently substituting this unary into that assessment. The original source-specific unary functions are required for faithful reproduction.

Canonical model: [pt-standard-reference.json](../../data/unary/pt-standard-reference.json). The canonical file records the validation results and staged-candidate SHA256. Local diagnostic artifacts remain under `working/unary-pt/`.
