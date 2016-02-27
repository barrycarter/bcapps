(*

Simple relativity:

A shoots light at B, 0.9 light second away moving at .9c

A sees light reach B at 9s, 9ls away

B sees light t seconds later at distance 0, with ???

Thus, A to B transform is:

{9, 9} -> {0, t}

*)

(* the Loretnz contraction, v as fraction of light speed *)

Sqrt[1-v^2]

(* time dilation *)

1/Sqrt[1-v^2]

(* using pqrs to avoid conflicting vars *)

m = {{p,q},{r,s}}

Solve[{
 m.{9,9} == {0,t}, 
 m.m == {{-1,0},{0,1}}
}, {p,q,r,s}]
