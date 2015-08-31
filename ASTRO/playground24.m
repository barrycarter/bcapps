(* simple example for http://mathematica.stackexchange.com/questions/92698/techniques-to-find-all-local-minima-of-black-box-function-with-n-continuous-deri?noredirect=1#comment252156_92698 *)

g[x_] := Module[{},Return[x+5]];
f[x_] := Module[{},Print["F CALLED: ",x];Return[x^2+g[x]]];

f[x_] := Module[{},If[x>0,Return[x^2-1]];Return[x^2+1]];

methods = {ConjugateGradient, PrincipalAxis, LevenbergMarquardt, Newton,
 QuasiNewton, InteriorPoint, Gradient};

badmethod = {LinearProgramming,QuadraticProgramming};

Table[FindMinimum[f[x],{x,1},Method->m],{m,methods}]

