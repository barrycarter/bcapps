(* implied volatility of non-normal <h>abnormal!</h> distributions *)

(* under Black-Scholes, this is the value of an option whose
Log[strike] is 1 SD from the current Log[price]; we are combining time
and volatility into one parameter for the moment [v represents the
volatility for whatever time period we're using] *)

value[s_] = Integrate[
 PDF[NormalDistribution[0,v]][x]*(x-s), {x,s,+Infinity}, 
 Assumptions -> {Element[v,Reals]}
]

(* If an option with strike s has value x at price p, it's implied
volatility is a function of current price and current value *)

impvol[p_, s_, x_] = Solve[value[s]==x, v]


