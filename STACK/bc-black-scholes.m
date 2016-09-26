(* See also http://quant.stackexchange.com/questions/24970/estimate-probability-of-limit-order-execution-over-a-large-time-frame *)

TODO: legacy note this file

(* deriving Black-Scholes, other ways to do it *)

(* following https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black.E2.80.93Scholes_formula *)

TODO: put summary here

<b>Note: Because we will be using interest rates as percentages, I am
using the percentage definition of volatility here, which is different
from the "standard deviation of the log price" version used in
https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black.E2.80.93Scholes_formula
and other formulas. See my http://quant.stackexchange.com/a/25074/59
for the difference between the two definitions of volatility</b>

In this answer:

  - $p$ is the price of the underlying security
  - $k$ is the strike price of the call
  - $t$ is the time until expiration
  - $v$ is the volatility as a percentage (eg, .14 = 14%)
  - $r$ is the risk-free interest rate as a percentage

If the risk-free interest rate is $r$, we expect a security's price to
increase, on average, by a factor of $(1+r)^t$, which means the
security's $\log (\text{price})$ will change by an average of $t \log
(r+1)$.

If a security's volatility is $v$ percentage, we expect that, with a
probability of about 68% (1 standard deviation), the security will
remain between $1+v$ and $\frac{1}{1+v}$ of its current price within 1
unit of time. Note that the opposite of $1+v$ it's current value is
$\frac{1}{1+v}$ of its current value, NOT $1-v$ of its current value
(see linked URL in Note above for more details).

In other words, $\log (p)$ will change less than $\log (v+1)$ in 1
time unit approximately 68% of the time.

In time $t$, $\log (p)$ will change less than $\sqrt{t} \log (v+1)$
about 68% of the time.

More formally, the change in $\log (p)$ of the stock at expiration is
normally distributed with mean $t \log(r+1)$ and standard deviation
$\sqrt{t} \log (v+1)$

Over time $t$, the total volatility will be $v \sqrt{t}$, so there's a
~68% chance the stock will remain between $v \sqrt{t} +1$ and
$\frac{1}{\sqrt{t} v+1}$ of its current value after time $t$.

This means that $\log (p)$ will change by less than 

TODO: make sure I use underlying security consistently, not "stock" or just "underlying"


bscall[p_,e_,t_,v_,r_] := Module [ {standardnormal,d1,d2,value},
 standardnormal=NormalDistribution[0,1];
 d1=(Log[p/e]+t*(r+v*v/2))/v/Sqrt[t];
 d2=d1-v*Sqrt[t];
 value=p*CDF[standardnormal,d1]-e*Exp[-r*t]*CDF[standardnormal,d2]
]

bs2[p_,k_,t_,v_,r_] = FullSimplify[bscall[p,k,t,v,r], {p>0, k>0, t>0, v>0}]

bs2[p,k,t,sigma,r]

== CUT HERE ALPHA ==

<b>Note: Because we will be using interest rates as percentages, I am
using the percentage definition of volatility here, which is different
from the "standard deviation of the log price" version used in
https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black.E2.80.93Scholes_formula
and other formulas. See my http://quant.stackexchange.com/a/25074/59
for the difference between the two definitions of volatility</b>

Following
https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black.E2.80.93Scholes_formula, and combining, the Black-Scholes formula for a call's value (per Mathematica) is:

TODO: add "c =" below, since I'll use it later

$
c =  
\frac{1}{2} \left(p \text{erf}\left(\frac{-\log (k)+\log (p)+r t+\frac{\sigma
    ^2 t}{2}}{\sqrt{2} \sigma  \sqrt{t}}\right)-k e^{-r t}
    \text{erfc}\left(\frac{2 \log (k)-2 \log (p)-2 r t+\sigma ^2 t}{2 \sqrt{2}
    \sigma  \sqrt{t}}\right)+p\right)
$

where:

  - $c$ is the price of the call
  - $p$ is the price of the underlying security
  - $k$ is the strike price of the call
  - $t$ is the time until expiration
  - $\sigma$ is the volatility as the standard deviation of the log price
  - $r$ is the risk-free continuous interest rate as a percentage

Because we want to measure volatility $v$ as a percentage, we apply the transform $\sigma \to \log (v+1)$ to get:

$
c = 
   \frac{1}{2} \left(p \text{erf}\left(\frac{-\log (k)+\log (p)+r t+\frac{1}{2}
    t \log ^2(v+1)}{\sqrt{2} \sqrt{t} \log (v+1)}\right)-k e^{-r t}
    \text{erfc}\left(\frac{2 \log (k)-2 (\log (p)+r t)+t \log ^2(v+1)}{2
    \sqrt{2} \sqrt{t} \log (v+1)}\right)+p\right)
$

By choosing our units carefully, we can always set $p=1$ and
$t=1$. This gives us a call value of:

$
c =
   \frac{1}{2} \left(\text{erf}\left(\frac{-\log (k)+r+\frac{1}{2} \log
    ^2(v+1)}{\sqrt{2} \log (v+1)}\right)-k e^{-r} \text{erfc}\left(\frac{2 \log
    (k)-2 r+\log ^2(v+1)}{2 \sqrt{2} \log (v+1)}\right)+1\right)
$

where $k$ is expressed as a ratio to the underlying price.

Since the problem states the options we're comparing "same expiration
date" and the options are valued at the same underlying price, the
only difference between the two options is the strike price, $k$.

**Specific Example**

Let's first consider what interest rates and volatilities are
consistent with an at the money option. For this, we set $k=1$ to get
a call value of:

$
c =
  \frac{1}{2} \left(\text{erf}\left(\frac{r+\frac{1}{2} \log ^2(v+1)}{\sqrt{2}
    \log (v+1)}\right)-e^{-r} \text{erfc}\left(\frac{\log ^2(v+1)-2 r}{2
    \sqrt{2} \log (v+1)}\right)+1\right)
$

It turns out this equation isn't easy to solve for an arbitrary call
value (no closed-form solution), so let's choose a specific call value
of 0.05 as an example and solve numerically. Again, this means the
call price is 5% of the stock price, since we've normalized the
stock price to 1.

[[image34.gif]]

If it seems confusing that $r$ approaches $-\log (0.95)$
(approximately 5.129%) and not 5% as the $v$ approaches zero,
see footnote 1.

Note that, even though I've show the volatility on the x axis and the
interest rate on the y axis, neither variable is independent. The
curve simply shows which pairs of interest rates and volatilities are
consistent with Black-Scholes for this specific case.

Now, let's consider an in-the-money call by setting the strike price
to 0.99. If we assume a delta of 0.5, the value of this call would be
0.055. What interest rates/volatility curve is consistent with this
call?

[[image35.gif]]

For why $r$ approaches TODO as $v$ approaches zero, see footnote 2.

approxv[r_] = Normal[FullSimplify[Series[FullSimplify[bscallperc[1,1,1,v,r], 
 {r>0,v>0}], {r,0,1}]]]

Solve[approxv[r] == x, v]



TODO: let people skip

What happens to $c$ if we increase $k$ by an infinitesimal amount
$dk$? There's no Greek for this (since strike prices are usually
constant), but, under Black-Scholes assumptions, the effect should be
the same as if we decreased the underlying price by $dk$, and the
Greek for that would be $-\delta$ (negative, since increasing the
strike price makes it less valuable).

If we differentiate both sides of the equation above with respect to
$k$ while holding $v$ constant (but allowing $c$ and $r$ to vary), we
get:

$
-\delta = 
  \frac{1}{2} e^{-r} (\beta  k-1) \text{erfc}\left(\frac{2 \log (k)-2 r+\log
  ^2(v+1)}{2 \sqrt{2} \log (v+1)}\right)
$

where $\beta$ is the change in $r$ due to the change in $k$.

There's actually a mistake in the above, but let's ignore it for the moment.

Solving for $\beta$, we get:

$
\beta \to
   \frac{1-\frac{2 \delta  e^r}{\text{erfc}\left(\frac{2 \log (k)-2 r+\log
    ^2(v+1)}{2 \sqrt{2} \log (v+1)}\right)}}{k}
$

The question now: for what values of is the above 0? In other words,
if we hold $v$ constant and change $k$ (the only thing we can change),
for what values of $r$ does the above remain constant.

TODO: is this infentes approach correct? 


TODO: sophistry re sigma



temp0812[beta_] =
FullSimplify[D[bscallperc[1, k, 1, v, r], k, NonConstants -> {r}]] /.
  {D[r, k, NonConstants -> {r}] -> beta}

temp0819[beta_] = FullSimplify[Solve[temp0812[beta] == -delta, beta][[1,1,2]]]

Solve[temp0819[beta] == 0, v][[1,1,2]]











bscallperc[1, k, 1, v, r]

TODO: note erfc is 1-erf?

bscallperc[p_, k_, t_, v_, r_] =
(p + p*Erf[(r*t - Log[k] + Log[p] + (t*Log[1 + v]^2)/2)/
     (Sqrt[2]*Sqrt[t]*Log[1 + v])] - 
  (k*Erfc[(2*Log[k] - 2*(r*t + Log[p]) + t*Log[1 + v]^2)/
      (2*Sqrt[2]*Sqrt[t]*Log[1 + v])])/E^(r*t))/2

conds = {p>0, e>0, t>0, v>0, r>0};

FullSimplify[bscallperc[1, k, 1, v, r], conds]

FullSimplify[D[bscallperc[1, k, 1, v, r],k], conds]

D[bscallperc[1, k, 1, v, r], k, NonConstants -> {r}]

D[bscallperc[1, k, 1, v, r], k, NonConstants -> {r}] /.
 {D[r, k, NonConstants -> {r}] -> x}


FullSimplify[D[bscallperc[1,k,1,v,r],r]]
FullSimplify[D[bscallperc[1,k,1,v,r],k]]

above are INSANELY SIMILAR (divide to -k)

first is dc/dr, second is dc/dk

so dc/dr / (dc/dk) = dk/dr

Solve[bscallperc[1,k1,1,v,r] == bscallperc[1,k2,1,v,0]]

FullSimplify[bscallperc[1,k1,1,v,r],conds]
FullSimplify[bscallperc[1,k2,1,v,0],conds]


FullSimplify[bscallperc[1,k1*Exp[-r],1,v,0],conds]


FullSimplify[bscallperc[1,k1*Exp[-r],1,v,0],conds] -
FullSimplify[bscallperc[1,k1,1,v,r],conds]

(* above simplifies to 0, confirmed *)

bscallperc[1,k1,1,v1,r1] == c1
bscallperc[1,k2,1,v2,r2] == c2

Solve[{
 bscallperc[1,k1,1,v1,r1] == c1,
 bscallperc[1,k2,1,v2,r2] == c2
}, v, Reals]

Solve[{
 bscallperc[1,k1,1,v,0] == c1,
 bscallperc[1,k2,1,v,0] == c2
}, v, Reals]


FullSimplify[
 bscallperc[1,k1,1,v,0] /. Log[1+v] -> alpha /. Erfc[x_] -> 1-Erf[x]
]


Solve[bscallperc[1,k,1,v,0] == c1,v]

It turns out this problem is trivial once you realize that the price
of a call with strike price $k$ and risk-free interest $r$ is
identical to the price of a call with strike price $k e^{-r}$ and
risk-free interest $0$. I'll try to post an answer later.

bscallperc[1,k1,1,v,0] - bscallperc[1,k2,1,v,0]














TODO: reading specifics may help with generic

TODO: infentesimal argument inaccurate for larger moves?


<start footnote1>

At zero volatility, you may think a 5%
interest rate would be identical to purchasing a call at 5% of the
underlying value. As it turns out, this isn't the case.

At a volatility of zero, the underlying's price at expiration would be
$e^{0.05}$, so the investor could sell the call for $e^{0.05}-1$,
netting a profit of $(e^{0.05}-1)-.05$ (since he originally bought the
option at 0.05), or about $0.0012711$ (in other words, 0.12711% of the
underlying's original value).

If the investor had put the same $0.05$ into a risk-free interest
account, he would have $0.05 e^{0.05}$, for a profit of $0.05
e^{0.05}-0.05$ or about $0.00256355$ (ie, 0.256% of the underlying's
value), almost twice as much.

So, at what interest rate is a zero volatility call worth 5% of the
underlying's price? If the interest rate is $r$, the underlying's
value at expiration will be $e^r$, the investor will sell the call at
$e^r-1$ and net a profit of $(e^r-1)-.05$, since he paid 0.05 for the
option originally.

If the investor had instead put the 0.05 in a risk-free interest
account, he would have $0.05 e^r$, for a profit of $0.05 e^r - 0.05$

To find what $r$ makes these equal, we have (after simplification):

$e^r-1.05=0.05 e^r-0.05$

The solution turns out to be approximately $0.0512933$, so a
volatility of zero for an call costing 5% of the underlying
corresponds to an interest rate of 5.129%, not 5%. At 5.129%, the
investor makes the same profit with the call as he does with risk-free
interest.

In general, if a call is $s$ of the underlying, the breakeven interest
rate will be $-\log (1-s)$.

</start>

Note that, at zero volatility, the call is worth $e^r-0.99$ at
expiration, so the investor profits $(e^r-0.99)-0.055$, the value
minus the price he paid. If he had put the same money in a risk-free
interest account, he would've made $0.055 \left(e^r-1\right)$. Setting
these numbers equal, we find the breakeven interest rate at zero
volatility to be ~4.652%

Since we're interested in seeing if the two calls agree on volatility
and interest rate, let's graph them together:




TODO: focusing overly much on zero vol?


Solve[Exp[r]-0.99-.055 == (Exp[r]-1)*.055, r]

Solve[Exp[r]-99/100-55/1000 == (Exp[r]-1)*55/1000, r]



TODO: disclaim specitivity 

TODO: use word trader/investor consistently
TODO: consider not doing below

TODO: not considering neg interest rates (unless I do)

Of course, we can run similar analysis for different call prices to
see the curve shape is essentially the same:

[[place image here]]






TODO: breakeven volatility for 0 interest? (solvable?)







TODO: use "call" not "option" throughout

It may seem that, at zero
volatility, a call would be worth 5% of the underlying only if the
risk-free interest rate were also 5%. As it turns out, this isn't the
case.

Solve[%, x]


D[bscallperc[1, k, 1, v, r], k, NonConstants -> {v}] /.
  {D[v, k, NonConstants -> {v}] -> x}









rateatm2[v_,val_] := r /. FindRoot[bscallperc[1,1,1,v,r] == val, {r,0}]

rateitm2[v_,val_] := r /. FindRoot[bscallperc[1,.99,1,v,r] == val, {r,0}]

rateotm2[v_,val_] := r /. FindRoot[bscallperc[1,1.01,1,v,r] == val, {r,0}]

Plot[rateitm2[v, .05],{v,0,.2}]

Plot[rateotm2[v, .05],{v,0,.2}]


p1 = Plot[{
 rateatm2[v,.01], rateatm2[v,.05], rateatm2[v,.10]
 },{v,0,.4},
 Frame -> {True, True, False, False},
 FrameLabel -> {
  Text[Style["Volatility (%)", FontSize->20]],
  Text[Style["Interest Rate (%)", FontSize->20]]
  }, AxesOrigin -> {0,0}, PlotRangePadding -> 0,
 PlotLegends -> {"1%", "5%", "10%"}, PlotRange -> {{0,.29}, {0,.11}},
 PlotLabel -> "Volatility vs Interest Rate for ATM Call at ..."
];
showit

DIGRESSION: can Mathematica do math on imcplicits

f[x_] = Solve[Exp[a] + Log[a] == x, a]

f'[x]


p0 = Plot[rateatm2[v,.05],{v,0,.133617},
 Frame -> {True, True, False, False},
 FrameLabel -> {
  Text[Style["Volatility (%)", FontSize->25]],
  Text[Style["Interest Rate (%)", FontSize->25]]
  }, AxesOrigin -> {0,0}, PlotRangePadding -> 0,
 PlotLabel -> "Volatility vs Interest Rate for ATM Call at 5% Underlying"
];

g0 = Graphics[{
 Text[Style["Risk-free interest is worth more", FontSize -> 30], {.05,.015}],
 Text[Style["Call is worth more", FontSize -> 30], {.10,.045}],
}];

Show[p0,g0]
showit

p1 = Plot[rateitm2[v,.055],{v,0,.133617},
 Frame -> {True, True, False, False},
 FrameLabel -> {
  Text[Style["Volatility (%)", FontSize->25]],
  Text[Style["Interest Rate (%)", FontSize->25]]
  }, AxesOrigin -> {0,0}, PlotRangePadding -> 0,
 PlotLabel -> "Volatility vs Interest Rate for ~1% ITM Call at 5.5% Underlying"
];

g1 = Graphics[{
 Text[Style["Risk-free interest is worth more", FontSize -> 30], {.05,.015}],
 Text[Style["Call is worth more", FontSize -> 30], {.10,.04}],
}];

Show[p1,g1]
showit

p2 = Plot[{rateitm2[v,.055]-rateatm2[v,.05]},{v,0,.133617},
 Frame -> {True, True, False, False},
 FrameLabel -> {
  Text[Style["Volatility (%)", FontSize->25]],
  Text[Style["Interest Rate (%)", FontSize->25]]
  }, AxesOrigin -> {0,0}, PlotRangePadding -> 0,
 PlotLabel -> "Volatility vs Interest Rate for ~1% ITM Call at 5.5% Underlying"
];

g2 = Graphics[{
 Text[Style["Risk-free interest is worth more", FontSize -> 30], {.05,.015}],
 Text[Style["Call is worth more", FontSize -> 30], {.10,.04}],
}];

Show[p2,g2]
showit




r = rate

(r-.05)/.05

Solve[(r-.05)/.05 == .05*r, r]
Solve[(Exp[r]-1.05)/.05 == .05*Exp[r]-.05, r]

Solve[(r-.05)/.05 == .05*Exp[r]-.05, r]

Solve[r-.05 == .05*r, r]


0.0512933 is the magic rateatm number, if this is risk free interest over time

(0.0512933-0.05)

0.05*0.0512933

(1.0512933-1)/.05

.05*0.0512933

r-.05 == r*Exp[.05]

Solve[Exp[r] - 1.05 == 0.05*r, r]

(* the above is probably the correct thing to do *)

Solve[r-.05 == .05*r, r]

Solve[r-1/20 == r/20, r]

Solve[(Exp[r]-1)-1/20 == (Exp[r]-1)/20, r]

Log[20/19] IS the magic number yay!

TODO: no xy dependency









TODO: give more traditional numbers in graph too

TODO: bad things happen if not measured as a percentage

$
   \frac{1}{2} \left(\text{erf}\left(\frac{r+\frac{v^2}{2}}{\sqrt{2}
    v}\right)-e^{-r} \text{erfc}\left(\frac{v^2-2 r}{2 \sqrt{2}
    v}\right)+1\right)
$

rateatm[v_] := r /. FindRoot[bs2[1,1,1,v,r] == .05, {r,0}]

Plot[rateatm[v],{v,0,.125}, 
 Frame -> {True, True, False, False},
 FrameLabel -> {
  Text[Style["If p is ...", FontSize->25]],
  Text[Style["Chance of winning 14/20 is...", FontSize->25]]
 }];
showit




FullSimplify[bs2[1,1,1,v,r], {v>0,r>0}]

FullSimplify[bs2[1,k,1,v,r]]


FullSimplify[bs2[1,k,1,v,r]]




TODO: explain interst rate differential

TODO: assumes constant interest rate expected; volatility or yield curve can change that



Limit[bs2[1,1,1,v,1/100 ], v -> 0]

Using[r>0, Limit[bs2[1,1,1,v,r ], v -> 0, Direction -> -1]] 

you have to get back what you paid for the call

bs2[p_,e_,t_,v_,r_] = FullSimplify[bscall[p,e,t,v,r], {p>0, e>0, t>0, v>0}]

bs2[1,1.01,1,v,r]

vol[r_] := v /. FindRoot[bs2[1,1.01,1,v,r] == .005, {v,.01}]

vol[r_] := v /. FindRoot[bs2[1,1,1,v,r] == .05, {v,.01}]

Plot[vol[r], {r,0,.051}, AxesOrigin -> {0,0}]

Integrate[x*PDF[NormalDistribution[0,vol[0]]][x], {x,0,Infinity}]

above is exactly .05 as expected/desired

rateatm[v_] := r /. FindRoot[bs2[1,1,1,v,r] == .05, {r,0}]

rateim[v_] := r /. FindRoot[bs2[1,1,0.90,v,r] == .05, {r,0}]

rateom[v_] := r /. FindRoot[bs2[1,1,1.10,v,r] == .05, {r,0}]

Plot[rateatm[v],{v,0,.125}]

Plot[{rateatm[v],rateom[v],rateim[v]},{v,0,.125}]


Solve[{
 bs2[p,e1,t,v,r] == c1,
 bs2[p,e2,t,v,r] == c2
 }, {v,r}]

bs2[1,s1,1,v,r]
bs2[1,s2,1,v,r]

bs2[1,1.01,1,v,r]
bs2[1,1.02,1,v,r]

Solve[bscall[p,e,t,v,r] == c1, v]

Solve[bs2[1,s,1,v,r] == c1, r]

FullSimplify[bscall[p,e,t,v,r] /. Erfc[x_] -> 1-Erf[x], conds]


*)




(* above this line, http://mathematica.stackexchange.com/questions/11687/option-pricing-with-the-black-scholes-model-code-not-running *)

(*

This really isn't worth the bounty, but it's too long for a comment.

Quoting
https://www.tradeking.com/education/options/option-greeks-explained#theta

<blockquote>
At-the-money options move at the square root of time. This means if a
one-month ATM option is trading for $1, then a two-month ATM option
would be trading for 1 x sqrt of 2 or $1.41. A three-month ATM option
would be trading for 1 x sqrt of 3 or $1.73.
</blockquote>

As you can see from this example, selling 3 1 month options over 3
months would be worth $3, whereas a single 3 month option would be
worth only $1.73.

Formula-wise, this means the price of an at money option expiring in
$t$ days is $k \sqrt{t}$ (for some value of $k$ that depends on the
volatility). So, the money you make per day is $\frac{k \sqrt{t}}{t}$
or $\frac{k}{\sqrt{t}}$. As t becomes smaller, this number becomes
larger.

Thus, to maximize your per-day income, sell options as frequently as possible.

Of course, this assumes the underlying's price doesn't change. As I
noted in the comments, per the rule of arbitrage, there is no
guaranteed way to make money: this method only works on the assumption
the underlying's price is relatively stable (ie, more stable than the
volatility would indicate).

Another source re theta decay as a square root:

http://www.optionseducation.org/strategies_advanced_concepts/advanced_concepts/understanding_option_greeks/theta.html






Consider an asset whose $\log (\text{p})$ (p = price) change in 1 day
is modeled as a normal distribution with mean 0 (we're ignoring the
risk free interest rate) and standard deviation $s$.

The value of an at-the-money option expiring the next day will be 0 if
the asset price drops. If $\log (\text{p})$ increases by $d$, we have:

$\log \left(p_{\text{new}}\right)=d+\log \left(p_{\text{old}}\right)$

so the option in-money value is:

$p_{\text{new}}-p_{\text{old}}=\left(e^d-1\right) p_{\text{old}}$

The "chance" this happens is the PDF of the normal distribution with
standard deviation $s$ evaluated at $d$:

$\frac{e^{-\frac{d^2}{2 s^2}}}{\sqrt{2 \pi } s}$

Thus, for a $\log (\text{p})$ increase of $d$, the contribution to the
expected value is:

$\frac{\left(e^d-1\right) e^{-\frac{d^2}{2 s^2}} p_{\text{old}}}{\sqrt{2 \pi }
s}$

Integrating the above over all positive d:



In[18]:= 
FullSimplify[Integrate[(Exp[d]-1)*Exp[-d^2/2/s^2]/Sqrt[2*Pi]/s*Subscrip
t[p,old], {d,0,Infinity}], s>0]                                                 


(* tweaking BlackScholes.m to avoid function name collision *)

norm[z_] = 1/2 + Erf[z/Sqrt[2]]/2

aux[p_,k_,sd_,r_,t_] = (Log[p/(k (1+r)^-t)]/(sd Sqrt[t])) + 1/2* sd Sqrt[t]

optionvalue[p_,k_,sd_,r_,t_] = p  norm[aux[p,k,sd,r,t]]-
                               k (1+r)^-t (norm[aux[p,k,sd,r,t]-sd Sqrt[t]])











TODO: not worth bounty, black-scholes
