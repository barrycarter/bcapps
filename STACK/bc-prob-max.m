http://math.stackexchange.com/questions/1700486/probability-of-inequalities-between-max-values-of-samples-from-two-different-dis

I thought there'd be a well-known distribution for the maximum of n
standard normal variables, but, as
http://math.stackexchange.com/questions/473229 notes, there isn't. You
can't even find a closed form for the expected value (though you can
for the median).

The PDF for the max of n standard normal variables is:

$
\frac{2^{\frac{1}{2}-n} n e^{-\frac{x^2}{2}}
\left(\text{erf}\left(\frac{x}{\sqrt{2}}\right)+1\right)^{n-1}}{\sqrt{\pi }}
$

and the CDF is:

$2^{-n} \left(\text{erf}\left(\frac{x}{\sqrt{2}}\right)+1\right)^n$

Here's what the PDF looks like for various values of n:

Plot[{
 maxdist[1,x],
 maxdist[2,x],
 maxdist[5,x],
 maxdist[25,x]
}, {x,-4,4}, PlotLegends -> {"n=1", "n=2", "n=5", "n=25"}]

Of course, n=1 is just the standard normal distribution itself.

Plot[{
 maxdist[25,x],
 PDF[NormalDistribution[1.89997,0.486849]][x]
},
 {x,-4,4}]
showit

 PDF[NormalDistribution[1.92133,0.5]][x]
diff[mu_,sigma_] := NIntegrate[
 (maxdist[25,x]-PDF[NormalDistribution[mu,sigma]][x])^2,
{x, -Infinity, Infinity}]

ContourPlot[diff[mu,sigma], {mu,1.8,2.0}, {sigma,0.4,0.6}, 
 ColorFunction -> "Rainbow"]

NMinimize[N[diff[mu,sigma]], {mu,sigma}]




Integrate[(maxdist[25,x]-NormalDistribution[mu,sigma][x])^2,
 {x,-Infinity,Infinity}]

Integrate[(maxdist[2,x]-NormalDistribution[mu,sigma][x])^2,
 {x,-Infinity,Infinity}]


TODO: figure out why I need 'n' product below

maxdist[n_,x_] = 
FullSimplify[
 n*CDF[NormalDistribution[0,1]][x]^(n-1)*PDF[NormalDistribution[0,1]][x],
{Element[x,Reals], Element[n, Integers], n>0}]

cumdist[n_,x_] = FullSimplify[((1+Erf[x/Sqrt[2]])/2)^n,
 {Element[x,Reals], Element[n, Integers], n>0}]



(x-72)/6

Plot[maxdist[1,(x-72)/6],{x,72-3*6,72+3*6}]

Plot[maxdist[5,(x-72)/6],{x,72-3*6,72+3*6}]

Plot[maxdist[25,(x-66)/3],{x,66-3*3,66+3*3}]

Plot[{
 maxdist[1,(x-66)/3],
 maxdist[1,(x-72)/6],
 maxdist[25,(x-66)/3],
 maxdist[5,(x-72)/6]
}, {x,57,90}]

Integrate[5,x

Plot[cumdist[25,(x-66)/3]*(1-cumdist[5,(x-72)/6]), {x,60,75}]

Integrate[cumdist[25,(x-66)/3]*maxdist[5, (x-72)/6], {x,-Infinity,Infinity}]

Integrate[cumdist[25,(x-66)/3]*(1-cumdist[5,(x-72)/6]), {x,-Infinity,Infinity}]

cumdist[25,(x-66)/3]*(1-cumdist[5,(x-72)/6])==1/2


Plot[maxdist[0,1,1,x],{x,-3,3}]

Plot[maxdist[0,1,2,x],{x,-3,3}]

means are 1/Sqrt[Pi], 3/(2*Sqrt[Pi]), 

Plot[Log[PDF[NormalDistribution[0,1]][x]],{x,-3,3}]

Plot[Log[maxdist[0,1,2,x]],{x,-3,3}]

median[n_] = FullSimplify[x /. Solve[cumdist[n,x] == 1/2, x][[1]],
 {Element[n,Integers], n>0}]

Plot[{
 maxdist[0,1,1,x],
 maxdist[0,1,2,x],
 maxdist[0,1,3,x],
 maxdist[0,1,5,x],
 maxdist[0,1,25,x]
}, {x,-3,3}]

Plot[{
 maxdist[72,6,5,x], maxdist[66,3,25,x]
}, {x,60,78}]



