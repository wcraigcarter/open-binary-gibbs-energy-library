(* ::Package:: *)

(* ::Title:: *)
(*Open Binary Gibbs Energy Library: Unary Reference Reader*)


(* ::Subtitle:: *)
(*Development exemplar \[LongDash] this notebook is intended to demonstrate the current OBGEL JSON reader and will evolve with the schema and reference implementation.*)


(* ::Section:: *)
(*Purpose*)


(* ::Text:: *)
(*discussion of purpose to appear here.*)


(* ::Subsection:: *)
(**)


(* ::Section:: *)
(*Assumption*)


(* ::Text:: *)
(*Current unary-reader assumption:*)
(**)
(*All derived unary phase-reference functions share a single*)
(*root reference function. The root is the function having no*)
(*baseFunction.*)
(**)
(*Dependencies are resolved symbolically by replacing the*)
(*baseFunction identifier with the root reference expression*)
(*before constructing Function[{T}, ...] objects.*)
(**)
(*If future unary data require chained or multiple base-function*)
(*dependencies, replace this single-root substitution with a*)
(*general dependency-resolution step.*)


(* ::Section:: *)
(*Setup and data loading*)


(* ::Text:: *)
(*Run this section first. The path is derived from the notebook location so that the exemplar can live inside the repository without hard-coded user-specific paths.*)


(* ::Subsubsection:: *)
(*Library Location:*)


(* ::Input:: *)
(*ParentDirectory[ParentDirectory[NotebookDirectory[]]]*)


obglLibrary = ParentDirectory[ParentDirectory[NotebookDirectory[]]];

If[DirectoryQ[obglLibrary],
$OBGELBaseDirectory = obglLibrary,
Print["OBGEL directory not found: ", obglLibrary]
];


(* ::Subsubsection:: *)
(*Loading Data*)


With[
{
unaryPbJSON =FileNameJoin[{obglLibrary,"working","unary","Pb_Standard_Reference.json"}]
},

Which[
FileExistsQ[unaryPbJSON],
jsonDataUnaryPb = Import[unaryPbJSON, "RawJSON"];
,
True,
StringTemplate["Data files not found:\n `1`"][unaryPbJSON]
]
]


(* ::Text:: *)
(*Examples of exploring data*)


(* ::Input:: *)
(*Dataset[jsonDataUnaryPb]*)


(* ::Input:: *)
(*Dataset[jsonDataUnaryPb["referenceState"]]*)


(* ::Input:: *)
(*Dataset[jsonDataUnaryPb["referenceState"]["referenceConditions"]]*)


(* ::Input:: *)
(*jsonDataUnaryPb["functions"]//Dataset*)


(* ::Input:: *)
(*jsonDataUnaryPb["functions"]["stableReference"]//Dataset*)


(* ::Input:: *)
(*jsonDataUnaryPb["functions"]["metastableLiquidReference"]//Dataset*)


(* ::Input:: *)
(*jsonDataUnaryPb["functions"]["stableReference"]["temperatureSegments"]//Dataset*)


(* ::Subsection:: *)
(*Helper Functions*)


(* ::Input:: *)
(*temperatureBasisFunctions = <|*)
(*   "constant" -> Function[{T, term}, 1],*)
(*   "temperature" -> Function[{T, term}, T],*)
(*   "temperatureLogTemperature" -> Function[{T, term}, T Log[T]],*)
(*   "temperaturePower" -> Function[{T, term}, T^term["exponent"]]*)
(*   |>;*)
(**)
(*temperatureDependenceExpression[terms_List][T_] :=*)
(*    Total[(#["coefficient"] * temperatureBasisFunctions[#["basis"]][T, #]) & /@ terms]*)
(**)
(*temperatureSegmentExpression[segment_Association][T_] :=*)
(*    temperatureDependenceExpression[segment["terms"]][T];*)
(**)


(* ::Text:: *)
(*Example: Get a list of temperature dependence expressions over the temperature intervals*)


(* ::Input:: *)
(*temperatureSegments = jsonDataUnaryPb["functions"]["stableReference"]["temperatureSegments"];*)
(**)
(*temperatureSegmentExpression[#][T]&/@temperatureSegments*)


(* ::Input:: *)
(**)


(* ::Input:: *)
(*temperatureSegmentsToRanges[T_][temperatureSegment_Association]:= *)
(*Block[{},*)
(*Inequality[temperatureSegment["minimumTemperature"],lessOrLessThan[temperatureSegment["minimumInclusive"]],T,lessOrLessThan[temperatureSegment["maximumInclusive"]],temperatureSegment["maximumTemperature"]] *)
(*]*)


(* ::Text:: *)
(*Example: Get a list of temperature temperature intervals*)


(* ::Input:: *)
(*temperatureSegmentsToRanges[T]/@temperatureSegments*)


(* ::Subsection:: *)
(*Molar free energy extraction functions*)


(* ::Input:: *)
(*Clear[molarGibbsReferenceFunction];*)
(*molarGibbsReferenceFunction[json_Association][phaseIdentifier_String]:=*)
(*With[{phase= json["functions"][phaseIdentifier]},*)
(*Block[*)
(*{ functions, ranges, T,temperatureSegments=phase["temperatureSegments"], terms = phase["temperatureSegments"][[All,"terms"]]},*)
(*functions =temperatureDependenceExpression[#][T]&/@terms;*)
(*ranges = temperatureSegmentsToRanges[T]/@temperatureSegments;*)
(*res =Piecewise[Transpose[{functions,ranges}]]+*)
(*Which[MissingQ[phase["baseFunction"]],0,True,phase["baseFunction"]]]*)
(*]*)


(* ::Text:: *)
(*Example: Get the Gibbs energy for the metastable liquid (there may be a place holder for the stable phase which becomes an additive constant*)


(* ::Input:: *)
(*molarGibbsReferenceFunction[jsonDataUnaryPb]["metastableLiquidReference"]*)


(* ::Subsubsection:: *)
(*Get a data structure for the molar free energies in the library json.*)


(* ::Input:: *)
(*molarGibbsReference[json_Association]:=*)
(*Block[{*)
(*functions = json["functions"],*)
(*phases,*)
(*functionsAssociation,*)
(*referencePhase,referenceFunction,referenceFunctionName,referencePhaseKey, result,T,*)
(*resultExpressions,resultFunctions*)
(*},*)
(*phases= Keys[functions];*)
(*fa =functionsAssociation =AssociationMap[molarGibbsReferenceFunction[json],phases];*)
(*referencePhase=Select[json["functions"],!KeyExistsQ[#,"baseFunction"]&];*)
(*referencePhaseKey =Keys[referencePhase][[1]];referenceFunctionName = Values[referencePhase][[1]]["name"];*)
(*referenceFunction=functionsAssociation[referencePhaseKey];*)
(*re =resultExpressions =functionsAssociation/.referenceFunctionName->referenceFunction;*)
(*rf =resultFunctions=Map[Function[{T},#]&,resultExpressions];*)
(*AssociateTo[resultFunctions, "stableEnvelope"->Function[{T},Evaluate[Min[Values[resultExpressions]]]]]*)
(*]*)
(**)


(* ::Text:: *)
(*Example*)


(* ::Input:: *)
(*examplePbReference=molarGibbsReference[jsonDataUnaryPb]*)


(* ::Subsection:: *)
(*visual debugging*)


(* ::Input:: *)
(*examplePbReference["stableReference"]*)


(* ::Input:: *)
(*Plot[examplePbReference["stableReference"][temperature],{temperature,250,2400},*)
(*Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLabel->"Reference (FCC)"]*)


(* ::Input:: *)
(*Plot[{examplePbReference["stableReference"][temperature],examplePbReference["metastableLiquidReference"][temperature]},{temperature,300,2200}, Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLegends->{"Reference", "Liquid"},ImageSize->Large]*)


(* ::Text:: *)
(*Find the transition temperature:*)


(* ::Input:: *)
(*transitionTemperature = temperature/.FindRoot[examplePbReference["stableReference"][temperature]==  examplePbReference["metastableLiquidReference"][temperature], {temperature,300}]*)


(* ::Input:: *)
(*Plot[{examplePbReference["stableReference"][temperature],examplePbReference["metastableLiquidReference"][temperature]},{temperature,transitionTemperature-5,transitionTemperature+5}, Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLegends->{"Reference", "Liquid"},ImageSize->Large]*)


(* ::Input:: *)
(*Plot[examplePbReference["stableEnvelope"][temperature],{temperature,transitionTemperature-2,transitionTemperature+2}, Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLegends->{"Reference", "Liquid"},ImageSize->Large, Epilog->{InfiniteLine[{transitionTemperature,0},{0,1}]}]*)
