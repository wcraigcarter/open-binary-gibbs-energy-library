(* ::Package:: *)

ClearAll[
  repoDirectory,
  canonicalModel,
  legacyModel,
  makeLegacyPhase,
  phaseValue,
  phaseDerivative,
  tangentIntercept,
  eutecticRoot,
  eutecticResiduals,
  twoPhaseRoot,
  sampleTemperatures,
  sampleCompositions,
  energyRows,
  energyMaximumByPhase,
  boundaryCases,
  boundaryRows,
  topologyPreserved,
  symbolicInterfacePassed,
  regressionTolerances,
  regressionPassed,
  regressionReport
];

repoDirectory = ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]];
Get[FileNameJoin[{repoDirectory, "examples", "mathematica", "Binary-reference-reader.wl"}]];

canonicalModel = binaryLoadSystemModel[
  FileNameJoin[{repoDirectory, "data", "cu-ag", "system.json"}]
];

canonicalLiquidFunction =
  binaryMolarGibbsFreeEnergyFunction[canonicalModel]["liquid"];
canonicalFccFunction =
  binaryMolarGibbsFreeEnergyFunction[canonicalModel]["fcc-a1"];

symbolicInterfacePassed =
  Head[canonicalLiquidFunction] === Function &&
  Head[canonicalFccFunction] === Function &&
  Head[canonicalLiquidFunction[symbolicTemperature]] === Function &&
  Head[canonicalFccFunction[symbolicTemperature]] === Function &&
  FreeQ[canonicalLiquidFunction, binaryMolarGibbsFreeEnergy] &&
  FreeQ[canonicalFccFunction, binaryMolarGibbsFreeEnergy] &&
  ! FreeQ[canonicalLiquidFunction[symbolicTemperature][symbolicComposition], symbolicTemperature] &&
  ! FreeQ[canonicalLiquidFunction[symbolicTemperature][symbolicComposition], symbolicComposition] &&
  NumericQ[canonicalLiquidFunction[1053.][0.4]] &&
  NumericQ[canonicalFccFunction[1053.][0.4]];

makeLegacyPhase[phaseData_Association] := Module[{expressionData},
  expressionData = phaseData["gibbsEnergyModel"]["expression"];
  ReplacePart[
    phaseData,
    {"gibbsEnergyModel", "expression"} ->
      KeyDrop[expressionData, "unaryEndmemberReferences"]
  ]
];

legacyModel = ReplacePart[
  canonicalModel,
  "PhaseDataByIdentifier" -> Map[makeLegacyPhase, canonicalModel["PhaseDataByIdentifier"]]
];

phaseValue[model_Association][phaseIdentifier_String][temperature_?NumericQ][moleFractionCu_?NumericQ] :=
  binaryMolarGibbsFreeEnergy[model][phaseIdentifier][temperature][moleFractionCu];

phaseDerivative[model_Association][phaseIdentifier_String][temperature_?NumericQ][moleFractionCu_?NumericQ] :=
  With[{compositionStep = 10^-5},
    (
      phaseValue[model][phaseIdentifier][temperature][moleFractionCu + compositionStep] -
      phaseValue[model][phaseIdentifier][temperature][moleFractionCu - compositionStep]
    )/(2 compositionStep)
  ];

tangentIntercept[model_, phaseIdentifier_, temperature_, moleFractionCu_] :=
  phaseValue[model][phaseIdentifier][temperature][moleFractionCu] -
    moleFractionCu phaseDerivative[model][phaseIdentifier][temperature][moleFractionCu];

eutecticRoot[model_Association] := Quiet[
  FindRoot[
    {
      phaseDerivative[model]["fcc-a1"][temperature][moleFractionFccAg] ==
        phaseDerivative[model]["liquid"][temperature][moleFractionLiquid],
      phaseDerivative[model]["fcc-a1"][temperature][moleFractionFccCu] ==
        phaseDerivative[model]["liquid"][temperature][moleFractionLiquid],
      tangentIntercept[model, "fcc-a1", temperature, moleFractionFccAg] ==
        tangentIntercept[model, "liquid", temperature, moleFractionLiquid],
      tangentIntercept[model, "fcc-a1", temperature, moleFractionFccCu] ==
        tangentIntercept[model, "liquid", temperature, moleFractionLiquid]
    },
    {
      {moleFractionFccAg, 0.13},
      {moleFractionLiquid, 0.40},
      {moleFractionFccCu, 0.95},
      {temperature, 1053.}
    },
    AccuracyGoal -> 8,
    PrecisionGoal -> 8,
    MaxIterations -> 200
  ],
  {FindRoot::lstol}
];

eutecticResiduals[model_Association, root_List] := Module[
  {moleFractionFccAgValue, moleFractionLiquidValue, moleFractionFccCuValue, temperatureValue},
  {
    moleFractionFccAgValue,
    moleFractionLiquidValue,
    moleFractionFccCuValue,
    temperatureValue
  } = {moleFractionFccAg, moleFractionLiquid, moleFractionFccCu, temperature} /. root;
  {
    phaseDerivative[model]["fcc-a1"][temperatureValue][moleFractionFccAgValue] -
      phaseDerivative[model]["liquid"][temperatureValue][moleFractionLiquidValue],
    phaseDerivative[model]["fcc-a1"][temperatureValue][moleFractionFccCuValue] -
      phaseDerivative[model]["liquid"][temperatureValue][moleFractionLiquidValue],
    tangentIntercept[model, "fcc-a1", temperatureValue, moleFractionFccAgValue] -
      tangentIntercept[model, "liquid", temperatureValue, moleFractionLiquidValue],
    tangentIntercept[model, "fcc-a1", temperatureValue, moleFractionFccCuValue] -
      tangentIntercept[model, "liquid", temperatureValue, moleFractionLiquidValue]
  }
];

twoPhaseRoot[
  model_Association,
  firstPhase_String,
  secondPhase_String,
  temperatureValue_?NumericQ,
  firstGuess_?NumericQ,
  secondGuess_?NumericQ
] := Quiet[
  FindRoot[
    {
      phaseDerivative[model][firstPhase][temperatureValue][firstComposition] ==
        phaseDerivative[model][secondPhase][temperatureValue][secondComposition],
      tangentIntercept[model, firstPhase, temperatureValue, firstComposition] ==
        tangentIntercept[model, secondPhase, temperatureValue, secondComposition]
    },
    {{firstComposition, firstGuess}, {secondComposition, secondGuess}},
    AccuracyGoal -> 8,
    PrecisionGoal -> 8,
    MaxIterations -> 200
  ],
  {FindRoot::lstol}
];

sampleTemperatures = {
  298.15, 500., 800., 1000., 1053., 1100., 1200., 1234.92,
  1234.93, 1300., 1357.76, 1357.77, 1600., 2999., 3000.
};
sampleCompositions = {0., 0.05, 0.13, 0.25, 0.4, 0.5, 0.75, 0.95, 1.};

energyRows = Flatten[
  Table[
    <|
      "phase" -> phaseIdentifier,
      "temperature" -> temperatureValue,
      "moleFractionCu" -> moleFractionCuValue,
      "deltaG" -> (
        phaseValue[canonicalModel][phaseIdentifier][temperatureValue][moleFractionCuValue] -
        phaseValue[legacyModel][phaseIdentifier][temperatureValue][moleFractionCuValue]
      )
    |>,
    {phaseIdentifier, {"liquid", "fcc-a1"}},
    {temperatureValue, sampleTemperatures},
    {moleFractionCuValue, sampleCompositions}
  ],
  2
];

energyMaximumByPhase = Association @ KeyValueMap[
  #1 -> Max[Abs[Lookup[#2, "deltaG"]]] &,
  GroupBy[energyRows, #1["phase"] &]
];

legacyEutecticRoot = eutecticRoot[legacyModel];
canonicalEutecticRoot = eutecticRoot[canonicalModel];

boundaryCases = {
  <|"name" -> "fcc-fcc", "temperature" -> 800., "firstPhase" -> "fcc-a1", "secondPhase" -> "fcc-a1", "guesses" -> {0.03, 0.99}|>,
  <|"name" -> "fcc-fcc", "temperature" -> 1000., "firstPhase" -> "fcc-a1", "secondPhase" -> "fcc-a1", "guesses" -> {0.10, 0.97}|>,
  <|"name" -> "fcc-liquid", "temperature" -> 1100., "firstPhase" -> "fcc-a1", "secondPhase" -> "liquid", "guesses" -> {0.11, 0.27}|>,
  <|"name" -> "liquid-fcc", "temperature" -> 1100., "firstPhase" -> "liquid", "secondPhase" -> "fcc-a1", "guesses" -> {0.53, 0.95}|>,
  <|"name" -> "fcc-liquid", "temperature" -> 1200., "firstPhase" -> "fcc-a1", "secondPhase" -> "liquid", "guesses" -> {0.03, 0.06}|>,
  <|"name" -> "liquid-fcc", "temperature" -> 1200., "firstPhase" -> "liquid", "secondPhase" -> "fcc-a1", "guesses" -> {0.76, 0.96}|>
};

boundaryRows = Map[
  Function[boundaryCase,
    Module[{legacyRoot, canonicalRoot, legacyValues, canonicalValues},
      legacyRoot = twoPhaseRoot[
        legacyModel,
        boundaryCase["firstPhase"],
        boundaryCase["secondPhase"],
        boundaryCase["temperature"],
        boundaryCase["guesses"][[1]],
        boundaryCase["guesses"][[2]]
      ];
      canonicalRoot = twoPhaseRoot[
        canonicalModel,
        boundaryCase["firstPhase"],
        boundaryCase["secondPhase"],
        boundaryCase["temperature"],
        boundaryCase["guesses"][[1]],
        boundaryCase["guesses"][[2]]
      ];
      legacyValues = {firstComposition, secondComposition} /. legacyRoot;
      canonicalValues = {firstComposition, secondComposition} /. canonicalRoot;
      Join[
        KeyTake[boundaryCase, {"name", "temperature", "firstPhase", "secondPhase"}],
        <|
          "legacyCompositions" -> legacyValues,
          "canonicalCompositions" -> canonicalValues,
          "compositionDelta" -> (canonicalValues - legacyValues)
        |>
      ]
    ]
  ],
  boundaryCases
];

regressionTolerances = <|
  "phaseEnergyJPerMol" -> 0.01,
  "eutecticTemperatureK" -> 0.001,
  "composition" -> 10^-6,
  "equilibriumResidual" -> 10^-5
|>;

eutecticLegacyValues =
  {moleFractionFccAg, moleFractionLiquid, moleFractionFccCu, temperature} /. legacyEutecticRoot;
eutecticCanonicalValues =
  {moleFractionFccAg, moleFractionLiquid, moleFractionFccCu, temperature} /. canonicalEutecticRoot;
eutecticDelta = eutecticCanonicalValues - eutecticLegacyValues;
legacyResiduals = eutecticResiduals[legacyModel, legacyEutecticRoot];
canonicalResiduals = eutecticResiduals[canonicalModel, canonicalEutecticRoot];

topologyPreserved = And @@ Map[
  Function[boundaryRow,
    OrderedQ[boundaryRow["legacyCompositions"]] &&
      OrderedQ[boundaryRow["canonicalCompositions"]] &&
      And @@ Thread[0 < boundaryRow["canonicalCompositions"] < 1]
  ],
  boundaryRows
];

regressionPassed =
  Max[Values[energyMaximumByPhase]] <= regressionTolerances["phaseEnergyJPerMol"] &&
  Max[Abs[eutecticDelta[[1 ;; 3]]]] <= regressionTolerances["composition"] &&
  Abs[eutecticDelta[[4]]] <= regressionTolerances["eutecticTemperatureK"] &&
  Max[Abs[Flatten[Lookup[boundaryRows, "compositionDelta"]]]] <= regressionTolerances["composition"] &&
  Max[Abs[Join[legacyResiduals, canonicalResiduals]]] <= regressionTolerances["equilibriumResidual"] &&
  topologyPreserved &&
  symbolicInterfacePassed;

regressionReport = <|
  "passed" -> regressionPassed,
  "effectiveValidity" -> AssociationMap[
    binaryPhaseValidity[canonicalModel][#1] &,
    {"liquid", "fcc-a1"}
  ],
  "tolerances" -> regressionTolerances,
  "maximumAbsoluteDeltaGByPhase" -> energyMaximumByPhase,
  "legacyEutectic" -> eutecticLegacyValues,
  "canonicalEutectic" -> eutecticCanonicalValues,
  "eutecticDelta" -> eutecticDelta,
  "legacyEutecticResiduals" -> legacyResiduals,
  "canonicalEutecticResiduals" -> canonicalResiduals,
  "phaseBoundaryComparisons" -> boundaryRows,
  "topologyPreserved" -> topologyPreserved,
  "symbolicNestedFunctionInterface" -> symbolicInterfacePassed
|>;

Print[regressionReport // InputForm];
If[! TrueQ[regressionPassed], Exit[1]];
