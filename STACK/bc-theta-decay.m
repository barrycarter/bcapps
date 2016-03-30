(*

We could use Black-Scholes here, but it might be easier and more
instructive to answer from first(ish) principles.

I take a few shortcuts here, since I answered a similar question
earlier. Please read: http://quant.stackexchange.com/a/25074/59 if any
of the shortcuts seem too shorty.

If a stock has an annual volatility of $v \%$, the standard deviation
of the change in its log price over one year is $\log (v+1)$, and the
variance of this change is thus $\log ^2(v+1)$

Therefore, the variance for 1 month is $\frac{1}{12} \log ^2(v+1)$,
and the variance for $n$ months is $\frac{n}{12} \log ^2(v+1)$, and
the standard deviation for $n$ months is $\sqrt{\frac{n}{12}} \log
(v+1)$

Note that the **variance**, and **not the standard deviation**,
increases linearly with time. This point is critical to understanding
why theta decay increases as time to expiration decreases.

Now, if the log of a stock's price increases/decreases by $x$, the new
price is $p e^x$, where $p$ is the original price. Thus, the closing
value of a call with strike price $s$ is:

$\begin{cases}
                    0 & s<p e^x \\
                    p e^x-s & s\geq p e^x
                   \end{cases}
$

We can use this to compute the expected value of the closing price
(ie, the fair value of the call) as follows:

  - the PDF of a normal distribution a mean of 0 and standard deviation
  $\sqrt{\frac{n}{12}} \log (v+1)$ is:

$
   \frac{e^{-\frac{x^2}{2 \left(\frac{\sqrt{n} \log
    (1+v)}{\sqrt{12}}\right)^2}}}{\sqrt{2 \pi } \frac{\sqrt{n} \log
    (1+v)}{\sqrt{12}}}
$

  - We multiply by this by the closing value to get:

$
(p e^x-s)
   \frac{e^{-\frac{x^2}{2 \left(\frac{\sqrt{n} \log 
    (1+v)}{\sqrt{12}}\right)^2}}}{\sqrt{2 \pi } \frac{\sqrt{n} \log 
    (1+v)}{\sqrt{12}}} 
$

(valid when $s\geq p e^x$)

  - Finally we integrate:

Integrate[
HoldForm[(p*Exp[x]-s)]*   PDF[NormalDistribution[0, HoldForm[
Sqrt[n]*Log[1+v]/Sqrt[12]]]][x] , x]


HoldForm[(p*Exp[x]-s)]*
 PDF[NormalDistribution[0, HoldForm[Sqrt[n]*Log[1+v]/Sqrt[12]]]][x]


HoldForm[Integrate[(p*Exp[x]-s)*PDF[NormalDistribution[0,
Log[1+v]/Sqrt[12]]][x], {x, p*Exp[x], Infinity}]]

Integrate[(p*Exp[x]-s)*PDF[NormalDistribution[0, Log[1+v]/Sqrt[12]]][x], {x,
 p*Exp[x], Infinity}]



yielding a
monthly standard deviation of $\frac{\log (v+1)}{\sqrt{12}}$.





TODO: pedantically, v*100

Let's assume a stock with an yearly volatility of 15%. This means the
standard deviation of the change in the log of the stock's price over
one year is $\log (1.15)$ (about $0.1398$) and the variance is thus
$\log ^2(1.15)$ or about $0.0195$.

The monthly variance is thus $\frac{0.0195334}{12}$, yielding a one
month standard deviation of $\sqrt\frac{0.0195334}{12}$ or about
$0.0403$

Using an yearly variance (of the change in the log of the stock's
price) value of $\log ^2(1.15)$, let's find the variance and standard
deviation for 1, 2, and 3 months respectively:

$
   \begin{array}{cccc}
    \text{Time} & \text{Variance} & \text{SD} & \text{Numerical} \\
    \text{1 month} & \frac{\log ^2(1.15)}{12} & \sqrt{\frac{\log ^2(1.15)}{12}}
      & 0.0403 \\
    \text{2 months} & 2 \frac{\log ^2(1.15)}{12} & \sqrt{2 \frac{\log
      ^2(1.15)}{12}} & 0.0571 \\
    \text{3 months} & 3 \frac{\log ^2(1.15)}{12} & \sqrt{3 \frac{\log
      ^2(1.15)}{12}} & 0.0699 \\
   \end{array}
$








how
much has the stock price itself increased? If $p$ is the original
price, we have:



Graphing these:

Plot[{
 PDF[NormalDistribution[0, Log[1.15]/Sqrt[12]]][x], 
 PDF[NormalDistribution[0, Sqrt[2]*Log[1.15]/Sqrt[12]]][x], 
 PDF[NormalDistribution[0, Sqrt[3]*Log[1.15]/Sqrt[12]]][x]
}, {x, -.21, +.21}]
showit




grid = {
{"Time", "Variance", "SD", "Numerical"},

{"1 month", HoldForm[Log[1.15]^2/12], HoldForm[Sqrt[Log[1.15]^2/12]], 0.0403},

{"2 months", HoldForm[2]*HoldForm[Log[1.15]^2/12], 
             Sqrt[HoldForm[2]*HoldForm[Log[1.15]^2/12]], 0.0571},

{"3 months", HoldForm[3]*HoldForm[Log[1.15]^2/12], 
             Sqrt[HoldForm[3]*HoldForm[Log[1.15]^2/12]], 0.0699}
};

Grid[grid]
showit




TODO: risk-free rate
