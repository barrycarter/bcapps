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

Over time $t$, the total volatility will be $v \sqrt{t}$, so there's a
~68% chance the stock will remain between $v \sqrt{t} +1$ and
$\frac{1}{\sqrt{t} v+1}$ of its current value after time $t$.

This means that $\log (p)$ will change by less than 

TODO: make sure I use underlying security consistently, not "stock" or just "underlying"



Following
https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black.E2.80.93Scholes_formula, and combining, the Black-Scholes formula for a call (per Mathematica) is:

$
   \frac{1}{2} \left(p \text{erf}\left(\frac{-\log (k)+\log (p)+r t+\frac{t
    v^2}{2}}{\sqrt{2} \sqrt{t} v}\right)-k e^{-r t} \text{erfc}\left(\frac{2
    \log (k)-2 \log (p)-2 r t+t v^2}{2 \sqrt{2} \sqrt{t} v}\right)+p\right)
$

where:

By choosing our units carefully, we can always set $p=1$ and
$t=1$. This gives us:

$
   \frac{1}{2} \left(\text{erf}\left(\frac{-\log (k)+r+\frac{v^2}{2}}{\sqrt{2}
    v}\right)-k e^{-r} \text{erfc}\left(\frac{2 \log (k)-2 r+v^2}{2 \sqrt{2}
    v}\right)+1\right)
$

where $k$ is expressed as a ratio to the underlying price.

Let's first consider what interest rates and volatilities are
consistent with an at the money option. For this, we set $k=1$ to get:

$
   \frac{1}{2} \left(\text{erf}\left(\frac{r+\frac{v^2}{2}}{\sqrt{2}
    v}\right)-e^{-r} \text{erfc}\left(\frac{v^2-2 r}{2 \sqrt{2}
    v}\right)+1\right)
$

It turns out this equation isn't easy to solve for an arbitrary call
value (no closed-form solution), so let's choose a specific call value
of 0.05 as an example and solve numerically. Again, this means the
option price is 5% of the stock price, since we've normalized the
stock price to 1.

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


bscall[p_,e_,t_,v_,r_] := Module [ {standardnormal,d1,d2,value},
 standardnormal=NormalDistribution[0,1];
 d1=(Log[p/e]+t*(r+v*v/2))/v/Sqrt[t];
 d2=d1-v*Sqrt[t];
 value=p*CDF[standardnormal,d1]-e*Exp[-r*t]*CDF[standardnormal,d2]
]

bs2[p_,k_,t_,v_,r_] = FullSimplify[bscall[p,k,t,v,r], {p>0, k>0, t>0, v>0}]

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

conds = {p>0, e>0, t>0, v>0, Element[r,Reals]}

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
