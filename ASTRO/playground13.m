(* conjunctions approximation for http://astronomy.stackexchange.com/questions/11456/has-the-conjunction-between-venus-jupiter-and-regulus-only-occurred-twice-in-2?noredirect=1#comment15731_11456 *)

(* convert three coordinates to vector *)

vector[target_,center_,t_] = {
pos[x,target,center][t], pos[y,target,center][t], pos[z,target,center][t]
}

(* vector as seen from earth (via Sun) *)

earthvector[target_,t_] = vector[target,0,t] - vector[301,0,t];

(* right ascension and declination *)

ra[target_,t_]=
 ArcTan[earthvector[target,t][[1]],earthvector[target,t][[2]]];

dec[target_,t_]=
 ArcSin[earthvector[target,t][[3]]/Norm[earthvector[target,t]]];

(* convert right ascension and declination (in radians) to vector *)

sph2xyz[{th_,ph_,r_}] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]}

(* test *)

LogPlot[{
 VectorAngle[earthvector[2,t],earthvector[5,t]]/Degree,
 VectorAngle[earthvector[2,t],earthvector[4,t]]/Degree,
 VectorAngle[earthvector[4,t],earthvector[5,t]]/Degree
},
 {t,16436,16436+366}, PlotRange->All]

ang[t_] = VectorAngle[earthvector[2,t],earthvector[5,t]];

Plot[ang[t],{t,16436,16436+366}]

(* regulus = 10h 08m 22.311s, 1158# 01.95 *)

regulus = sph2xyz[{(10+8/60+22.311/3600)/12*Pi, (11+58/60+1.95/3600)*Degree,1}]

LogPlot[VectorAngle[earthvector[2,t],regulus]/Degree,{t,16436,16436+366}]





(* approach using polynomials not circles *)

(* Earth to Venus vector *)

ev[t_] = {pos[x,2,0][t] - pos[x,301,0][t],
          pos[y,2,0][t] - pos[y,301,0][t],
          pos[z,2,0][t] - pos[z,301,0][t]};

(* Venus declination *)

(* Plot[ArcSin[ev[t][[3]]/Norm[ev[t]]]/Degree,{t,16436,16436+366}] *)

(* Earth to Jupiter vector *)

ej[t_] = {pos[x,5,0][t] - pos[x,301,0][t],
          pos[y,5,0][t] - pos[y,301,0][t],
          pos[z,5,0][t] - pos[z,301,0][t]};

Plot[ArcSin[ej[t][[3]]/Norm[ej[t]]]/Degree,{t,16436,16436+366}]

(* angle between them *)

ang[t_] = VectorAngle[ev[t],ej[t]];

Plot[ang[t+16435]/Degree,{t,1,366}]

(* planet d AU away, p years to orbit, at perfect vernal opp at 0 *)

planet[t_,p_,d_] = {d*Cos[t*2*Pi/p],d*Sin[t*2*Pi/p]}

earth[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]}

ParametricPlot[earth[t],{t,0,1}]

ang[t_,p_,d_] = Apply[ArcTan,planet[t,p,d]-earth[t]]

angd[t_,p_,d_] = Simplify[D[ang[t,p,d],t]]

angd[t,p,p^(2/3)]

angd[t,11.8618,5.204267]


Plot[ang[t,12,5],{t,0,12}]

Plot[ang[t,11.8618,5.204267],{t,0,12}]

Solve[(planet[t,p,d]-earth[t])[[1]]==0,t]

NSolve[(planet[t,11.8618,5.204267]-earth[t])[[1]]==0,t]
FindRoot[(planet[t,11.8618,5.204267]-earth[t])[[1]]==0,{t,0,12}]

Plot[(planet[t,11.8618,5.204267]-earth[t])[[1]],{t,0,12}]

Plot[(planet[t,11.8618,5.204267]-earth[t])[[1]],{t,0,240}]

Solve[a*Cos[b*t]==Cos[t],t]

Series[a*Cos[b*t]-Cos[t],{t,0,10}]

Series[a*Sin[b*t]-Sin[t],{t,0,10}]

planet[t,p,p^(3/2)][[1]]

(* catchup time *)

p/(p-1)

Plot[{planet[t,11.8618,5.204267][[2]],earth[t][[2]]},{t,0,24}]

ParametricPlot[{Cos[t],2*Sin[t]},{t,0,2*Pi}]

(* using Mathematica's astro data *)

mdec2 = Table[AstronomicalData["Moon", {"Declination", DateList[t]}],
 {t, AbsoluteTime[{2014,1,1}], AbsoluteTime[{2015,1,1}], 3600}];

test1010 = Table[AstronomicalData["Jupiter", {"Declination", DateList[t]}],
 {t, AbsoluteTime[{-9998,1,1}], AbsoluteTime[{-9997,1,1}], 3600}];












