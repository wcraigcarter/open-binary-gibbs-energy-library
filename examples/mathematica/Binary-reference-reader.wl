(* ::Package:: *)

(*
  OBGEL binary reference reader.

  Canonical unary end-member references are preferred when present. Embedded
  referenceStateContributions remain supported as a backward-compatible
  baseline for binary phase files that have not yet migrated.

  Distribute this file with the referenced JSON data and load it with Get.
  The four documented entry points below form the public interface. Helpers
  are internal by convention; this reader currently loads into the caller's
  context rather than isolating symbols with BeginPackage/Private.
*)

ClearAll[
  binaryLoadSystemModel,
  binaryPhaseMetadata,
  binaryTemperatureBasisValue,
  binaryTemperatureTermsValue,
  binaryTemperatureSegmentCondition,
  binaryTemperatureSegmentContainsQ,
  binaryUnaryFunctionExpression,
  binaryUnaryFunctionValue,
  binaryEmbeddedEndmemberExpression,
  binaryEmbeddedEndmemberValue,
  binaryComponentFraction,
  binaryCanonicalReferenceContribution,
  binaryEmbeddedReferenceContribution,
  binaryReferenceContribution,
  binaryIdealMixingContribution,
  binaryRedlichKisterContribution,
  binaryPhaseValidity,
  binaryMolarGibbsFreeEnergy,
  binaryMolarGibbsFreeEnergyFunction
];

binaryLoadSystemModel::usage =
  "binaryLoadSystemModel[systemFile] loads an OBGEL binary system JSON file and its referenced phase and unary data, resolving paths relative to the system file. It returns a model Association for the binary reader. Query model[\"Phase Metadata\"] for detailed phase provenance or model[\"Provenance Summary\"] for a compact status summary. Detected missing files or unary schema/identity mismatches return $Failed with a message.";
binaryPhaseValidity::usage =
  "binaryPhaseValidity[model][phaseIdentifier] returns {minimumTemperature, maximumTemperature} in kelvin, intersecting the declared system, phase, and referenced unary system temperature ranges. This is a model-use interval, not a phase-stability or assessment-status claim. Use an identifier from Keys[model[\"PhaseDataByIdentifier\"]], such as \"fcc-a1\".";
binaryMolarGibbsFreeEnergy::usage =
  "binaryMolarGibbsFreeEnergy[model][phaseIdentifier][temperature][moleFraction] gives molar Gibbs free energy in J/mol using temperature in kelvin and the phase's declared independent component mole fraction (xCu for Cu-Ag). It supports symbolic arguments and numerical evaluation, prefers canonical unary endpoints when available, and retains embedded endpoints as a fallback. Numerical arguments outside the effective temperature interval or [0,1] composition interval return Missing with a message.";
binaryMolarGibbsFreeEnergyFunction::usage =
  "binaryMolarGibbsFreeEnergyFunction[model][phaseIdentifier] constructs an expanded symbolic Function[temperature, Function[moleFraction, expression]] for differentiation, plotting, and common-tangent calculations. For example, g = binaryMolarGibbsFreeEnergyFunction[model][\"liquid\"]; g[1053.][0.4]. Units and composition conventions match binaryMolarGibbsFreeEnergy. The returned function does not rerun numerical argument checks; callers must respect binaryPhaseValidity[model][phaseIdentifier] and 0 <= moleFraction <= 1.";

binaryLoadSystemModel::missing = "Required OBGEL file does not exist: `1`.";
binaryLoadSystemModel::unaryschema =
  "Unary source for `1` declares schema `2`; expected `3`.";
binaryLoadSystemModel::unaryidentity =
  "Unary source for `1` declares identity symbol `2`; expected `3`.";
binaryUnaryFunctionValue::function =
  "Unary function `1` is absent from the canonical unary object for `2`.";
binaryUnaryFunctionValue::segment =
  "No unary temperature segment for function `1` contains `2` K.";
binaryCanonicalReferenceContribution::structure =
  "Unary function `1` for `2` declares structural phase `3`; the binary phase requires `4`.";
binaryEmbeddedEndmemberValue::segment =
  "No embedded temperature segment for component `1` contains `2` K.";
binaryRedlichKisterContribution::order =
  "No explicit Redlich-Kister component order is present; inferring independent-component-first ordering for backward compatibility.";
binaryMolarGibbsFreeEnergy::temperature =
  "Temperature `1` K is outside the effective validity interval `2` for phase `3`.";
binaryMolarGibbsFreeEnergy::composition =
  "Composition `1` is outside the closed mole-fraction interval [0,1].";

binaryLoadSystemModel[systemFile_String] := Module[
  {
    systemPath,
    systemDirectory,
    systemData,
    phaseDataByIdentifier,
    unaryDataByComponent,
    unarySourceByComponent,
    phasePath,
    unaryPath,
    unaryData,
    component
  },
  systemPath = ExpandFileName[systemFile];
  If[! FileExistsQ[systemPath],
    Message[binaryLoadSystemModel::missing, systemPath];
    Return[$Failed]
  ];
  systemDirectory = DirectoryName[systemPath];
  systemData = Import[systemPath, "RawJSON"];
  phaseDataByIdentifier = Association @ Map[
    Function[phaseEntry,
      phasePath = ExpandFileName[FileNameJoin[{systemDirectory, phaseEntry["file"]}]];
      If[! FileExistsQ[phasePath],
        Message[binaryLoadSystemModel::missing, phasePath];
        Return[$Failed, Module]
      ];
      phaseEntry["phaseIdentifier"] -> Import[phasePath, "RawJSON"]
    ],
    systemData["phaseModels"]
  ];
  unarySourceByComponent = Association @ Map[
    #1["component"] -> #1 &,
    Lookup[systemData, "unaryDataSources", {}]
  ];
  unaryDataByComponent = Association @ Map[
    Function[unarySource,
      component = unarySource["component"];
      unaryPath = ExpandFileName[FileNameJoin[{systemDirectory, unarySource["file"]}]];
      If[! FileExistsQ[unaryPath],
        Message[binaryLoadSystemModel::missing, unaryPath];
        Return[$Failed, Module]
      ];
      unaryData = Import[unaryPath, "RawJSON"];
      If[unaryData["schemaVersion"] =!= unarySource["schemaVersion"],
        Message[
          binaryLoadSystemModel::unaryschema,
          component,
          unaryData["schemaVersion"],
          unarySource["schemaVersion"]
        ];
        Return[$Failed, Module]
      ];
      If[unaryData["identity"]["elementSymbol"] =!= unarySource["identitySymbol"],
        Message[
          binaryLoadSystemModel::unaryidentity,
          component,
          unaryData["identity"]["elementSymbol"],
          unarySource["identitySymbol"]
        ];
        Return[$Failed, Module]
      ];
      component -> unaryData
    ],
    Values[unarySourceByComponent]
  ];
  <|
    "SystemFile" -> systemPath,
    "SystemDirectory" -> systemDirectory,
    "SystemData" -> systemData,
    "PhaseDataByIdentifier" -> phaseDataByIdentifier,
    "UnaryDataByComponent" -> unaryDataByComponent,
    "UnarySourceByComponent" -> unarySourceByComponent,
    "Phase Metadata" -> Map[binaryPhaseMetadata, phaseDataByIdentifier],
    "Provenance Summary" -> Map[
      KeyTake[#, {"modelProvenance", "binaryInteractionProvenance"}] &,
      Map[binaryPhaseMetadata, phaseDataByIdentifier]
    ]
  |>
];

(* Internal helper: assemble the queryable provenance record for one phase.
   Metadata is descriptive only: never infer assessment from stability or
   inventory membership, and never emit notices during function evaluation. *)
binaryPhaseMetadata[phaseData_Association] := Join[
  <|"modelProvenance" -> Lookup[phaseData, "modelProvenance", "unspecified"]|>,
  KeyTake[phaseData, {
    "phase", "intendedUse", "unaryEndpointProvenance",
    "binaryInteractionProvenance", "references"
  }],
  <|"binaryInteractionTerms" -> Lookup[
    phaseData["gibbsEnergyModel"]["expression"], "redlichKisterTerms", {}
  ]|>
];

(* Internal helper: evaluate one supported temperature basis without its coefficient. *)
binaryTemperatureBasisValue[term_Association, temperature_] := Switch[
  term["basis"],
  "constant", 1,
  "temperature", temperature,
  "temperatureLogTemperature", temperature Log[temperature],
  "temperaturePower", temperature^term["exponent"]
];

(* Internal helper: sum coefficient-weighted temperature basis terms. *)
binaryTemperatureTermsValue[terms_List, temperature_] := Total[
  #1["coefficient"] binaryTemperatureBasisValue[#1, temperature] & /@ terms
];

(* Internal helper: construct a unary segment condition with explicit endpoint inclusion. *)
binaryTemperatureSegmentCondition[segment_Association, temperature_] :=
  If[
    TrueQ[segment["minimumInclusive"]],
    segment["minimumTemperature"] <= temperature,
    segment["minimumTemperature"] < temperature
  ] && If[
    TrueQ[segment["maximumInclusive"]],
    temperature <= segment["maximumTemperature"],
    temperature < segment["maximumTemperature"]
  ];

(* Internal helper: test numerical membership in a unary temperature segment. *)
binaryTemperatureSegmentContainsQ[segment_Association, temperature_?NumericQ] :=
  TrueQ[binaryTemperatureSegmentCondition[segment, temperature]];

(* Internal helper: expand a canonical unary function into its Piecewise expression. *)
binaryUnaryFunctionExpression[unaryData_Association][functionKey_String][temperature_] := Module[
  {functionData},
  functionData = Lookup[unaryData["functions"], functionKey, Missing["NotFound"]];
  If[MissingQ[functionData],
    Message[
      binaryUnaryFunctionValue::function,
      functionKey,
      unaryData["identity"]["elementSymbol"]
    ];
    Return[Missing["UnaryFunctionNotFound"]]
  ];
  Piecewise[
    Map[
      Function[temperatureSegment,
        {
          binaryTemperatureTermsValue[temperatureSegment["terms"], temperature],
          binaryTemperatureSegmentCondition[temperatureSegment, temperature]
        }
      ],
      functionData["temperatureSegments"]
    ],
    Indeterminate
  ]
];

(* Internal helper: evaluate the canonical unary expression at the supplied argument. *)
binaryUnaryFunctionValue[unaryData_Association][functionKey_String][temperature_] :=
  binaryUnaryFunctionExpression[unaryData][functionKey][temperature];

(* Internal helper: expand legacy embedded segments, retaining their inclusive boundaries. *)
binaryEmbeddedEndmemberExpression[endmember_Association][temperature_] := Piecewise[
  Map[
    Function[temperatureSegment,
      {
        binaryTemperatureTermsValue[temperatureSegment["terms"], temperature],
        temperatureSegment["minimum"] <= temperature <= temperatureSegment["maximum"]
      }
    ],
    endmember["temperatureSegments"]
  ],
  Indeterminate
];

(* Internal helper: evaluate a legacy embedded end-member expression. *)
binaryEmbeddedEndmemberValue[endmember_Association][temperature_] :=
  binaryEmbeddedEndmemberExpression[endmember][temperature];

(* Internal helper: map a binary component to x or 1-x using the declared coordinate. *)
binaryComponentFraction[phaseData_Association][component_String][moleFraction_] := Module[
  {independentComponent},
  independentComponent = SelectFirst[
    phaseData["compositionVariables"],
    #1["role"] == "independent" &
  ]["component"];
  If[component == independentComponent, moleFraction, 1 - moleFraction]
];

(* Internal helper: weight canonical unary endpoints after checking structural identity. *)
binaryCanonicalReferenceContribution[
  binaryModel_Association,
  phaseData_Association
][temperature_][moleFraction_] := Module[
  {endmemberReferences, unaryDataByComponent},
  endmemberReferences =
    phaseData["gibbsEnergyModel"]["expression"]["unaryEndmemberReferences"];
  unaryDataByComponent = binaryModel["UnaryDataByComponent"];
  Total @ Map[
    Function[endmemberReference,
      Module[{unaryData, functionData},
        unaryData = unaryDataByComponent[endmemberReference["component"]];
        functionData = Lookup[
          unaryData["functions"],
          endmemberReference["function"],
          Missing["NotFound"]
        ];
        If[
          AssociationQ[functionData] &&
            functionData["phase"] =!= endmemberReference["structuralPhase"],
          Message[
            binaryCanonicalReferenceContribution::structure,
            endmemberReference["function"],
            endmemberReference["component"],
            functionData["phase"],
            endmemberReference["structuralPhase"]
          ];
          Return[Missing["StructuralPhaseMismatch"], Module]
        ];
        binaryComponentFraction[phaseData][endmemberReference["component"]][moleFraction] *
          binaryUnaryFunctionValue[unaryData][endmemberReference["function"]][temperature]
      ]
    ],
    endmemberReferences
  ]
];

(* Internal helper: form the composition-weighted legacy embedded reference contribution. *)
binaryEmbeddedReferenceContribution[phaseData_Association][temperature_][moleFraction_] :=
  Total @ Map[
    Function[endmember,
      binaryComponentFraction[phaseData][endmember["component"]][moleFraction] *
        binaryEmbeddedEndmemberValue[endmember][temperature]
    ],
    phaseData["gibbsEnergyModel"]["expression"]["referenceStateContributions"]
  ];

(* Internal helper: prefer canonical endpoint references, falling back to embedded data. *)
binaryReferenceContribution[
  binaryModel_Association,
  phaseData_Association
][temperature_][moleFraction_] := Module[
  {expressionData},
  expressionData = phaseData["gibbsEnergyModel"]["expression"];
  If[
    KeyExistsQ[expressionData, "unaryEndmemberReferences"],
    binaryCanonicalReferenceContribution[binaryModel, phaseData][temperature][moleFraction],
    binaryEmbeddedReferenceContribution[phaseData][temperature][moleFraction]
  ]
];

(* Internal helper: build ideal mixing with its finite zero limits at pure endpoints. *)
binaryIdealMixingContribution[phaseData_Association][temperature_][moleFraction_] := Module[
  {idealMixingData, gasConstant, mixingExpression},
  idealMixingData = phaseData["gibbsEnergyModel"]["expression"]["idealMixingTerm"];
  If[! TrueQ[idealMixingData["included"]], Return[0]];
  gasConstant = idealMixingData["gasConstant"]["value"];
  mixingExpression = gasConstant temperature (
    moleFraction Log[moleFraction] +
    (1 - moleFraction) Log[1 - moleFraction]
  );
  If[
    NumericQ[moleFraction],
    If[moleFraction == 0 || moleFraction == 1, 0, mixingExpression],
    Piecewise[
      {{0, moleFraction == 0 || moleFraction == 1}},
      mixingExpression
    ]
  ]
];

(* Internal helper: evaluate the excess RK sum in the explicitly declared component order. *)
binaryRedlichKisterContribution[phaseData_Association][temperature_][moleFraction_] := Module[
  {
    expressionData,
    redlichKisterTerms,
    componentOrder,
    firstFraction,
    secondFraction
  },
  expressionData = phaseData["gibbsEnergyModel"]["expression"];
  redlichKisterTerms = expressionData["redlichKisterTerms"];
  componentOrder = Lookup[expressionData, "redlichKisterComponentOrder", Missing["NotFound"]];
  If[MissingQ[componentOrder],
    Message[binaryRedlichKisterContribution::order];
    componentOrder = {
      SelectFirst[phaseData["compositionVariables"], #1["role"] == "independent" &]["component"],
      SelectFirst[
        Lookup[phaseData["components"], "identifier"],
        #1 =!= SelectFirst[
          phaseData["compositionVariables"],
          #1["role"] == "independent" &
        ]["component"] &
      ]
    }
  ];
  firstFraction = binaryComponentFraction[phaseData][componentOrder[[1]]][moleFraction];
  secondFraction = binaryComponentFraction[phaseData][componentOrder[[2]]][moleFraction];
  firstFraction secondFraction Total @ Map[
    Function[redlichKisterTerm,
      binaryTemperatureTermsValue[
        redlichKisterTerm["temperatureDependence"],
        temperature
      ] * If[
        redlichKisterTerm["order"] == 0,
        1,
        (firstFraction - secondFraction)^redlichKisterTerm["order"]
      ]
    ],
    redlichKisterTerms
  ]
];

binaryPhaseValidity[binaryModel_Association][phaseIdentifier_String] := Module[
  {
    systemData,
    phaseData,
    expressionData,
    endmemberReferences,
    unaryDataByComponent,
    minimumTemperatures,
    maximumTemperatures
  },
  systemData = binaryModel["SystemData"];
  phaseData = binaryModel["PhaseDataByIdentifier"][phaseIdentifier];
  expressionData = phaseData["gibbsEnergyModel"]["expression"];
  minimumTemperatures = {
    systemData["temperatureValidity"]["minimum"],
    phaseData["temperatureRange"]["minimum"]
  };
  maximumTemperatures = {
    systemData["temperatureValidity"]["maximum"],
    phaseData["temperatureRange"]["maximum"]
  };
  If[KeyExistsQ[expressionData, "unaryEndmemberReferences"],
    endmemberReferences = expressionData["unaryEndmemberReferences"];
    unaryDataByComponent = binaryModel["UnaryDataByComponent"];
    minimumTemperatures = Join[
      minimumTemperatures,
      unaryDataByComponent[#1["component"]]["systemValidity"]["minimumTemperature"] & /@
        endmemberReferences
    ];
    maximumTemperatures = Join[
      maximumTemperatures,
      unaryDataByComponent[#1["component"]]["systemValidity"]["maximumTemperature"] & /@
        endmemberReferences
    ]
  ];
  {Max[minimumTemperatures], Min[maximumTemperatures]}
];

binaryMolarGibbsFreeEnergy[
  binaryModel_Association
][phaseIdentifier_String][temperature_][moleFraction_] := Module[
  {phaseData, validityInterval},
  phaseData = binaryModel["PhaseDataByIdentifier"][phaseIdentifier];
  validityInterval = binaryPhaseValidity[binaryModel][phaseIdentifier];
  If[NumericQ[temperature] && ! TrueQ[validityInterval[[1]] <= temperature <= validityInterval[[2]]],
    Message[
      binaryMolarGibbsFreeEnergy::temperature,
      temperature,
      validityInterval,
      phaseIdentifier
    ];
    Return[Missing["OutsideTemperatureValidity"]]
  ];
  If[NumericQ[moleFraction] && ! TrueQ[0 <= moleFraction <= 1],
    Message[binaryMolarGibbsFreeEnergy::composition, moleFraction];
    Return[Missing["OutsideCompositionValidity"]]
  ];
  binaryReferenceContribution[binaryModel, phaseData][temperature][moleFraction] +
    binaryIdealMixingContribution[phaseData][temperature][moleFraction] +
    binaryRedlichKisterContribution[phaseData][temperature][moleFraction]
];

binaryMolarGibbsFreeEnergyFunction[
  binaryModel_Association
][phaseIdentifier_String] := Module[
  {symbolicTemperature, symbolicComposition, symbolicExpression},
  symbolicTemperature = Unique["temperature"];
  symbolicComposition = Unique["moleFraction"];
  symbolicExpression = binaryMolarGibbsFreeEnergy[
    binaryModel
  ][phaseIdentifier][symbolicTemperature][symbolicComposition];
  Function[
    Evaluate[{symbolicTemperature}],
    Evaluate[
      Function[
        Evaluate[{symbolicComposition}],
        Evaluate[symbolicExpression]
      ]
    ]
  ]
];
