(*** NOT WORKING ***)

(* Module/function to compute box option values. Inputs:
 p0 - current price of underlying instrument
 v - volatility of underlying instrument (per year)
 p1 - box price lower limit
 p2 - box price upper limit
 t1 - time to start of option, in hours
 t2 - time to end of option, in hours
 *)

(* TODO: we can probably combine pt1 <=> p1,p2 cases *)
(* TODO: many equations below can be simplified *)

boxvalue[p0_, v_, p1_, p2_, t1_, t2_] := 
 Module[{hv, vt1t2, vt0t1, odds, mvol, pt1x, answer},

  (* volatility between t1 and t2 [365.2425 days/Gregorian year] *)
  vt1t2 = v/Sqrt[365.2425*24]*Sqrt[t2-t1];

  (* and between t0 and t1 *)
  vt0t1 = v/Sqrt[365.2425*24]*Sqrt[t1];

  (* given that the price is pt1 at t1, odds of hitting box *)

  (* trivial case of hitting left edge *)
  odds[pt1_] := 1 /; p1 <= pt1 <= p2;

  (* case: pt1 < p1 *)
  (* how many multiples of volatility must price move? *)
  (* <h> Advanced math: Log[x]-Log[y] == Log[x/y] </h> *)
  mvol[pt1_] = (Log[p1]-Log[pt1])/vt1t2;
  (* and the odds that it will move at least that much? *)
  (* "magic formula" from http://math.stackexchange.com/questions/9608/determining-distribution-of-maximum-of-dependent-normal-variables/9740#9740 *)
  odds[pt1_] := Erf[mvol[pt1]/Sqrt[2]] /; pt1 < p1;

  (* similar for pt1 > p2 *)
  mvol[pt1_] = (Log[pt1]-Log[p2])/vt1t2;
  odds[pt1_] := Erf[mvol[pt1]/Sqrt[2]] /; pt1 > p2;

  (* the chance that pt1 == x *)
  pt1x[x_] = PDF[NormalDistribution[Log[p0],vt0t1]][Log[x]];

  (* integrating over all possible values for pt1 *)
  answer = NIntegrate[pt1x[x]*odds[x],{x,0,Infinity}];
  Print["ANSWER",answer];
]

(* test cases *)

boxvalue[1.0004, .15, 1.0000, 1.00150, 25/60, 1+25/60]
