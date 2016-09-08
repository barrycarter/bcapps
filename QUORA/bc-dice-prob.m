https://www.quora.com/unanswered/If-you-roll-a-dice-over-and-over-until-a-6-comes-up-what-is-the-probability-that-all-other-numbers-have-come-up-at-least-once


(* the chance of being in state 0, no numbers rolled, at t=0 is 1 *)

p[0,0] = 1

p[x_,0] = 0

(* if you're in state x at time n, there's a x/6 chance you'll stay in
that state *)

(* and this chance that you'll see a new number that's not six *)

p[x_,n_] := x/6*p[x,n-1] + (6-x)/6*p[x-1,n-1]




p[x_,n_] := 

(* and a 1/6 chance you'll end up rolling a 6, which we call state 7 for clarity?*)

p[7,n_] := Sum[p[x,n-1],{x,1,6}]/6;


1+Random[Integer, 5]

roll := Module[{r,l},
 l = {};
 While[True,
 r = 1+Random[Integer,5];
 If[r==6, Return[l], l = Append[l,r]];
 ]
]

t = Table[roll,{i,1,1000000}];

u = Table[Length[DeleteDuplicates[i]],{i,t}];

Length[Select[u, # == 5 &]]
