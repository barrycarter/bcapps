(*

Can I do "wavelets" using finite differences

*)


f[t_] = t^2;

g[a_, b_, c_, d_, t_] = a + b*Cos[c*t - d]


Solve[{
 g[a,b,c,d,t] == f[t],
 D[g[a,b,c,d,t], t] == f'[t],
 D[g[a,b,c,d,t], t, t] == f''[t],
 D[g[a,b,c,d,t], t, t, t] == f'''[t]
}, {a,b,c,d}]

Solve[{
 g[a,b,c,d,t] == f[t],
 D[g[a,b,c,d,t], t] == f'[t],
 D[g[a,b,c,d,t], t, t] == f''[t]
}, {a,b,c,d}]

(* given a three elements, find the "derivative", y is ignored but
important "in theory" *)

f[x_,y_,z_] := (z-x)/2;

f[{a[i-1], a[i






Solve[a+ b*Cos[c*t - d] == f[t], {a,b,c,d}]


