(*

Simple relativity:

A shoots light at B, 0.9 light second away moving at .9c after 1s

A sees light reach B at 9s, 9ls away

beam origin for A: (0,1)

beam target for A: (9, 9)

beam travel for A: (9,8)

B sees light t seconds later at distance 0

beam origin for B: (-0.9*t, t)

beam target for B: (0, t + 0.9*t/c)

beam travel for B: (0.9*t, 0.9*t/c)

Thus, A to B transform is:

{9, 9} -> {0, t}

*)

(* the Loretnz contraction, v as fraction of light speed *)

Sqrt[1-v^2]

(* time dilation *)

1/Sqrt[1-v^2]

(* using pqrs to avoid conflicting vars *)

d2[d1_,t1_] = r*t1+s*d1
t2[d1_,t1_] = p*t1+q*d1

sol0 = Solve[{
 d2[d2[d1,t1],t2[d1,t1]] == -d1,
 t2[d2[d1,t1],t2[d1,t1]] == -t1
}, {p,q,r,s}][[1]]

eq0 = (d2[9,8]/t2[9,8] == c /. sol0)

Solve[eq0,r]


eq1 = (d2[9,8] == 0.9*t /. sol0)
eq2 = (t2[9,8] == 0.9*t/c /. sol0)

Solve[{eq1,eq2},{q,r}]

sol1 = Solve[{
 d2[9,8] == 0.9*t,
 t2[9,8] == 0.9*t/c
} /. sol0, {q,r}]






t2[t2[t1,d1],d2[t1,d1]]
d2[t2[t1,d1],d2[t1,d1]]

Solve[{
 t2[t2[t1,d1],d2[t1,d1]] == t1,
 d2[t2[t1,d1],d2[t1,d1]] == -d1
}, {p,q,r,s,t}]
