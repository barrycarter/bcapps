(*

http://math.stackexchange.com/questions/1720741/closed-form-of-int-0-pi-x3-ln82-sinx-dx

EDIT: This doesn't answer your question but may be helpful.

From http://math.stackexchange.com/questions/674769 (and many other
sources) note that:

$\sin(x) =  x\prod_{n=1}^\infty \left(1-\frac{x^2}{n^2\pi^2}\right)$

and thus:

$
\log (\sin (x))=\log (x) +\sum _{n=1}^{\infty } \log \left(1-\frac{x^2}{n^2 \pi
^2}\right)
$

The partial sum turns out to be:



$
\log(x) +   \sum _{n=1}^k \log \left(1-\frac{x^2}{n^2 \pi ^2}\right) \to
   \log \left(\sin (x) \Gamma \left(k-\frac{x}{\pi }+1\right) \Gamma
    \left(k+\frac{x}{\pi }+1\right)\right)-2 \text{log$\Gamma $}(k+1)
$

(after massive simplification).

We can thus write the kth approximation to the integrand as:

$
   x^3 \left(-2 \text{log$\Gamma $}(k+1)+\log \left(\sin (x) \Gamma
    \left(k-\frac{x}{\pi }+1\right) \Gamma \left(k+\frac{x}{\pi
    }+1\right)\right)+\log (2)\right)^8
$

(note that the log(2) accounts for the 2*x we were ignoring earlier)

Sum[Log[1-x^2/n^2/Pi^2],{n,1,Infinity}]

x^3*(Log[2] + Log[x] + Sum[Log[1-x^2/n^2/Pi^2],{n,1,k}])^8

Simplify[Coefficient[Normal[Series[f[x],{x,0,20}]],x,7],conds]

Integrate[Log[2*Sin[x]]^8,{x,0,Pi}]




conds = {x>0,x<Pi,Element[k,Integers],k>1}

Log[Gamma[1 + k - x/Pi]*Gamma[1 + k + x/Pi]*Sin[x]] - 2*LogGamma[1 + k]

x^3* (Log[Gamma[1 + k - x/Pi]*Gamma[1 + k + x/Pi]*Sin[x]] -
2*LogGamma[1 + k] + Log[2])^8




odd in the sense of unusual, not f(-x) = -f(x)

f[x_] = x^3*Log[2*Sin[x]]^8

Integrate[f[x],{x,0,Pi/2}]

Plot[f[x],{x,0,Pi}, PlotRange -> All]

Table[f[i], {i,Pi-.001,Pi,.0001}]

approx[n_] := Total[Drop[10^-(n+1)*Table[f[i], {i,Pi-10^-n,Pi,10^-(n+1)}],-1]]

approx[n_] := Total[Drop[10^-(n+1)*Table[f[i], {i,Pi-10^-n,Pi,10^-(n+1)}],1]]


Series[f[x], {x,Pi,2}]

Integrate[x^3*Log[2*Sin[x]],x]
Integrate[x^3*Log[2*Sin[x]]^2,{x,0,Pi}]

$Version

9.0 for Linux x86 (32-bit) (November 20, 2012)

NIntegrate[x^3*Log[2*Sin[x]]^8,{x,0,Pi}, WorkingPrecision -> 50,
AccuracyGoal -> 40, PrecisionGoal -> 40]

624509.97425476323973864321155907856915353495760746

(uv)' = uv'+vu'

uv = int uv' + int vu'

int uv' = uv - int vu'

binomial helps?

Integrate[Log[Sin[x/2]]^7, x]

g[x_] = Expand[x^3*(Log[4]+Log[Sin[x/2]]+Log[Cos[x/2]])^8]

test2058 = Apply[List,g[x]]

test2059 = Table[Integrate[i,{x,0,Pi}], {i,test2058}];


2*Sin[x] -> 4*Sin[x/2]*Cos[x/2] -> 

Log[2*Sin[x]] = 2*Log[x] + 2*Sum[Log[1-x^2/n^2/Pi^2],{n,1,Infinity}]

2*Sum[Log[1-x^2/n^2/Pi^2],{n,1,k}]

x^3*(Log[2]+2*Log[x] + 2*Sum[Log[1-x^2/n^2/Pi^2],{n,1,k}])

x^3*Log[1-x^2/n^2/Pi^2]



