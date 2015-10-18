(* best fit fourier for a given function, not list *)

(* the -1/3 below so function integrates to 0 *)

f[x_] = x^2-1/3;

t = Table[f[x],{x,-1,1,.01}];

g[n_] = Integrate[f[x]*Cos[n*x],{x,-1,1}]

Plot[g[n],{n,-1,1}]

Plot[g[n],{n,-10,10}]

(* found via nminimize *)

h[x_] = Cos[3.34209*x]

Plot[h[x],{x,-1,1}]

