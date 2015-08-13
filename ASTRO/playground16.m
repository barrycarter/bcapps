(* dump the daily positions of planets, with help from bc-dump-cheb.pl *)

jd2params[jd_,planet_] := Module[{jd2,chunk,days,t},
   (* normalize to boundary *)
   jd2 = jd-33/2;
   (* days in a given chunk *)
   days = 32/info[planet][chunks];
   (* which chunk *)
   chunk = Floor[Mod[jd2,32]/days]+1;
   (* where in chunk *)
   t = Mod[jd2,days]/days*2-1;
   {Quotient[jd2,32]*32+33/2,chunk,t}
];

(* Chebyshev with memoization *)

cheb[n_,t_] := cheb[n,t] = ChebyshevT[n,t];

(* list of cheb at t w/ coeffs *)

chebval[t_,list_] := Table[cheb[n,t],{n,0,Length[list]-1}].list

jd2params[2457248.209699,mercury]





jd2params[2451536+1/2+5,mercury]


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


