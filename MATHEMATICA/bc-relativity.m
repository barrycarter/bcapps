(*

Simple relativity:

A shoots light at B, 0.9 light second away moving at .9c after 1s

A sees light reach B at 9s, 9ls away

beam origin for A: (0,1)

beam target for A: (9, 9)

beam travel for A: (9,8); general case: ((1-v)^-1, ((1-v)*c)^-1)

B sees light t seconds later at distance 0

beam origin for B: (-0.9*t, t)

beam target for B: (0, t + 0.9*t/c)

beam travel for B: (0.9*t, 0.9*t/c), general case: (v*t, v*t/c)

Thus, A to B transform is:

{9, 9} -> {0, t}

*)

g0[t_] := Graphics[{
 PointSize[0.01],
 Text[Style[StringJoin["t=",ToString[t]],FontSize -> 20],{0.9*t,0.2}],
 Text[Style[StringJoin["d=",ToString[0.9*t]],FontSize -> 20],{0.9*t,-0.2}],
 Hue[1],
 Point[{0,0}],
 If[t>1, Line[{{0,0},{t-1,0}}]],
 Hue[1/3],
 Point[{0.9*t,0}],
}];

Show[g0[5], PlotRange -> {{-0.1,10},{-0.4,0.4}}]
showit



(* the Loretnz contraction, v as fraction of light speed *)

Sqrt[1-v^2]

(* time dilation *)

1/Sqrt[1-v^2]

(* using pqrs to avoid conflicting vars *)

d2[d1_,t1_] = r*t1+s*d1
t2[d1_,t1_] = p*t1+q*d1

sol6 = Solve[t2[v*t,v*t/c] == 1,t][[1]]

sol3 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1]/t2[(1-v)^-1,((1-v)*c)^-1] == c
},p][[1]]

eq1 = (d2[d2[d1,t1],t2[d1,t1]] == d1 /. sol3)
eq2 = (t2[d2[d1,t1],t2[d1,t1]] == t1 /. sol3)

sol4 = Solve[{eq1,eq2},{q,r}][[1]]

eq5 = (d2[(1-v)^-1,((1-v)*c)^-1] == v*t)





sol0 = Solve[{
 d2[d2[d1,t1],t2[d1,t1]] == d1,
 t2[d2[d1,t1],t2[d1,t1]] == t1
}, {p,q,r,s}][[1]]

eq5 = (d2[(1-v)^-1,((1-v)*c)^-1] == v*t) /. sol3

Solve[eq5]

sol4 = Solve[


sol1 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1] == v*t,
 t2[(1-v)^-1,((1-v)*c)^-1] == v*t/c
}][[1]]

sol1 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1] == v*t,
 t2[(1-v)^-1,((1-v)*c)^-1] == v*t/c
}, {p,q,r,s}]

eq1 = (d2[d2[d1,t1],t2[d1,t1]] == d1 /. sol1)
eq2 = (t2[d2[d1,t1],t2[d1,t1]] == t1 /. sol1)

sol2 = Solve[{eq1,eq2},{q,s}]




sol0 = Solve[{
 d2[d2[d1,t1],t2[d1,t1]] == d1,
 t2[d2[d1,t1],t2[d1,t1]] == t1
}, {p,q,r,s}][[1]]

eq0 = (d2[9,8]/t2[9,8] == c /. sol0)

Solve[eq0,r]

sol1 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1] == v*t,
 t2[(1-v)^-1,((1-v)*c)^-1] == v*t/c
} /. sol0, {q,r}]




eq1 = (d2[9,8] == v*t /. sol0)
eq2 = (t2[9,8] == v*t/c /. sol0)

Solve[{eq1,eq2},{q,r}]






t2[t2[t1,d1],d2[t1,d1]]
d2[t2[t1,d1],d2[t1,d1]]

Solve[{
 t2[t2[t1,d1],d2[t1,d1]] == t1,
 d2[t2[t1,d1],d2[t1,d1]] == -d1
}, {p,q,r,s,t}]
