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
  cumulative distribution function of the above:

[[image28.gif]]

So, if you pick 1000 marbles, you can be 90% confident that the 10
resulting frequencies will be within 24 (or 2.4%) of the mean value of 100.




p = Table[1/10,{i,1,10}]

minmax := Module[{d},
 d = RandomVariate[MultinomialDistribution[1000,p]];
 Return[{Min[d],Max[d]}]];

minmax2 := Module[{d},
 d = RandomVariate[MultinomialDistribution[10000,p]];
 Return[{Min[d],Max[d]}]];

monte = Table[minmax,{i,1,10000}];

monte2 = Table[minmax2,{i,1,10000}];



m2 = Transpose[monte];

m3 = Table[Max[{Abs[i[[1]]-100], Abs[i[[2]]-100]}], {i,monte}];

g = Histogram[m3]

g = Histogram[m3, Automatic, "CDF"]

ytics = Table[N[i/10],{i,0,10}];
xtics = Table[i*5,{i,0,20}];
g = Histogram[m3, Automatic, "CDF", Ticks -> {xtics, ytics}]
showit


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


