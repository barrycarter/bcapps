(*

http://math.stackexchange.com/questions/1720741/closed-form-of-int-0-pi-x3-ln82-sinx-dx

odd in the sense of unusual, not f(-x) = -f(x)

f[x_] = x^3*Log[2*Sin[x]]^8

Integrate[f[x],{x,0,Pi/2}]

Plot[f[x],{x,0,Pi}, PlotRange -> All]

Table[f[i], {i,Pi-.001,Pi,.0001}]

approx[n_] := Total[Drop[10^-(n+1)*Table[f[i], {i,Pi-10^-n,Pi,10^-(n+1)}],-1]]

approx[n_] := Total[Drop[10^-(n+1)*Table[f[i], {i,Pi-10^-n,Pi,10^-(n+1)}],1]]


Series[f[x], {x,Pi,2}]

Integrate[x^3*Log[2*Sin[x]],x]
Integrate[x^3*Log[2*Sin[x]]^2,{x,0,Pi}]

$Version

9.0 for Linux x86 (32-bit) (November 20, 2012)

NIntegrate[x^3*Log[2*Sin[x]]^8,{x,0,Pi}, WorkingPrecision -> 50,
AccuracyGoal -> 40, PrecisionGoal -> 40]

624509.97425476323973864321155907856915353495760746
