(* dump the daily positions of planets, with help from bc-dump-cheb.pl *)

(* Given a planet id [purely so I can spit it back out], start date,
end date, and Chebyshev coefficients, return values for each date in
interval *)

f[id_,sd_,ed_,l_] := Module[{p,d},
 p[t_] = Sum[l[[i]]*ChebyshevT[i-1,t],{i,1,Length[l]}];
 Table[p[(d-sd)/(ed-sd)*2-1],{d,sd,ed}]
]


