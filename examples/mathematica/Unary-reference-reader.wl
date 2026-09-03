(* ::Package:: *)

(* ::Input:: *)
(*NotebookDirectory[]*)


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
(*Loading Data (Using Pb as an example)*)


With[
{
unaryPbJSON =FileNameJoin[{obglLibrary,"data","unary","pb-standard-reference.json"}]
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
(*temperatureSegments = jsonDataUnaryPb["functions"]["stableReference"]["temperatureSegments"]*)
(**)
(*temperatureSegmentExpression[#][T]&/@temperatureSegments*)


(* ::Input:: *)
(**)


(* ::Input:: *)
(*lessOrLessThan[boundType_]:= Which[boundType,LessEqual,True,Less]*)
(**)
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
(*resultExpressions,resultFunctions,validTemperatureRanges,minimumValidTemperature,maximumValidTemperature*)
(*},*)
(*phases= Keys[functions];*)
(*functionsAssociation =AssociationMap[molarGibbsReferenceFunction[json],phases];*)
(*referencePhase=Select[json["functions"],!KeyExistsQ[#,"baseFunction"]&];*)
(*referencePhaseKey =Keys[referencePhase][[1]];referenceFunctionName = Values[referencePhase][[1]]["name"];*)
(*referenceFunction=functionsAssociation[referencePhaseKey];*)
(*resultExpressions =functionsAssociation/.referenceFunctionName->referenceFunction;*)
(*resultFunctions=Map[Function[{T},#]&,resultExpressions];*)
(*validTemperatureRanges = Lookup[json["functions"]//Values, "validity"];*)
(*minimumValidTemperature = Max[Lookup[validTemperatureRanges,"minimumTemperature"]];*)
(*maximumValidTemperature = Min[Lookup[validTemperatureRanges,"maximumTemperature"]];*)
(*<|"Valid Temperature Range"->{minimumValidTemperature,maximumValidTemperature},"functions"->resultFunctions|>*)
(**)
(*]*)
(**)


(* ::Input:: *)
(*Options[stabilityEnvelope]={"Temperature Resolution"->1};*)
(**)
(*stabilityEnvelope[molarGibbsReferenceResult_Association, OptionsPattern[]]:=*)
(*Block[{*)
(*keys = Keys[molarGibbsReferenceResult["functions"]],*)
(*functions = Values[molarGibbsReferenceResult["functions"]],*)
(*temperatureLow =First[molarGibbsReferenceResult["Valid Temperature Range"]],*)
(*temperatureHigh=Last[molarGibbsReferenceResult["Valid Temperature Range"]],*)
(*grid , gridCount,functionValuesOnGrid,hullIndices,hullPhases,segments,*)
(*transitionIntervals,transitionPhases,transitionTemperatures,stablePhaseAtT*)
(*},*)
(*gridCount = Round[(temperatureHigh-temperatureLow)/OptionValue["Temperature Resolution"]];*)
(*grid =Subdivide[temperatureLow + .001 ,temperatureHigh - .001,gridCount];*)
(*functionValuesOnGrid = Comap[functions,#]&/@grid;*)
(*hullIndices = First[PositionSmallest[#]]&/@functionValuesOnGrid;*)
(*hullPhases=Transpose[{grid,hullIndices}];*)
(*segments = Most[MapThread[{#1,#2}&,{hullPhases,RotateLeft[hullPhases]}]];*)
(*transitionIntervals =Cases[segments,{{_?NumericQ,p1_?IntegerQ},{_?NumericQ,p2_?IntegerQ}}/;p1!=p2];*)
(*transitionPhases ={keys[[ Last[First[#]]]],keys[[Last[Last[#]]]]}&/@transitionIntervals;*)
(*transitionTemperatures=Block[{temperature},*)
(*With[{tdown =#[[1,1]] , tup =#[[2,1]], pdown =#[[1,2]], pup =#[[2,2]] },*)
(*temperature/.FindRoot[functions[[pdown]][temperature]== functions[[pup]][temperature],{temperature,Mean[{tdown,tup }], tdown,tup}]*)
(*]*)
(*]&/@transitionIntervals;*)
(*transitionPhases ={keys[[ Last[First[#]]]],keys[[Last[Last[#]]]]}&/@transitionIntervals;*)
(*stablePhaseAtT=*)
(*Block[{interpolator,phaseSequence},*)
(*phaseSequence = Join[{hullPhases[[1]]}, Sequence@@transitionIntervals, {hullPhases[[-1]]}];*)
(*phaseSequence = phaseSequence/.{t_?NumericQ,pos_?IntegerQ}:> {t,keys[[pos]]};*)
(*Interpolation[phaseSequence,*)
(*InterpolationOrder->0]*)
(*]*)
(*;*)
(*<|"Stable Phase at Temperature"->stablePhaseAtT,"Transitions"->*)
(*MapThread[<|"Transition Temperature"->#1, "Phases"-><|"Low Temperature"->First[#2],"High Temperature"->Last[#2]|>|>&,*)
(*{transitionTemperatures, transitionPhases}]*)
(*|>*)
(*]*)
(**)


(* ::Text:: *)
(*Example*)


(* ::Input:: *)
(*examplePbReference=molarGibbsReference[jsonDataUnaryPb]*)


(* ::Subsection:: *)
(*visual debugging*)


(* ::Input:: *)
(*examplePbReference["functions"]["stableReference"]*)


(* ::Input:: *)
(*Plot[examplePbReference["functions"]["stableReference"][temperature],{temperature,250,2400},*)
(*Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLabel->"Reference (FCC)"]*)


(* ::Input:: *)
(*Plot[{examplePbReference["functions"]["stableReference"][temperature],examplePbReference["functions"]["metastableLiquidReference"][temperature]},{temperature,300,2200}, Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLegends->{"Reference", "Liquid"},ImageSize->Large]*)


(* ::Text:: *)
(*Find the transition temperature:*)


(* ::Input:: *)
(*transitionTemperature = temperature/.FindRoot[examplePbReference["functions"]["stableReference"][temperature]==  examplePbReference["functions"]["metastableLiquidReference"][temperature], {temperature,300}]*)


(* ::Input:: *)
(*Plot[{examplePbReference["functions"]["stableReference"][temperature],examplePbReference["functions"]["metastableLiquidReference"][temperature]},{temperature,transitionTemperature-5,transitionTemperature+5}, Frame->True,FrameLabel->{"Temperarure (K)","Molar Gibbs Free Energy"}, PlotLegends->{"Reference", "Liquid"},ImageSize->Large]*)


(* ::Subsubsection:: *)
(*extract data for the phase transitions*)


(* ::Input:: *)
(*stabilityDataPb =stabilityEnvelope[examplePbReference]*)


(* ::Input:: *)
(*stabilityDataPb["Stable Phase at Temperature"][433]*)


(* ::Chapter:: *)
(*Example for Bi*)


(* ::Input:: *)
(*With[*)
(*{*)
(*unaryBiJSON =FileNameJoin[{obglLibrary,"data","unary","bi-standard-reference.json"}]*)
(*},*)
(**)
(*Which[*)
(*FileExistsQ[unaryBiJSON],*)
(*jsonDataUnaryBi = Import[unaryBiJSON, "RawJSON"];*)
(*,*)
(*True,*)
(*StringTemplate["Data files not found:\n `1`"][unaryBiJSON]*)
(*]*)
(*]*)


(* ::Input:: *)
(*Dataset[jsonDataUnaryBi]*)


(* ::Input:: *)
(*Dataset[jsonDataUnaryBi["functions"]]*)


(* ::Input:: *)
(*Dataset[*)
(*exampleBiReference=molarGibbsReference[jsonDataUnaryBi]*)
(*]*)


(* ::Input:: *)
(*Dataset[exampleBiReference["functions"]]*)


(* ::Input:: *)
(*Keys[exampleBiReference]*)


(* ::Input:: *)
(*funcs = Values[exampleBiReference["functions"]]*)


(* ::Input:: *)
(*With[{funcs =Comap[funcs, temperature]},*)
(* Plot[funcs,{temperature,300,1000}, PlotLegends->Keys[exampleBiReference["functions"]],*)
(*Frame->True, FrameLabel->{"Temperature (K)", "Molar Free Energy"}, ImageSize->Large]*)
(*]*)
(**)


(* ::Input:: *)
(*Keys[exampleBiReference]*)


(* ::Input:: *)
(*FindRoot[exampleBiReference["functions"]["stableReference"][T]== exampleBiReference["functions"]["metastableLiquidReference"][T],{T,500}]*)


(* ::Input:: *)
(*544.5200027063481`*)


(* ::Input:: *)
(*With[{funcs =Comap[funcs, temperature]},*)
(* Plot[funcs,{temperature,1000,1200}, PlotLegends->Keys[exampleBiReference["functions"]],*)
(*Frame->True, FrameLabel->{"Temperature (K)", "Molar Free Energy"}, ImageSize->Large]*)
(*]*)


(* ::Subsection:: *)
(*equilibrium properties*)


(* ::Input:: *)
(*Dataset[exampleBiReference]*)


(* ::Input:: *)
(*stabilityEnvelope[exampleBiReference]*)
