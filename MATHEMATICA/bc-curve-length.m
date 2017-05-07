(*

thoughts about sine wave curve lengths and light frequency/speed/slowing


f[x_, n_] = Sin[n*x]

f2[x_, n_] = Integrate[D[f[x,n],x]^2+1, x]

t = Table[f2[Pi/4,n],{n,1,20}]

f3[n_] = FullSimplify[f2[Pi/4,n]/f2[Pi/4,1]]

NSolve[f3[n] == 1.0003, n]

WRONG: N[f3[Rationalize[1.000413]],200] == 1.0003 wow

1.0004138

668-789 Thz = violet
400-484 = red

water = 1.33

1.4633 roughly

shift red to green, signifigant

Integrate[D[a*Sin[x],x]^2+1,{x,0,Pi/4}]
















 *)
