(*

 https://www.quora.com/Is-e-x-+-e-x-a-parabola

 *)

f[x_] = Exp[x] + Exp[-x]

t = Table[{x,f[x]}, {x,-2,2,.01}];

t2 = Table[{x,f[x]-2}, {x,-2,2,.01}];

Fit[t2,{x^2},x]

Plot[{1.26574*x^2,f[x]-2}, {x,-2,2}]

bestfit[n_] := Module[{t},
 t =  Table[{x,f[x]-2}, {x,-n,n,.01}];
 Return[Fit[t, x^2, x]];
]

Plot[{f[x], 90.6002*x^2+2}, {x,-10,10}]

t3 = Table[{x,f[x]-2}, {x,-100,100,.01}];

Fit[t3, {1,x,x^2}, x]


