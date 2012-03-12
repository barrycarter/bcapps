(*

Created to separate out binary/barrier options, which can be handled
easier than box options (ie, no numerical integration required

For this file, times are in years to correspond to volatility

*)

bincallvalue[p0_, v_, s_, e_] =
 1-CDF[NormalDistribution[Log[p0],Sqrt[e]*v], Log[s]]

(* formula below was wrong, may still be *)

barriervalue[p0_, v_, s_, e_] =
 1-(2*CDF[NormalDistribution[Log[p0],Sqrt[e]*v*Sqrt[2]], Log[s]]-1)

(*

Suppose I purchased $n worth of a parity at price p. My profit at
price p1 would be n*(1-p/p1).

Now, if I hedge this profit against a binary option (losing my entire
profit if the option goes in money), I make:

*)

binhedge[p_, n_, p0_, v_, s_, e_] = n*(1-p/s)*bincallvalue[p0,v,s,e]
barhedge[p_, n_, p0_, v_, s_, e_] = n*(1-p/s)*barriervalue[p0,v,s,e]

(*

Example: I bought 100K USDJPY at 78 and think it won't reach 79; if
USDJPY reaches 79, I've made $1265.82, so I bet that amount that it
won't. Assume vol = .1 and expiration one week from now; below shows I
could make $226.24 right now

binhedge[78, 100000, 78, .1, 79, 7/365.2425]

*)

(*

Of course, if I don't care about the strike price, I can maximize
profit (bs = best strike)

*)

bsbinhedge[p_, n_, p0_, v_, e_] = Maximize[binhedge[p,n,p0,v,s,e],s]
bsbarhedge[p_, n_, p0_, v_, e_] = Maximize[barhedge[p,n,p0,v,s,e],s]

(*

And if I'm not picky about expiration, I can maximize profit/time (bt
= best time)

Mathematica handles nested maximize poorly, so using 2-variable maximize

*)

bsbtbinhedge[p_, n_, p0_, v_] = Maximize[binhedge[p, n, p0, v, s, e]/e, {s,e}]
bsbtbarhedge[p_, n_, p0_, v_] = Maximize[barhedge[p, n, p0, v, s, e]/e, {s,e}]

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* If oanda is willing to pay you x return on x0 investment, the
percentage change is of a miss is ... *)

oanda2pct[x0_, x_] = x0/x

