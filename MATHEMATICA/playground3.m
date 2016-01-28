eq = {phib''[ t] == (m2*l2*ls)/(m1*l1^2 + m2*l2^2 + Ib)*(phis''[t]*
Cos[phib[t] - phis[t]] + (phis'[t])^2* Sin[phib[t] - phis[t]]) -
g*(m1*l1 - m2*l2 + mb*(l2 - l1)/2)/(m1*l1^2 + m2*l2^2 + Ib)*
Sin[phib[t]], phis''[t] == l2/ls*(phib''[t]*Cos[phis[t] - phib[t]] +
(phib'[t])^2* Sin[phis[t] - phib[t]]) - g/ls*Sin[phis[t]], phib[0] ==
3*Pi/4, phis[0] == Pi/2, phib'[0] == 0, phis'[0] == 0}

NDSolve[eq, t, {t,0,10}]

