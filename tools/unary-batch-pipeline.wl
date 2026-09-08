#!/usr/bin/env wolframscript

(* OBGEL schema-0.2.0 unary batch candidate generator and validator. *)

ClearAll["Global`*"];

repositoryRoot = DirectoryName[DirectoryName[$InputFileName]];
workingRoot = FileNameJoin[{repositoryRoot, "working", "unary-batch-0.2.0"}];
candidateRoot = FileNameJoin[{workingRoot, "candidates"}];
diagnosticRoot = FileNameJoin[{workingRoot, "diagnostics"}];
reportRoot = FileNameJoin[{workingRoot, "reports"}];
sourcePath = If[Length[$ScriptCommandLine] >= 2, $ScriptCommandLine[[2]],
  FileNameJoin[{workingRoot, "sources", "unary50.tdb"}]];

Scan[If[! DirectoryQ[#], CreateDirectory[#, CreateIntermediateDirectories -> True]] &,
  {candidateRoot, diagnosticRoot, reportRoot}];

If[! FileExistsQ[sourcePath],
  Print["Source TDB not found: " <> sourcePath]; Exit[2]
];

elementConfigurations = <|
  "Ag" -> <|"name" -> "silver", "referencePhase" -> "FCC-A1", "maximumTemperature" -> 3000.,
    "functions" -> <|"fcc" -> "GHSERAG", "liquid" -> "GLIQAG", "bcc" -> "GBCCAG", "hcp" -> "GHCPAG"|>,
    "expectedTransitions" -> {{"fcc", "liquid", 1234.93}}, "sourcePages" -> {323, 328}|>,
  "Al" -> <|"name" -> "aluminium", "referencePhase" -> "FCC-A1", "maximumTemperature" -> 2900.,
    "functions" -> <|"fcc" -> "GHSERAL", "liquid" -> "GLIQAL", "bcc" -> "GBCCAL", "hcp" -> "GHCPAL"|>,
    "expectedTransitions" -> {{"fcc", "liquid", 933.47}}, "sourcePages" -> {323, 329}|>,
  "Au" -> <|"name" -> "gold", "referencePhase" -> "FCC-A1", "maximumTemperature" -> 3200.,
    "functions" -> <|"fcc" -> "GHSERAU", "liquid" -> "GLIQAU", "bcc" -> "GBCCAU", "hcp" -> "GHCPAU"|>,
    "expectedTransitions" -> {{"fcc", "liquid", 1337.33}}, "sourcePages" -> {323, 331}|>,
  "Cd" -> <|"name" -> "cadmium", "referencePhase" -> "HCP-A3", "maximumTemperature" -> 1600.,
    "functions" -> <|"hcp" -> "GHSERCD", "liquid" -> "GLIQCD", "fcc" -> "GFCCCD"|>,
    "expectedTransitions" -> {{"hcp", "liquid", 594.219}}, "sourcePages" -> {323, 340}|>,
  "Cu" -> <|"name" -> "copper", "referencePhase" -> "FCC-A1", "maximumTemperature" -> 3200.,
    "functions" -> <|"fcc" -> "GHSERCU", "liquid" -> "GLIQCU", "bcc" -> "GBCCCU", "hcp" -> "GHCPCU"|>,
    "expectedTransitions" -> {{"fcc", "liquid", 1357.77}}, "sourcePages" -> {323, 347}|>,
  "Hf" -> <|"name" -> "hafnium", "referencePhase" -> "HCP-A3", "maximumTemperature" -> 3000.,
    "functions" -> <||>, "expectedTransitions" -> {{"hcp", "bcc", 2016.}, {"bcc", "liquid", 2506.}},
    "sourcePages" -> {323, 357, 358}, "sourceBlocker" -> "SGTE v5 explicitly revises Hf HCP-A3, BCC-A2, and FCC-A1; a version-pinned Dinsdale-1991 transcription is required."|>,
  "Mo" -> <|"name" -> "molybdenum", "referencePhase" -> "BCC-A2", "maximumTemperature" -> 4000.,
    "functions" -> <|"bcc" -> "GHSERMO", "liquid" -> "GLIQMO", "fcc" -> "GFCCMO", "hcp" -> "GHCPMO"|>,
    "expectedTransitions" -> {{"bcc", "liquid", 2896.}}, "sourcePages" -> {324, 371, 372},
    "specialContributions" -> {"Dinsdale Gpres is omitted for this fixed 1 bar temperature-only reduction, following the low/moderate-pressure convention used by the Fe exemplar."}|>,
  "Nb" -> <|"name" -> "niobium", "referencePhase" -> "BCC-A2", "maximumTemperature" -> 6000.,
    "functions" -> <|"bcc" -> "GHSERNB", "liquid" -> "GLIQNB", "fcc" -> "GFCCNB", "hcp" -> "GHCPNB"|>,
    "expectedTransitions" -> {{"bcc", "liquid", 2750.}}, "sourcePages" -> {324, 374, 375}|>,
  "Ta" -> <|"name" -> "tantalum", "referencePhase" -> "BCC-A2", "maximumTemperature" -> 6000.,
    "functions" -> <|"bcc" -> "GHSERTA", "liquid" -> "GLIQTA", "fcc" -> "GFCCTA", "hcp" -> "GHCPTA"|>,
    "expectedTransitions" -> {{"bcc", "liquid", 3290.}}, "sourcePages" -> {325, 407, 408}|>,
  "Ti" -> <|"name" -> "titanium", "referencePhase" -> "HCP-A3", "maximumTemperature" -> 4000.,
    "functions" -> <|"hcp" -> "GHSERTI", "bcc" -> "GBCCTI", "liquid" -> "GLIQTI", "fcc" -> "GFCCTI"|>,
    "expectedTransitions" -> {{"hcp", "bcc", 1155.}, {"bcc", "liquid", 1941.}}, "sourcePages" -> {325, 412, 413, 414}|>,
  "V" -> <|"name" -> "vanadium", "referencePhase" -> "BCC-A2", "maximumTemperature" -> 4000.,
    "functions" -> <|"bcc" -> "GHSERV", "liquid" -> "GLIQV", "fcc" -> "GFCCV", "hcp" -> "GHCPV"|>,
    "expectedTransitions" -> {{"bcc", "liquid", 2183.}}, "sourcePages" -> {325, 417, 418}|>,
  "W" -> <|"name" -> "tungsten", "referencePhase" -> "BCC-A2", "maximumTemperature" -> 6000.,
    "functions" -> <|"bcc" -> "GHSERW", "liquid" -> "GLIQW", "fcc" -> "GFCCW", "hcp" -> "GHCPW"|>,
    "expectedTransitions" -> {{"bcc", "liquid", 3695.}}, "sourcePages" -> {325, 419}|>,
  "Zn" -> <|"name" -> "zinc", "referencePhase" -> "HCP_A3 (Zn non ideal)", "maximumTemperature" -> 1700.,
    "functions" -> <|"hcp" -> "GHSERZN", "liquid" -> "GLIQZN", "bcc" -> "GBCCZN", "fcc" -> "GFCCZN"|>,
    "expectedTransitions" -> {{"hcp", "liquid", 692.68}}, "sourcePages" -> {325, 422, 423},
    "phaseNames" -> <|"hcp" -> "HCP_A3 (Zn non ideal)"|>,
    "phaseIdentityNotes" -> <|"hcp" -> "The canonical key hcp records phase/structure identity; Dinsdale's thermodynamic/model qualification is retained verbatim as source metadata."|>|>,
  "Zr" -> <|"name" -> "zirconium", "referencePhase" -> "HCP-A3", "maximumTemperature" -> 4000.,
    "functions" -> <||>, "expectedTransitions" -> {{"hcp", "bcc", 1139.45}, {"bcc", "liquid", 2127.85}},
    "sourcePages" -> {325, 423, 424, 425}, "sourceBlocker" -> "Dinsdale includes OMEGA and explicit pressure terms, while the standard-function source route omits OMEGA; phase completeness and ambient-pressure reduction require audit."|>
|>;

phaseDisplayNames = <|"fcc" -> "FCC-A1", "bcc" -> "BCC-A2", "hcp" -> "HCP-A3", "liquid" -> "LIQUID"|>;
supportedBases = {"constant", "temperature", "temperatureLogTemperature", "temperaturePower"};
longDash = FromCharacterCode[8212];
sourceText = Import[sourcePath, "Text"];
sourceHash = FileHash[sourcePath, "SHA256", "HexString"];

normalizeExpressionText[text_String] := Module[{result},
  result = StringReplace[text, WhitespaceCharacter .. -> ""];
  result = StringReplace[result, RegularExpression["([0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)E([+-]?[0-9]+)"] :> "$1*10^($2)"];
  result = StringReplace[result, {"**" -> "^", "LN(T)" -> "Log[temperatureValue]"}];
  result = StringReplace[result, RegularExpression["\\bT\\b"] -> "temperatureValue"];
  result
];

extractFunctionRecord[identifier_String] := Module[{pattern, match, startTemperature, body, pieces, segments, currentMinimum},
  pattern = RegularExpression["(?ms)^\\s*FUNCTION\\s+" <> identifier <> "\\s+([0-9.]+)\\s+(.*?)!"];
  match = StringCases[sourceText, pattern :> {"$1", "$2"}];
  If[Length[match] != 1, Return[Missing["FunctionNotFound", identifier]]];
  startTemperature = ToExpression[match[[1, 1]]]; body = match[[1, 2]];
  pieces = StringCases[body, RegularExpression["(?ms)(.*?);\\s*([0-9.]+)\\s+([YN])"] :> {"$1", "$2", "$3"}];
  currentMinimum = startTemperature;
  segments = Map[
    Function[piece, With[{segment = <|"minimumTemperature" -> N[currentMinimum], "maximumTemperature" -> N[ToExpression[piece[[2]]]],
        "expressionText" -> StringTrim[StringReplace[piece[[1]], WhitespaceCharacter .. -> " "]],
        "continuationFlag" -> piece[[3]]|>}, currentMinimum = ToExpression[piece[[2]]]; segment]], pieces];
  <|"identifier" -> identifier, "sourceStartTemperature" -> N[startTemperature], "segments" -> segments|>
];

parsedRecords = AssociationMap[extractFunctionRecord,
  DeleteDuplicates[Flatten[Values[Lookup[Values[elementConfigurations], "functions", <||>]]]]];

parseAlgebraicExpression[text_String] := Quiet@Check[ToExpression[normalizeExpressionText[text]], $Failed];

selectSourceSegment[record_Association, temperature_?NumericQ] := SelectFirst[record["segments"],
  #["minimumTemperature"] <= temperature < #["maximumTemperature"] || temperature == #["maximumTemperature"] && #["continuationFlag"] == "N" &, Missing["NoSegment"]];

flattenFunctionExpression[identifier_String, temperature_?NumericQ, visited_: {}] := Module[{record, segment, expression, dependencyNames},
  If[MemberQ[visited, identifier], Return[$Failed]];
  record = Lookup[parsedRecords, identifier, Missing["NotFound"]];
  If[MissingQ[record], Return[$Failed]];
  segment = selectSourceSegment[record, temperature]; If[MissingQ[segment], Return[$Failed]];
  expression = parseAlgebraicExpression[segment["expressionText"]]; If[expression === $Failed, Return[$Failed]];
  dependencyNames = DeleteDuplicates@StringCases[segment["expressionText"], RegularExpression["\\b(G[A-Z0-9]+)\\b"] :> "$1"];
  Fold[Function[{currentExpression, dependencyName}, With[{dependencySymbol = Symbol[dependencyName]},
      currentExpression /. dependencySymbol -> flattenFunctionExpression[dependencyName, temperature, Append[visited, identifier]]]],
    expression, dependencyNames] // Expand
];

expressionToTerms[expression_] := Module[{summands, convertTerm},
  summands = If[Head[Expand[expression]] === Plus, List @@ Expand[expression], {Expand[expression]}];
  convertTerm[term_] := Which[
    FreeQ[term, temperatureValue], <|"basis" -> "constant", "coefficient" -> N[term]|>,
    ! FreeQ[term, Log[temperatureValue]] && FreeQ[term/(temperatureValue Log[temperatureValue]), temperatureValue],
      <|"basis" -> "temperatureLogTemperature", "coefficient" -> N[term/(temperatureValue Log[temperatureValue])]|>,
    True, Replace[term,
      coefficient_. * temperatureValue^exponent_. /; FreeQ[coefficient, temperatureValue] :>
        If[exponent === 1, <|"basis" -> "temperature", "coefficient" -> N[coefficient]|>,
          <|"basis" -> "temperaturePower", "coefficient" -> N[coefficient], "exponent" -> N[exponent]|>], {0}],
    False, Missing["UnsupportedTerm", ToString[term, InputForm]]
  ];
  convertTerm /@ summands
];

functionBreakpoints[identifier_String, minimum_, maximum_, visited_: {}] := Module[{record, directBreakpoints, dependencyNames},
  If[MemberQ[visited, identifier], Return[{}]];
  record = Lookup[parsedRecords, identifier, Missing["NotFound"]]; If[MissingQ[record], Return[{}]];
  directBreakpoints = Flatten[Lookup[record["segments"], {"minimumTemperature", "maximumTemperature"}]];
  dependencyNames = DeleteDuplicates@Flatten[StringCases[Lookup[record["segments"], "expressionText"],
    RegularExpression["\\b(G[A-Z0-9]+)\\b"] :> "$1"]];
  Select[DeleteDuplicates@Join[directBreakpoints,
    Flatten[functionBreakpoints[#, minimum, maximum, Append[visited, identifier]] & /@ dependencyNames], {minimum, maximum}], minimum <= # <= maximum &]
];

buildFunction[phaseKey_String, identifier_String, minimum_, maximum_] := Module[{breakpoints, intervals, segments},
  breakpoints = Sort[functionBreakpoints[identifier, minimum, maximum]];
  intervals = Partition[breakpoints, 2, 1];
  segments = MapIndexed[Function[{interval, index}, Module[{sample, expression, terms},
    sample = Mean[interval]; expression = flattenFunctionExpression[identifier, sample]; terms = expressionToTerms[expression];
    <|"minimumTemperature" -> N[interval[[1]]], "maximumTemperature" -> N[interval[[2]]],
      "minimumInclusive" -> True, "maximumInclusive" -> (First[index] == Length[intervals]),
      "segmentRole" -> "dependency-flattened exact SGTE analytic expression", "terms" -> terms|>
  ]], intervals];
  <|"name" -> ("g" <> StringJoin[Capitalize /@ StringSplit[phaseKey, RegularExpression["(?=[A-Z])"]]]),
    "sgteIdentifier" -> identifier, "phase" -> Lookup[phaseDisplayNames, phaseKey, phaseKey],
    "thermodynamicRole" -> If[phaseKey == "liquid", "pure-liquid Gibbs-energy candidate", "solid-phase Gibbs-energy candidate"],
    "quantity" -> "G(phase,T) - H_SER(element)",
    "validity" -> <|"minimumTemperature" -> N[minimum], "maximumTemperature" -> N[maximum], "unit" -> "K", "basis" -> "source model"|>,
    "temperatureSegments" -> segments,
    "metadata" -> <|"sourceReference" -> "sgte-unary-v5-machine-readable-crosscheck-to-dinsdale-1991",
      "sourceFunctionIdentifier" -> identifier, "dependencyTreatment" -> "All SGTE function dependencies were analytically flattened; no coefficients were fitted."|>|>
];

buildCandidate[symbol_String, configuration_Association] := Module[{minimum = 298.15, maximum, functions, expected, configuredPhaseNames, configuredPhaseIdentityNotes},
  maximum = configuration["maximumTemperature"];
  functions = Association@KeyValueMap[#1 -> buildFunction[#1, #2, minimum, maximum] &, configuration["functions"]];
  configuredPhaseNames = Lookup[configuration, "phaseNames", <||>];
  configuredPhaseIdentityNotes = Lookup[configuration, "phaseIdentityNotes", <||>];
  KeyValueMap[If[KeyExistsQ[configuredPhaseNames, #1], functions[#1, "phase"] = configuredPhaseNames[#1]] &, functions];
  KeyValueMap[If[KeyExistsQ[configuredPhaseNames, #1], functions[#1, "metadata", "sourcePhaseDesignation"] = configuredPhaseNames[#1]] &, functions];
  expected = Map[<|"transition" -> <|"lowTemperaturePhase" -> #[[1]], "highTemperaturePhase" -> #[[2]]|>,
      "sourceValue" -> <|"temperature" -> #[[3]], "unit" -> "K", "reference" -> "Dinsdale 1991 transition table", "auditStatus" -> "page-located"|>|> &,
    configuration["expectedTransitions"]];
  <|"schemaVersion" -> "0.2.0", "objectType" -> "unaryStandardReference", "status" -> "batch-candidate-unreviewed",
    "identity" -> <|"elementName" -> configuration["name"], "elementSymbol" -> symbol|>,
    "dataRole" -> "staged batch candidate; exact analytic flattening of selected SGTE unary source functions",
    "referenceState" -> <|"name" -> "Standard Element Reference", "abbreviation" -> "SER",
      "phase" -> <|"name" -> configuration["referencePhase"], "role" -> "stable reference phase at 298.15 K"|>,
      "referenceConditions" -> <|"temperature" -> <|"value" -> 298.15, "unit" -> "K"|>, "pressure" -> <|"value" -> 1, "unit" -> "bar"|>|>,
      "energyReference" -> "H_SER(element), the enthalpy in the Standard Element Reference state"|>,
    "systemConditions" -> <|"pressure" -> <|"value" -> 1, "unit" -> "bar", "treatment" -> "Temperature-only ambient-pressure unary model."|>|>,
    "physicalContributions" -> Lookup[configuration, "specialContributions", {}],
    "scope" -> <|"phases" -> Keys[functions], "sourceToRepositoryPhaseNames" ->
      KeyValueMap[Join[<|"sourceName" -> Lookup[configuredPhaseNames, #1, Lookup[phaseDisplayNames, #1, #1]], "phaseName" -> #1, "sourceFunction" -> #2|>,
        If[KeyExistsQ[configuredPhaseIdentityNotes, #1], <|"identityNote" -> configuredPhaseIdentityNotes[#1]|>, <||>]] &, configuration["functions"]]|>,
    "systemValidity" -> <|"minimumTemperature" -> minimum, "maximumTemperature" -> maximum, "unit" -> "K", "basis" -> "sourceLimited",
      "rationale" -> "Closed OBGEL evaluation domain bounded by the selected Dinsdale/SGTE unary source functions; no extrapolation is supplied."|>,
    "units" -> <|"temperature" -> "K", "molarGibbsEnergy" -> "J/mol"|>,
    "mathematicalConventions" -> <|"temperatureVariable" -> "T", "logarithm" -> "natural", "basisVocabulary" -> supportedBases,
      "termEvaluation" -> "coefficient * basis(T)", "segmentIntervals" -> "lower-inclusive and upper-exclusive, except final segment upper-inclusive",
      "outsideValidity" -> "No candidate value is supplied outside systemValidity.",
      "baseFunctionSemantics" -> "Source dependencies are flattened into single-root phase functions for the current reader."|>,
    "functions" -> functions,
    "sourceProvenance" -> <|"primarySource" -> <|"authors" -> {"A. T. Dinsdale"}, "title" -> "SGTE data for pure elements",
        "journal" -> "CALPHAD", "volume" -> 15, "year" -> 1991, "pages" -> "317-425", "elementDataPages" -> configuration["sourcePages"],
        "doi" -> "10.1016/0364-5916(91)90030-N"|>,
      "machineReadableCrosscheck" -> <|"publisher" -> "Scientific Group Thermodata Europe", "database" -> "SGTE Unary Database",
        "version" -> "5.0", "date" -> "2009-06-02", "sha256" -> sourceHash,
        "note" -> "Coefficient source consumed by the pipeline; candidate phase identities, temperature scope, and transition checks are pinned to the Dinsdale (1991) source audit."|>|>,
    "verification" -> <|"dataRole" -> "derived-non-model-defining", "overallStatus" -> "batch-pipeline-pending-gates",
      "expectedPhaseTransitions" -> expected|>|>
];

evaluateTerms[terms_List, temperature_?NumericQ] := Total[Map[Switch[#["basis"],
    "constant", #["coefficient"], "temperature", #["coefficient"] temperature,
    "temperatureLogTemperature", #["coefficient"] temperature Log[temperature],
    "temperaturePower", #["coefficient"] temperature^#["exponent"], _, Indeterminate] &, terms]];

evaluateFunction[function_Association, temperature_?NumericQ] := Module[{segment},
  segment = SelectFirst[function["temperatureSegments"],
    (#["minimumTemperature"] <= temperature < #["maximumTemperature"]) || (#["maximumInclusive"] && temperature == #["maximumTemperature"]) &, Missing["Gap"]];
  If[MissingQ[segment], Indeterminate, evaluateTerms[segment["terms"], temperature]]
];

continuityMetrics[function_Association] := Module[{segments, boundaries},
  segments = function["temperatureSegments"]; boundaries = Range[Length[segments] - 1];
  Map[Function[index, Module[{left, right, boundary, leftValue, rightValue, leftSlope, rightSlope},
    left = segments[[index]]; right = segments[[index + 1]]; boundary = left["maximumTemperature"];
    leftValue = evaluateTerms[left["terms"], boundary]; rightValue = evaluateTerms[right["terms"], boundary];
    leftSlope = (evaluateTerms[left["terms"], boundary + .001] - evaluateTerms[left["terms"], boundary - .001])/.002;
    rightSlope = (evaluateTerms[right["terms"], boundary + .001] - evaluateTerms[right["terms"], boundary - .001])/.002;
    <|"temperature" -> boundary, "c0Residual" -> N[rightValue - leftValue], "c1Residual" -> N[rightSlope - leftSlope]|>
  ]], boundaries]
];

collapseRuns[list_List] := First /@ Split[list];

bisectRoot[differenceFunction_, lowerInitial_?NumericQ, upperInitial_?NumericQ] := Module[
  {lower = lowerInitial, upper = upperInitial, lowerValue, midpoint, midpointValue, iteration},
  lowerValue = differenceFunction[lower];
  For[iteration = 1, iteration <= 80, iteration++,
    midpoint = Mean[{lower, upper}]; midpointValue = differenceFunction[midpoint];
    If[Sign[midpointValue] == Sign[lowerValue], lower = midpoint; lowerValue = midpointValue, upper = midpoint];
  ];
  Mean[{lower, upper}]
];

findEnvelope[candidate_Association] := Module[{functions, minimum, maximum, grid, stableKeys, changeIndices, transitions},
  functions = candidate["functions"]; minimum = candidate["systemValidity", "minimumTemperature"]; maximum = candidate["systemValidity", "maximumTemperature"];
  grid = Subdivide[minimum, maximum, 5000];
  stableKeys = Map[Function[temperature, First@MinimalBy[Keys[functions], evaluateFunction[functions[#], temperature] &]], grid];
  changeIndices = Flatten@Position[Partition[stableKeys, 2, 1], {left_, right_} /; left =!= right];
  transitions = Map[Function[index, Module[{leftKey, rightKey, lower, upper, root, residual},
    leftKey = stableKeys[[index]]; rightKey = stableKeys[[index + 1]]; lower = grid[[index]]; upper = grid[[index + 1]];
    root = bisectRoot[Function[temperature, evaluateFunction[functions[leftKey], temperature] - evaluateFunction[functions[rightKey], temperature]], lower, upper];
    residual = evaluateFunction[functions[leftKey], root] - evaluateFunction[functions[rightKey], root];
    <|"lowTemperaturePhase" -> leftKey, "highTemperaturePhase" -> rightKey, "temperature" -> N[root], "rootResidual" -> N[residual]|>
  ]], changeIndices];
  <|"stableSequence" -> collapseRuns[stableKeys], "transitions" -> transitions,
    "finiteEvaluation" -> And @@ Flatten@Table[NumberQ[evaluateFunction[function, temperature]] && Im[N[evaluateFunction[function, temperature]]] == 0,
      {function, Values[functions]}, {temperature, Subdivide[minimum, maximum, 200]}]|>
];

validateCandidate[symbol_String, candidate_Association, configuration_Association] := Module[
  {functions, minimum, maximum, syntaxGate, schemaGate, endpointGate, validityGate, gapGate, basisGate, dependencyGate,
   continuity, continuityGate, envelope, recovered, expected, transitionGate, residualGate, topologyGate, provenanceGate, reasons, gates, status},
  functions = candidate["functions"]; minimum = candidate["systemValidity", "minimumTemperature"]; maximum = candidate["systemValidity", "maximumTemperature"];
  syntaxGate = Quiet@Check[AssociationQ[ImportString[ExportString[candidate, "RawJSON"], "RawJSON"]], False];
  schemaGate = candidate["schemaVersion"] === "0.2.0" && candidate["objectType"] === "unaryStandardReference" && AssociationQ[functions] && Length[functions] >= 2;
  endpointGate = And @@ Map[Function[function, With[{segments = function["temperatureSegments"]},
    First[segments]["minimumTemperature"] == minimum && Last[segments]["maximumTemperature"] == maximum &&
    First[segments]["minimumInclusive"] && Last[segments]["maximumInclusive"] &&
    And @@ MapThread[#1["maximumTemperature"] == #2["minimumTemperature"] && ! #1["maximumInclusive"] && #2["minimumInclusive"] &,
      {Most[segments], Rest[segments]}]]], Values[functions]];
  validityGate = And @@ Map[#["validity", "minimumTemperature"] <= minimum && #["validity", "maximumTemperature"] >= maximum &, Values[functions]];
  gapGate = And @@ Flatten@Table[NumberQ[evaluateFunction[function, temperature]], {function, Values[functions]}, {temperature, Subdivide[minimum, maximum, 500]}];
  basisGate = And @@ (MemberQ[supportedBases, #] & /@ Cases[candidate,
      association_Association /; KeyExistsQ[association, "basis"] && KeyExistsQ[association, "coefficient"] :> association["basis"], Infinity]);
  dependencyGate = FreeQ[candidate, "baseFunction"];
  continuity = Map[continuityMetrics, functions];
  continuityGate = And @@ Map[(Abs[#["c0Residual"]] <= 2.0 && Abs[#["c1Residual"]] <= .01) &, Flatten[Values[continuity]]];
  envelope = findEnvelope[candidate]; recovered = envelope["transitions"]; expected = configuration["expectedTransitions"];
  transitionGate = Length[recovered] == Length[expected] && And @@ MapThread[
    #1["lowTemperaturePhase"] == #2[[1]] && #1["highTemperaturePhase"] == #2[[2]] && Abs[#1["temperature"] - #2[[3]]] <= 1.0 &,
    {recovered, expected}];
  residualGate = And @@ (Abs[#["rootResidual"]] <= .001 & /@ recovered);
  topologyGate = Length[envelope["stableSequence"]] <= 4 && DuplicateFreeQ[envelope["stableSequence"]];
  provenanceGate = KeyExistsQ[candidate, "sourceProvenance"] && StringLength[sourceHash] == 64;
  gates = <|"sourceExtractionCompleteness" -> And @@ (AssociationQ[Lookup[parsedRecords, #, Missing[]]] & /@ Values[configuration["functions"]]),
    "jsonSyntax" -> syntaxGate, "schema020Structure" -> schemaGate, "segmentEndpoints" -> endpointGate,
    "validityConsistency" -> validityGate, "noUndefinedGaps" -> gapGate, "basisSupport" -> basisGate,
    "singleRootDependencies" -> dependencyGate, "continuity" -> continuityGate, "independentNumericalEvaluation" -> envelope["finiteEvaluation"],
    "envelopeTopology" -> topologyGate, "authoritativeTransitionComparison" -> transitionGate,
    "rootResiduals" -> residualGate, "provenanceAndStatus" -> provenanceGate|>;
  reasons = Join[Lookup[configuration, "reviewReasons", {}], Map[Function[gateName, Switch[gateName,
      "continuity", "One or more source segment boundaries exceed the pipeline C0/C1 tolerances; coefficients were not altered.",
      "authoritativeTransitionComparison", "Recovered stable transitions do not match the Dinsdale transition table within 1 K.",
      "envelopeTopology", "The stable envelope is re-entrant or topologically complex and requires review.",
      _, "Automated gate failed: " <> gateName]], Keys@Select[gates, Not]]];
  status = If[reasons === {}, "PASS " <> longDash <> " canonical unary candidate", "REVIEW REQUIRED " <> longDash <> " " <> StringRiffle[reasons, "; "]];
  <|"elementSymbol" -> symbol, "elementName" -> configuration["name"], "classification" -> status,
    "phasesFound" -> Keys[functions], "sourceValidity" -> <|"minimumTemperature" -> minimum, "maximumTemperature" -> maximum, "unit" -> "K"|>,
    "modelValidity" -> Map[#["validity"] &, functions], "systemScope" -> <|"pressure" -> "1 bar", "basis" -> supportedBases|>,
    "specialContributions" -> Lookup[configuration, "specialContributions", {}], "expectedStableTransitions" -> expected,
    "recoveredStableSequence" -> envelope["stableSequence"], "recoveredStableTransitions" -> recovered,
    "validationMetrics" -> <|"gates" -> gates, "continuity" -> continuity, "transitionToleranceK" -> 1.0,
      "c0ToleranceJPerMol" -> 2.0, "c1ToleranceJPerMolK" -> .01|>, "reasons" -> reasons|>
];

processElement[symbol_String, configuration_Association] := Module[{blocker, candidate, result, candidatePath},
  blocker = Lookup[configuration, "sourceBlocker", Missing["None"]];
  If[! MissingQ[blocker],
    result = <|"elementSymbol" -> symbol, "elementName" -> configuration["name"],
      "classification" -> "REVIEW REQUIRED " <> longDash <> " " <> blocker, "phasesFound" -> {},
      "sourceValidity" -> <|"minimumTemperature" -> 298.15, "maximumTemperature" -> configuration["maximumTemperature"], "unit" -> "K"|>,
      "modelValidity" -> <||>, "systemScope" -> <|"pressure" -> "1 bar", "basis" -> supportedBases|>,
      "specialContributions" -> If[symbol == "Zr", {"Dinsdale Gpres pressure contribution"}, {"Dinsdale Gpres pressure contribution"}],
      "expectedStableTransitions" -> configuration["expectedTransitions"], "recoveredStableSequence" -> {}, "recoveredStableTransitions" -> {},
      "validationMetrics" -> <|"gates" -> <|"sourceExtractionCompleteness" -> False|>|>, "reasons" -> {blocker}|>;
    Export[FileNameJoin[{diagnosticRoot, ToLowerCase[symbol] <> "-diagnostics.json"}], result, "RawJSON", "Compact" -> False];
    Return[result]
  ];
  candidate = buildCandidate[symbol, configuration]; result = validateCandidate[symbol, candidate, configuration];
  candidate["status"] = If[StringStartsQ[result["classification"], "PASS"],
    "staged-candidate-automated-gates-passed-pending-human-review", "staged-candidate-review-required"];
  candidate["verification", "overallStatus"] = candidate["status"];
  candidate["verification", "batchValidation"] = result["validationMetrics"];
  candidate["verification", "computedPhaseTransitions"] = result["recoveredStableTransitions"];
  candidatePath = FileNameJoin[{candidateRoot, ToLowerCase[symbol] <> "-standard-reference-candidate.json"}];
  Export[candidatePath, candidate, "RawJSON", "Compact" -> False];
  Export[FileNameJoin[{diagnosticRoot, ToLowerCase[symbol] <> "-diagnostics.json"}], result, "RawJSON", "Compact" -> False];
  result
];

evaluateCanonicalFunction[data_Association, functionKey_String, temperature_?NumericQ, visited_: {}] := Module[
  {function, segment, baseName, baseKey, ownValue, functions},
  If[MemberQ[visited, functionKey], Return[Indeterminate]];
  functions = data["functions"]; function = functions[functionKey];
  segment = SelectFirst[function["temperatureSegments"],
    (#["minimumTemperature"] <= temperature < #["maximumTemperature"]) || (#["maximumInclusive"] && temperature == #["maximumTemperature"]) &, Missing["Gap"]];
  If[MissingQ[segment], Return[Indeterminate]];
  ownValue = evaluateTerms[segment["terms"], temperature];
  baseName = Lookup[function, "baseFunction", Missing["None"]];
  If[MissingQ[baseName], ownValue,
    baseKey = SelectFirst[Keys[functions], functions[#]["name"] === baseName &, Missing["BaseNotFound"]];
    If[MissingQ[baseKey], Indeterminate, ownValue + evaluateCanonicalFunction[data, baseKey, temperature, Append[visited, functionKey]]]
  ]
];

runRegressionCheck[fileName_String, expectedSequence_List] := Module[{path, data, minimum, maximum, functions, grid, stableSequence},
  path = FileNameJoin[{repositoryRoot, "data", "unary", fileName}]; data = Import[path, "RawJSON"];
  minimum = data["systemValidity", "minimumTemperature"]; maximum = data["systemValidity", "maximumTemperature"]; functions = data["functions"];
  grid = Subdivide[minimum, maximum, 4000];
  stableSequence = collapseRuns@Map[Function[temperature,
      First@MinimalBy[Keys[functions], evaluateCanonicalFunction[data, #, temperature] &]], grid];
  <|"file" -> fileName, "expectedStableSequence" -> expectedSequence, "recoveredStableSequence" -> stableSequence,
    "pass" -> stableSequence === expectedSequence|>
];

regressionChecks = {
  runRegressionCheck["pb-standard-reference.json", {"stableReference", "metastableLiquidReference"}],
  runRegressionCheck["bi-standard-reference.json", {"stableReference", "metastableLiquidReference"}],
  runRegressionCheck["mg-standard-reference.json", {"stableReference", "metastableLiquidReference"}],
  runRegressionCheck["fe-standard-reference.json", {"bcc", "fcc", "bcc", "liquid"}]
};

formatNumber[value_?NumericQ] := ToString[DecimalForm[N[value], {Infinity, 4}], OutputForm];
formatTransitions[transitions_List] := If[transitions === {}, "-", StringRiffle[Map[
    #["lowTemperaturePhase"] <> " -> " <> #["highTemperaturePhase"] <> " at " <> formatNumber[#["temperature"]] <> " K" &, transitions], "; "]];
formatExpectedTransitions[transitions_List] := If[transitions === {}, "-", StringRiffle[Map[
    #[[1]] <> " -> " <> #[[2]] <> " at " <> formatNumber[#[[3]]] <> " K" &, transitions], "; "]];
formatGateSummary[result_Association] := Module[{gates = result["validationMetrics", "gates"], passed, total},
  passed = Count[Values[gates], True]; total = Length[gates]; ToString[passed] <> "/" <> ToString[total] <> " automated gates passed"];

results = KeyValueMap[processElement, elementConfigurations];
batchReport = <|"schemaVersion" -> "0.2.0", "reportType" -> "unaryBatchValidationReport", "generatedAt" -> DateString[Now, "ISODateTime"],
  "source" -> <|"path" -> sourcePath, "sha256" -> sourceHash, "primaryReference" -> "Dinsdale 1991", "machineReadableCrosscheck" -> "SGTE Unary Database v5.0"|>,
  "policy" -> <|"passLabel" -> "PASS " <> longDash <> " canonical unary candidate", "reviewLabel" -> "REVIEW REQUIRED " <> longDash <> " <specific reasons>",
    "promotion" -> "No files are written to data/unary by this pipeline."|>, "elements" -> results,
  "regressionChecks" -> regressionChecks,
  "summary" -> <|"pass" -> Lookup[Select[results, StringStartsQ[#["classification"], "PASS"] &], "elementSymbol"],
    "reviewRequired" -> Lookup[Select[results, StringStartsQ[#["classification"], "REVIEW"] &], "elementSymbol"]|>|>;

missingReportValues = Cases[batchReport, _Missing, Infinity];
If[missingReportValues =!= {}, Print["Unresolved report values: " <> ToString[missingReportValues, InputForm]]];
batchReport = batchReport /. _Missing -> Null;
Export[FileNameJoin[{reportRoot, "batch-report.json"}], batchReport, "RawJSON", "Compact" -> False];

summaryLines = Join[{
  "# OBGEL unary batch 0.2.0 - first batch report", "",
  "Generated by `tools/unary-batch-pipeline.wl`. Candidates remain under `working/`; nothing was promoted to `data/unary/`.", "",
  "## Outcome", "",
  "- PASS: " <> StringRiffle[batchReport["summary", "pass"], ", "],
  "- REVIEW REQUIRED: " <> StringRiffle[batchReport["summary", "reviewRequired"], ", "], "",
  "## Per-element results", ""
  }, Flatten@Map[Function[result, {
    "### " <> result["elementSymbol"] <> " - " <> result["elementName"], "",
    "- Classification: **" <> result["classification"] <> "**",
    "- Phases found: " <> If[result["phasesFound"] === {}, "not emitted because source extraction was blocked", StringRiffle[result["phasesFound"], ", "]],
    "- Source/model validity: " <> formatNumber[result["sourceValidity", "minimumTemperature"]] <> "-" <>
      formatNumber[result["sourceValidity", "maximumTemperature"]] <> " K; per-function model validity is recorded in the machine report.",
    "- System scope/basis: fixed 1 bar temperature-only unary; constant, T, T ln(T), and T^n.",
    "- Special contributions: " <> If[result["specialContributions"] === {}, "none", StringRiffle[result["specialContributions"], "; "]],
    "- Expected stable transitions: " <> formatExpectedTransitions[result["expectedStableTransitions"]],
    "- Recovered stable topology: " <> If[result["recoveredStableSequence"] === {}, "not evaluated", StringRiffle[result["recoveredStableSequence"], " -> "]],
    "- Recovered stable transitions: " <> formatTransitions[result["recoveredStableTransitions"]],
    "- Validation metrics: " <> formatGateSummary[result] <> "; detailed C0/C1 and root residuals are in `batch-report.json`.",
    "- Reasons: " <> If[result["reasons"] === {}, "all required automated gates passed", StringRiffle[result["reasons"], "; "]], ""
  }], results], {
  "## Regression checks", "",
  Sequence @@ Map[("- " <> #["file"] <> ": " <> If[#["pass"], "PASS", "FAIL"] <> " (" <>
      StringRiffle[#["recoveredStableSequence"], " -> "] <> ")") &, regressionChecks], "",
  "## Promotion rule", "",
  "PASS means the staged object is a canonical unary candidate, not that it has already been promoted. Human review remains required before copying any candidate into `data/unary/`. REVIEW REQUIRED records are diagnostic only."
}];
Export[FileNameJoin[{reportRoot, "batch-summary.md"}], StringRiffle[summaryLines, "\n"], "Text"];
Print[ExportString[batchReport["summary"], "RawJSON", "Compact" -> False]];
