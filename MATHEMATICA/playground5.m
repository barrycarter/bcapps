(*

If a binary event on an infinite population is p likely to occur and
you take n samples, what is the probability that taking another sample
will give you a mean within 2 standard deviations of the first sample?

*)

(* if the actual probability is p, the chance you'll get k out of n is... *)

f[k_, n_, p_] = Binomial[n,k]*p^k*(1-p)^(n-k)

(* the variance and standard deviation you'll compute is... *)

var[k_, n_, p_] = n*(k/n)*(1-k/n)

sd[k_, n_, p_] = Sqrt[var[k,n,p]]

(* you will correctly assume the real mean successes is within 2 SDs
of the rate you computed, but never less than 0 or more than n *)

range[k_, n_, p_] = Round[
 {Max[0, k - 2*sd[k,n,p]], Min[n, k + 2*sd[k,n,p]]}]

(* the actual chance the next sample of n will give you a value in that range *)

actual[k_, n_, p_] = Sum[f[k,n,p], {k, range[k,n,p][[1]], range[k,n,p][[2]]}]

(* the probability you'll get k times the change your guess will be
correct, added over all k; note the 'x' is 'total' is just a
placeholder so all functions can have three arguments *)

contrib[k_, n_, p_] = f[k,n,p]*actual[k,n,p]

total[x_, n_, p_] = Sum[contrib[k,n,p], {k, 0, n}]

(*

In Mathematica format, the total is...

Sum[((1 - p)^(-k + n)*p^k*Binomial[n, k]*
   (-((1 - p)^(1 + n - Round[Max[0, k - 2*Sqrt[(k*(-k + n))/n]]])*
      p^Round[Max[0, k - 2*Sqrt[(k*(-k + n))/n]]]*
      Binomial[n, Round[Max[0, k - 2*Sqrt[(k*(-k + n))/n]]]]*
      Hypergeometric2F1[1, -n + Round[Max[0, k - 2*Sqrt[(k*(-k + n))/n]]], 
       1 + Round[Max[0, k - 2*Sqrt[(k*(-k + n))/n]]], p/(-1 + p)]) + 
    (1 - p)^(n - Round[Min[n, k + 2*Sqrt[(k*(-k + n))/n]]])*
     p^(1 + Round[Min[n, k + 2*Sqrt[(k*(-k + n))/n]]])*
     Binomial[n, 1 + Round[Min[n, k + 2*Sqrt[(k*(-k + n))/n]]]]*
     Hypergeometric2F1[1, 1 - n + Round[Min[n, k + 2*Sqrt[(k*(-k + n))/n]]], 
      2 + Round[Min[n, k + 2*Sqrt[(k*(-k + n))/n]]], p/(-1 + p)]))/(-1 + p), 
 {k, 0, n}]

*)


