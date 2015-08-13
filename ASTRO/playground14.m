(* attempt to find conjunctions using Mathematicas AstronomicalData functions *)

(* if Im going to compute daily planetary positions, might as well do
it in a way others can use ... *)

AbsoluteTiming[
jdec = Table[{t,AstronomicalData["Jupiter", {"Position", DateList[t]}]},
 {t, AbsoluteTime[{1000,1,1}], AbsoluteTime[{1010,1,1}], 86400}]
][[1]]

(* 25.456544 for 10 years *)

(* now with Chebyshev (which is better because its barycenter? *)

AbsoluteTiming[t = Table[{t,pos[2,0][t]},{t,16436,16436+366*10}]][[1]]

(* 28.952640 for 10 years, so comparable *)

(* this is imperfect but tolerable *)
date[y_] := ToDate[FromDate[{Floor[y]}]+(y-Floor[y])*86400*365.2425]

aj[t_]:=aj[t]=AstronomicalData["Jupiter",{"Position",date[t]}];
ae[t_]:=ae[t]= AstronomicalData["Earth",{"Position",date[t]}];
av[t_]:=av[t]= AstronomicalData["Venus",{"Position",date[t]}];
regulus = AstronomicalData["Regulus", "Position"];

ang0[t_]:=ang[t]=VectorAngle[av[t]-ae[t],aj[t]-ae[t]]
ang1[t_]:=ang1[t]=VectorAngle[regulus,aj[t]-ae[t]]
ang2[t_]:=ang2[t]=VectorAngle[av[t]-ae[t],regulus]

max[t_]:=max[t]=Max[ang0[t],ang1[t],ang2[t]]/Degree

AbsoluteTiming[test = Table[ternary[t,t+.25,max,10^-9],{t,1600,1610,.25}]][[1]]

(* 41.064015 at that level of precision, 27.124001 at 10^-6, 14.816769
for 10^-3 *)

Table[Print[ternary[t,t+.25,max,10^-6]],{t,0,2100,.25}] >> /home/barrycarter/20150812/reg-ven-jup.txt




Plot[ang1[t],{t,2000,2024}]
Plot[ang2[t],{t,2000,2024}]
Plot[ang0[t],{t,2000,2024}]

AbsoluteTiming[list = Table[max[t],{t,1,10,.004}]][[1]]



(* 37.229233 for 1 to 10, 36.982120 for 11 to 20, 79.102711 for 21-40 *)

Table[
Table[{t,max[t]},{t,u,u+10,.004}] >> /home/barrycarter/20150812/output.txt,
{u,1,21,10}]

Plot[Max[ang0[t],ang1[t],ang2[t]]/Degree,{t,2015,2016},PlotRange->{0,10}]

Plot[max[t],{t,2015,2016},PlotRange->{0,10}]

Table[{t,Max[ang0[t],ang1[t],ang2[t]]/Degree},{t,2015.4,2015.6,.001}]  

Plot[Log10[Max[ang0[t],ang1[t],ang2[t]]/Degree],{t,2015,2016}]

(*

Plot[{
 Log10[ang0[t]/Degree],
 Log10[ang1[t]/Degree],
 Log10[ang2[t]/Degree]
}, {t,2015,2016},PlotRange->All]

*)





