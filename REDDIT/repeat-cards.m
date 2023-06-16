(* solves https://www.reddit.com/r/askmath/comments/1497uz8/comment/jo81lns/?context=3 *)


(*

f1 is the chance of picking a unique card

f2 is the chance of picking a duplicate card that you don't already have

f3 is the chance of picking a duplicate card you already have (thus ending the game); note that f3 isn't used in the final calculation

*)

f1[n_, k_] = (16-n)/(72-n-k)

f2[n_, k_] = (56-2*k)/(72-n-k)

f3[n_, k_] = k/(72-n-k) 

(* base conditions *)

a[0,0] = 1

a[-1, k_] = 0

a[n_, -1] = 0

(* ways to reach a[n,k] *)

a[n_, k_] := a[n,k] = a[n-1,k]*f1[n-1,k] + a[n,k-1]*f2[n, k-1]


