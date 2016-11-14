(*

From first principles, we know the log of the underlying's price at
time T follows a normal distribution with mean $\log (p)+r T$ (where
$p$ is the current price) and variance $\sigma ^2 T$ assuming we're
using the logrithimic (not percentage) definition of volatility.

The standard deviation is thus $\sigma \sqrt{t}$, so the PDF of the
log price is:

$\frac{e^{-\frac{(\log (p)+r T-x)^2}{2 \sigma ^2 T}}}{\sqrt{2 \pi } \sigma \sqrt{T}}$

(and does not appear to simplify, at least according to Mathematica)

The option is only in the money if the log price $x$ exceeds $\log
(k)$, at which point the value is $\left(k-e^x\right)^2$. We thus
integrate:

$
   \int_{\log (k)}^{\infty } \frac{\left(e^x-k\right)^2}{e^{\frac{(r T-x+\log
    (p))^2}{2 T \sigma ^2}} \sqrt{2 \pi } \sqrt{T} \sigma } \, dx
$

to get:

$
   \frac{1}{2} \left(p^2 e^{2 T \left(r+\sigma ^2\right)}
    \left(\text{erf}\left(\frac{-\log (k)+\log (p)+r T+2 \sigma ^2 T}{\sqrt{2}
   \sigma  \sqrt{T}}\right)+1\right)+k \left(-2 p e^{r T+\frac{\sigma ^2 T}{2}}
    \left(\text{erf}\left(\frac{-\log (k)+\log (p)+T \left(r+\sigma
    ^2\right)}{\sqrt{2} \sigma  \sqrt{T}}\right)+1\right)+k
    \text{erf}\left(\frac{-\log (k)+\log (p)+r T}{\sqrt{2} \sigma 
    \sqrt{T}}\right)+k\right)\right)
$

even after Mathematica simplification, which I agree is ugly.

Integrate[f[x]*(Exp[x]-k)^n, {x,Log[k],Infinity}]

conds = {r>0, T>0, \[Sigma] > 0, p>0, k>0, Element[n,Reals]}

f[x_]=FullSimplify[
 PDF[NormalDistribution[r*T+Log[p],\[Sigma]*Sqrt[T]]][x],
conds];



TODO: theoretic but not real?
