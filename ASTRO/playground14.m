(* attempt to find conjunctions using Mathematicas AstronomicalData functions *)

(* this is imperfect but tolerable *)
date[y_] := ToDate[FromDate[{Floor[y]}]+(y-Floor[y])*86400*365.2425]

aj[t_]:=aj[t]=AstronomicalData["Jupiter",{"Position",date[t]}];
ae[t_]:=ae[t]= AstronomicalData["Earth",{"Position",date[t]}];
av[t_]:=av[t]= AstronomicalData["Venus",{"Position",date[t]}];

sph2xyz[{th_,ph_,r_}] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]}
regulus = sph2xyz[{(10+8/60+22.311/3600)/12*Pi, (11+58/60+1.95/3600)*Degree,1}]

ang0[t_]:=ang[t]=VectorAngle[av[t]-ae[t],aj[t]-ae[t]]
ang1[t_]:=ang[t]=VectorAngle[regulus,aj[t]-ae[t]]
ang2[t_]:=ang[t]=VectorAngle[av[t]-ae[t],regulus]

Plot[{
 Log10[ang0[t]/Degree],
 Log10[ang1[t]/Degree],
 Log10[ang2[t]/Degree]
}, {t,2015,2016},PlotRange->All]





