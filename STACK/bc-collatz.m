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

(* t1732 == A008908 pretty much *)

t1732 = Table[Length[runcoll[n]]+1, {n,2,10000}]

t1733 = Table[{i, Min[Position[t1732, i]]}, {i,2,500}]

t1732 = Table[Length[runcoll[n]]+1, {n,2,100000}];

t1733 = Table[{i, Min[Position[t1732, i]]}, {i,2,100000}]

(* 4 is special case to avoid 1 *)

anticasc[4] = {8};
anticasc[n_] = If[Mod[n,6] == 4, {n*2, (n-1)/3}, {n*2}];

anticascade[list_] := DeleteDuplicates[Flatten[Table[anticasc[i], {i,list}]]];


3n+1 = m 

(m-1)/3






Out[109]= 703122933531233285460504082466449258726249455117491574727979055863498\
 
>    3246913525562753031466207615418


 A014682 (diff is /2)

 0, 2, 1, 5, 2, 8, 3, 11, 4, 14, 5, 17, 6, 20, 7, 23, 8, 26, 9, 29, 10, 32, 11, 35, 12, 38, 13, 41, 14, 44, 15, 47, 16, 50, 17, 53, 18, 56, 19, 59, 20, 62, 21, 65, 22, 68, 23, 71, 24, 74, 25, 77, 26, 80, 27, 83, 28, 86, 29, 89, 30, 92, 31, 95, 32, 98, 33, 101, 34, 104

 The Collatz or 3x+1 function: a(n) = n/2 if n is even, otherwise (3n+1)/2. 

A006370 

 0, 4, 1, 10, 2, 16, 3, 22, 4, 28, 5, 34, 6, 40, 7, 46, 8, 52, 9, 58, 10, 64, 11, 70, 12, 76, 13, 82, 14, 88, 15, 94, 16, 100, 17, 106, 18, 112, 19, 118, 20, 124, 21, 130, 22, 136, 23, 142, 24, 148, 25, 154, 26, 160, 27, 166, 28, 172, 29, 178, 30, 184, 31, 190, 32, 196, 33

 The Collatz or 3x+1 map: a(n) = n/2 if n is even, 3n + 1 if n is odd. 

