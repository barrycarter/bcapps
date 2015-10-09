(* Predicting eclipse paths WITHOUT using Besselian elements? *)

(* using 2017 August 21 as test case; noon = JD 2457987 *)

(* required for earth *)

posxyz[jd,earth] := 
posxyz[jd,earthmoon]-50000000000000/4115028453709531*posxyz[jd,moongeo];

(* angle between geocenter-moon and earth-sun vectors *)

angle[t_] := VectorAngle[posxyz[t,moongeo],posxyz[t,earth]]








