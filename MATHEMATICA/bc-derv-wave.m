(*

Can I do "wavelets" using finite differences

*)


f[t_] = t^2;

g[a_, b_, c_, d_, t_] = a + b*Cos[c*t - d]
g1[a_, b_, c_, d_, t_] = D[a + b*Cos[c*t - d], t]
g2[a_, b_, c_, d_, t_] = D[a + b*Cos[c*t - d], t, t]
g3[a_, b_, c_, d_, t_] = D[a + b*Cos[c*t - d], t, t, t]



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

d0[i_] = a[i]

d1[i_] = f[a[i-1], a[i], a[i+1]]

d2[i_] = f[d1[i-1], d0[i], d0[i+1]]

d3[i_] = f[d2[i-1], d1[i], d1[i+1]]

pts = Table[t^2, {t,1,100}]

(* Given a list and an element index, return the 0-3rd 'derivative' *)

dervs[a_, i_] := {
 a[[i]], (-a[[-1 + i]] + a[[1 + i]])/2, 
 (a[[-2 + i]] - a[[i]] + 2*a[[1 + i]])/4,
 (-a[[-3 + i]] + a[[-1 + i]] - 4*a[[i]] + 2*a[[2 + i]])/8
};

dervs[pts, 50]

(* Find best fit cos wave given dervs at given index *)

eqs[list_, i_] := {
 g[a,b,c,d,i] == dervs[list, i][[1]],
 g1[a,b,c,d,i] == dervs[list, i][[2]],
 g2[a,b,c,d,i] == dervs[list, i][[3]],
 g3[a,b,c,d,i] == dervs[list, i][[4]]
};

bestfit[list_, i_] := Solve[{
 g[a,b,c,d,i] == dervs[list, i][[1]],
 g1[a,b,c,d,i] == dervs[list, i][[2]],
 g2[a,b,c,d,i] == dervs[list, i][[3]],
 g3[a,b,c,d,i] == dervs[list, i][[4]]
}, {a,b,c,d}]










Solve[a+ b*Cos[c*t - d] == f[t], {a,b,c,d}]


