repoDirectory = ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]];
Get[FileNameJoin[{repoDirectory,"examples","mathematica","Binary-reference-reader.wl"}]];
reference = binaryLoadSystemModel[FileNameJoin[{repoDirectory,"data","cu-ag","system.json"}]];
metadataPassed = Lookup[Values[reference["Phase Metadata"]],"modelProvenance"] === {"assessed","assessed","constructed","constructed"};
metadataPassed = metadataPassed && Check[
  And @@ Table[
    reference["Provenance Summary"][phaseKey]["modelProvenance"] ===
      reference["Phase Metadata"][phaseKey]["modelProvenance"] &&
    AllTrue[reference["Phase Metadata"][phaseKey]["binaryInteractionTerms"],
      #["parameterOrigin"] === If[MemberQ[{"bcc","hcp"},phaseKey],
        "legacyTeachingAssumption","assessedParameter"] &] &&
    AllTrue[reference["Phase Metadata"][phaseKey]["binaryInteractionProvenance"]["references"],
      MemberQ[Lookup[reference["Phase Metadata"][phaseKey]["references"],"identifier"],#] &],
    {phaseKey,Keys[reference["Phase Metadata"]]}], False];
quietPassed = Check[Table[binaryMolarGibbsFreeEnergyFunction[reference][phaseKey][1000.][.4],{phaseKey,Keys[reference["PhaseDataByIdentifier"]]}];True,False];
legacyData = KeyDrop[reference["PhaseDataByIdentifier"]["liquid"],"modelProvenance"];
unspecifiedPassed = binaryPhaseMetadata[legacyData]["modelProvenance"] === "unspecified";
phaseExpressions = AssociationMap[binaryMolarGibbsFreeEnergyFunction[reference][#][temperature][composition]&, {"liquid","bcc","hcp"}];
phaseSlope[phaseKey_,xValue_] := D[phaseExpressions[phaseKey],composition]/.composition->xValue;
phaseIntercept[phaseKey_,xValue_] := (phaseExpressions[phaseKey]-composition D[phaseExpressions[phaseKey],composition])/.composition->xValue;
rootEquations = {phaseSlope["hcp",firstX]-phaseSlope["liquid",liquidX],phaseSlope["hcp",secondX]-phaseSlope["liquid",liquidX],phaseIntercept["hcp",firstX]-phaseIntercept["liquid",liquidX],phaseIntercept["hcp",secondX]-phaseIntercept["liquid",liquidX]};
constrainedRoot = FindRoot[Thread[rootEquations==0],{{firstX,.03},{liquidX,.36},{secondX,.97},{temperature,978.5}},AccuracyGoal->8,PrecisionGoal->8];
rootResidual = Max[Abs[rootEquations/.constrainedRoot]];
supportSlope = phaseSlope["liquid",liquidX]/.constrainedRoot;
supportIntercept = phaseIntercept["liquid",liquidX]/.constrainedRoot;
supportMargins = AssociationMap[First[NMinimize[{(phaseExpressions[#]/.constrainedRoot)-supportSlope composition-supportIntercept,10^-10<=composition<=1-10^-10},composition]]&,Keys[phaseExpressions]];
constrainedPassed = 978 < (temperature/.constrainedRoot) < 979 && Abs[(liquidX/.constrainedRoot)-.3301214250]<10^-8 && rootResidual<10^-5 && Min[Values[supportMargins]]> -10^-5;
Print[<|"metadataPassed"->metadataPassed,"quietEvaluationPassed"->quietPassed,"unspecifiedFallbackPassed"->unspecifiedPassed,"constrainedPassed"->constrainedPassed,"constrainedRoot"->constrainedRoot,"residual"->rootResidual,"supportMargins"->supportMargins|>//InputForm];
If[!And[metadataPassed,quietPassed,unspecifiedPassed,constrainedPassed],Exit[1]];
