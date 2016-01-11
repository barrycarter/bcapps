(* http://money.stackexchange.com/questions/57938/calculate-apy-revolving-loan-with-offset-staggered-payment-schedule *)


(* 

**The surprising answer: your daily interest rate is 3.74%, for an APY
of about 67 million %**

Let d be the daily interest rate, compounded daily.

I can't think of an easy way to do this, so below is a difficult way.

I'm sure there is an easier way, and would appreciate if someone posted it.

*)

(* Day 1: you borrow $7 *)

owed = 7

(* Days 1-5: you pay 4 days interest *)

owed = owed*(1+d)^4

(* Day 5: you pay back $6 *)

owed = owed - 6

(* Days 5-8: you pay 3 days interest *)

owed = owed*(1+d)^3

(* Day 8: you borrow $7 more *)

owed = owed + 7

(* Days 8-10: you pay 2 days interest *)

owed = owed*(1+d)^2

(* Day 10: you pay back $6 *)

owed = owed - 6

(* Days 10-15: you pay 5 days interest *)

owed = owed*(1+d)^5

(* Day 15: you pay back $6, but borrow $7 *)

owed = owed + 7 - 6

(* Days 15-20: you pay 5 days interest *)

owed = owed*(1+d)^5

(* Day 20: you pay back $6 *)

owed = owed - 6

(* Days 20-22: you pay 2 days interest *)

owed = owed*(1+d)^2

(* Day 22: you borrow $7 more *)

owed = owed + 7

(* Days 22-25: you pay 3 days interest *)

owed = owed*(1+d)^3

(* Day 25: you pay back $6 *)

owed = owed - 6

(* Days 25-29: you pay 4 days interest *)

owed = owed*(1+d)^4

(* Day 29: you borrow $7 more *)

owed = owed + 7

(* Days 29-30: you pay 1 day interest *)

owed = owed*(1+d)

(* Day 30: you pay back $6 *)

owed = owed - 6

(* Days 30-35: you pay 5 days interest *)

owed = owed*(1+d)^5

(* Day 35: you pay back $6 *)

owed = owed - 6

(*

We know you now owe $0. In terms of d, from the computations above, this is:

[[IMAGE]]

(this site apparently doesn't support TeX so that's an image)

We now solve for d (using numerical methods), getting 0.037417, or
3.74% daily interest, or right around 67,118,717 percent annual interest.

Note that I'm not solving the "first loan" problem, but you can use a
technique similar to this to find it.

*)
