# Cu–Ag candidate restoration regression — 2026-09-13

The assessed liquid/FCC files and all canonical unary, reader, notebook and interface
files were preserved byte-for-byte relative to the start of this restoration.
Existing uncommitted work was retained. No commit or push was made.

BCC/HCP use canonical structural endpoints, legacy R=8.314 J/(mol K), and one
order-zero RK coefficient L0=30000 J/mol. The latter is explicitly an undocumented
legacy teaching assumption, not an assessed parameter. No supporting citation is
invented. See the Cu–Ag editorial note and schema README for metadata semantics.

## Historical versus restored

Differences are restored minus historical. Energies and dG/dxCu are J/mol;
dG/dT differences are J/(mol K). Full results include xCu=0.1,0.4,0.9 at
500,1053,1200,1600 K in `cu-ag-candidate-regression.json`.

| Phase | T (K) | xCu | Old G | Restored G | Delta G | Old dG/dxCu | Restored dG/dxCu | Delta dG/dT |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| bcc | 500.00000000 | 0.40000000 | -13353.06020808 | -13351.77901469 | 1.28119339 | 9561.39691850 | 9561.30586588 | 0.00686375 |
| bcc | 1053.00000000 | 0.40000000 | -52145.57091702 | -52137.75847542 | 7.81244160 | 12992.22351332 | 12991.95220308 | 0.01676338 |
| bcc | 1200.00000000 | 0.40000000 | -64114.20864224 | -64103.73871615 | 10.46992609 | 13959.72569678 | 13959.39730639 | 0.01939201 |
| bcc | 1600.00000000 | 0.40000000 | -99364.55627772 | -99336.90190311 | 27.65437461 | 16831.96413956 | 16806.52489073 | 0.11807975 |
| hcp | 500.00000000 | 0.40000000 | -15879.86220808 | -15882.57901469 | -2.71680661 | 9296.89691850 | 9296.80586588 | -0.01113625 |
| hcp | 1053.00000000 | 0.40000000 | -53886.52673702 | -53898.78247542 | -12.25573840 | 12785.78851332 | 12785.51720308 | -0.02335662 |
| hcp | 1200.00000000 | 0.40000000 | -65644.21064224 | -65660.13871615 | -15.92807391 | 13768.72569678 | 13768.39730639 | -0.02660799 |
| hcp | 1600.00000000 | 0.40000000 | -100316.15827772 | -100336.50190311 | -20.34362539 | 16682.96413956 | 16657.52489073 | 0.05607975 |

At 1053 K, delta(dG/dxCu) is -0.27131024 J/mol for both candidates.
These changes arise from the notebook's independently rounded/transcribed endpoint
coefficients; the BCC and HCP quadratic coefficients differ as well. They should not
be described solely as last-digit rounding. Above 1234.93/1357.77 K, canonical
piecewise continuation also contributes, while the old examples continue a single
low-temperature expression. R and L0 match the historical candidates exactly.
The artifact `cu-ag-legacy-teaching-functions.wl` preserves the literal BCC/HCP/FCC
coefficients (only symbols renamed), including endpoint x log x = 0.

## Ordinary equilibrium envelope

For 298.15–650 K each candidate is above the line joining the pure FCC endpoints.
For 650–3000 K each is above homogeneous assessed FCC. Subtracting the common FCC
unary functions leaves differences affine in T. Therefore positive minima over x
at both temperature endpoints bound each complete interval. The comparison includes
the R difference from assessed FCC. Numerical global one-variable minimizations give:

| Candidate | Reference | T (K) | Minimum margin (J/mol) |
|---|---|---:|---:|
| bcc | fccEndpointChord | 298.15 | 3086.93151921 |
| bcc | fccEndpointChord | 650.0 | 2697.95948586 |
| bcc | homogeneousFcc | 650.0 | 2737.10649067 |
| bcc | homogeneousFcc | 3000.0 | 250.00000000 |
| hcp | fccEndpointChord | 298.15 | 389.43267616 |
| hcp | fccEndpointChord | 650.0 | 474.52079575 |
| hcp | homogeneousFcc | 650.0 | 320.70528906 |
| hcp | homogeneousFcc | 3000.0 | 1200.00000000 |

The composition endpoints have positive lattice-stability margins as well.
The analytic differences were checked against actual reader functions across unary
segment boundaries. This establishes non-intrusion within the declared range to
numerical minimization precision, rather than relying only on a sampled phase diagram.
The ordinary convex envelope is unchanged because its original phase functions are
unchanged and neither added phase can lie below it. No unexpected intrusion occurred.

The existing `tools/cu-ag-unary-regression.wl` also passed, including the assessed
energies, boundaries, topology and nested symbolic-function interface. Its recalculated
canonical eutectic is 1053.0155580717 K with xCu=(0.13143707336,
0.40289837839,0.95500428936) for Ag-rich FCC, liquid, Cu-rich FCC. This is a solver
regression, not a new measurement of the user's CTT session. Existing verification
metadata and the user's preliminary visual observation have not been overwritten.

## Constrained equilibria

Each row lists refined common-tangent endpoint compositions, in phase order.
A 2001-composition lower hull supplies starting brackets, followed by analytic
composition-derivative root solving and supporting-line minimization against every
allowed phase. These are selected examples, not a complete constrained phase diagram.

| Allowed phases | T (K) | Coexisting phases | xCu endpoints |
|---|---:|---|---|
| liquid,bcc,hcp | 800.0 | hcp/hcp | 0.0121142784, 0.9878857216 |
| liquid,bcc,hcp | 1053.0 | hcp/liquid | 0.0199817350, 0.1524895715 |
| liquid,bcc,hcp | 1053.0 | liquid/hcp | 0.5753475026, 0.9698974071 |
| liquid,bcc,hcp | 1200.0 | liquid/hcp | 0.9101159330, 0.9866006012 |
| bcc,hcp | 800.0 | hcp/hcp | 0.0121142784, 0.9878857216 |
| bcc,hcp | 1053.0 | hcp/hcp | 0.0413550430, 0.9586449570 |
| bcc,hcp | 1200.0 | hcp/hcp | 0.0700738607, 0.9299261393 |
| liquid,bcc | 800.0 | bcc/bcc | 0.0121142784, 0.9878857216 |
| liquid,bcc | 1053.0 | liquid/bcc | 0.9664070016, 0.9956592288 |
| liquid,bcc | 1200.0 | single liquid |  |
| liquid,fcc-a1,bcc,hcp | 800.0 | fcc-a1/fcc-a1 | 0.0333417293, 0.9916877748 |
| liquid,fcc-a1,bcc,hcp | 1053.0 | fcc-a1/fcc-a1 | 0.1314279209, 0.9550082021 |
| liquid,fcc-a1,bcc,hcp | 1200.0 | fcc-a1/liquid | 0.0307674513, 0.0636570731 |
| liquid,fcc-a1,bcc,hcp | 1200.0 | liquid/fcc-a1 | 0.7647902676, 0.9595979112 |

Largest tangent residual is below 6e-10 J/mol; supporting-line violations are below
2e-11 J/mol (floating-point noise). At the selected temperatures HCP suppresses BCC
when both are allowed; excluding HCP as well demonstrates BCC participation.

## Validation and reproduction

Run `wolframscript -file tools/cu-ag-candidate-regression.wl` from any directory.
It writes the detailed JSON report here and exits nonzero on failed checks.
It validates endpoint equality, reversed independent coordinate xAg, actual-reader
agreement with the affine envelope expressions, and the common-tangent conditions.
Run `wolframscript -file tools/cu-ag-unary-regression.wl` for the assessed regression.
JSON Schema Draft 2020-12 validation covers system.json and all four phase records.
The unchanged reader supplies BCC/HCP symbolic nested functions; no CTT GUI session
was modified or exercised. All validation computations use Mathematica; Python is
used only for schema validation, file integrity, and documentation/data serialization.

## Exact files changed by this restoration

Repository: `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library`

- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/data/cu-ag/phases/bcc.json`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/data/cu-ag/phases/hcp.json`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/data/cu-ag/system.json`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/data/cu-ag/editorial.md`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/schemas/thermodynamic-phase-model.schema.json`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/schemas/system.schema.json`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/schemas/README.md`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/schemas/CHANGELOG.md`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/tools/README.md`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/tools/cu-ag-candidate-regression.wl`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/docs/audits/cu-ag-legacy-teaching-functions.wl`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/docs/audits/cu-ag-candidate-regression.json`
- `/Users/ccarter/MIT Dropbox/Craig Carter/Projects/open-binary-gibbs-energy-library/docs/audits/cu-ag-candidate-restoration.md`

Seven existing files were updated and six files added. Changes shown below in assessed
phase files, unary reader/notebook files, and other unlisted files predate this task.
Protected-file SHA-256 comparison found zero changed files. The scoped whitespace
check passes; the repository-wide check reports existing whitespace in the unchanged
Mathematica notebook. No files are staged.

```text
 M data/cu-ag/editorial.md
 M data/cu-ag/phases/fcc-a1.json
 M data/cu-ag/phases/liquid.json
 M data/cu-ag/system.json
 M docs/README.md
 M examples/README.md
 M examples/mathematica/Unary-reference-reader.nb
 M examples/mathematica/Unary-reference-reader.wl
 M implementation-observations.md
 M schemas/CHANGELOG.md
 M schemas/README.md
 M schemas/schema-overview.md
 M schemas/system.schema.json
 M schemas/thermodynamic-phase-model.schema.json
 M tools/README.md
 M working/unary/Unary-reference-reader-development-notes.md
?? data/cu-ag/phases/bcc.json
?? data/cu-ag/phases/hcp.json
?? docs/audits/cu-ag-candidate-regression.json
?? docs/audits/cu-ag-candidate-restoration.md
?? docs/audits/cu-ag-legacy-teaching-functions.wl
?? docs/audits/cu-ag-unary-integration-regression.md
?? docs/audits/mg-pb-unary-integration-deferred.md
?? docs/binary-unary-integration.md
?? examples/mathematica/Binary-reference-reader-interface.nb
?? examples/mathematica/Binary-reference-reader.wl
?? tools/cu-ag-candidate-regression.wl
?? tools/cu-ag-unary-regression.wl
```
