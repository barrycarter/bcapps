(* formulas start here *)

vol2sd[v_,t_] = Sqrt[t]*Log[1+v];

(* this is only accurate for x>0 *)

cdf[v_,t_,x_] = Simplify[CDF[HalfNormalDistribution[1/vol2sd[v,t]]][x],x>0]

sol[v_,t_,p_,s_] = s/Exp[x /. Solve[cdf[v,t,x]==1-p,x][[1]]]

(* formulas end here *)

(*

http://quant.stackexchange.com/questions/24970/estimate-probability-of-limit-order-execution-over-a-large-time-frame

<h1>My Answer</h1>

You should set your limit order to: $s (v+1)^{-0.0314192 \sqrt{t}}$
where $s$ is the current price, $t$ is the time in years you're
willing to wait, and $v$ is the annual volatility as a percentage.

If you want to be $p$ percent sure (instead of 0.98), set your limit
order to:

$s (v+1)^{-\sqrt{\pi } \sqrt{t} \text{erf}^{-1}(1-p)}$

Of course, this is based on many assumptions and disclaimers later in
this message.

TODO: examples?

<h1>Other Answers</h1>

It turns out this question has been studied extensively, and there are
some papers on it:

http://fiquant.mas.ecp.fr/wp-content/uploads/2015/10/Limit-Order-Book-modelling.pdf

http://arxiv.org/pdf/1311.5661

I'll use a much simpler model (see disclaimers at end of message).

<h1>Example</h1>

If a stock has a volatility of 15%, that means there's a 68% chance
it's price after 1 year will be between 87% and 115% of its current
price. Note that the lower limit is 87% (= 1/1.15), not 85%.

Overall, the price probability for a stock with volatility 15% forms
this bell curve:

[[image11.gif]]

Note that:

  - Because volatility is inherently based on logrithms, the tick
  marks aren't evenly spaced, and aren't symmetric. The numbers +65%
  and -39% are symmetric because it takes a 39% loss to offset a 65%
  gain and vice versa. In other words: `(1+ (-39/100))*(1+ (65/100))`
  is approximately one.

  - The labels on the y axis are relative to each other and don't
  refer to percentages.

Of course, this isn't the probability curve you're looking for: I drew
it just for reference.

Instead, let's look at the probability distribution of the *minimum*
value over the next year for our 15% volatility stock.

[[image12.gif]]

The same caveats apply to this graph as the previous one.

Suppose you set your limit order at 5% below the current price (ie,
95% of its current price). There is a ~77% chance your order will be
filled:

[[image13.gif]]

You can also see this using the cumulative distribution function (CDF):

[[image14.gif]]

In this case, the y values do represent percentages, namely the
cumulative percentage change that the stock's lowest value will the
percentage value on the x axis.

For this volatility, if you want be 98% sure you order is filled, you
could only set your limit order to 0.44% below the current price.

<h1>General Case</h1>

Of course, that was for a specific volatility over a specific period
of time.

In general, a volatility of v% means the stock is ~68% (1 standard
deviation) likely to remain within v% of its current price in the next
year. More conveniently, it means the logarithm of the price is 68%
likely to remain within (plus/minus) $\log (v+1)$ of its current value
(within the next year). For example, a volatility of 15% means the log
of the stock price is 68% likely to remain within .1398 of its current
value, since $e^{0.1398}$ is approximately $1.15$

More generally, the $\log (\text{price})$ one year from now has a
normal distribution with mean $\log (\text{price})$ and standard
deviation $\log (v+1)$.

Thus, the *change* in the $\log (\text{price})$ for one year is
normally distributed with a mean of 0 and a standard deviation of
$\log (v+1)$.

A standard deviation of $\log (v+1)$ translates to a variance of $\log
^2(v+1)$. Since the variance of a process like this scales linearlly,
the variance for $t$ years is given by $t \log ^2(v+1)$ and the
standard deviation for $t$ years is given by $\sqrt{t} \log (v+1)$.

Thus, the change in $\log (\text{price})$ for time $t$ has a normal
distribution with mean 0 and standard deviation $\sqrt{t} \log (v+1)$.

As noted below in another section, this means the minimum (most
negative) value of this change has a halfnormal distribution with
parameter $\frac{1}{\sqrt{t} \log (v+1)}$

The cumulative distribution of a halfnormal distribution with
parameter $\frac{1}{\sqrt{t} \log (v+1)}$ evaluted at x>0 (the only
place the halfnormal distribution is non-zero) is:

$\text{erf}\left(\frac{x}{\sqrt{\pi } \sqrt{t} \log (v+1)}\right)$

where erf() is the standard error function.

If we draw this cumulative distribution for volatility 15% again, this
time letting the x axis be "change in $\log (\text{price})$ (instead
of the percentage change in price), the x axis looks more like we
expect:


TODO: more here?

Plot[CDF[HalfNormalDistribution[1/Log[1.15]]][x], {x,0,.5}]

If our limit order is $\lambda$% of the current price (meaning it's
$\lambda s$ where $s$ is the current price), it will only be hit if
the $\log (\text{price})$ moves more than $\left| \log (\lambda )
\right|$ (note that we need the absolute values since we're measuring
the absolute change in $\log (\text{price})$, which is always
positive). The chance of that happening is:

$
   1-\text{erf}\left(\frac{\left| \log (\lambda ) \right|}{\sqrt{\pi } \sqrt{t}
    \log (v+1)}\right)
$

Note that we need the "1-" since we're looking for the probability the
$\log (\text{price})$ moves *more* than the given amount.

Of course, in this case, we're *given* the probability and asked to
solve for the limit price. Using $p$ as the probability we find:

$\lambda \to (v+1)^{-\sqrt{\pi } \sqrt{t} \text{erf}^{-1}(1-p)}$

and the price is thus:

$s (v+1)^{-\sqrt{\pi } \sqrt{t} \text{erf}^{-1}(1-p)}$

as in the answer section. Substituting 0.98 for p, we have:

$s (v+1)^{-0.0314192 \sqrt{t}}$

as noted for this specific example.

TODO: power series approx?

Solve[1-cdf[v,t,Abs[Log[lambda]]] == p, lambda][[2,1]]                


Solve[1-cdf[v,t,Abs[Log[1-lambda]]] == p, lambda]




Solve[Abs[Log[1 - lambda]] == cdf[v,t,x]  ,x]

Abs[Log[1 - lambda]] > cdf[v,t,x]


As noted later, this means the maximum of value of $\log (\text{price})$

To generalize, the maximum change in the $\log (\text{price})$ of a
stock over one year has a halfnormal distribution with parameter 


TODO: confirm formulas above after general solution, I don't think i'm
off by an exponent



the minimum value of a stock over a year has
the probability distribution function (PDF):



$ 
   \begin{cases} 
    \frac{2 e^{-\frac{x^2}{\pi  \log ^2(v+1)}}}{\pi  \log (v+1)} & x>0 \\ 
    0 & x\leq 0
   \end{cases} 
$ 

where $v$ is the volatility as a percentage (eg, 0.15).

For a period of $t$ years, the standard deviation (which isn't quite
the same as volatility in this case) would be $\sqrt{t}$ as much, so
our PDF becomes:

$
   \begin{cases}
    \frac{2 e^{-\frac{x^2}{\pi  t \log ^2(v+1)}}}{\pi  \sqrt{t} \log (v+1)} &
      x>0 \\
    0 & x\leq 0
   \end{cases}
$

I establish the basis for this PDF later, but, knowing this, we can
solve the problem: we want to know when the cumulative distribution
function (CDF) is 0.02 (which means there's a 98% chance that order
will be filled).

The CDF for the price is:



TODO: answer at top
TODO: put this below

It turns out this is a well-known problem and has been studied extensively:

  - It's the running maximum/minimum of Brownian motion:
  https://en.wikipedia.org/wiki/Brownian_motion also known as a Wiener
  process
  (https://en.wikipedia.org/wiki/Wiener_process#Running_maximum)

  - Item 37 of http://www.math.uah.edu/stat/brown/Standard.html
  establishes this maximum is the halfnormal distribution: https://en.wikipedia.org/wiki/Half-normal_distribution

  - This stackexchange/google search shows many more results:

https://stackexchange.com/search?q=brownian+halfnormal

  - It can also be regarded as the running maximum value of a random walk:

https://stackexchange.com/search?q=brownian+halfnormal

  - Or as the fair value of a one-touch option: http://www.investopedia.com/terms/o/onetouchoption.asp:

http://quant.stackexchange.com/questions/17083

  - I myself wrote two questions to help answer this question, one
  asking about a random walk and the other about what turns out to be
  Brownian motion:

    - https://mathematica.stackexchange.com/questions/110565

    - https://mathematica.stackexchange.com/questions/110657

If you use Mathematica (or just want to read even more about this subject),
you might look at my:

  - https://github.com/barrycarter/bcapps/blob/master/STACK/bc-stock-min.m

  - https://github.com/barrycarter/bcapps/blob/master/box-option-value.m

the latter of which computes the probability that a stock price will
be between two given values at two given times (ie, the fair value of
an O&A "box option") but can be used to answer your question in the
limiting case. See also: http://money.stackexchange.com/questions/4312

TODO: mention tick bias, volatility smile, this file

TODO: TeX-ify?

TODO: note these disclaimers but put them later

Both refer to this book about hypergeometric distributions (which I'll
also mention below):

http://www.springer.com/us/book/9780387975580

I'm going to make several simplifying assumptions and treat the stock
price as a random walk:

  - I define a "click" as when the stock trades at a different price
  than previously. I originally wanted to use the word "tick", but
  that means a minimal change in price (eg, 1/8th of a dollar).

  - I'll assume the stock has an equal chance of clicking up or
  clicking down (which means I'm ignoring the risk-free interest
  rate).

  - I'm also assuming each click has a price change of 1 tick (eg,
  1/8th of a dollar)

  - Technically speaking, it's the logarithm of the stock price that
  ticks up or down with equal probability, but I'll ignore this for
  simplicity.

  - Note that I am explicitly ignoring cases where the stock trades at
  the same price as previously.

  - I am also ignoring cases where the stock "gaps" and the price
  jumps suddenly instead of by ticks.

  - Thus, number of clicks is related to volume, but not directly. For
  example, a stock may trade millions of shares in a single day, but
  if all those trades are at the same price, there are 0 "clicks" per
  my definition of tick above.

  - As noted in the works above, a stock is less likely to tick down
  after it's already ticked down once (or many times). Why? Other
  people place limit orders, and the further down the stock gets from
  its starting price, the more limit orders will be triggered.
  Generally, the *volume* of limit orders *also* increases as the
  stock price goes down. In other words, the limit orders act as a
  "buffer", slowing the rate at which a stock's price drops, meaning
  the random walk model I use below overestimates the chances of a
  large drop in price.

  - I also assume that once a stock reaches your limit price, your
  order will be triggered. However, if there are several orders at
  that price, the larger orders will trigger first, and the stock
  price may rise again before your limit order is triggered at all.

Having said all that, you're effectively asking: if I believe the
stock will click a total of $n$ times in a certain amount of time,
what is the chance it will click down $k$ at least once, and thus
trigger my limit order?

In random walk terms: if I take a standard random walk (start at
origin, 50-50 chance of going left/right) of $n$ steps, what is the
chance I'll hit step $k$ at least once?

It turns out this isn't an easy question to answer. I couldn't answer
it myself, but the geniuses at mathematica.stackexchange.com did
answer it for me:

https://mathematica.stackexchange.com/questions/110565

$
   2 \binom{n+1}{\left\lfloor \frac{1}{2} (k+n+1)\right\rfloor +1} \,
   _2F_1\left(n+2,\left\lfloor \frac{1}{2} (k+n+1)\right\rfloor +1;\left\lfloor
    \frac{1}{2} (k+n+1)\right\rfloor +2;-1\right)
$

is the hideously ugly answer, which I'm sure isn't much use to you.

Instead, I'll use this formula to make some computations.

As it turns out 98% is a fairly high confidence level to require. If
you set your limit order just 1 tick (eg, 1/8th of a dollar) below the
current price, you will need 1591 clicks to be 98% sure that order
will be filled.

There's a 50% chance your order will be filled on the very next click,
(if that click happens to be a tick down), so the number increases
fairly rapidly with the level of certainty...


TODO: mention this file

chance of sum of normal hitting in two shots, let 'a' be the value to hit

1-CDF[NormalDistribution[0,1]][a] of hitting first time

Integrate[PDF[NormalDistribution[0,1]][x]*PDF[NormalDistribution[0,1]][a-x],
 {x,-Infinity,a}]

(4 + (1 + Erf[a/2])/(E^(a^2/4)*Sqrt[Pi]) - 2*(1 + Erf[a/Sqrt[2]]))/4

when adding those two

http://math.stackexchange.com/questions/68553/distribution-of-maximum-of-partial-sums-of-independent-random-variables

CDF[NormalDistribution[0,1]][a]*
 Integrate[PDF[NormalDistribution[0,1]][a-x], {x,a,Infinity}]

monte carlo jff

t = Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,2}]]],
 {j,1,10000}];

BinCounts[t,0.1]

histogram functions useful

t = Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,10}]]],
 {j,1,10000}];

t = Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,100}]]],
 {j,1,10000}];

t = Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,1000}]]],
 {j,1,10000}];

t = Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,1000}]]],
 {j,1,100000}];

t = Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,2}]]],
 {j,1,100000}];


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

==== CUT HERE ====

Subject: Distribution of max of partial sums of normal distributions

I was surprised not to find this question already answered: if I take
the maximum of the partial sums of `n` normal distributions, what is
the resulting distribution?

I know that http://math.stackexchange.com/questions/68553 "solves"
this in general, but I'm hoping for a simpler form for the normal
distribution.

<pre><code>
t[n_] := t[n] = Histogram[
 Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[]],{i,n}]]],
 {j,1,100000}]];
</code></pre>

The code above convinces me the resulting distribution isn't normal
(except for n=1 of course), although it looks somewhat normal for low
values of `n`.

*)

(* TODO: http://quant.stackexchange.com/questions/235 *)

f[t_] = 1- (
 (CDF[NormalDistribution[0,1]][t])*
 (CDF[NormalDistribution[0,Sqrt[2]]][t])
);

Plot[f'[t], {t,-3,3}]

f[t_] = 
 (CDF[NormalDistribution[0,1]][t])*
 (CDF[NormalDistribution[0,Sqrt[2]]][t])
;

g[t_] = 
 (CDF[NormalDistribution[0,1]][t])*
 (CDF[NormalDistribution[0,Sqrt[2]]][t])*
 (CDF[NormalDistribution[0,Sqrt[3]]][t])*
 (CDF[NormalDistribution[0,Sqrt[4]]][t])*
 (CDF[NormalDistribution[0,Sqrt[5]]][t])
;

g[t_] = Product[CDF[NormalDistribution[0,Sqrt[n]]][t], {n,1,50}];

h[n_,t_] = E^(-(t^2/(2*n)))*Sqrt[2/(n*Pi)]

h[n,t/n]

Integrate[h[n,u/n], {u,0,Sqrt[n]}]

Integrate[h[n,u/n], {u,0,t}]

Integrate[t*h[n,t],{t,0,Infinity}]

Integrate[t*h[n,t],{t,0,n}]

Sqrt[2*Pi*n] is the mean
-3 + 2*Pi is the variance, about 1.81196

(* g[n_,t_] = h[n,t]/Integrate[h[n,t],{t,0,n}] *)

g[n_,t_] = Sqrt[2/Pi]/(E^(t^2/(2*n))*Sqrt[n]*Erf[Sqrt[n]/Sqrt[2]])

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



1591 for 1 to 98%

u[n_] := u[n] = 
 Table[Max[Accumulate[Table[RandomVariate[NormalDistribution[0,1./Sqrt[n]]],
 {i,n}]]], {j,1,100000}];


t[n_] := t[n] = Histogram[u[n]];

test1132 = Table[Mean[u[n]],{n,1,100}];
test1135 = Table[Sqrt[Variance[u[n]]],{n,1,100}];

halfnormal of 1.25 might be the magic number

for t[10000] ... 0.789786 is mean, 0.362133 is variance, 0.601775 is SD

right around 1.26 param

hist1 = Histogram[u[10000], "Scott", "PDF"]

plot1 = Plot[PDF[HalfNormalDistribution[1.25]][x],{x,0,4}]
plot2 = Plot[PDF[HalfNormalDistribution[1.24]][x],{x,0,4}]
plot3 = Plot[PDF[HalfNormalDistribution[1.26]][x],{x,0,4}]

Show[{hist1,plot1,plot2,plot3}]
showit

ListPlot[test1132]

(* and is halfnormal? *)

test0510 = Table[{k/Sqrt[500],d[500,k]},{k,0,500}];
test0518 = Table[{k/Sqrt[500],d[500,k]-d[500,k-1]},{k,1,500}];

(* below is chance of hitting +k but not +k+1 or more *)

pdf[n_,k_] = FullSimplify[d[n,k]-d[n,k+1], {n>k,k>0,Element[{n,k},Integers]}];

test0524= Table[N[pdf[500,k]], {k,0,499}]


Sum[k*pdf[n,k],{k,0,n}]/Sqrt[n]

Limit[Sum[k*pdf[n,k],{k,0,n}]/Sqrt[n], n -> Infinity]

ToExpression["(4\pi \frac{\sigma^2}{2} t)^{-\frac{1}{2}} \text{e}^{(-x^2/(4 \frac{\sigma^2}{2} t) )}", TeXForm]

p[x_,t_,sigma_] = (4*Pi*sigma^2/2*t)^(-1/2)*Exp[(-x^2/(4*sigma^2/2*t))]

(* box-option-value.m *)

boxvalue[p0_, v_, p1_, p2_, t1_, t2_] :=
 Module[{},

  (* the pdf of Log[price] at t1; chance that Log[price]=x *)
  pdflp[x_] =
   PDF[NormalDistribution[Log[p0], Sqrt[t1]*v/Sqrt[365.2425*24]]][x];

  (* the anti-cdf of the max of Log[price]-Log[price[t1]] between t1 and t2;
     chance this value is more than x, for x > 0 *)
   cdfmaxlp[x_] = 1-Erf[x/(v*Sqrt[t2-t1]/Sqrt[24*365.2425/Sqrt[2]])];

  (* 3 cases: price[t1] < p1, between p1 and p2, or price[t1] > p2 *)
  (* these are silly global variables I added at the last second + I know
     this is bad programming practise *)
  upandin = NIntegrate[pdflp[x]*cdfmaxlp[Log[p1]-x],{x,-Infinity,Log[p1]}];
  hitleftedge = NIntegrate[pdflp[x]*1,{x,Log[p1],Log[p2]}];
  downandin = NIntegrate[pdflp[x]*cdfmaxlp[x-Log[p2]],{x,Log[p2],Infinity}];

  upandin+hitleftedge+downandin
]

boxvalue[p0, v, p1, p2, t1, t2]



cum[x_,t_] = FullSimplify[Sqrt[2/Pi/t]*Integrate[Exp[-u^2/2/t], {u,0,x}],
 {x>0, t>0}]

pdf[x_,t_] = FullSimplify[D[cum[x,t],x]]

Plot[pdf[x,5],{x,0,3}]

HalfNormal[2/Pi]

Mean[HalfNormalDistribution[Sqrt[Pi/2]]]

var is (Pi-2)/Pi = 0.36338

sd is Sqrt[(-2 + Pi)/Pi] or 0.60281

image11.gif:

xtics = Table[{i, 
 If[i>0,"+",""]<>ToString[Round[100*(Exp[i]-1),1]]<>"% "},
 {i,-.5,.5,.05}]

Plot[
 PDF[NormalDistribution[0,Log[1.15]]][x]/
 PDF[NormalDistribution[0,Log[1.15]]][0], 
 {x,-0.5,+0.5}, PlotRange->All,
 TicksStyle -> Directive[Black,12],
 Ticks -> {xtics, Automatic}
]
showit

image12.gif:

xtics2 = Table[{i, 
 ToString[Round[100*(Exp[-i]-1),1]]<>"% "},
 {i,0,.5,.025}]

Plot[PDF[HalfNormalDistribution[1/Log[1.15]]][x]/(2/Pi/Log[1.15]),
 {x,0,0.5},
 TicksStyle -> Directive[Black,12],
 Ticks -> {xtics2, Automatic}
]
showit

image13.gif:

graph[x_] = PDF[HalfNormalDistribution[1/Log[1.15]]][x]/(2/Pi/Log[1.15])

xtics2 = Table[{i, 
 ToString[Round[100*(Exp[-i]-1),1]]<>"% "},
 {i,0,.5,.025}]

plot1 = Plot[graph[x], {x,0,0.05}, TicksStyle -> Directive[Black,12],
 Ticks -> {xtics2, Automatic}, AxesOrigin -> {0,0}
]

plot2 = Plot[graph[x], {x,0.05,0.5}, TicksStyle -> Directive[Black,12],
 Ticks -> {xtics2, Automatic}, AxesOrigin -> {0,0}, Filling -> Axis
]

line = Graphics[{
 Line[{{0.05,0},{0.05, graph[0.05]}}],
 Text[Style["77%", FontSize->100], {0.16,.25}],
 Rotate[Text[Style["23%", FontSize->100], {0.025, .5}],Pi/2]
}
];

Show[{plot2,plot1,line}, PlotRange -> All]
showit

image14.gif:

graph[x_] = CDF[HalfNormalDistribution[1/Log[1.15]]][x]

xtics2 = Table[{i, 
 ToString[Round[100*(Exp[-i]-1),1]]<>"% "},
 {i,0,.5,.025}]

ytics2 = Table[{i, 
 ToString[ToString[Round[i*100]]<>"% "]}, {i,0,1,.1}]

plot2 = Plot[graph[x], {x,0,0.5}, TicksStyle -> Directive[Black,12],
 Ticks -> {xtics2, ytics2}, AxesOrigin -> {0,0}]

line = Graphics[{
 RGBColor[1,0,0], Dashed,
 Line[{{0.05,0},{0.05, graph[0.05]}}],
 Line[{{0,graph[0.05]},{0.05, graph[0.05]}}],
 Text[Style["23%", FontSize-> 30], {0.025,.26}],
 Text[Style["-5%", FontSize-> 30], {0.073,.1}]
}
];

Show[{plot2,line}, PlotRange -> All]
showit

TODO: note these actually ARE percentages

showit

plot1 = Plot[graph[x], {x,0,0.05}, TicksStyle -> Directive[Black,12],
 Ticks -> {xtics2, Automatic}, AxesOrigin -> {0,0}
]


TODO: note that with 0.44% risk free interest may be an issue (of
course, if you put that money into risk-free interest)
