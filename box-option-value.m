(* Module/function to compute box option values. Inputs:
 p0 - current price of underlying instrument
 v - volatility of underlying instrument (per year)
 p1 - box price lower limit
 p2 - box price upper limit
 t1 - time to start of option, in hours
 t2 - time to end of option, in hours

 Output: probability of hitting the box
 *)

(* Source: http://math.stackexchange.com/questions/9608/determining-distribution-of-maximum-of-dependent-normal-variables/9740 *)

boxvalue[p0_, v_, p1_, p2_, t1_, t2_] := 
 Module[{},

  (* the pdf of Log[price] at t1; chance that Log[price]=x *)
  pdflp[x_] = 
   PDF[NormalDistribution[Log[p0], Sqrt[t1]*v/Sqrt[365.2425*24]]][x];

  (* the anti-cdf of the max of Log[price]-Log[price[t1]] between t1 and t2;
     chance this value is more than x, for x > 0 *)
   cdfmaxlp[x_] = 1-Erf[x/(v*Sqrt[t2-t1]/Sqrt[24*365.2425/Sqrt[2]])];

  (* 3 cases: price[t1] < p1, between p1 and p2, or price[t1] > p2 *)
  (* these are silly global variables I added at the last second + I know
     this is bad programming practise *)
  upandin = NIntegrate[pdflp[x]*cdfmaxlp[Log[p1]-x],{x,-Infinity,Log[p1]}];
  hitleftedge = NIntegrate[pdflp[x]*1,{x,Log[p1],Log[p2]}];
  downandin = NIntegrate[pdflp[x]*cdfmaxlp[x-Log[p2]],{x,Log[p2],Infinity}];

  upandin+hitleftedge+downandin
]

(* returns several useful quantities: 

chance of hit
value of $1000 hit/miss options [2 quants]
psuedodelta of hit/miss options [2 quants]
psuedotheta of hit/miss options [2 quants]
psuedovega of hit/miss options [2 quants]

*)

quants[p0_, v_, p1_, p2_, t1_, t2_] := 
 Module[{p, hv, mv, deltah, thetah, vegah, deltahigh, deltalow, thetahigh,
         thetalow, vegahigh, vegalow, deltam, thetam, vegam},
 p = boxvalue[p0, v, p1, p2, t1, t2];
 hv = 1000/p;
 mv = 1000/(1-p);
 deltahigh = boxvalue[p0+1/20000, v, p1, p2, t1, t2];
 deltalow =  boxvalue[p0-1/20000, v, p1, p2, t1, t2];
 thetahigh = boxvalue[p0, v, p1, p2, t1+1/120, t2+1/120];
 thetalow =  boxvalue[p0, v, p1, p2, t1-1/120, t2-1/120];
 vegahigh =  boxvalue[p0, v+1/200, p1, p2, t1, t2];
 vegalow  =  boxvalue[p0, v-1/200, p1, p2, t1, t2];
 deltah = 1000/deltahigh - 1000/deltalow;
 deltam = 1000/(1-deltahigh) - 1000/(1-deltalow);
 thetah = 1000/thetahigh - 1000/thetalow;
 thetam = 1000/(1-thetahigh) - 1000/(1-thetalow);
 vegah = 1000/vegahigh - 1000/vegalow;
 vegam = 1000/(1-vegahigh) - 1000/(1-vegalow);
 {p, hv, mv, deltah, deltam, thetah, thetam, vegah, vegam}
]

(* Binary options:
 Binary options are a limiting case of box options, but the formulas are 
 simpler.
 p0 - current price of underlying instrument
 v - volatility of underlying instrument (per year)
 s - strike price of binary option
 e - time to option expiration, in hours

 Output: probability binary call will be in money
*)

bincallvalue[p0_, v_, s_, e_] =
 1-CDF[NormalDistribution[Log[p0],Sqrt[e/365.2425/24]*v], Log[s]]
