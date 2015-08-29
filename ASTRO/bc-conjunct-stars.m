(* compute planet/star conjuctions using daily positions *)

star = earthvecstar[(10+8/60+22.311/3600)/12*Pi, (11+58/60+1.95/3600)*Degree];

test0907 = AbsoluteTiming[
 Table[VectorAngle[earthvector2[jd,mars],star],{jd,info[jstart],info[jend]}]];

