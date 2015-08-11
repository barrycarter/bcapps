(* attempt to find conjunctions using Mathematicas AstronomicalData functions *)

(* this is imperfect but tolerable *)
date[y_] := ToDate[FromDate[{Floor[y]}]+(y-Floor[y])*86400*365.2425]

aj[t_]:=aj[t]=AstronomicalData["Jupiter",{"Position",date[t]}];
ae[t_]:=ae[t]= AstronomicalData["Earth",{"Position",date[t]}];
av[t_]:=av[t]= AstronomicalData["Venus",{"Position",date[t]}];
regulus = AstronomicalData["Regulus", "Position"];

ang0[t_]:=ang[t]=VectorAngle[av[t]-ae[t],aj[t]-ae[t]]
ang1[t_]:=ang1[t]=VectorAngle[regulus,aj[t]-ae[t]]
ang2[t_]:=ang2[t]=VectorAngle[av[t]-ae[t],regulus]

Plot[Max[ang0[t],ang1[t],ang2[t]]/Degree,{t,2015,2016},PlotRange->{0,10}]

Table[{t,Max[ang0[t],ang1[t],ang2[t]]/Degree},{t,2015.4,2015.6,.001}]  

Plot[Log10[Max[ang0[t],ang1[t],ang2[t]]/Degree],{t,2015,2016}]

(*

Plot[{
 Log10[ang0[t]/Degree],
 Log10[ang1[t]/Degree],
 Log10[ang2[t]/Degree]
}, {t,2015,2016},PlotRange->All]

*)





