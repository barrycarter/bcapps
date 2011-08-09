(* Mathematica stuff for NADEX *)

(* TODO: sublibrary to include in all .m files *)

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* value of spread from lo to hi at price p *)

spread[p_, lo_, hi_] = Min[Max[p,lo],hi]

(* profit at price p if you sell a q option for $r [incl NADEX fees;
if trading over 7 contracts, reduce fee as needed] *)

optionprofit[p_, q_, r_] =  r + If[p>q,-101,-2]

(* profit at price q if you buy 1 unit of parity at price p; not
directly NADEX, but useful for hedging *)

profit[p_, q_] = (q/p-1)

(* testing and plots *)

Plot[spread[p, .99, 1.01], {p,.95,1.05}]

Plot[10000*profit[.99, q], {q,.98,1}]

Plot[10000*profit[1, q], {q,.5,2}]

Plot[10000*profit[1, q], {q,.5,2}]

Plot[210000*profit[.9905,q] - 
 (spread[q, .99, 1] - .9911)*21*10000,
{q,.98,1}]

