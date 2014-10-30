(* implied volatility of non-normal <h>abnormal!</h> distributions *)

(* under Black-Scholes, this is the value of an option whose
Log[strike] is s SD's from the current Log[price]; we are combining time
and volatility into one parameter for the moment [v represents the
volatility for whatever time period we're using] *)

value[s_] = Integrate[
 PDF[NormalDistribution[0,v]][x]*(Exp[x]-Exp[s]), {x,s,+Infinity},
 Assumptions -> {Element[v,Reals], v>0}
]

(* If an option with strike s SDs out has value x, its implied
volatility is: *)

impvol[s_, x_] = Solve[value[s]==x, v]

(* no closed form, so numerical *)

frimpvol[s_, x_] := FindRoot[value[s]==x, {v,.5}]

(* suppose underlying follows StudentT w/ nu degrees of freedom *)

stvalue[s_] = Integrate[
 PDF[StudentTDistribution[nu]][x]*(Exp[x]-Exp[s]), {x,s,+Infinity}
]

(* no easy closed form, so trying nu=2 *)

stvalue[s_] = Integrate[
 PDF[StudentTDistribution[2]][x]*(Exp[x]-Exp[s]), {x,s,+Infinity}
]

stvalue[s_] := NIntegrate[
 PDF[StudentTDistribution[2]][x]*(Exp[x]-Exp[s]), {x,s,+Infinity}
]

Integrate[
 PDF[NormalDistribution[mu,sigma]][x]*Exp[x], {x,-Infinity,+Infinity},
Assumptions -> {sigma>0}
]

Integrate[
 PDF[CauchyDistribution[location,scale]][x]*Exp[x], {x,-Infinity,+Infinity}
]

Integrate[
 PDF[StudentTDistribution[nu]][x]*Exp[x], {x,-Infinity,+Infinity}
]

Integrate[
 PDF[StudentTDistribution[mu,sigma,nu]][x]*Exp[x], {x,-Infinity,+Infinity}
]





(****** BELOW THIS LINE: IGNORE *******)

(* no closed form, so numerical version below *)

nimpvol[p_, s_, x_] := NSolve[value[s]==x, v]

frimpvol[p_, s_, x_] := FindRoot[value[s]==x, {v,0.5}]

(* hmmm, I think p is unnecessary + unused above *)

(* Now suppose option actually follows Cauchy w/ scale b *)

cvalue[s_] = Integrate[
 PDF[CauchyDistribution[0,b]][x]*(x-s), {x,s,+Infinity}, 
 Assumptions -> {Element[b,Reals]}
]

(* Mathematica can't simplify that, trying w b=1 *)

cvalue[s_] = Integrate[
 PDF[CauchyDistribution[0,1]][x]*(x-s), {x,s,+Infinity}
]

(* above does not converge *)

(* need something w/ finite mean? *)

(* StudentT? *)

stvalue[s_] = Integrate[
 PDF[StudentTDistribution[nu]][x]*(x-s), {x,s,+Infinity}
]

(* Mathematica can't simplify above, trying nu=2 *)

stvalue[s_] = Integrate[
 PDF[StudentTDistribution[2]][x]*(x-s), {x,s,+Infinity}
]

Plot[stvalue[s], {s,-5,5}]

(* implied volatility of above?; general case hard *)

impvol[p, s, stvalue[s]]

(* imp vol if 1 sd out? *)

frimpvol[0, 1, stvalue[1]]

Plot[v /. frimpvol[0, s, stvalue[s]], {s,-5,5}]
