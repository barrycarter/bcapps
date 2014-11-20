(* Mercurian parameters *)

a0 = 0.387098
e0 = 0.205630
b0 = ellipseEA2B[a0,e0]

(* mean anamoly at given time 2014-Jul-31 00:00:00.0000 *)
ma0 = 4.429045524674828*Degree

ellipseMA2XY[a0,b0,ma0]

(* formula for ma2ta? *)

test[a_,t_] = Sum[a^n/n*Sin[n*t],{n,0,Infinity}]

Plot[test[2,t],{t,0,2*Pi}]



