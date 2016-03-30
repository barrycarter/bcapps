(*

http://math.stackexchange.com/questions/1717271/

If you have a set with $n$ elements and intersect two randomly
selected subsets, the probability that the intersection will have
exactly $k$ elements is: $4^{-n} 3^{n-k} \binom{n}{k}$ (the $4^{-n}$
is because there are $4^n$ ways to choose a pair of subsets from $n$
elements).

I couldn't actually prove this, but I'm pretty sure it's true and that
I'm just being lazy. Perhaps someone else could provide a proof?

If you accept the formula above, the mean for a given value of $n$ is
$\frac{n}{4}$, the variance is $\frac{3 n}{16}$, and the standard
deviation is thus $\frac{\sqrt{3 n}}{4}$

For large values of $n$, the distribution is essentially normal with
the parameters above.

TODO: add graphs?

tab[n_] := Table[f[n,k],{k,0,n}]

ListPlot[tab[500], PlotRange -> All]




As $n$ grows large, this looks like a normal distribution with mean $\frac{n}{4}$ and variance 

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




