(* conjunctions approximation for http://astronomy.stackexchange.com/questions/11456/has-the-conjunction-between-venus-jupiter-and-regulus-only-occurred-twice-in-2?noredirect=1#comment15731_11456 *)

(* approach using polynomials not circles *)





















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












