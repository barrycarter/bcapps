(* https://www.quora.com/unanswered/How-long-would-an-object-fall-to-Earth-from-1-light-year-distance-if-other-bodies-didnt-perturb-the-trajectory *)

c = 299792458

ly = c*86400*365.2425

ly = 9.461*10^12

er = 40000/2/Pi

g = -9.812/1000

DSolve[{x[0] == d, x'[0] == 0, x''[0] == 0, x''[t] == -g/x[t]^2}, x[t], t]

sol = DSolve[{x''[t] == -g/x[t]^2}, x[t], t]

t[x_] = sol[[1,1,1]]-C[2] /. x[t] -> x

(* solving for constants *)

c1sol = Solve[Simplify[1/t'[d]] == 0, C[1]][[1]]

(* above gives C[1] -> -2*g/d *)

t2[x_] = t[x] /. c1sol

c2sol = Solve[t2[d] == 0, C[2]][[1]]

t3[x_] = FullSimplify[t2[x] /. c2sol, Element[{x,g,d}, Reals]]

(* testing formula near Earth *)


