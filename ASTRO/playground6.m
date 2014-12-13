(* Chebyshev polynomials for a "perfect" elliptical orbit *)

(* simple case: xy planar *)

tab0512 = Table[{ma,ellipseMA2XY[1.2,1,ma]},{ma,0,2*Pi,.01}];

xs = Table[{(i[[1]]-Pi)/Pi,i[[2,1]]},{i,tab0512}];

chebs = Table[ChebyshevT[n,t],{n,0,3}]

coss = Table[Cos[Pi/2*n*t],{n,0,3}]


fx0[t_] = Fit[xs,coss,t]








