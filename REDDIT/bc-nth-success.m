(*

https://www.reddit.com/r/askscience/comments/5k1fmb/whats_the_average_number_of_attempts_necessary_to/

*)

(* 3rd success on attempt 5 *)

Binomial[4,2]*p^3*(1-p)^2

(* 3rd success on attempt n *)

Binomial[n-1,2]*p^3*(1-p)^(n-3)

(* 3rd success on or before attempt n *)

Sum[Binomial[i-1,2]*p^3*(1-p)^(i-3),{i,0,n}]

(* kth success on attempt n *)

s[k_,n_,p_] = Binomial[n-1,k-1]*p^k*(1-p)^(n-k)

cs[k_,n_,p_] = Sum[s[k,i,p],{i,k,n}]

Table[{1000*i,cs[1000,1000*i,1/100]}, {i,1,100}];

Table[{i,cs[1000,i,1/100]}, {i,99000,100000,100}];

Table[{i,cs[1000,i,1/100]}, {i,99900,100000,1}];

Table[{i,cs[1000,i,1/100]}, {i,1000,100000,1000}];

t1857 = Table[{i,cs[1000,i,1/100]}, {i,1000,110000,1000}];

t1859 = Table[{i,cs[1000,i,1/100]}, {i,90000,110000,100}];

Plot[s[1000,i,1/100],{i,1000,200000}, PlotRange -> All]

Integrate[s[1000,i,1/100],{i,1000,n}]

nd[x_] = PDF[NormalDistribution[100000, Sqrt[100000*1/100*99/100]]][x]

nd2[x_] = PDF[NormalDistribution[100000, 10*Sqrt[100000*99/100]]][x]

nd3[x_] = PDF[NormalDistribution[100000, Sqrt[100000*100]]][x]

Plot[{s[1000,i,1/100], nd[i]},{i,1000,200000}, PlotRange -> All]

Plot[{s[1000,i,1/100],nd2[i]},{i,90000,110000}, PlotRange -> All]

Plot[{s[1000,i,1/100]-nd2[i]},{i,90000,110000}, PlotRange -> All]

Plot[{s[1000,i,1/100]-nd2[i]},{i,0,200000}, PlotRange -> All]

Plot[{s[1000,i,1/100]/nd2[i]},{i,0,200000}, PlotRange -> All]

Plot[{s[1000,i,1/100]-nd3[i]},{i,0,200000}, PlotRange -> All]

Plot[{s[500,i,1/2]},{i,500,2000}, PlotRange -> All]

norm[u_,sd_,x_] = PDF[NormalDistribution[u,sd]][x]

Plot[{s[500,i,1/2], norm[1000, Sqrt[500/4], i]},{i,500,2000}, PlotRange -> All]

Plot[{s[500,i,1/2], norm[1000,Sqrt[2*500],i]},{i,500,2000}, PlotRange -> All]

Plot[{s[500,i,1/2]-norm[1000,Sqrt[2*500],i]},{i,500,2000}, PlotRange -> All]

Plot[{s[500,i,1/3]},{i,1000,2000}, PlotRange -> All]

Integrate[t^(a-1)*(1-t)^(b-1),{t,0,x}]

Beta[x,a,b]

Binomial[n,k]

n! -> Gamma[n+1]

binomial[n_,k_] = n!/k!/(n-k)! /. x_! -> Gamma[x+1]

s[k_,n_,p_] = binomial[n-1,k-1]*p^k*(1-p)^(n-k)

cs[k_,n_,p_] = Sum[s[k,i,p],{i,k,n}]

Simplify[PDF[NegativeBinomialDistribution[n,p]][x],x>0]

Simplify[PDF[NegativeBinomialDistribution[k,p]][n-k],n>k]

Simplify[PDF[NegativeBinomialDistribution[a,p]][k],k>0]

Simplify[CDF[NegativeBinomialDistribution[k,p]][n-k], n>k]

Simplify[PDF[NegativeBinomialDistribution[n-k,1-p]][k],k>0]

Simplify[CDF[NegativeBinomialDistribution[n-k,1-p]][k],k>0]

Median[NegativeBinomialDistribution[n-k,1-p]]

BetaRegularized[1 - p, -k + n, 1 + Floor[k]]

Plot[BetaRegularized[1 - 1/100, -1000+n, 1000], {n,0,200000}]



BetaRegularized[1/100, 1000, n-999]

Plot[BetaRegularized[1/100, 1000, n-999], {n,99000,101000}]

Plot[(1 - 1/100)^(-1000 + n)*p^1000*Binomial[-1 + n, -1 + 1000], 
 {n,99000,101000}]

