Get[Environment["HOME"]<>"/BCGIT/STACK/nmintab.txt"]

Table[nmin[i] = nmintab[[i]], {i,1,Length[nmintab]}]

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

median[n_] = Sqrt[2]*InverseErf[2^((n-1)/n)-1]

mean[n_] := mean[n] = NIntegrate[x*maxdist[n,x], {x,-Infinity,Infinity}]

derv[n_,x_] = D[maxdist[n,x],x]

mode[1] = 0;

(* TODO: this fails for even fairly low n, and NSolve won't work either *)

mode[n_] := mode[n] = FindRoot[derv[n,x], {x,0,median[n]}][[1,2]]

sd[n_] := sd[n] = 
 Sqrt[NIntegrate[(x-mean[n])^2*maxdist[n,x], {x,-Infinity,Infinity}]]

(* 

the estimate of the standard deviation by comparing this CDF to the
standard normal's CDF for a given number of sds (this uses the median
we define above, which may be bad)

Solve[cumdist[n,median[n]+x] == CDF[NormalDistribution[0,1]][y], x][[1,1,2]]/y
Solve[cumdist[n,median[n]-x] == CDF[NormalDistribution[0,1]][-y], x][[1,1,2]]/y

the limit of this as y -> 0 has a closed form and is actually a pretty
good estimate

FullSimplify[Assuming[{Element[k,Integers],k>0}, Limit[sdEstimate[k,y]
, y -> 0]], Element[k,Integers]]
*)

sdEstimateTwoParam[n_,y_] = 
(Sqrt[2]*(-InverseErf[-1 + 2^((-1 + n)/n)] + 
   InverseErf[-1 + (2^(-1 + n)*(1 + Erf[y/Sqrt[2]]))^n^(-1)]))/y

sdEstimate[k_] = (2^((-1 + k)/k)*E^InverseErf[-1 + 2^((-1 + k)/k)]^2)/k

(* expected rarity of successes in n trials; this is just median, so
commenting out *)

(*
murare[n_] = -(Sqrt[2]*InverseErfc[2^(1 - n^(-1))])
*)

(* TODO: add (1/2)^(1/n) denormalized or whatever and Integrate[(x-median[5])^2*maxdist[5,x],{x,-Infinity,Infinity}] *)

(*

http://math.stackexchange.com/questions/1700486/probability-of-inequalities-between-max-values-of-samples-from-two-different-dis

NOTE: This assumes the heights are normally distributed.

I thought there'd be a well-known distribution for the maximum of n
standard normal variables, but, as
http://math.stackexchange.com/questions/473229 notes, there isn't. You
can't even find a closed form for the expected value (though you can
for the median).

TODO: derivations or just point to this file?

The PDF for the max of n standard normal variables is:

$
\frac{2^{\frac{1}{2}-n} n e^{-\frac{x^2}{2}}
\left(\text{erf}\left(\frac{x}{\sqrt{2}}\right)+1\right)^{n-1}}{\sqrt{\pi }}
$

and the CDF is:

$2^{-n} \left(\text{erf}\left(\frac{x}{\sqrt{2}}\right)+1\right)^n$

Here's what the PDF looks like for various values of n:

[[image8.gif]]

Of course, n=1 is just the standard normal distribution itself.

Except for n=1, these aren't normal distributions, but can be
approximated as such. For n=5, for example, 
$\{\mu \to 1.11241,\sigma \to 0.656668\}$ and the graph looks like this:

[[image9.gif]]

The integral of the difference squared from $-\infty$ to $\infty$ is
about 0.000848615

For n=25, $\{\mu \to 1.89997,\sigma \to 0.486849\}$:

[[image10.gif]]

with an error squared of 0.00331485.

In both cases, I used numerical methods to minimize integral of the
difference squared (ie, the "error" squared).

Of course, you used 5 and 25 as examples. Below is a tabulation for
the best fit parameters from 1 to 25, plus some larger values for
comparison. I also include:

  - the true median of the distribution: 
$\sqrt{2} \text{erf}^{-1}\left(2^{\frac{n-1}{n}}-1\right)$

  - the mode of the distribution (I couldn't find a closed form,
  though one may exist)

  - the true mean of the distribution (from the linked post, I don't
  think there is a closed form).

  - an estimate of the standard deviation obtained by comparing the
  distribution to the normal distribution in the limiting case around
  the median; the only advantage this estimate has is that it can be
  expressed in closed form:

$   
   \frac{2^{\frac{n-1}{n}}
    e^{\text{erf}^{-1}\left(2^{\frac{n-1}{n}}-1\right)^2}}{n}
$

  - the true standard deviation of the distribution (no closed form I
  could find)

Of course, if these were true normal distributions, the median, mode,
mean, and "best fit $\mu$" would be identical, as would the "best fit
$\sigma$" and the true standard deviation.

row[0] = {
 "n",
 Subscript["\[Mu]",fit],
 Subscript["\[Sigma]",fit], 
 err^2,
 "",
 Subscript["\[Mu]", true],
 "Median",
 "Mode",
 "",
 Subscript["\[Sigma]", true]
 Subscript["\[Sigma]", est]
};

row[1] = {"1", " 0.000", " 0.000", " 0.000000", " 0.000", " 0.000",
" 0.000", " 1.000"}

row[i_] := {i, 
 PaddedForm[nmu[i],{4,3}], 
 PaddedForm[nsigma[i],{4,3}], 
 PaddedForm[nmin[i][[1]],{6,6}],
 "",
 PaddedForm[mean[i],{4,3}],
 PaddedForm[N[median[i]],{4,3}], 
 PaddedForm[mode[i],{4,3}], 
 "",
 PaddedForm[sd[i],{4,3}],
 PaddedForm[N[sdEstimate[i]],{4,3}]
};

Grid[Table[row[i], {i,0,25}]]
showit

Table[row[i], {i,
 Join[Range[0,25], {50,100,500,1000,5000,10000,100000}]}]

Grid[Table[row[i],{i,0,25}]]
showit
 

t = Table[Chop[N[{i, nmu[i], nsigma[i], nmin[i][[1]], mean[i],
 median[i], mode[i], sd[i]}]], {i,1,25}]

Grid[Prepend[t, {"n", Subscript["\[Mu]",fit], 
                      Subscript["\[Sigma]",fit], err^2,
                      Subscript["\[Mu]", true],
 "Median", "Mode", Subscript["\[Sigma]", true]}],
 Frame -> All, ItemStyle -> "Text"]
showit

t2 = Table[Chop[N[{i, nmu[i], nsigma[i], nmin[i][[1]], mean[i],
 median[i], mode[i], sd[i]}]], {i,{50,100,500,1000,5000,10000}}]



TODO: cleanup above, it's still too ugly, but also realize I might put
it in TeX

TODO: mention this file

TODO: generalish formula

If we use these approximations, your distributions are:

  - tallest of 5 from Country A: $\{\mu \to 78.6745,\text{sd}\to 3.94001\}$

  - tallest of 25 from Country B: $\{\mu \to 71.6999,\text{sd}\to 1.46055\}$

  - The difference: $\{\mu \to 6.9746,\sigma \to 4.20201\}$

So the chance A will be taller is about 95.15%

Of course, that's just an approximation, so let's do a more rigorous
analysis below.

The CDF for the tallest of 25 from Country B:

$
   \frac{\left(\text{erf}\left(\frac{x-66}{3
    \sqrt{2}}\right)+1\right)^{25}}{33554432}
$

and the PDF for the tallest of 5 from Country A:

$
   \frac{5 e^{-\frac{1}{72} (x-72)^2} \left(\text{erf}\left(\frac{x-72}{6
    \sqrt{2}}\right)+1\right)^4}{96 \sqrt{2 \pi }}
$

If we use Mathematica to numerically integrate the product from
$-\infty$ to $\infty$ we get 95.77%, which is pretty close to our
earlier estimate.

Just for fun, I ran a Monte Carlo simulation as well:

<pre><code>
countryA := Max[RandomVariate[NormalDistribution[72, 6], 5]]
countryB := Max[RandomVariate[NormalDistribution[66, 3], 25]]
t =Table[countryA>countryB,{i,1,100000}]
</code></pre>

and got 95.79% (I ran it several times, 95.79% is the average).

*)

Plot[{
 maxdist[1,x],
 maxdist[2,x],
 maxdist[5,x],
 maxdist[25,x]
}, {x,-4,4}, PlotLegends -> 
 {"n=1", "n=2", "n=5", "n=25"}
]

Plot[{
 maxdist[1,x],
 maxdist[2,x],
 maxdist[5,x],
 maxdist[25,x]
}, {x,-4,4}, PlotLegends -> 
 Placed[{"n=1", "n=2", "n=5", "n=25"}, {0.1,0.5}]
]

Plot[{
 maxdist[5,x],
 PDF[NormalDistribution[nmu[5], nsigma[5]]][x]
}, {x,-4,4}, PlotLegends -> 
 Placed[{"Normal Approximation", "Actual Distribution"}, {0.21,0.5}]
]
showit

Plot[{
 maxdist[25,x],
 PDF[NormalDistribution[nmu[25], nsigma[25]]][x]
}, {x,-4,4}, PlotLegends -> 
 Placed[{"Normal Approximation", "Actual Distribution"}, {0.21,0.5}]
]
showit

Plot[{
 maxdist[25,x],
 PDF[NormalDistribution[nmu[25],nsigma[25]]][x]
},
 {x,-4,4}]
showit

subset = Table[{i, nmu[[i]]}, {i,15,100}]
fit0[x_] = Fit[subset,{1,Log[x],x},x]
fit = Table[{x,fit0[x]}, {x, 15, 100}]
ListPlot[{subset,fit}]
showit
diff = Table[{i[[1]], i[[2]] - fit0[i[[1]]]}, {i, subset}]
ListPlot[diff]

subset = Table[{i, nmu[[i]]}, {i,15,100}]
fit0[x_] = Fit[subset,{1,Log[x],Sqrt[x]},x]

fit0[x_] = Fit[subset,{1,x,Sqrt[x],x^2},x]
fit = Table[{x,fit0[x]}, {x, 15, 100}]
ListPlot[{subset,fit}, PlotRange->All]
showit
diff = Table[{i[[1]], i[[2]] - fit0[i[[1]]]}, {i, subset}]
ListPlot[diff, PlotRange->All]
showit

guess[x_] = a*x^b /. FindFit[nmu, a*x^b, {a,b}, x]

guess[x_] = a*x^b+c /. FindFit[nmu, a*x^b+c, {a,b,c}, x]

guess[x_] = a*Log[b*x+c] /. FindFit[nmu, a*Log[b*x+c], {a,b,c}, x]

guess[x_] = d*x^2 + e*x + a*Log[b*x+c] /. FindFit[nmu, 
 d*x^2 + e*x + a*Log[b*x+c], {a,b,c,d,e}, x]

guess[x_] = a*Log[b*x+c] + d*Sqrt[e*x+f] /. FindFit[nmu, 
 a*Log[b*x+c] + d*Sqrt[e*x+f], {a,b,c,d,e,f}, x]

guess[x_] = a*x + b*x^2 + c*Log[d*x] /.
 FindFit[nmu, a*x + b*x^2 + c*Log[d*x], {a,b,c,d}, x]

subset = Table[{i, nmu[[i]]}, {i,20,100}]
expr = a*x^b;
guess[x_] = expr /.  FindFit[subset, expr, {a,b,c,d}, x]

guesstab = Table[guess[i],{i,1,100}]


fit = Table[Evaluate[Fit[nmu,Log[x],x]], {x, 1, 100}]

fit = Table[Evaluate[Fit[nmu,{1,Log[x]},x]], {x, 1, 100}]
ListPlot[{fit,nmu}]
showit

fit = Table[Evaluate[Fit[nmu,{1,Sqrt[x],Log[x],x},x]], {x, 1, 100}]
ListPlot[{fit,nmu}]
showit



fit = Table[Evaluate[Fit[nmu,{1,Log[x]},x]], {x, 1, 100}]
ListPlot[{fit,nmu}]
showit

tab = Table[x^n,{n,0,5}]
fit = Table[Evaluate[Fit[nmu,tab,x]], {x, 1, 100}]
ListPlot[{fit,nmu}]
showit

Plot[{PDF[ExtremeValueDistribution[1,1/2]][x], maxdist[5,x]}, {x,-3,3}]

Plot[{PDF[ExtremeValueDistribution[1.1,1/1.5]][x], maxdist[5,x]}, {x,-3,3}]
showit

Plot[{PDF[GumbelDistribution[1.1,1/1.5]][x], maxdist[5,x]}, {x,-3,3}]
showit

gdiff[alpha_,beta_,n_] := gdiff[alpha,beta,n] = NIntegrate[
 (maxdist[n,x]-PDF[GumbelDistribution[alpha,beta]][x])^2,
{x, -Infinity, Infinity}]

gnmin[i_] := gnmin[i] = NMinimize[N[gdiff[alpha,beta,i]],{alpha,beta}]

ediff[alpha_,beta_,n_] := ediff[alpha,beta,n] = NIntegrate[
 (maxdist[n,x]-PDF[ExtremeValueDistribution[alpha,beta]][x])^2,
{x, -Infinity, Infinity}]

enmin[i_] := enmin[i] = NMinimize[N[ediff[alpha,beta,i]],{alpha,beta}]




