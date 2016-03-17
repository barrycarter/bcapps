TODO: figure out why I need 'n' product below

maxdist[n_,x_] = 
FullSimplify[
 n*CDF[NormalDistribution[0,1]][x]^(n-1)*PDF[NormalDistribution[0,1]][x],
{Element[x,Reals], Element[n, Integers], n>0}]

cumdist[n_,x_] = FullSimplify[((1+Erf[x/Sqrt[2]])/2)^n,
 {Element[x,Reals], Element[n, Integers], n>0}]

(* memoize here may help NMinimize *)

diff[mu_,sigma_,n_] := diff[mu,sigma,n] = NIntegrate[
 (maxdist[n,x]-PDF[NormalDistribution[mu,sigma]][x])^2,
{x, -Infinity, Infinity}]

nmin[i_] := nmin[i] = NMinimize[N[diff[mu,sigma,i]],{mu,sigma}]

nmu[i_] := nmin[i][[2,1,2]]

nsigma[i_] := nmin[i][[2,2,2]]

(*

http://math.stackexchange.com/questions/1700486/probability-of-inequalities-between-max-values-of-samples-from-two-different-dis

NOTE: This assumes the heights are normally distributed.

I thought there'd be a well-known distribution for the maximum of n
standard normal variables, but, as
http://math.stackexchange.com/questions/473229 notes, there isn't. You
can't even find a closed form for the expected value (though you can
for the median).

The PDF for the max of n standard normal variables is:

$
\frac{2^{\frac{1}{2}-n} n e^{-\frac{x^2}{2}}
\left(\text{erf}\left(\frac{x}{\sqrt{2}}\right)+1\right)^{n-1}}{\sqrt{\pi }}
$

and the CDF is:

$2^{-n} \left(\text{erf}\left(\frac{x}{\sqrt{2}}\right)+1\right)^n$

Here's what the PDF looks like for various values of n:

Plot[{
 maxdist[1,x],
 maxdist[2,x],
 maxdist[5,x],
 maxdist[25,x]
}, {x,-4,4}, PlotLegends -> {"n=1", "n=2", "n=5", "n=25"}]

Of course, n=1 is just the standard normal distribution itself.

Except for n=1, these aren't normal distributions, but can be
approximated as such. For n=5, for example, 
$\{\mu \to 1.11241,\sigma \to 0.656668\}$ and the graph looks like this:

Plot[{
 maxdist[5,x],
 PDF[NormalDistribution[nmu[5], nsigma[5]]][x]
},
 {x,-4,4}]
showit

where the blue line is actual distribution and the red line is the
normal approximation (I tried to use Mathematica's PlotLegends to
label the graph directly, but it was seriously ugly).

The integral of the difference squared from $-\infty$ to $\infty$ is
about 0.000848615

For n=25, $\{\mu \to 1.89997,\sigma \to 0.486849\}$:

Plot[{
 maxdist[25,x],
 PDF[NormalDistribution[nmu[25],nsigma[25]]][x]
},
 {x,-4,4}]
showit

with an error squared of 0.00331485.

TODO: generalish formula

If we use these approximations, your distributions are:

  - tallest of 5 from Country A: $\{\mu \to 78.6745,\text{sd}\to 3.94001\}$

  - tallest of 25 from Country B: $\{\mu \to 71.6999,\text{sd}\to 1.46055\}$

  - The difference: $\{\mu \to 6.9746,\sigma \to 4.20201\}$

So the chance A will be taller is about 95.15%

Of course, that's just an approximation, but it can help us check our
more rigorous analysis below.

The CDF for the tallest of 25 from Country B:

$
   \frac{25 e^{-\frac{1}{18} (x-66)^2} \left(\text{erf}\left(\frac{x-66}{3
    \sqrt{2}}\right)+1\right)^{24}}{50331648 \sqrt{2 \pi }}
$

and the PDF for the tallest of 5 from Country A:

$
   \frac{5 e^{-\frac{1}{72} (x-72)^2} \left(\text{erf}\left(\frac{x-72}{6
    \sqrt{2}}\right)+1\right)^4}{16 \sqrt{2 \pi }}
$

If we numerically integrate the product from $-\infty$ to $\infty$ we
get 0.140074 (using "MinRecursion -> 25, MaxRecursion -> 50" for
Mathematica's NIntegrate), so the probability we want is 85.99%, not
as good of an approximation as I'd hoped.

Plot[{maxdist[5,x], PDF[NormalDistribution[1.11241, 0.656668]][x]},
 {x,-4,4}, PlotLegends -> LineLegend["Expressions"]]

TODO: Monte Carlo





NMinimize[N[diff[mu,sigma,1]],{mu,sigma}]
NMinimize[N[diff[mu,sigma,2]],{mu,sigma}]

t = Table[NMinimize[N[diff[mu,sigma,i]],{mu,sigma}], {i,1,25}]




Plot[{
 maxdist[25,x],
 PDF[NormalDistribution[1.89997,0.486849]][x]
},
 {x,-4,4}]
showit

 PDF[NormalDistribution[1.92133,0.5]][x]

ContourPlot[diff[mu,sigma], {mu,1.8,2.0}, {sigma,0.4,0.6}, 
 ColorFunction -> "Rainbow"]

NMinimize[N[diff[mu,sigma]], {mu,sigma}]




Integrate[(maxdist[25,x]-NormalDistribution[mu,sigma][x])^2,
 {x,-Infinity,Infinity}]

Integrate[(maxdist[2,x]-NormalDistribution[mu,sigma][x])^2,
 {x,-Infinity,Infinity}]


(x-72)/6

Plot[maxdist[1,(x-72)/6],{x,72-3*6,72+3*6}]

Plot[maxdist[5,(x-72)/6],{x,72-3*6,72+3*6}]

Plot[maxdist[25,(x-66)/3],{x,66-3*3,66+3*3}]

Plot[{
 maxdist[1,(x-66)/3],
 maxdist[1,(x-72)/6],
 maxdist[25,(x-66)/3],
 maxdist[5,(x-72)/6]
}, {x,57,90}]

Integrate[5,x

Plot[cumdist[25,(x-66)/3]*(1-cumdist[5,(x-72)/6]), {x,60,75}]

Integrate[cumdist[25,(x-66)/3]*maxdist[5, (x-72)/6], {x,-Infinity,Infinity}]

Integrate[cumdist[25,(x-66)/3]*(1-cumdist[5,(x-72)/6]), {x,-Infinity,Infinity}]

cumdist[25,(x-66)/3]*(1-cumdist[5,(x-72)/6])==1/2


Plot[maxdist[0,1,1,x],{x,-3,3}]

Plot[maxdist[0,1,2,x],{x,-3,3}]

means are 1/Sqrt[Pi], 3/(2*Sqrt[Pi]), 

Plot[Log[PDF[NormalDistribution[0,1]][x]],{x,-3,3}]

Plot[Log[maxdist[0,1,2,x]],{x,-3,3}]

median[n_] = FullSimplify[x /. Solve[cumdist[n,x] == 1/2, x][[1]],
 {Element[n,Integers], n>0}]

Plot[{
 maxdist[0,1,1,x],
 maxdist[0,1,2,x],
 maxdist[0,1,3,x],
 maxdist[0,1,5,x],
 maxdist[0,1,25,x]
}, {x,-3,3}]

Plot[{
 maxdist[72,6,5,x], maxdist[66,3,25,x]
}, {x,60,78}]

(* Monte *)

countryA := Max[RandomVariate[NormalDistribution[72, 6], 5]]
countryB := Max[RandomVariate[NormalDistribution[66, 3], 25]]
t =Table[countryA>countryB,{i,1,10000}]

9555/10000
9563/10000
95791 out of 100K


