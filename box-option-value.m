(*** NOT WORKING ***)

(* Module/function to compute box option values. Inputs:
 p0 - current price of underlying instrument
 v - volatility of underlying instrument (per year)
 p1 - box price lower limit
 p2 - box price upper limit
 t1 - time to start of option, in hours
 t2 - time to end of option, in hours
 *)

(* Source: http://math.stackexchange.com/questions/9608/determining-distribution-of-maximum-of-dependent-normal-variables/9740 *)

(* TODO: we can probably combine pt1 <=> p1,p2 cases *)
(* TODO: many equations below can be simplified *)

boxvalue[p0_, v_, p1_, p2_, t1_, t2_] := 
 Module[{pdflp, cdfmaxlp},

  (* the pdf of Log[price] at t1; chance that Log[price]=x *)
  pdflp[x_] = 
   PDF[NormalDistribution[Log[p0], Sqrt[t1]*v/Sqrt[365.2425*24]]][x];

  (* the anti-cdf of the max of Log[price]-Log[price[t1]] between t1 and t2;
     chance this value is more than x, for x > 0 *)
   cdfmaxlp[x_] = 1-Erf[x/(v*Sqrt[t2-t1]/Sqrt[365.2425/Sqrt[2]])];

  (* 3 cases: price[t1] < p1, between p1 and p2, or price[t1] > p2 *)
  N[
  Integrate[pdflp[x]*cdfmaxlp[Log[p1]-x],{x,-Infinity,Log[p1]}] +
  Integrate[pdflp[x]*1,{x,Log[p1],Log[p2]}] +
  Integrate[pdflp[x]*cdfmaxlp[x-Log[p2]],{x,Log[p2],Infinity}]
  ]
]
