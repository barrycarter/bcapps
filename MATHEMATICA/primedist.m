(* https://www.reddit.com/r/math/comments/z48vpa/sum_of_consecutive_primes_question/ *)

distPrime[n_] := distPrime[n] = Min[n-Prime[PrimePi[n]], Prime[PrimePi[n]+1]-n]

t0305 = Table[Prime[n] + Prime[n+1], {n,1,10^5}];

t0306 = Map[distPrime, t0305];

Tally[t0306];

t0333 = Table[Prime[n] + Prime[n+1], {n,10^9,10^9+10^5}];

t0334 = Map[distPrime, t0333];

Tally[t0334]

(*

result of t0334 tally:

{{1, 18879}, {3, 9208}, {5, 12644}, {7, 10925}, {9, 5656}, {11, 8438}, 
 {13, 6788}, {15, 2910}, {17, 4951}, {19, 3939}, {21, 1849}, {23, 2672}, 
 {25, 2122}, {27, 1078}, {29, 1680}, {31, 1254}, {33, 555}, {35, 759}, 
 {37, 764}, {39, 359}, {41, 505}, {43, 432}, {45, 166}, {47, 279}, {49, 256}, 
 {51, 109}, {53, 168}, {55, 123}, {57, 77}, {59, 102}, {61, 84}, {63, 29}, 
 {65, 48}, {67, 34}, {69, 16}, {71, 18}, {73, 26}, {75, 14}, {77, 14}, 
 {79, 16}, {81, 9}, {83, 8}, {85, 12}, {87, 5}, {89, 2}, {91, 3}, {93, 2}, 
 {95, 5}, {99, 1}, {101, 1}, {105, 1}, {107, 2}, {109, 1}, {115, 1}, {117, 2}}

*)

t0336 = Table[Prime[n] + Prime[n+1], {n,10^11,10^11+10^5}];

t0337 = Map[distPrime, t0336];

Sort[Tally[t0337]]

(*

result of t0337 tally:

{{1, 15902}, {3, 8138}, {5, 11109}, {7, 10287}, {9, 5292}, {11, 8233}, 
 {13, 6674}, {15, 3106}, {17, 5104}, {19, 4332}, {21, 2085}, {23, 3327}, 
 {25, 2522}, {27, 1491}, {29, 2165}, {31, 1749}, {33, 897}, {35, 1134}, 
 {37, 1150}, {39, 526}, {41, 810}, {43, 675}, {45, 290}, {47, 515}, {49, 413}, 
 {51, 237}, {53, 311}, {55, 236}, {57, 147}, {59, 206}, {61, 167}, {63, 73}, 
 {65, 121}, {67, 101}, {69, 50}, {71, 73}, {73, 56}, {75, 37}, {77, 41}, 
 {79, 31}, {81, 21}, {83, 24}, {85, 22}, {87, 8}, {89, 21}, {91, 15}, {93, 9}, 
 {95, 18}, {97, 6}, {99, 7}, {101, 4}, {103, 6}, {105, 2}, {107, 3}, {109, 4}, 
 {111, 2}, {113, 4}, {115, 1}, {117, 2}, {119, 2}, {121, 1}, {123, 1}, 
 {125, 1}, {129, 1}, {135, 1}, {139, 1}, {143, 1}}

*)

(* primes this high use probabilistic prime testing with PrimeQ *)

t1053 = Table[NextPrime[10^25, i], {i, 1, 10000}];

t1054 = Table[t1053[[i-1]] + t1053[[i]], {i, 2, Length[t1053]}];

t1058 = NextPrime[10^25, Table[i, {i, 1, 100000}]];

t1059 = Table[t1058[[i-1]] + t1058[[i]], {i, 2, Length[t1058]}];

t1100 = Map[PrimeQ, t1059+1];

t1101 = Map[PrimeQ, t1059-1];

Length[Select[t1100, # &]]

Length[Select[t1101, # &]]

(* 

Assuming no twin primes, the above shows 4057 + 4025 or 8082 are primes

*)

t1105 = NextPrime[10^100, Table[i, {i, 1, 10000}]];

t1106 = Table[t1105[[i-1]] + t1105[[i]], {i, 2, Length[t1105]}];

t1107 = Map[PrimeQ, t1106+1];

t1108 = Map[PrimeQ, t1106-1];

Length[Select[t1107, #&]]

Length[Select[t1108, #&]]

(* generic module *)

nearPrimes[n_, k_:1000] := Module[{s1, s2, s3},
 s1 = NextPrime[Floor[n], Table[i, {i, 1, k}]];
 s2 = Table[s1[[i]] + s1[[i-1]], {i, 2, Length[s1]}];
 s3 = Select[s2, PrimeQ[#-1] || PrimeQ[#+1] &];
 Return[Length[s3]/k];
];

Table[{k, nearPrimes[10^k]}, {k, 0, 100, 0.5}]

nearPrimesP[n_, k_:1000] := Module[{s1, s2, s3},
 Print[n];
 s1 = NextPrime[Floor[n], Table[i, {i, 1, k}]];
 s2 = Table[s1[[i]] + s1[[i-1]], {i, 2, Length[s1]}];
 s3 = Select[s2, PrimeQ[#-1] || PrimeQ[#+1] &];
 Return[Length[s3]/k];
];

Plot[nearPrimesP[10^n], {n, 0, 100}]






 

 







