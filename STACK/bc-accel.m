(*

This is a rewrite of bc-solve-astronomy-13817.m which was getting
hideously nasty. This only includes formulas and my brief notes, and
attempts to make derivations easier (and also computes light travel
time issues).

TODO: all todos from bc-solve-astronomy-13817.m still apply

stationReladist[a_,s0_,v0_,t_]= 
 s0+t*v0+((-1 + Sqrt[1 + a^2*t^2])*Sqrt[1 - v0^2])/a
stationNewtdist[a_,s0_,v0_,t_] = s0 + v0*t + a*t^2/2

g = 98/10/299792458;
y2s = 31556952;

conds = {Element[{a,s0,v0,t},Reals]}

by dervs:

stationRelavel[a_,s0_,v0_,t_] = v0 + (a*t*Sqrt[1 - v0^2])/Sqrt[1 + a^2*t^2]
stationNewtvel[a_,s0_,v0_,t_] = a*t + v0

this is "observed" accel from station:

stationRelaacc[a_,s0_,v0_,t_] = (a*Sqrt[1 - v0^2])/(1 + a^2*t^2)^(3/2)
stationNewtacc[a_,s0_,v0_,t_] = a

*)

(* from ship:

Log[Cosh[a*t]]/a

Sqrt[1-Tanh[a*t]^2]*v0*t 

shipReladist[a_,s0_,v0_,t_] = Log[Cosh[a*t]]/a + t*v0*Sech[a*t]

shipRelavel[a_,s0_,v0_,t_] = Tanh[a*t] + Sech[a*t]*(v0 - a*t*v0*Tanh[a*t])

*)

(* lets confirm answers from bc-solve-astr... *)

Solve[stationRelavel[a,0,0,t] == s, t]


FullSimplify[shipReladist[a,s0,v0,t],conds] 

FullSimplify[Solve[relavel[a,s0,v0,t] == s,t,Reals], {s>0}]

Plot[reladist[g,0,0,t*y2s]/y2s,{t,0,5}]

Plot[relavel[g,0,0,t*y2s],{t,0,5}]



