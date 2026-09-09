#!/usr/bin/env wolframscript

(* Independent numerical validation of the staged Dinsdale-1991 Zr candidate. *)

ClearAll["Global`*"];

repositoryRoot = DirectoryName[DirectoryName[DirectoryName[$InputFileName]]];
candidatePath = FileNameJoin[{repositoryRoot, "working", "unary-batch-0.2.0", "candidates",
  "zr-dinsdale-1991-1atm-standard-reference-candidate.json"}];
readerPath = FileNameJoin[{repositoryRoot, "examples", "mathematica", "Unary-reference-reader.wl"}];
candidate = Import[candidatePath, "RawJSON"];
readerSourceText = Import[readerPath, "Text"];
pressureValue = 101325.;
supportedBases = {"constant", "temperature", "temperatureLogTemperature", "temperaturePower"};
phaseKeys = {"hcp", "omega", "bcc", "liquid", "fcc"};
temperatureGrid = Subdivide[298.15, 4000., 20000];

pressureParameters = <|
  "hcp" -> <|"A" -> 13.9567*10^-6, "a0" -> 12.443*10^-6, "a1" -> 14.76*10^-9, "K0" -> 1.0063*10^-11, "K1" -> 1.573*10^-15, "n" -> 3.006|>,
  "omega" -> <|"A" -> 1.37115*10^-5, "a0" -> 3.0381*10^-5, "a1" -> 0., "K0" -> 1.0063*10^-11, "K1" -> 1.573*10^-15, "n" -> 3.006|>,
  "bcc" -> <|"A" -> 13.7141*10^-6, "a0" -> 3.0381*10^-5, "a1" -> 0., "K0" -> 1.0063*10^-11, "K1" -> 1.573*10^-15, "n" -> 3.006|>,
  "liquid" -> <|"A" -> 1.44092*10^-5, "a0" -> 3.0381*10^-5, "a1" -> 0., "K0" -> 1.0063*10^-11, "K1" -> 1.573*10^-15, "n" -> 3.006|>,
  "fcc" -> <|"A" -> 13.9567*10^-6, "a0" -> 12.443*10^-6, "a1" -> 14.76*10^-9, "K0" -> 1.0063*10^-11, "K1" -> 1.573*10^-15, "n" -> 3.006|>
|>;

reducedPressureContribution[phaseKey_String, temperature_?NumericQ] := Module[{parameters = pressureParameters[phaseKey]},
  parameters["A"] pressureValue (1 + parameters["a0"] temperature + parameters["a1"] temperature^2/2)
];

fullMurnaghanPressureContribution[phaseKey_String, temperature_?NumericQ] := Module[
  {parameters = pressureParameters[phaseKey], thermalExponent, compressibility},
  thermalExponent = parameters["a0"] temperature + parameters["a1"] temperature^2/2;
  compressibility = parameters["K0"] + parameters["K1"] temperature;
  parameters["A"] Exp[thermalExponent]/(compressibility (parameters["n"] - 1)) *
    ((1 + parameters["n"] pressureValue compressibility)^(1 - 1/parameters["n"]) - 1)
];

sourceZeroPressureFunctions = <|
  "hcp" -> Function[{temperature}, Piecewise[{
    {-7827.595 + 125.64905 temperature - 24.1618 temperature Log[temperature] - 4.37791*10^-3 temperature^2 + 34971 temperature^-1, 298.15 <= temperature < 2128.},
    {-26085.921 + 262.724183 temperature - 42.144 temperature Log[temperature] - 1.342895*10^31 temperature^-9, 2128. <= temperature <= 4000.}}, Indeterminate]],
  "omega" -> Function[{temperature}, Piecewise[{
    {-8878.082 + 144.432234 temperature - 26.8556 temperature Log[temperature] - 2.7994455*10^-3 temperature^2 + 38376 temperature^-1, 298.15 <= temperature < 2128.},
    {-29500.524 + 265.290858 temperature - 42.144 temperature Log[temperature] + 7.17444982*10^31 temperature^-9, 2128. <= temperature <= 4000.}}, Indeterminate]],
  "bcc" -> Function[{temperature}, Piecewise[{
    {-525.539 + 124.9457 temperature - 25.607406 temperature Log[temperature] - 3.40084*10^-4 temperature^2 - 9.7289735*10^-9 temperature^3 - 7.6142894*10^-11 temperature^4 + 25233 temperature^-1, 298.15 <= temperature < 2128.},
    {-30705.955 + 264.284163 temperature - 42.144 temperature Log[temperature] + 1.276058*10^32 temperature^-9, 2128. <= temperature <= 4000.}}, Indeterminate]],
  "liquid" -> Function[{temperature}, Piecewise[{
    {10320.095 + 116.568238 temperature - 24.1618 temperature Log[temperature] - 4.37791*10^-3 temperature^2 + 34971 temperature^-1 + 1.6275*10^-22 temperature^7, 298.15 <= temperature < 2128.},
    {-8281.26 + 253.812609 temperature - 42.144 temperature Log[temperature], 2128. <= temperature <= 4000.}}, Indeterminate]],
  "fcc" -> Function[{temperature}, Piecewise[{
    {-227.595 + 124.74905 temperature - 24.1618 temperature Log[temperature] - 4.37791*10^-3 temperature^2 + 34971 temperature^-1, 298.15 <= temperature < 2128.},
    {-18485.921 + 261.824183 temperature - 42.144 temperature Log[temperature] - 1.342895*10^31 temperature^-9, 2128. <= temperature <= 4000.}}, Indeterminate]]
|>;

sourceReducedFunction[phaseKey_String, temperature_?NumericQ] :=
  sourceZeroPressureFunctions[phaseKey][temperature] + reducedPressureContribution[phaseKey, temperature];

evaluateTerm[term_Association, temperature_?NumericQ] := Switch[term["basis"],
  "constant", term["coefficient"],
  "temperature", term["coefficient"] temperature,
  "temperatureLogTemperature", term["coefficient"] temperature Log[temperature],
  "temperaturePower", term["coefficient"] temperature^term["exponent"],
  _, Indeterminate];

evaluateTerms[terms_List, temperature_?NumericQ] := Total[evaluateTerm[#, temperature] & /@ terms];

selectSegment[function_Association, temperature_?NumericQ] := SelectFirst[function["temperatureSegments"],
  (#minimumTemperature <= temperature < #maximumTemperature) || (#maximumInclusive && temperature == #maximumTemperature) &,
  Missing["NoSegment"]];

evaluateCandidateFunction[phaseKey_String, temperature_?NumericQ, visited_: {}] := Module[
  {function, segment, ownValue, baseFunctionName, basePhaseKey},
  If[MemberQ[visited, phaseKey], Return[Indeterminate]];
  function = candidate["functions", phaseKey];
  segment = selectSegment[function, temperature];
  If[MissingQ[segment], Return[Indeterminate]];
  ownValue = evaluateTerms[segment["terms"], temperature];
  baseFunctionName = Lookup[function, "baseFunction", Missing["NoBase"]];
  If[MissingQ[baseFunctionName], Return[ownValue]];
  basePhaseKey = SelectFirst[Keys[candidate["functions"]], candidate["functions", #, "name"] == baseFunctionName &, Missing["NoBase"]];
  If[MissingQ[basePhaseKey], Indeterminate, ownValue + evaluateCandidateFunction[basePhaseKey, temperature, Append[visited, phaseKey]]]
];

segmentEndpointGate[function_Association] := Module[{segments = function["temperatureSegments"]},
  First[segments]["minimumTemperature"] == 298.15 && Last[segments]["maximumTemperature"] == 4000. &&
  First[segments]["minimumInclusive"] && Last[segments]["maximumInclusive"] &&
  And @@ MapThread[#1["maximumTemperature"] == #2["minimumTemperature"] && ! #1["maximumInclusive"] && #2["minimumInclusive"] &,
    {Most[segments], Rest[segments]}]
];

functionBreakpoints[phaseKey_String, visited_: {}] := Module[{function, ownBreakpoints, baseFunctionName, basePhaseKey},
  If[MemberQ[visited, phaseKey], Return[{}]];
  function = candidate["functions", phaseKey];
  ownBreakpoints = Most[Lookup[function["temperatureSegments"], "maximumTemperature"]];
  baseFunctionName = Lookup[function, "baseFunction", Missing["NoBase"]];
  If[MissingQ[baseFunctionName], Return[ownBreakpoints]];
  basePhaseKey = SelectFirst[Keys[candidate["functions"]], candidate["functions", #, "name"] == baseFunctionName &, Missing["NoBase"]];
  If[MissingQ[basePhaseKey], ownBreakpoints, Sort@DeleteDuplicates@Join[ownBreakpoints, functionBreakpoints[basePhaseKey, Append[visited, phaseKey]]]]
];

continuityMetrics[phaseKey_String] := Module[{boundaries = functionBreakpoints[phaseKey]},
  Map[Function[boundary, Module[{epsilon = 10^-3, leftValue, rightValue, leftSlope, rightSlope},
    leftValue = evaluateCandidateFunction[phaseKey, boundary - 10^-8];
    rightValue = evaluateCandidateFunction[phaseKey, boundary];
    leftSlope = (evaluateCandidateFunction[phaseKey, boundary - epsilon] - evaluateCandidateFunction[phaseKey, boundary - 2 epsilon])/epsilon;
    rightSlope = (evaluateCandidateFunction[phaseKey, boundary + 2 epsilon] - evaluateCandidateFunction[phaseKey, boundary + epsilon])/epsilon;
    <|"temperature" -> boundary, "c0Residual" -> rightValue - leftValue, "c1Residual" -> rightSlope - leftSlope|>
  ]], boundaries]
];

stablePhaseAt[temperature_?NumericQ] := First@MinimalBy[phaseKeys, evaluateCandidateFunction[#, temperature] &];
stablePhaseGrid = stablePhaseAt /@ temperatureGrid;
stableSequence = First /@ Split[stablePhaseGrid];
changeIndices = Flatten@Position[Partition[stablePhaseGrid, 2, 1], {left_, right_} /; left =!= right];

findBracketedRoot[phaseOne_String, phaseTwo_String, lower_?NumericQ, upper_?NumericQ] :=
  temperature /. FindRoot[evaluateCandidateFunction[phaseOne, temperature] == evaluateCandidateFunction[phaseTwo, temperature],
    {temperature, lower, upper}, Method -> "Brent"];

envelopeTransitions = Map[Function[index, Module[{lowPhase, highPhase, root},
  lowPhase = stablePhaseGrid[[index]]; highPhase = stablePhaseGrid[[index + 1]];
  root = findBracketedRoot[lowPhase, highPhase, temperatureGrid[[index]], temperatureGrid[[index + 1]]];
  <|"lowTemperaturePhase" -> lowPhase, "highTemperaturePhase" -> highPhase, "temperature" -> root,
    "rootResidual" -> evaluateCandidateFunction[lowPhase, root] - evaluateCandidateFunction[highPhase, root]|>
]], changeIndices];

pairwiseCrossings = Flatten@Table[Module[{phaseOne = phaseKeys[[firstIndex]], phaseTwo = phaseKeys[[secondIndex]], differences, brackets, roots},
  differences = (evaluateCandidateFunction[phaseOne, #] - evaluateCandidateFunction[phaseTwo, #]) & /@ temperatureGrid;
  brackets = Flatten@Position[Partition[differences, 2, 1], {left_, right_} /; NumericQ[left] && NumericQ[right] && left right <= 0];
  roots = DeleteDuplicates[findBracketedRoot[phaseOne, phaseTwo, temperatureGrid[[#]], temperatureGrid[[# + 1]]] & /@ brackets, Abs[#1 - #2] < 10^-6 &];
  Map[<|"phases" -> {phaseOne, phaseTwo}, "temperature" -> #,
    "rootResidual" -> evaluateCandidateFunction[phaseOne, #] - evaluateCandidateFunction[phaseTwo, #],
    "classification" -> If[stablePhaseAt[# - 10^-4] =!= stablePhaseAt[# + 10^-4], "equilibrium", "metastable"]|> &, roots]
], {firstIndex, 1, Length[phaseKeys] - 1}, {secondIndex, firstIndex + 1, Length[phaseKeys]}];

continuity = AssociationMap[continuityMetrics, phaseKeys];
analyticResiduals = AssociationMap[Function[phaseKey,
  Max[Abs[(evaluateCandidateFunction[phaseKey, #] - sourceReducedFunction[phaseKey, #]) & /@ temperatureGrid]]
], phaseKeys];
pressureApproximation = AssociationMap[Function[phaseKey, Module[{residuals, exactValues},
  residuals = (reducedPressureContribution[phaseKey, #] - fullMurnaghanPressureContribution[phaseKey, #]) & /@ temperatureGrid;
  exactValues = fullMurnaghanPressureContribution[phaseKey, #] & /@ temperatureGrid;
  <|"maximumAbsoluteResidualJPerMol" -> Max[Abs[residuals]], "maximumExactContributionJPerMol" -> Max[exactValues]|>
]], phaseKeys];

omegaMinusHcp = (evaluateCandidateFunction["omega", #] - evaluateCandidateFunction["hcp", #]) & /@ temperatureGrid;
omegaMinusBcc = (evaluateCandidateFunction["omega", #] - evaluateCandidateFunction["bcc", #]) & /@ temperatureGrid;
omegaMetrics = <|
  "minimumOmegaMinusHcpJPerMol" -> Min[omegaMinusHcp],
  "temperatureOfMinimumOmegaMinusHcpK" -> temperatureGrid[[First@Ordering[omegaMinusHcp, 1]]],
  "omegaMinusHcpAtHcpBccTransitionJPerMol" -> (evaluateCandidateFunction["omega", envelopeTransitions[[1, "temperature"]]] - evaluateCandidateFunction["hcp", envelopeTransitions[[1, "temperature"]]]),
  "minimumOmegaMinusBccJPerMol" -> Min[omegaMinusBcc],
  "temperatureOfMinimumOmegaMinusBccK" -> temperatureGrid[[First@Ordering[omegaMinusBcc, 1]]],
  "omegaReachesLowerEnvelope" -> MemberQ[stableSequence, "omega"]
|>;

requiredTopLevelKeys = {"schemaVersion", "objectType", "status", "modelIdentifier", "identity", "referenceState", "systemConditions", "systemValidity", "units", "functions", "sourceProvenance", "verification"};
allTerms = Cases[candidate, association_Association /; KeyExistsQ[association, "basis"] && KeyExistsQ[association, "coefficient"] :> association, Infinity];
sourceTransitions = {{"hcp", "bcc", 1139.45}, {"bcc", "liquid", 2127.85}};

validationGates = <|
  "jsonSyntax" -> AssociationQ[candidate],
  "schema020Structure" -> (candidate["schemaVersion"] == "0.2.0" && candidate["objectType"] == "unaryStandardReference" && And @@ (KeyExistsQ[candidate, #] & /@ requiredTopLevelKeys)),
  "completeSourcePhaseSet" -> (Keys[candidate["functions"]] == phaseKeys),
  "segmentEndpoints" -> And @@ (segmentEndpointGate /@ Values[candidate["functions"]]),
  "sourceModelSystemValidityConsistency" -> (And @@ (#["minimumTemperature"] <= 298.15 && #["maximumTemperature"] >= 4000. & /@ Values[candidate["sourceProvenance", "sourceModelValidity"]]) &&
    And @@ (#["validity", "minimumTemperature"] == 298.15 && #["validity", "maximumTemperature"] == 4000. & /@ Values[candidate["functions"]])),
  "basisSupportByUnchangedReader" -> (And @@ (MemberQ[supportedBases, #["basis"]] & /@ allTerms) &&
    And @@ (StringContainsQ[readerSourceText, "\"" <> # <> "\" -> Function"] & /@ DeleteDuplicates[#["basis"] & /@ allTerms])),
  "baseFunctionDependencyResolution" -> (Count[Values[candidate["functions"]], function_ /; ! KeyExistsQ[function, "baseFunction"]] == 1 && And @@ (NumberQ[evaluateCandidateFunction[#, 1000.]] & /@ phaseKeys)),
  "finiteIndependentNumericalEvaluation" -> And @@ Flatten@Table[NumberQ[evaluateCandidateFunction[phaseKey, temperature]], {phaseKey, phaseKeys}, {temperature, Subdivide[298.15, 4000., 1000]}],
  "analyticEquivalenceToSourceReduction" -> And @@ (Abs[#] <= 10^-8 & /@ Values[analyticResiduals]),
  "c0Continuity" -> And @@ (Abs[#["c0Residual"]] <= 2. & /@ Flatten[Values[continuity]]),
  "c1Continuity" -> And @@ (Abs[#["c1Residual"]] <= 0.01 & /@ Flatten[Values[continuity]]),
  "lowerEnvelopeTopology" -> (stableSequence == {"hcp", "bcc", "liquid"}),
  "transitionComparisonToDinsdale1991" -> And @@ MapThread[#1["lowTemperaturePhase"] == #2[[1]] && #1["highTemperaturePhase"] == #2[[2]] && Abs[#1["temperature"] - #2[[3]]] <= 1. &,
    {envelopeTransitions, sourceTransitions}],
  "pairwiseCrossingsRestrictedToSystemValidity" -> And @@ (298.15 <= #["temperature"] <= 4000. & /@ pairwiseCrossings),
  "rootResiduals" -> And @@ (Abs[#["rootResidual"]] <= 10^-6 & /@ pairwiseCrossings),
  "omegaExcludedFromLowerEnvelope" -> ! omegaMetrics["omegaReachesLowerEnvelope"],
  "provenanceAndStatus" -> (KeyExistsQ[candidate["sourceProvenance"], "pressureModelProvenance"] && StringContainsQ[candidate["status"], "pending-independent-reader-validation"])
|>;

result = <|
  "elementSymbol" -> "Zr",
  "modelIdentifier" -> candidate["modelIdentifier"],
  "candidatePath" -> FileNameDrop[candidatePath, FileNameDepth[repositoryRoot]],
  "classification" -> If[And @@ Values[validationGates], "PASS - staged candidate pending independent unchanged-reader validation", "REVIEW REQUIRED - one or more automated gates failed"],
  "validationGates" -> validationGates,
  "analyticEquivalenceMaximumResidualsJPerMol" -> analyticResiduals,
  "pressureReductionComparisonToFullMurnaghan" -> pressureApproximation,
  "continuity" -> continuity,
  "stableSequence" -> stableSequence,
  "computedTransitions" -> envelopeTransitions,
  "sourceTransitionTemperaturesK" -> {1139.45, 2127.85},
  "pairwiseCrossingsWithinSystemValidity" -> pairwiseCrossings,
  "omegaBehavior" -> omegaMetrics,
  "tolerances" -> <|"transitionK" -> 1., "rootResidualJPerMol" -> 10^-6, "c0JPerMol" -> 2., "c1JPerMolK" -> 0.01, "analyticEquivalenceJPerMol" -> 10^-8|>,
  "validationImplementation" -> <|"language" -> "Wolfram Language", "script" -> "working/unary-batch-0.2.0/zr-dinsdale-1991-1atm-validation.wl", "readerFilesModified" -> False|>,
  "unchangedReaderValidation" -> <|"status" -> "pending-project-owner-independent-test", "reader" -> "examples/mathematica/Unary-reference-reader.nb", "readerModified" -> False|>
|>;

Print[ExportString[result, "RawJSON", "Compact" -> False]];
