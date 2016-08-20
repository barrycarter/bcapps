(* https://www.quora.com/unanswered/How-long-would-an-object-fall-to-Earth-from-1-light-year-distance-if-other-bodies-didnt-perturb-the-trajectory *)

(*

c = 299792458

ly = c*86400*365.2425

ly = 9.461*10^12

g = -9.812/1000

*)

er = 40000/2/Pi
conds = {g -> -9.812/1000, d -> er+1}

(* above makes C[1] approx 3*10^-6, and C[2] approx 8.38553*10^6 or its neg *)

cond2 = {C[1] -> 3*10^-6, C[2] -> 8.4*10^6, g -> -9.812/1000}

DSolve[{x[0] == d, x'[0] == 0, x''[0] == 0, x''[t] == -g/x[t]^2}, x[t], t]

sol = DSolve[{x''[t] == -g/x[t]^2}, x[t], t]

t[x_] = -sol[[1,1,1]]-C[2] /. x[t] -> x

(* solving for constants *)

c1sol = Solve[Simplify[1/t'[d]] == 0, C[1]][[1]]

(* above gives C[1] -> -2*g/d *)

t2[x_] = t[x] /. c1sol

c2sol = Solve[t2[d] == 0, C[2]][[1]]

t3[x_] = FullSimplify[t2[x] /. c2sol, Element[{x,g,d}, Reals]]

(* sanity testing *)

t3[x] /. {d -> 1, g -> -1}

using positive sol value yields imaginary for t3[.5]
using negative sol value ALSO yields imaginary for t3[.5]

(* testing formula near Earth *)

Plot[t3[x] /. {d -> 40000/2/Pi + 1, g -> -9.812/1000}, {x,40000/2/Pi,
40000/2/Pi+1}]


Solve[q^2 == (t+C[2])^2, t]


