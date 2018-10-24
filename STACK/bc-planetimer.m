(* How could the planettime possibly work? perhaps as below *)

(* solving this as generic http://math.stackexchange.com/questions/1512996/angle-of-point-on-one-circle-to-match-view-from-another-circle *)

(* given the three radii and theta, phi, return the angle *)

(* TODO: this does NOT have to be a module, since a closed form solution exists *)

(* memoizing because this is slow for some reason *)

(* TODO: Fourier analysis on result? if we assume planets ecliptic longitude is linear in time? *)

(* TODO: have CSPICE work out the fake angles *)

(* TODO: create a fake planettimer like image *)

(* TODO: answer my own q on stack re this by showing similar items *)

recircle[r1_,r2_,r3_,theta_,phi_] := recircle[r1,r2,r3,theta,phi] = 
Module[{s,f,t},
 f[t_] = t*r3*{Cos[phi],Sin[phi]}+(1-t)*r1*{Cos[theta],Sin[theta]};
 Apply[ArcTan,f[NSolve[{Norm[f[t]]==r2,0<=t<=1},t][[1,1,2]]]]
]

recircle[1,2,5,280*Degree,50*Degree]/Degree

(* now for simple planets *)

p1[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]};
p2[t_] = 5*{Cos[2*Pi*t/11],Sin[2*Pi*t/11]};

Plot[{t,t/5,recircle[1,2,5,t,t/5]}/Degree,{t,0,2*Pi}]

t= Table[recircle[1,2,5,t,t/5],{t,0,2*Pi,.01}]


(* planet positions given angles *)

p1 = r1*{Cos[theta],Sin[theta]}
p3 = r3*{Cos[phi],Sin[phi]}

(* parametrized vector *)

p[t_] = t*p3 + (1-t)*p1

conds = {r1>0, r2>0, r3>0, Element[{theta,phi},Reals]}

s0 = Solve[Norm[p[t]] == r2, t, Reals]

(* assuming the conditions are met for first solution *)

pt = p[t] /. t -> s0[[1,1,2,1]]

p2 = FullSimplify[pt,conds]

at = FullSimplify[ArcTan[p2[[2]]/p2[[1]]],conds]

(* two planets, 1AU and 5AU, dist = 3 AU *)

p1[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]};
p2[t_] = 3*{Cos[2*Pi*t/5],Sin[2*Pi*t/5]};

(* vector between them *)

v[t_] = p2[t]-p1[t];

(* vector angle *)

ang[t_] = ArcTan[v[t][[2]]/v[t][[1]]];

(* the psuedo-planet is at distance 2 *)

(* parametrized vector *)

Norm[u*p1[t] + (1-u)*p2[t]]


