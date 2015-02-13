(* Bayesian *)

(* if p% or less are bad, n trials yielding 0 failures *)

phigher[p_,n_] = Simplify[Integrate[r^n,{r,0,p}], n>0]
ptotal[p_,n_] = Simplify[Integrate[r^n,{r,0,1}], n>0]

pgood[p_,n_] = 1 - phigher[p,n]/ptotal[p,n]

(* 95% sure that 95% are good, sample size = ? *)

pgood[.95,n]

Solve[p^(n+1)==1-p,n]

f[p_] = Log[1-p]/Log[p] - 1

Solve[((10^10-n)/10^10)^x==1/2,x,Reals]

g[n_,p_] := NSolve[((10^10-n)/10^10)^x==p,x,Reals]



