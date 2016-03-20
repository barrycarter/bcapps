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
comparison (n=1 is the standard normal distribution):

$
   \begin{array}{ccccc}
   \text{n} & \mu _{\text{fit}} & \sigma _{\text{fit}} & \text{err}^2 & \text{}
      \\
    1 & 0 & 1 & 0 & \text{} \\
    2 & \text{ 0.536} & \text{ 0.820} & \text{ 0.000145} & \text{} \\
    3 & \text{ 0.806} & \text{ 0.740} & \text{ 0.000382} & \text{} \\
    4 & \text{ 0.983} & \text{ 0.691} & \text{ 0.000622} & \text{} \\
    5 & \text{ 1.112} & \text{ 0.657} & \text{ 0.000849} & \text{} \\
    6 & \text{ 1.214} & \text{ 0.631} & \text{ 0.001058} & \text{} \\
    7 & \text{ 1.297} & \text{ 0.611} & \text{ 0.001252} & \text{} \\
    8 & \text{ 1.366} & \text{ 0.595} & \text{ 0.001432} & \text{} \\
    9 & \text{ 1.427} & \text{ 0.582} & \text{ 0.001599} & \text{} \\
    10 & \text{ 1.479} & \text{ 0.570} & \text{ 0.001755} & \text{} \\
    11 & \text{ 1.526} & \text{ 0.560} & \text{ 0.001901} & \text{} \\
    12 & \text{ 1.568} & \text{ 0.551} & \text{ 0.002038} & \text{} \\
    13 & \text{ 1.606} & \text{ 0.543} & \text{ 0.002167} & \text{} \\
    14 & \text{ 1.641} & \text{ 0.536} & \text{ 0.002289} & \text{} \\
    15 & \text{ 1.673} & \text{ 0.529} & \text{ 0.002405} & \text{} \\
    16 & \text{ 1.703} & \text{ 0.524} & \text{ 0.002515} & \text{} \\
    17 & \text{ 1.730} & \text{ 0.518} & \text{ 0.002619} & \text{} \\
    18 & \text{ 1.756} & \text{ 0.513} & \text{ 0.002719} & \text{} \\
    19 & \text{ 1.780} & \text{ 0.509} & \text{ 0.002815} & \text{} \\
    20 & \text{ 1.803} & \text{ 0.504} & \text{ 0.002907} & \text{} \\
    21 & \text{ 1.825} & \text{ 0.500} & \text{ 0.002995} & \text{} \\
    22 & \text{ 1.845} & \text{ 0.497} & \text{ 0.003079} & \text{} \\
    23 & \text{ 1.864} & \text{ 0.493} & \text{ 0.003161} & \text{} \\
    24 & \text{ 1.882} & \text{ 0.490} & \text{ 0.003239} & \text{} \\
    25 & \text{ 1.900} & \text{ 0.487} & \text{ 0.003315} & \text{} \\
    50 & \text{ 2.182} & \text{ 0.440} & \text{ 0.004654} & \text{} \\
    100 & \text{ 2.440} & \text{ 0.403} & \text{ 0.006047} & \text{} \\
    500 & \text{ 2.971} & \text{ 0.342} & \text{ 0.009231} & \text{} \\
    1000 & \text{ 3.176} & \text{ 0.323} & \text{ 0.010527} & \text{} \\
    5000 & \text{ 3.616} & \text{ 0.287} & \text{ 0.013320} & \text{} \\
    10000 & \text{ 3.791} & \text{ 0.275} & \text{ 0.014434} & \text{} \\
    100000 & \text{ 4.328} & \text{ 0.244} & \text{ 0.017810} & \text{} \\
   \end{array}
$

I couldn't get Mathematica to compute best fit mean and sd for values
much higher than n=100000, but I didn't try that hard.

I couldn't find a closed form for the best fit mean, or even the true
mean, but there is one for the median:

$\sqrt{2} \text{erf}^{-1}\left(2^{\frac{n-1}{n}}-1\right)$

Since we know the PDF, you'd think we could find a closed form for the
mode, by setting the PDF's derivative to 0, which would be:

FullSimplify[D[maxdist[n,x],x],{Element[n,Integers], n>0, x>0}]


FullSimplify[D[maxdist[n,x],x],{Element[n,Integers]n>0, x>0}] /.
 Erfc[y_] -> 1 - Erf[y]

temp[x_]=Simplify[Exp[x^2]*2^n*Pi*D[maxdist[n,x]/n*(1+Erf[x/Sqrt[2]])^(2-n),x]]


row[0] = {
 "n",
 Subscript["\[Mu]",fit],
 Subscript["\[Sigma]",fit], 
 err^2,
};

row[1] = {1,0,1,0}

row[i_] := {i, 
 PaddedForm[nmu[i],{4,3}], 
 PaddedForm[nsigma[i],{4,3}], 
 PaddedForm[nmin[i][[1]],{6,6}]
};

Grid[Table[row[i],{i,Join[Range[0,25], 
 {50,100,500,1000,5000,10000,100000}]}]]
showit






I also include:

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

(*

Subject: Dependency of parameter to find maximum vanishes after simplification

I'm using Mathematica to try to solve:
http://math.stackexchange.com/questions/1700486

The probability distribution function (PDF) of the maximum of n
standard normally distributed variables is:

<pre><code>
(2^(1/2 - n)*n*(1 + Erf[x/Sqrt[2]])^(-1 + n))/(E^(x^2/2)*Sqrt[Pi])
</code></pre>

To find the mode, I take the derivative and set equal to 0. The
"raw" derivative is:

<pre><code>
(2^(1 - n)*(-1 + n)*n*(1 + Erf[x/Sqrt[2]])^(-2 + n))/(E^x^2*Pi) - 
 (2^(1/2 - n)*n*x*(1 + Erf[x/Sqrt[2]])^(-1 + n))/(E^(x^2/2)*Sqrt[Pi])
</code></pre>

and `Simplify` will reduce it to:

<pre><code>
-((n*(1 + Erf[x/Sqrt[2]])^(-2 + n)*(2 - 2*n + E^(x^2/2)*Sqrt[2*Pi]*x + 
    E^(x^2/2)*Sqrt[2*Pi]*x*Erf[x/Sqrt[2]]))/(2^n*E^x^2*Pi))
</code></pre>

Since I only need to see when this value is 0, I can multiply it by
anything that's not 0 (or undefined), in particular:

`Exp[x^2]*2^n*Pi/n*(1+Erf[x/Sqrt[2]])^(2-n)`

Multiplying the simplifed derivative by that quantity yields:

<pre><code>
2^n*E^x^2*Pi*(2^(1 - n)/(E^x^2*Pi) - (2^(1/2 - n)*x*(1 + Erf[x/Sqrt[2]]))/
   (E^(x^2/2)*Sqrt[Pi]))
</code></pre>

Simplifying again, we have:

`2 - E^(x^2/2)*Sqrt[2*Pi]*x - E^(x^2/2)*Sqrt[2*Pi]*x*Erf[x/Sqrt[2]]`

The problem? This value no longer depends on n.

However, graphing the PDF for various values of n shows that the mode changes:

[[image8]]

Where have I gone wrong?

*)


