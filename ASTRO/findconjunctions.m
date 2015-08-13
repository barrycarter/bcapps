(* This script finds Jupiter-Venus-Regulus conjunctions and can theoretically be modified to find others *)

(* this is imperfect but tolerable *)

date[y_] := ToDate[FromDate[{Floor[y]}]+(y-Floor[y])*86400*365.2425];

aj[t_]:=aj[t]=AstronomicalData["Jupiter",{"Position",date[t]}];
ae[t_]:=ae[t]= AstronomicalData["Earth",{"Position",date[t]}];
av[t_]:=av[t]= AstronomicalData["Venus",{"Position",date[t]}];
regulus = AstronomicalData["Regulus", "Position"];

regulus[t_]:=regulus[t]=AstronomicalData["Regulus", {"Position",date[t]}];

ang0[t_]:=ang[t]=VectorAngle[av[t]-ae[t],aj[t]-ae[t]];
ang1[t_]:=ang1[t]=VectorAngle[regulus,aj[t]-ae[t]];
ang2[t_]:=ang2[t]=VectorAngle[av[t]-ae[t],regulus];

max[t_]:=max[t]=Max[ang0[t],ang1[t],ang2[t]]/Degree;

For[t=-100,t<=2100,t=t+.25,Print[FullForm[ternary[t,t+.25,max,10^-6]]]];


