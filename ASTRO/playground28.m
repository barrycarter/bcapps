(* Predicting eclipse paths WITHOUT using Besselian elements? *)

(* using 2017 August 21 as test case; noon = JD 2457987 *)

(* angle between geocenter-moon and earth-sun vectors *)

angle[t_] := VectorAngle[posxyz[t,moongeo],posxyz[t,sun]-posxyz[t,earth]]

Plot[angle[t+2457987]/Degree,{t,-1,1}]

N[Expand[
Assuming[2457986 < t < 2457988, PiecewiseExpand[posxyz[t,earthmoon]]]
]]

FullSimplify[Mod[t,10], t>101 && t<109]

Assuming[101 < t < 109, PiecewiseExpand[Quotient[t,10]]]

Plot[posxyz[t+2457987,moongeo][[1]],{t,-1,1}]
Plot[posxyz[t+2457987,moongeo][[2]],{t,-1,1}]
Plot[posxyz[t+2457987,moongeo][[3]],{t,-1,1}]

(* this returns polynomials, not value *)

pospolys[jd_, planet_] := Module[{jd2, chunk, days, t}, 
    If[planet == earth, Return[posxyz[jd, earthmoon] - 
        (50000000000000*posxyz[jd, moongeo])/4115028453709531]]; 
     jd2 = jd - 33/2; days = 32/info[planet][chunks]; 
     chunk = Floor[Mod[jd2, 32]/days] + 1; 
t = (Mod[jd2, days]*2)/days - 1; 
     (* TODO: this should return a function, not a global poly in x *)
     Table[chebyshev[pos[planet][Quotient[jd2, 32]*32 + 33/2][[chunk]][[i]], 
       x], {i, 1, 3}]]

theday = 2457987;

sun0[x_] = N[Expand[pospolys[theday,sun]]]













