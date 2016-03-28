(*

http://math.stackexchange.com/questions/1717271/

t = Subsets[Range[5]];
s = Flatten[Table[{i,j}, {i,t}, {j,t}],1];

u = Table[Length[Intersection[i[[1]],i[[2]]]], {i,s}]

t = Subsets[Range[6]];
s = Flatten[Table[{i,j}, {i,t}, {j,t}],1];

u = Table[Length[Intersection[i[[1]],i[[2]]]], {i,s}]

(a+3)^n

f[n_,k_] = Binomial[n,k]*3^(n-k)/4^n

FullSimplify[f[n,k], {Element[{n,k}, Integers], n>k, k>0}]

Sum[f[n,k],{k,0,n}] == 4^n as expected

Table[f[20,k],{k,0,20}]

Table[f[20,k]*(k-5),{k,0,20}]

Table[f[20,k]*(k-5)^2,{k,0,20}]

Sum[f[n,k]*k,{k,0,n}]

(* above is n/4 *)

Sum[f[n,k]*(k-n/4)^2,{k,0,n}]

(* above is 3n/16 *)

Sqrt[3*n]/4 == standard deviation

*)




