(* http://money.stackexchange.com/questions/57938/calculate-apy-revolving-loan-with-offset-staggered-payment-schedule *)

(* d = daily interest rate, compounded daily *)

(*

Let d be the daily interest rate, compounded daily.

On day 1, you owe $7

*)

owed = 7

(* By day 5, you've accrued 4 days worth of interest on what you owe *)

owed = owed*(1+d)^4

(* Day 5, you pay $6, reducing your total debt *)

owed = owed - 6

(* 

From days 1-5, you are borrowing $7 for 4 days, so the total you owe is:

*)

d0 = 7*(1+d)^4

(*

You pay back $6 on day 5, so you're borrowing 6 dollars less for the
next 3 days:

*)

d1 = (d0-6)*(1+d)^3

(*

You owe $7 more as of day 8, so from days 8-10 you are paying interest
on d1+7 for 2 days:

*)

d2 = (d1+7)*(1+d)^2

(*

You pay back $6 on day 10, so you pay 5 days worth of interest on d2-6

*)

d3 = (d2-6)*(1+d)^5

(*

On day 15, you pay back $6 but borrow another $7 so you owe 1 dollar
more from day 15 through day 20

*)

d4 = (d3+1)*(1+d)^5


