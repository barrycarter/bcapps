(* https://www.reddit.com/r/math/comments/z48vpa/sum_of_consecutive_primes_question/ *)

distPrime[n_] := distPrime[n] = Min[n-Prime[PrimePi[n]], Prime[PrimePi[n]+1]-n]

t0305 = Table[Prime[n] + Prime[n+1], {n,1,10^5}];

t0306 = Map[distPrime, t0305];

Tally[t0306];




