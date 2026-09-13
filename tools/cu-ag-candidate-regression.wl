(* Reads canonical data and writes docs/audits/cu-ag-candidate-regression.json. *)
repoDirectory = ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]];
Get[FileNameJoin[{repoDirectory,"examples","mathematica","Binary-reference-reader.wl"}]];
Get[FileNameJoin[{repoDirectory,"docs","audits","cu-ag-legacy-teaching-functions.wl"}]];
restoredModel = binaryLoadSystemModel[FileNameJoin[{repoDirectory,"data","cu-ag","system.json"}]];
phaseKeys = Keys[restoredModel["PhaseDataByIdentifier"]];
phaseFunctions = AssociationMap[binaryMolarGibbsFreeEnergyFunction[restoredModel][#] &,phaseKeys];
energyExpression[phaseKey_,temperature_] := phaseFunctions[phaseKey][temperature][composition];
comparisonRows = Flatten[Table[Module[{newExpression,oldExpression},
 newExpression=energyExpression[phaseKey,temperatureValue];
 oldExpression=legacyTeachingEnergy[phaseKey][temperatureValue][composition];
 <|"phase"->phaseKey,"temperature"->temperatureValue,"xCu"->compositionValue,
 "historicalEnergy"->(oldExpression/.composition->compositionValue),
 "restoredEnergy"->(newExpression/.composition->compositionValue),
 "deltaEnergy"->((newExpression-oldExpression)/.composition->compositionValue),
 "historicalDx"->(D[oldExpression,composition]/.composition->compositionValue),
 "restoredDx"->(D[newExpression,composition]/.composition->compositionValue),
 "deltaDx"->(D[newExpression-oldExpression,composition]/.composition->compositionValue),
 "deltaDt"->(D[phaseFunctions[phaseKey][temperature][composition]-legacyTeachingEnergy[phaseKey][temperature][composition],temperature]/.{temperature->temperatureValue,composition->compositionValue})|>],
 {phaseKey,{"bcc","hcp"}},{temperatureValue,{500.,1053.,1200.,1600.}},{compositionValue,{.1,.4,.9}}],2];
(* Sufficient envelope certificate: below 650 K compare with the pure-FCC
 endpoint chord; above 650 K compare with homogeneous assessed FCC.
 Both differences are affine in T after common unary FCC terms cancel.
 Check both T endpoints of each interval over the entire composition range. *)
mixingEntropy = composition Log[composition]+(1-composition) Log[1-composition];
latticeDifference[phaseKey_] := Switch[phaseKey,"bcc",composition (4017-1.255 temperature)+(1-composition)(3400-1.05 temperature),"hcp",composition(600+.2 temperature)+(1-composition)(300+.3 temperature)];
fccExcess=composition(1-composition)(36772.58-11.02847 temperature+(4612.43-.28869 temperature)(2 composition-1));
marginRows=Flatten[Table[Module[{marginExpression,minimumResult},
 marginExpression=latticeDifference[phaseKey]+30000 composition(1-composition)+If[comparisonKey=="fccEndpointChord",8.314 temperature mixingEntropy,(8.314-8.314462618) temperature mixingEntropy-fccExcess];
 minimumResult=NMinimize[{marginExpression/.temperature->temperatureValue,10^-12<=composition<=1-10^-12},composition];
 <|"phase"->phaseKey,"reference"->comparisonKey,"temperature"->temperatureValue,"minimumMargin"->First[minimumResult],"xCu"->(composition/.Last[minimumResult])|>],
 {phaseKey,{"bcc","hcp"}},{comparisonKey,{"fccEndpointChord","homogeneousFcc"}},{temperatureValue,If[comparisonKey=="fccEndpointChord",{298.15,650.},{650.,3000.}]}],2];
(* Discrete lower convex hull selects brackets; common tangents refine them. *)
lowerHull[points_] := Module[{hull={},crossProduct},
 Do[While[Length[hull]>=2,
 crossProduct=(hull[[-1,1]]-hull[[-2,1]])(point[[2]]-hull[[-1,2]])-(hull[[-1,2]]-hull[[-2,2]])(point[[1]]-hull[[-1,1]]);
 If[crossProduct>0,Break[]];hull=Most[hull]];AppendTo[hull,point],{point,points}];hull];
constrainedCase[allowedPhases_,temperatureValue_] := Module[{points,hull,tieEdges,tieRows},
 points=Table[First[SortBy[Table[{compositionValue,phaseFunctions[phaseKey][temperatureValue][compositionValue],phaseKey},{phaseKey,allowedPhases}],#[[2]]&]],{compositionValue,N[Subdivide[0,1,2000]]}];
 hull=lowerHull[points];
 tieEdges=Select[Partition[hull,2,1],#[[2,1]]-#[[1,1]]>.00075&];
 tieRows=Map[Function[edge,Module[{firstExpression,secondExpression,root,firstX,secondX,slope,intercept,residual,supportMinimum},
 firstExpression=energyExpression[edge[[1,3]],temperatureValue];secondExpression=energyExpression[edge[[2,3]],temperatureValue];
 root=FindRoot[{(D[firstExpression,composition]/.composition->firstX)==(D[secondExpression,composition]/.composition->secondX),((firstExpression-composition D[firstExpression,composition])/.composition->firstX)==((secondExpression-composition D[secondExpression,composition])/.composition->secondX)},{{firstX,Clip[edge[[1,1]],{.000001,.999999}]},{secondX,Clip[edge[[2,1]],{.000001,.999999}]}},AccuracyGoal->8,PrecisionGoal->8];
 slope=D[firstExpression,composition]/.composition->firstX/.root;
 intercept=(firstExpression/.composition->firstX/.root)-slope(firstX/.root);
 residual=Max[Abs[{(D[secondExpression,composition]/.composition->secondX/.root)-slope,(secondExpression/.composition->secondX/.root)-slope(secondX/.root)-intercept}]];
 supportMinimum=Min[Table[First[NMinimize[{energyExpression[phaseKey,temperatureValue]-slope composition-intercept,10^-10<=composition<=1-10^-10},composition]],{phaseKey,allowedPhases}]];
 <|"phases"->edge[[All,3]],"xCu"->({firstX,secondX}/.root),"residual"->residual,"minimumSupportingLineMargin"->supportMinimum|>]],tieEdges];
 <|"temperature"->temperatureValue,"allowedPhases"->allowedPhases,"hullPhases"->DeleteDuplicates[hull[[All,3]]],"tieLines"->tieRows|>];
constrainedRows=Flatten[Table[constrainedCase[allowedPhases,temperatureValue],{allowedPhases,{{"liquid","bcc","hcp"},{"bcc","hcp"},{"liquid","bcc"},phaseKeys}},{temperatureValue,{800.,1053.,1200.}}],1];
endpointPassed=And@@Flatten[Table[Abs[phaseFunctions[phaseKey][temperatureValue][compositionValue]-binaryUnaryFunctionValue[restoredModel["UnaryDataByComponent"][If[compositionValue==1,"Cu","Ag"]]][phaseKey][temperatureValue]]<10^-7,{phaseKey,{"bcc","hcp"}},{temperatureValue,{298.15,1053.,1234.93,1357.77,3000.}},{compositionValue,{0.,1.}}]];
(* Check the affine certificate against actual reader expressions and reverse
 the independent coordinate to xAg without changing the RK component order. *)
marginIdentityErrors=Flatten[Table[Module[{actualDifference,analyticDifference},
 actualDifference=phaseFunctions[phaseKey][temperatureValue][compositionValue]-phaseFunctions["fcc-a1"][temperatureValue][compositionValue];
 analyticDifference=(latticeDifference[phaseKey]+30000 composition(1-composition)+(8.314-8.314462618)temperature mixingEntropy-fccExcess)/.{temperature->temperatureValue,composition->compositionValue};
 Abs[actualDifference-analyticDifference]],{phaseKey,{"bcc","hcp"}},{temperatureValue,{298.15,650.,1053.,1234.93,1357.77,1600.,3000.}},{compositionValue,{.01,.4,.99}}]];
coordinateErrors=Flatten[Table[Module[{reversedModel},
 reversedModel=ReplacePart[restoredModel,{"PhaseDataByIdentifier",phaseKey,"compositionVariables"}-> {<|"name"->"xAg","quantity"->"moleFraction","component"->"Ag","role"->"independent"|>}];
 Abs[binaryMolarGibbsFreeEnergy[reversedModel][phaseKey][1053.][1-compositionValue]-phaseFunctions[phaseKey][1053.][compositionValue]]],{phaseKey,{"bcc","hcp"}},{compositionValue,{.1,.4,.9}}]];
validationPassed=Max[marginIdentityErrors]<10^-7&&Max[coordinateErrors]<10^-7&&endpointPassed&&Min[Lookup[marginRows,"minimumMargin"]]>0&&And@@Flatten[Map[Function[caseRow,Map[# ["residual"]<10^-5&&#["minimumSupportingLineMargin"]> -10^-5&,caseRow["tieLines"]]],constrainedRows]];
regressionReport=<|"passed"->validationPassed,"phaseKeys"->phaseKeys,"endpointChecks"->endpointPassed,"maximumMarginIdentityError"->Max[marginIdentityErrors],"maximumCoordinateReversalError"->Max[coordinateErrors],"comparisonRows"->comparisonRows,"envelopeCertificate"->marginRows,"constrainedExamples"->constrainedRows|>;
Export[FileNameJoin[{repoDirectory,"docs","audits","cu-ag-candidate-regression.json"}],regressionReport,"RawJSON"];
Print[regressionReport//InputForm];If[!TrueQ[validationPassed],Exit[1]];
