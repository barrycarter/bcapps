(* General case for m-sided dice rolled n times *)

p[m_] := p[m] = Table[1/m,{i,1,m}];

minmax[n_,m_] := Module[{d},
 d = RandomVariate[MultinomialDistribution[n,p[m]]];
 Return[{Min[d],Max[d]}]];

monte[n_,m_] := monte[n,m] = Table[minmax[n,m],{i,1,1000}];

maxvar[n_,m_] := Table[Max[{Abs[i[[1]] - m/n], Abs[i[[2]] - m/n]}], 
 {i, monte[n,m]}];

params[n_,m_] := N[{Mean[maxvar[n,m]], Sqrt[Variance[maxvar[n,m]]],
Median[maxvar[n,m]]}]

params2[n_,m_] := {params[n,m][[1]]/n-1/m,
 params[n,m][[2]]/Sqrt[n],
 params[n,m][[3]]/n-1/m
};

mins[n_,m_] := Transpose[monte[n,m]][[1]]
maxs[n_,m_] := Transpose[monte[n,m]][[2]]

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

I ran a Monte Carlo simulation on picking 1000 marbles (10,000 times),
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
resulting frequencies will be within 24 (or 2.4%) of the mean value of
100. Of course, this is based on a Monte Carlo simulation, and
shouldn't be regarded as absolutely precise.

For 2000 marbles, jumping straight to the CDF:



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

g2 = Graphics[{
 Dashed, RGBColor[1,0,0], 
 Line[{{3,.9}, {24, .9}}]
}];

Show[{g,g2}]
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


