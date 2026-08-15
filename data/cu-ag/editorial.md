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

The binary Cu-Ag interaction parameters reproduced in Kusoffsky (2002) are attributed there to a 1998 private communication from H. L. Lukas. NIST identifies the earlier Hayes-Lukas-Effenberg-Petzow work (1986) as a full Cu-Ag thermodynamic assessment and lists Murray (1984) as an additional assessment. For OBGEL, these provenance layers are kept separate: the published Kusoffsky paper is the directly inspectable source of the tabulated Cu-Ag interaction parameters used here; the NIST page provides an independent assessment status and phase-equilibrium check.

## Composition convention

OBGEL uses the first component in the system name as the independent composition variable. Thus

\[
x = x_{\mathrm{Cu}}, \qquad x_{\mathrm{Ag}} = 1-x.
\]

The published interaction parameters in Kusoffsky (2002) are given in the Ag-Cu ordering. The odd Redlich-Kister coefficient is therefore sign-reversed for the OBGEL Cu-Ag convention; even-order coefficients are unchanged.

## Model summary

For either phase,

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
