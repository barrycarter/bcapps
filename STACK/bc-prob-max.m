http://math.stackexchange.com/questions/1700486/probability-of-inequalities-between-max-values-of-samples-from-two-different-dis

http://math.stackexchange.com/questions/473229/expected-value-for-maximum-of-n-normal-random-variable

TODO: figure out why I need 'n' product below

maxdist[mu_,sigma_,n_,x_] = 
FullSimplify[
 n*CDF[NormalDistribution[mu,sigma]][x]^(n-1)*PDF[NormalDistribution[0,1]][x],
{Element[x,Reals], Element[n, Integers], n>0}]

cumdist[n_,x_] = ((1+Erf[x/Sqrt[2]])/2)^n

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



