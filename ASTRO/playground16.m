(* dump the daily positions of planets, with help from bc-dump-cheb.pl *)


(* for a given JD, find the "base" 32-day-"multiple" JD and the
remainder term *)

(* TODO: first part can maybe be written better as Quotient? *)

jd2jd[jd_] = {Floor[(jd-33/2)/32]*32+33/2,Mod[jd-33/2,32]}

(* which coefficient set to use? *)

jd2setn[jd_,planet_] = Floor[jd2jd[jd][[2]]/32*info[planet][chunks]+1]

(* where in [-1,1] are we for that coefficient set? *)





(* Given a planet id [purely so I can spit it back out], start date,
end date, and Chebyshev coefficients, return values for each date in
interval *)

f[id_,sd_,ed_,l_] := Module[{p,d},
 p[t_] = Sum[l[[i]]*ChebyshevT[i-1,t],{i,1,Length[l]}];
 Table[p[(d-sd)/(ed-sd)*2-1],{d,sd,ed}]
]


