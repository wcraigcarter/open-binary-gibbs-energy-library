# Examples

Small examples demonstrating how to read and use the library data belong here. Examples should consume the canonical data rather than duplicating thermodynamic parameters.

`mathematica/Binary-reference-reader.wl` assembles binary solution-phase Gibbs
energies from canonical unary end-member functions plus the binary ideal and
Redlich-Kister contributions. It retains a fallback for older phase files that
contain only embedded reference-state expressions. Its
`binaryMolarGibbsFreeEnergyFunction` constructor returns the nested symbolic
function form required by the Common Tangents Tool.
