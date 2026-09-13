(* Historical regression only. Transcribed verbatim coefficients from
 Common_Tangents_From_Free_Energies.nb, initial example functions, lines 77-218
 and saved definitions lines 2133-2170 (inspected 2026-09-13).
 Symbols renamed only. xCu is the Cu mole fraction; J/mol and K.
 These unsegmented teaching formulas are NOT the assessed FCC/liquid model.
 No assessment citation is claimed for L0=30000. *)
ClearAll[legacyXLogX, legacyTeachingEnergy];
legacyXLogX[0] = 0; legacyXLogX[0.] = 0.;
legacyXLogX[composition_] := composition Log[composition];
legacyTeachingEnergy[phaseKey_][temperature_][xCu_] :=
 Switch[phaseKey,
 "bcc", -3809.51 - 12011/temperature + 117.152 temperature - .0018 temperature^2 - 3.985*^-7 temperature^3 - 23.846 temperature Log[temperature] + xCu (56.054 + 64489/temperature + 12.078 temperature - .0008662 temperature^2 + 5.2781*^-7 temperature^3 - .266 temperature Log[temperature]),
 "hcp", -6909.512 - 12011/temperature + 118.5 temperature - .00178 temperature^2 - 3.985*^-7 temperature^3 - 23.846 temperature Log[temperature] + xCu (-260.946 + 64489/temperature + 12.183 temperature - .0008662 temperature^2 + 5.2781*^-7 temperature^3 - .2660 temperature Log[temperature]),
 "fcc-a1", -7209.5 - 12011/temperature + 118.2 temperature - .0018 temperature^2 - 3.985*^-7 temperature^3 - 23.85 temperature Log[temperature] + xCu (-560.95 + 64489/temperature + 12.283 temperature - .00086 temperature^2 + 5.2781*^-7 temperature^3 - .266 temperature Log[temperature])
 ] + 30000 (1-xCu) xCu + 8.314 temperature (legacyXLogX[1-xCu]+legacyXLogX[xCu]);
