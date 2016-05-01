(* General case for m-sided dice rolled n times *)

p[m_] := p[m] = Table[1/m,{i,1,m}];

minmax[n_,m_] := Module[{d},
 d = RandomVariate[MultinomialDistribution[n,p[m]]];
 Return[{Min[d],Max[d]}]];

monte[n_,m_] := monte[n,m] = Table[minmax[n,m],{i,1,10000}];

maxvar[n_,m_] := Table[Max[{Abs[i[[1]] - n/m], Abs[i[[2]] - n/m]}], 
 {i, monte[n,m]}];

mins[n_,m_] := Transpose[monte[n,m]][[1]]
maxs[n_,m_] := Transpose[monte[n,m]][[2]]

params[n_,m_] := N[Table[{Mean[i], Sqrt[Variance[i]], Median[i]},
 {i, {mins[n,m], maxs[n,m], maxvar[n,m]}}]];

params2[n_,m_] := {params[n,m][[1]]/n-1/m,
 params[n,m][[2]]/Sqrt[n],
 params[n,m][[3]]/n-1/m
};

params[1000,10]

TODO: this works rapidlyish

t = Table[Random[Integer, 10], {i, 100000000}];

(* about 5 seconds for below *)

t2 = Table[Tally[RandomChoice[t,10000],{j,10000}]];

t2 = Table[Tally[Table[1+Random[Integer, 9], {i, 10000}]], {j,1,10000}];

t2 = Table[Random[Integer, 10], {i,10000}];

Sort[Transpose[t2][[2]]]

Table[RandomChoice[t,10000],{j,10000}];

getcounts := Transpose[Tally[Table[Random[Integer,{1,10}], {i, 10000}]]][[2]]

t2034 = Flatten[Table[getcounts,{i,10000}]];

Histogram[t2034]

OrderDistribution[{NormalDistribution[1000, Sqrt[10000*.1*.9]], 10}, 10]

PDF[OrderDistribution[{NormalDistribution[0,1],6}, 3]][x]

PDF[OrderDistribution[{NormalDistribution[1000,Sqrt[1000*.9]],10}, 10]][x]





Solve[CDF[NormalDistribution[100,Sqrt[1000*.9*.1]],x]==1/10, x]

Solve[CDF[NormalDistribution[n*p, Sqrt[n*p*(1-p)]], x] == p,x]

{{x -> n*p - Sqrt[2]*Sqrt[-(n*(-1 + p)*p)]*InverseErfc[2*p]}}

Solve[CDF[NormalDistribution[n*0.1, Sqrt[n*0.1*(1-0.1)]], x] == 0.1,x]

{{x -> -0.384465 Sqrt[n] + 0.1 n}}

Solve[CDF[NormalDistribution[n*0.1, Sqrt[n*0.1*(1-0.1)]], x] == 0.05,x]

0.493456 Sqrt[n] (if going to 1/20)

Solve[CDF[NormalDistribution[n/10, Sqrt[n/10*9/10]], x] == 1/10,x]

Sqrt[2] Sqrt[-(n (-1 + p) p)] InverseErfc[2 p]

appears to be the "magic number", for large n

CDF[NormalDistribution[n/10, Sqrt[n/10*9/10]], x]

CDF[NormalDistribution[1000/10, Sqrt[1000/10*9/10]], 100-17.6229]

CDF[NormalDistribution[50000/10, Sqrt[50000/10*9/10]], 5000-39.466]

CDF[NormalDistribution[500/10, Sqrt[500/10*9/10]], 50-12.4655]

CDF[NormalDistribution[100000/10, Sqrt[100000/10*9/10]], 10000-175.799]





(* this just to force evaluation *)

Table[params[n,10], {n,100,5000,100}];

(* minmeans *)

minmeans[m_] := Table[{n,Transpose[params[n,m]][[1,1]]}, 
 {n,100,5000,100}];

maxmeans[m_] := Table[{n,Transpose[params[n,m]][[1,2]]}, 
 {n,100,5000,100}];

sds[m_] := Table[{n,Transpose[params[n,m]][[2,1]]},
 {n,100,5000,100}];


fminmeans[m_] := Interpolation[minmeans[m]];

aminmeans[m_] := aminmeans[m] = Function[x, Fit[minmeans[m], 1/y, y] /. y -> x]

Plot[{fminmeans[2][x], aminmeans[2]}, {x, 100, 5000}]

Table[Transpose[params[n,2]][[2,1]]/Sqrt[n], {n,100,5000,100}]

Table[Transpose[params[n,2]][[3,1]]/n, {n,100,5000,100}]

(*

Some results:

minmeans[10] fairly close to Sqrt[n]/2 as is maxmeans[10]
and sds[10] close to 0.15403 Sqrt[x]

minmeans[5] is sort of kind of close to Sqrt[n]/2 too

0.225271 Sqrt[x] for that one

n/m - Sqrt[n]/2

(* tests *)

k^-n*(Sum[t^j/j!])^k



tab2225 = Table[{m,Mean[mins[25000,m]]},{m,5,20}]
tab2226 = Table[{m,25000/m-Mean[mins[25000,m]]},{m,5,20}]
Fit[tab2225,{1,1/x},x]



(* reducing this to a single case, since that seems to work anyway *)

supertab[m_] := Table[params2[n*1000, m], {n,25,25}];

bestguess[m_] := {Min[Transpose[supertab[m]][[1]]],
 Mean[Transpose[supertab[m]][[2]]], Min[Transpose[supertab[m]][[3]]]};

plotme = Table[{i,bestguess[i]}, {i,2,20}];


plotmeans = Table[{i[[1]], i[[2,1]]}, {i,plotme}]

plotsds = Table[{i[[1]], i[[2,2]]}, {i,plotme}]

plotmeans2 = Table[{i[[1]], Sqrt[i[[2,1]]]}, {i,plotme}]
plotmeans3 = Table[{i[[1]], i[[2,1]]-1/200/Pi}, {i,plotme}]

ListLogPlot[plotmeans3, PlotRange -> All]


temp2057 = Table[params2[n*1000,2],{n,1,10}]

ListPlot[Transpose[temp2057][[3]]]
showit


DownValues[monte][[2,1]]

In[107]:= bestguess[200]                                                        

Out[107]= {0.00126584, 0.0292901, 0.00123968}

Table[i[[1]], {i,DownValues[monte]}]
Table[i[[1]], {i,DownValues[monte]}][[1,1,2]]

vals = Drop[Table[i[[1,1,2]], {i,DownValues[monte]}],-1];

tab = Table[{i, bestguess[i][[1]]}, {i,vals}]

0.00035646415004234885 + 0.005425781000943534/x^2 - 0.01879105398650147/x + 
 0.014505133926303258/x^0.5

is a good approx

0.0005409926118595783 - 0.013490021261969458/x + 0.012322628254679823/x^0.5

is also a good approx

ListPlot[Table[{i, bestguess[i][[1]]}, {i, vals}], PlotRange -> All,
PlotJoined -> True]
ListPlot[Table[{i, 1/bestguess[i][[1]]}, {i, vals}], PlotRange -> All,
PlotJoined -> True]
showit














(*
http://stats.stackexchange.com/questions/210005/how-many-replications-to-eliminate-noise
*)

(*

ANSWER STARTS HERE:

Although I upvoted @EngrStudent's comment, it turns out this is not a
simple problem, and I couldn't find an exact answer. The closest I came was:

https://www.jstor.org/stable/2347220

"Algorithm AS 145: Exact Distribution of the Largest Multinomial
Frequency", which provides an algorithm to compute the formula given
in the book "Combinatorial Chance":
https://en.wikipedia.org/wiki/Special:BookSources/9780852640579

For an approximation and some discussion of this distribution:

  - http://mathoverflow.net/questions/104948

  - http://mathoverflow.net/questions/146418

Of course, this just gives you the maximum frequency. To answer your
question, you also need the minimum frequency, and compute which one
is further from the mean.

What you have here is a multinomial distribution. As @EngrStudent
notes, adding the marbles 11-100 has no effect on the problem, so
let's consider selecting $n$ marbles (with replacement) from a bag
with $10 m$ marbles, with $m$ marbles labeled 1, $m$ marbles labeled
2, etc. This is also equivalent to rolling a fair 10-sided die $n$
times.

As $n$ grows large, we would expect $\frac{n}{10}$ marbles with each
number. However, some marbles will be chosen less frequently and some
marbles will be chosen more frequently.

One sample version of the question: for a given $k$, how large must
$n$ be to guarantee there's a 90% chance that each marble occurs
$\frac{n}{10}\pm k$ times.

Of course, we can replace 90% with a different probability, and talk
about $k$ as a percentage instead of an absolute number.

In general, we're asking: how far away from $\frac{n}{10}$ is the
frequency of the most or least frequently appearing marble (whichever
is further from $\frac{n}{10}$).

I ran a Monte Carlo simulation for 1000 draws (10,000 times),
and found the following:

  - The distribution of the frequency of the least picked marble:

[[image25.gif]]

  - And the most picked marble:

[[image26.gif]]

  - The frequency furthest away from the mean minus the mean:

[[image27.gif]]

  - Since you're looking for a 90% confidence level, let's take the
  cumulative distribution function (CDF) of the above:

[[image28.gif]]

So, if you pick 1000 marbles, you can be 90% confident that the 10
resulting frequencies will be within 24 (or 24%) of the mean value of
100. Of course, this is based on a Monte Carlo simulation, and
shouldn't be regarded as absolutely precise.

For 2000 draws, jumping straight to the CDF:

[[image29.gif]]

So you can be 90% sure that all 10 marbles have a frequency 200 of \pm 34
(ie, within 17% of the mean).

Finally, for 5000 draws:

[[image30.gif]]

You can be 90% sure that every marble's frequency will be between 446
and 554, or 10.8% of the mean.

The general case here isn't easy. To a very rough approximation, the
maximum distance from the expected (mean) frequency is normally
distributed with $\mu =0.557 \sqrt{n}$ and $\sigma = 0.158
\sqrt{n}$. Again this is based on Monte Carlo simulations and should
not be considered exact.

I'm still working on the case where there are more or fewer than 10 marbles:

https://github.com/barrycarter/bcapps/blob/master/STACK/bc-multinomial.m

(*

Results:

params[n_,m_] := N[Table[{
 Mean[maxvar[n,m]], Sqrt[Variance[maxvar[n,m]]], Median[maxvar[n,m]]
}]]

FullSimplify[Median[OrderDistribution[{NormalDistribution[0,Sqrt[n*p*(
1-p)]], 1/p}, 1/p] ], {p>0, p<1}]

-(Sqrt[2]*Sqrt[-(n*(-1 + p)*p)]*InverseErfc[2^(1 - p)])

FullSimplify[PDF[OrderDistribution[{NormalDistribution[0,Sqrt[n*p*(
1-p)]], 1/p}, 1/p] ], {p>0, p<1}][x]

(2^(1/2 - p^(-1))*Erfc[-(x/(Sqrt[2]*Sqrt[n]*Sqrt[(1 - p)*p]))]^(-1 + p^(-1)))/
 (E^(x^2/(2*n*(1 - p)*p))*Sqrt[n]*p*Sqrt[(1 - p)*p]*Sqrt[Pi])




OrderDistribution[{NormalDistribution[0,Sqrt[n*p*(1-p)]], 1/p}, 1/p]

OrderDistribution[{NormalDistribution[n/10,Sqrt[n/10*9/10]], 10}, 10]

PDF[OrderDistribution[{NormalDistribution[n/10,Sqrt[n/10*9/10]], 10}, 10]][x]

PDF[OrderDistribution[{NormalDistribution[0,Sqrt[n/10*9/10]], 10}, 10]][x]

{Mean[i], Sqrt[Variance[i]], Median[i]},
 {i, maxvar[n,m]}]]


for n=1: {0.9, 0., 0.9}
n=5: {1.2863, 0.60784, 1.5}
for n=10: {1.7598, 0.727981, 2.}
n=50: {3.9292, 1.18268, 4.}
for n=100: {5.5836, 1.6295, 5.}
n=500: {12.4655, 3.55391, 12.}
for n=1000: {17.6229, 4.98933, 17.}
n=5000: {39.466, 11.0872, 38.}
for n=10000: {55.8958, 15.7537, 55.}
n=50000: {125.296, 34.9461, 122.}
for n=100000: {175.799, 49.2998, 172.}
n=500000: {393.962, 111.698, 383.}

Table[maxvar[n,10],{n,100,1000,100}];

TODO: note this file and note could maybe get true PDF

p = Table[1/10,{i,1,10}]

monte[n_] := monte[n] = Table[minmax[n],{i,1,1000}];

maxs[n_] := maxs[n] = Transpose[monte[n]][[2]];

Histogram[maxs[25000], Automatic, "CDF"];

in my example for hoeffding

n=25000, k=10, d=50

http://www.jstor.org/stable/2236496?seq=2#page_scan_tab_contents



m3[n_]:=m3[n]= Table[Max[{Abs[i[[1]]-n/10], Abs[i[[2]]-n/10]}], {i,monte[n]}];

Transpose[m3][[1]]

means = Table[{n,Mean[m3[n]]},{n,1000,25000,1000}];
medians = Table[{n,Median[m3[n]]},{n,1000,25000,1000}];
sds = Table[{n,Sqrt[Variance[m3[n]]]},{n,1000,25000,1000}];

means2 = Table[{n, Mean[m3[n]]^2/n}, {n,1000,25000,1000}]; 

Fit[means, Sqrt[x], x]

PDF[NormalDistribution[mu,sd]][x] == k*E[-2*d^2/n]

tab2 = Table[{n, m3[n]}, {n,1000,25000,1000}];


N[{Mean[m3], Variance[m3], Median[m3]}]

(*

results for various n:

50: {3.9157, 1.43194}
100: {5.5928, 2.65685}
500: {12.4577, 12.2306}
1000: {17.6901, 25.0188} or {17.6667, 24.5651, 17.}
2000: {24.9331, 48.9469} or {24.8929, 47.5808, 24.}
5000: {39.259, 120.912} or {39.3733, 122.205, 38.}
10000: {55.7423, 247.769} or {55.817, 245.989, 54.}
25000: {88.0303, 608.016} or {88.4296, 605.507, 87.}

overall: Sqrt[n]*0.556753 roughly, and 0.0243206*n
or SD of 0.155951*Sqrt[n]

ran it again for 25000 and got: {88.4296, 605.507} making those numbers 0.559278 and 0.155629



mu[x_] = 0.55*Sqrt[x]
sd[x_] = 0.155951*Sqrt[x]


m4 = Tally[m3]

ListPlot[Sort[m4], PlotJoined->True]
showit

m5[x_] = Interpolation[m4][x]

Plot[{m5[x]/10000., PDF[NormalDistribution[mu[n],sd[n]]][x]},
{x, mu[n] - 3*sd[n], mu[n] + 3*sd[n]}]
showit



m5 = Table[{i[[1]], Log[i[[2]]]}, {i,m4}]

m6 = Table[{i[[1]], Log[Log[i[[2]]]]}, {i,m4}]

Fit[m5, {1,x,x^2}, x]

Accumulate[Transpose[Sort[m4]][[2]]]


Fit[m4, {1,x,x^2,x^3,x^4}, x]


g = Histogram[m3, Automatic, "CDF"]

ytics = Table[N[i/10],{i,0,10}];
xtics = Table[i*5,{i,0,20}];
g = Histogram[m3, Automatic, "CDF", Ticks -> {xtics, ytics}]
showit

minmax2 := Module[{d},
 d = RandomVariate[MultinomialDistribution[10000,p]];
 Return[{Min[d],Max[d]}]];

monte = Table[minmax,{i,1,10000}];

monte2 = Table[minmax2,{i,1,10000}];

m2 = Transpose[monte];

m3 = Table[Max[{Abs[i[[1]]-1000], Abs[i[[2]]-1000]}], {i,monte2}];

g = Histogram[m3]

g = Histogram[maxvar[2000,10], 51, "CDF"]

g = Histogram[maxvar[5000,10], 87, "CDF"]

g2 = Graphics[{
 Dashed, RGBColor[1,0,0], 
 Line[{{3,.9}, {24, .9}}]
}];

g3 = Graphics[{
 Dashed, RGBColor[1,0,0], 
 Line[{{5,.9}, {34, .9}}]
}];

g4 = Graphics[{
 Dashed, RGBColor[1,0,0], 
 Line[{{8,.9}, {54, .9}}]
}];

Show[{g,g4}]
showit


Histogram[m2[[1]]]
Histogram[m2[[2]]]




RandomVariate[MultinomialDistribution[3,{1/3,1/3,1/3}]]
RandomVariate[MultinomialDistribution[100,{1/3,1/3,1/3}]]



As https://en.wikipedia.org/wiki/Multinomial_distribution notes, the
distribution for a given marble has a mean of $\frac{n}{10}$ (in our
case) and a standard deviation of $\sqrt{n \frac{1}{10}
\frac{9}{10}}$.

If this distribution were independent, we could approximate this by
simply calculating the maximum value of 10 normally distributed values
to get the


TODO: mathoverflow

*)

PDF[MultinomialDistribution[3,{1/3,1/3,1/3}],{x,y,z}]

Skewness[MultinomialDistribution[3,{1/3,1/3,1/3}]]

Integrate[PDF[MultinomialDistribution[300,{1/3,1/3,1/3}],{x,y,z}],
 {x,99,101}]

PDF[MultinomialDistribution[300,{1/3,1/3,1/3}],{100,100,100}]

PDF[MultinomialDistribution[n,{1/3,1/3,1/3}],{100,100,100}]

Variance[MultinomialDistribution[n,{1/3,1/3,1/3}]]

var = Variance[MultinomialDistribution[n,{1/3,1/3,1/3}]]

covar = Covariance[MultinomialDistribution[300,{1/3,1/3,1/3}]]
means = Mean[MultinomialDistribution[300,{1/3,1/3,1/3}]]

CDF[MultinomialDistribution[300,{1/3,1/3,1/3}]][{105,105,105}]

MultinormalDistribution[means,covar]


http://math.stackexchange.com/questions/605183/the-minimum-value-of-a-uniform-multinomial-distribution

(* multinormal approx, using 300 rolls, expec value of each is 100 *)

means = Table[100,{i,1,3}]

cov[i_,j_] = If[i==j, 300*1/3*2/3, -300*1/3*1/3]
cov[i_,j_] = If[i==j, 0, -300*1/3*1/3]

mat = Table[cov[i,j], {i,1,3}, {j,1,3}]

MultinormalDistribution[means, mat]
