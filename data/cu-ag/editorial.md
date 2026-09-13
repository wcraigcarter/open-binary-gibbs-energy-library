# Cu-Ag

## Why this system?

Cu-Ag is the first OBGEL exemplar because it exercises several parts of the information model simultaneously while remaining mathematically transparent. It has a substitutional liquid solution, a substitutional FCC solid solution, strongly positive excess Gibbs energy, limited mutual solid solubility, and a simple eutectic.

## What does it teach?

- The distinction between ideal and excess Gibbs energy of mixing.
- Why positive excess Gibbs energy promotes phase separation.
- Why a single FCC solution model can produce Ag-rich and Cu-rich equilibrium phases through a miscibility gap.
- The common-tangent construction across distinct phase models.
- Chemical potentials as the slope/intercept geometry of tangent lines.
- The relationship between the Gibbs-energy curves and the observed eutectic phase diagram.

## Assessment provenance

The assessed liquid/FCC binary Cu-Ag interaction parameters reproduced in Kusoffsky (2002) are attributed there to a 1998 private communication from H. L. Lukas. NIST identifies the earlier Hayes-Lukas-Effenberg-Petzow work (1986) as a full Cu-Ag thermodynamic assessment and lists Murray (1984) as an additional assessment. For OBGEL, these provenance layers are kept separate: the published Kusoffsky paper is the directly inspectable source of the tabulated Cu-Ag interaction parameters used here; the NIST page provides an independent assessment status and phase-equilibrium check.

## Composition convention

OBGEL uses the first component in the system name as the independent composition variable. Thus

\[
x = x_{\mathrm{Cu}}, \qquad x_{\mathrm{Ag}} = 1-x.
\]

The published interaction parameters in Kusoffsky (2002) are given in the Ag-Cu ordering. The odd Redlich-Kister coefficient is therefore sign-reversed for the OBGEL Cu-Ag convention; even-order coefficients are unchanged.

## Model summary

For either assessed phase (liquid or FCC),

\[
G_m = x_{\mathrm{Cu}}G_{\mathrm{Cu}}^0(T)
     +(1-x_{\mathrm{Cu}})G_{\mathrm{Ag}}^0(T)
     +RT\left[x_{\mathrm{Cu}}\ln x_{\mathrm{Cu}}+(1-x_{\mathrm{Cu}})\ln(1-x_{\mathrm{Cu}})\right]
     +x_{\mathrm{Cu}}(1-x_{\mathrm{Cu}})\n\sum_k L_k(T)(2x_{\mathrm{Cu}}-1)^k.
\]

The phase-model JSON contains the piecewise SGTE standard-state functions and the Redlich-Kister excess terms. The complete model is documented to 3000 K here because the pure-element reference functions used by the model are documented to that temperature, even though the binary interaction parameters themselves are tabulated to 6000 K in the reproduced database representation.

## Numerical validation

Using the full liquid and FCC phase models, a numerical three-point common-tangent calculation gives an invariant temperature of approximately 1053.0 K (779.9 C). NIST reports 779.1 C for the Cu-Ag eutectic and gives the corresponding invariant-equilibrium compositions. This close agreement is used as the first independent numerical validation of the OBGEL transcription.

## Editorial status

This entry is the first complete OBGEL exemplar and establishes the editorial standard for subsequent systems. Before the first stable OBGEL release, the provenance and licensing status of privately communicated assessment parameters should be reviewed explicitly.

## Constructed BCC/HCP candidates restored 2026-09-13

The system inventory also includes `bcc` and `hcp`. These are constructed teaching
candidates, **not assessed Cu–Ag binary thermodynamics**. Their functions are

\[
G^\phi=x_{Cu}G_{Cu,canonical}^\phi+(1-x_{Cu})G_{Ag,canonical}^\phi
+8.314T[x_{Cu}\ln x_{Cu}+(1-x_{Cu})\ln(1-x_{Cu})]
+30000x_{Cu}(1-x_{Cu}),\qquad \phi=\mathrm{bcc,hcp}.
\]

The endpoints use canonical structural `bcc` (BCC-A2) and `hcp` (HCP-A3)
functions from the Cu/Ag unary datasets, with their own SGTE/Dinsdale provenance.
The order-zero RK coefficient 30000 J/mol is an **undocumented legacy teaching
assumption** copied from the original CTT examples. No literature citation supports
that binary coefficient in this entry. The retained R=8.314 J/(mol K) is also labeled
as a legacy teaching value; assessed liquid/FCC retain their existing R and RK values.
The explicit independent coordinate is xCu; RK component order is Cu, Ag.

System provenance labels liquid/FCC as assessed and BCC/HCP as constructed. Candidate
files separately record unary endpoint provenance, binary interaction provenance,
model provenance, intended uses, and term-level origin. Their display names expose
“constructed”; selection is controlled by phase inventory and the consuming workflow,
not by provenance. Reloading system.json with the existing binary reader exposes all
four nested `function[T][x]` expressions. No notebook/interface changes are required
for data availability; an interface with a hard-coded phase list must select the new
identifiers itself. Candidate TeX/PDF representations are declared not generated.

Historical BCC/HCP/FCC coefficients are preserved in
[the historical regression artifact](../../docs/audits/cu-ag-legacy-teaching-functions.wl).
They are unsegmented formulas, distinct from the assessed liquid/FCC model. Canonical
substitution changes their energies slightly at low temperature and changes their
continuation above unary segment boundaries; no compensating unary corrections are
introduced. See [the restoration regression](../../docs/audits/cu-ag-candidate-restoration.md)
for energies, derivatives, constrained examples, and the ordinary-envelope check.
The user's 1053–1054 K, xCu just above 0.4 visual eutectic observation remains preliminary;
precise verification metadata in the assessed phase files is unchanged.

## Reading model status and constrained results

| Phase identifier | Model status | Binary interaction provenance |
|---|---|---|
| `liquid` | assessed | Parameters reproduced by Kusoffsky (2002); assessment context and NIST check described above |
| `fcc-a1` (FCC) | assessed | Same assessment/source chain as liquid |
| `bcc` | constructed | Legacy teaching assumption, order-zero RK term |
| `hcp` | constructed | Legacy teaching assumption, order-zero RK term |

**Constructed candidate phase:** The BCC and HCP Cu-Ag functions are provided for
teaching, visualization, and constrained-equilibrium experiments. Their unary end
members use the canonical Cu and Ag unary thermodynamics, but their binary excess
Gibbs energy uses the legacy assumption G^ex = 30000 x_Cu x_Ag J/mol. No assessed
Cu-Ag source has been identified for this interaction parameter. Results that
depend on BCC or HCP should therefore be interpreted as predictions of a
constructed teaching model, not as assessed Cu-Ag phase equilibria. Metastability
alone does not make a phase unphysical; the distinction here concerns the origin
of the binary interaction thermodynamics.

**Constrained equilibrium example:** The supplied visual observation described
liquid -> Cu-rich BCC + Ag-rich BCC near 978–979 K with liquid x_Cu approximately
0.36 after excluding assessed FCC. Direct validation of the current distributed
reader instead identifies **HCP** on both solid branches: T = 978.0253560 K,
x_Cu = 0.0302990158 (Ag-rich HCP), 0.3301214250 (liquid), and 0.9697009842
(Cu-rich HCP). The common tangent supports liquid, BCC, and HCP when FCC is
excluded. The reported visual phase labels/composition are therefore not a
verified result of this reader. With HCP also excluded, the liquid/BCC/BCC
tangent occurs at 838.5418525 K and liquid x_Cu = 0.2351685168; HCP undercuts
that tangent if included. These thermodynamic thought experiments are results
of constructed models, **not validated Cu-Ag phase-diagram predictions**.

Separately, the authoritative [assessed-model regression](../../docs/audits/cu-ag-unary-integration-regression.md)
retains T = 1053.0155581 K, with x_Cu = 0.1314370734 (Ag-rich FCC),
0.4028983784 (liquid), and 0.9550042894 (Cu-rich FCC). The constrained example
and visual estimates do not replace those verification values.

Load the distributed `.wl` reader and query `reference["Provenance Summary"]`
or `reference["Phase Metadata"]` as shown in the
[reader documentation](../../docs/binary-unary-integration.md#querying-phase-provenance).
