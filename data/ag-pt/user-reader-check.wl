(* Run after loading your existing Binary-reference-reader.wl. *)
agPtSystemPath = FileNameJoin[{DirectoryName[$InputFileName], "system.json"}];
agPtModel = binaryLoadSystemModel[agPtSystemPath];
agPtLiquid[temperature_, composition_] := binaryMolarGibbsFreeEnergy[agPtModel]["liquid"][temperature][composition];
agPtFcc[temperature_, composition_] := binaryMolarGibbsFreeEnergy[agPtModel]["fcc-a1"][temperature][composition];
agPtLiquidExpression = agPtLiquid[agPtTemperature, agPtComposition];
agPtFccExpression = agPtFcc[agPtTemperature, agPtComposition];
agPtLiquidSlope = D[agPtLiquidExpression, agPtComposition];
agPtFccSlope = D[agPtFccExpression, agPtComposition];
agPtLiquidIntercept = agPtLiquidExpression - agPtComposition agPtLiquidSlope;
agPtFccIntercept = agPtFccExpression - agPtComposition agPtFccSlope;
agPtPeritectic = FindRoot[{
 (agPtLiquidSlope /. agPtComposition -> agPtLiquidContact) == (agPtFccSlope /. agPtComposition -> agPtSilverContact),
 (agPtLiquidSlope /. agPtComposition -> agPtLiquidContact) == (agPtFccSlope /. agPtComposition -> agPtPlatinumContact),
 (agPtLiquidIntercept /. agPtComposition -> agPtLiquidContact) == (agPtFccIntercept /. agPtComposition -> agPtSilverContact),
 (agPtLiquidIntercept /. agPtComposition -> agPtLiquidContact) == (agPtFccIntercept /. agPtComposition -> agPtPlatinumContact)
 }, {{agPtTemperature,1459.15},{agPtLiquidContact,.201},{agPtSilverContact,.406},{agPtPlatinumContact,.779}}];
Print[agPtPeritectic];
