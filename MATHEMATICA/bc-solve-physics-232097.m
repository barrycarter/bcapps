(*

See also:

http://physics.stackexchange.com/questions/14700/the-time-that-2-masses-will-collide-due-to-newtonian-gravity

*)

(* observer in center, 2*d = distance between objects *)

sol[g_, d_] := sol[g,d] = 
NDSolve[{
 x1[0] == -d, x2[0] == d, x1'[0] == 0, x2'[0] == 0,
 x1''[t] == g/(x1[t]-x2[t])^2,
 x2''[t] == -g/(x2[t]-x1[t])^2
}, {x1,x2}, {t,0,10^6}]

coll[g_,d_] := FindRoot[sol[g,d][[1,1,2]][t]==0, {t,0,4*d}][[1,2]]

(* using Mathematica's "stiffness limit" instead *)

col2[g_,d_] := sol[g,d][[1,1,2,1,1,2]]

Plot[col2[1,d],{d,0,20}]

tab = Table[{d,col2[1,d]},{d,1,100}]

FindFit[tab, x^a, {a}, x]

Plot[{x^1.68187, col2[1,x]},{x,0,100}]

FindFit[Take[tab,50], x^a, {a}, x]

tab2 = Table[{d,col2[1,d]},{d,1,500}]

(*

Numerical results: (these assume Mathematica "stiff" point is where it
goes wrong)

g=1, d=1: 0.785398
g=2, d=1: 0.55536 (above divided by sqrt(2))

g=1, d=2: 2.22144
g=1, d=3: 4.08105 
g=1, d=4: 6.28318 (8 times original result)
g=1, d=8: 17.7715
g=1, d=16: 20 [no, that was my time limit]

except for 20: square function? [n

*)

ListPlot[{
{1,0.785398}, {2,2.22144}, {3,4.08105}, {4,6.28318}, {8,17.7715}, {16,20}
}]

(* even simpler case *)

eqs = {x[0] == d, x'[0] == 0, x''[t] == x[t]^-2}

(* mathematica loses solutions w/ boundary conditions *)

eqs = {x''[t] == x[t]^-2}
s = DSolve[eqs,x,t]
form = s[[1]]

form[[1,1]] == form[[2,1]]

(* WRONG: convinced C[2] is 0 *)

s2 = form[[1,1]] == form[[2,1]] /. C[2] -> 0


