(*

http://quant.stackexchange.com/questions/24970/estimate-probability-of-limit-order-execution-over-a-large-time-frame

https://mathematica.stackexchange.com/questions/110565/closed-form-probability-random-walk-will-hit-k-1-times-in-n-steps

Subject: Closed form probability random walk will hit k >=1 times in n steps

I'm using Mathematica to try to solve
http://quant.stackexchange.com/questions/24970 and came across what
seems like a simple question: if you take a standard random walk of
`n` steps, what is the formula for the probability you'll touch `+k`
at least once. More generically, what's the probability distribution
of a random walk of `n` steps.

I can compute this chance using a recursive formula:

<pre><code>
c[n_,0] := 1
c[0, k_] := 0
c[n_,k_] := c[n,k] = 1/2*(c[n-1,k-1] + c[n-1,k+1])
</code></pre>

but Mathematica won't `RSolve` it:

<pre><code>
RSolve[{f[n,0] == 1, f[0,k] == 0, f[n,k] == 1/2*(f[n-1,k-1]+f[n-1,k+1])},
 f[n,k], {n,k}]
</code></pre>

returns unevaluated. I'm not too surprised, since Mathematica isn't
that good with two variable recursion.

However, I'm convinced there's a "simple" formula here, or at least a
good approximation for large `n`.

I did try a few different things to no avail:

  - Trying to find a formula for specific values of `n` or `k`.

  - Using `Log` to see if this was an exponential distribution of some sort.

  - Comparing it to the right half of the normal distribution.

  - Trying to find a formula for the interpolation, since the function
  itself is somewhat "juddery" (ie, f(x+1) = f(x) in many cases).

I'm convinced I can use Pascal's triangle (ie, the binomial theorem
and Mathematica's `Binomial` function) to resolve this, but can't
quite figure out how.

*)

n trades, and negatives outweigh positives by k or more

eg 10 trades, and 8+ negs vs 2+ pos (this is a 6 lead)

(n-k)/2 positive trades, (n+k)/2 negatives trades, negs lead by k

(won't work, incorrectly assumes Independence)

k below means "k above value you want"; n is number of trades remaining

c[n_,k_] := 0 /; k > n

c[n_,0] := 1
c[0, k_] := 0
c[n_,k_] := c[n,k] = 1/2*(c[n-1,k-1] + c[n-1,k+1])

t = Table[c[n,k],{n,0,20},{k,0,20}]



RSolve[
  {c[n,0] == 1, c[0,k] == 0, c[n,k] == 1/2*(c[n-1,k-1]+c[n-1,k+1])},
 c[n,k], {n,k}]

RSolve[
  c[n,k] == 1 /; k<=0, c[n,k] == 0 /; n<=0, 
 c[n,k] == 1/2*(c[n-1,k-1]+c[n-1,k+1]),
 {c[n,k]}, {n,k}]

RSolve[
 c[n,k] == 1/2*(c[n-1,k-1]+c[n-1,k+1]),
{c[n,k]}, {n,k}]

Table[c[100,k],{k,0,100}]

doing it just for 10

ListPlot[Table[c[100,k],{k,0,100}], PlotRange -> All]

t = Table[c[n,k],{n,0,10},{k,0,n+1}]

ListPlot[t, PlotRange -> All, PlotJoined -> True]

ListPlot[t[[7]], PlotRange -> All, PlotJoined -> True]

Table[
 ListPlot[t[[i]], PlotRange -> All, PlotJoined -> True]

t1 = Table[c[100,k],{k,0,101}]

ListPlot[Sqrt[-Log[t1]/Log[2]], PlotJoined -> True, PlotRange -> All]
showit

int = Interpolation[t1]
f[x_] = Fit[t1, x^2, x]

Plot[Sqrt[Log[int[x]]]/x,{x,1,101}]

LogPlot[{int[x], f[x]}, {x,0,101}, PlotRange -> All]

halfway points:

n=2 right at 1

at 8 and 9 really close to 2
at 19 and 20 really close to 3
at 36 and 37 just passes 4
at 55 and 56 just passes 5


n=10 between 2 and 3
n=50 between 4 and 5
n=100 between 6 and 7
n=1000 between 21 and 22

t = Table[{n,c[n,1]},{n,0,1001}]

t2 = Table[{i[[1]], (i[[2]]/(1-i[[2]]))^2}, {i,t}]

t3 = Table[{i[[1]], (i[[2]]/(1-i[[2]]))^2/i[[1]]}, {i,t}]

ListPlot[t3, PlotRange -> All]

if true...

Solve[(f/(1-f))^2/x == c, f]

t4 = Table[{n,c[n,5]},{n,0,1001}]
t6 = Table[{i[[1]], (i[[2]]/(1-i[[2]]))}, {i,t4}]
t5 = Table[{i[[1]], (i[[2]]/(1-i[[2]]))/i[[1]]}, {i,t4}]

N[PDF[NormalDistribution[0,1]][3/4]]

for n=7, sd is 7/4

chance you have walked more than 3 positive steps is

1 - CDF[NormalDistribution[0,7/4]][2.5]

1 - CDF[NormalDistribution[0,n/4]][k]

test[n_,k_] = 
1 - Product[CDF[RandomWalkProcess[1/2][i], k - 1], {i, 0, n}]

FullSimplify[test[n,k], {Element[{n,k}, Integers], n>=k, k>=0}]

test[n_,k_] = 
1 - Product[CDF[RandomWalkProcess[1/2][i], k], {i, 0, n}]

Table[CDF[RandomWalkProcess[1/2][25]][n],{n,1,25}]

t = N[Table[-Log[c[100,i]],{i,0,100}]]

f[x_] = Fit[t,{1,x^2},x]

t2 = Table[f[x],{x,0,100}]

ListPlot[{t,t2}, PlotRange -> All]

c[n_,0] := 1
c[0, k_] := 0
c[n_,k_] := c[n,k] = 1/2*(c[n-1,k-1] + c[n-1,k+1])

(* this module returns many things *)

fitness[n_] := Module[{t,f,u},
 t = Table[-Log[c[n,i]],{i,0,n}];
 f[x_] = Fit[t,{1,x^2},x];
 u = Table[f[x], {x,0,n}];
 Return[{t,f[x],u}];
]

Table[fitness[n][[2]] /. x -> 0,{n,1,250}]

Table[D[fitness[n][[2]],x,x],{n,1,1000}]

Table[(fitness[n][[2]] /. x -> 0)/n,{n,1,1000}]

test1705[n_,i_] = Exp[-(-0.013435*n + 0.00125151*i^2)]

Exp[c1*n + c2*i^2]

test1357[n_,k_] = Exp[c1*n + c2*k^2]

test1357[n-1,k-1]
test1357[n-1,k+1]

FullSimplify[(test1357[n-1,k-1]+test1357[n-1,k+1])/2]

Solve[(test1357[n-1,k-1]+test1357[n-1,k+1])/2 == test1357[n,k], {c1,c2}, 
 Reals]

Minimize[(test1357[n-1,k-1]+test1357[n-1,k+1])/2 - test1357[n,k], {c1,c2}]

fit[n_] := fit[n] = Function[x,Fit[Table[-Log[c[n,i]],{i,0,n}] ,{1,x^2},x]]

tab[n_] := ListPlot[{
 Table[-Log[c[n,i]], {i,0,n}],
 Table[fit[n][i], {i,0,n}]
}]

d[n_, k_] := If[OddQ[n - k],
 With[{d = Floor[(n + k)/2]},
  2^(1 - n) Binomial[n, d + 1] Hypergeometric2F1[1, 1 + d - n, 2 + d, -1]],
 With[{d = Floor[(n + k + 1)/2]},
  2^(-n) Binomial[n + 1, d + 1] Hypergeometric2F1[1, d - n, 2 + d, -1]]]

d2[n_,k_] = FullSimplify[d[n,k] /. Floor[x_] -> (x+1/2),
 {Element[{n,k},Integers], n>k, k>0}]



http://fiquant.mas.ecp.fr/wp-content/uploads/2015/10/Limit-Order-Book-modelling.pdf

http://arxiv.org/pdf/1311.5661

1591 for 1 to 98%

