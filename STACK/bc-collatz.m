(* http://stackoverflow.com/questions/6535505/collatz-conjecture-in-mathematica *)

collatz[1] = 1;
collatz[n_ /; EvenQ[n]] := (Sow[n]; collatz[n/2])
collatz[n_ /; OddQ[n]] := (Sow[n]; collatz[3 n + 1])
runcoll[n_] := Last@Last@Reap[collatz[n]]

x = Random[Integer,{2,10^100}]

cascade[n_] = If[Mod[n,2]==0,n/2,3*n+1]

cascm[n_] := Module[{var},
 var = n;
 While[var>1, 
  var = cascade[var];
  Print[Floor[Log[var]]];
 ]
]

RSolve[{ f[n+1] == cascade[f[n]]}, f[n], n]


Out[109]= 703122933531233285460504082466449258726249455117491574727979055863498\
 
>    3246913525562753031466207615418

