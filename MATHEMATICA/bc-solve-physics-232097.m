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

eqs = {x''[t] == -x[t]^-2}
s = DSolve[eqs,x,t]
form = s[[1]]
form[[1,1]] == form[[2,1]]

(* reverse form of above, let f be the function satisfying the inverse: *)

f[x[t]] = t

f'[x[t]] x'[t] = 1

x'[t]^2* f''[x[t]] + f'[x[t]] x''[t] = 0

eqs = {
 f[x[t]] == t, f'[x[t]] x'[t] == 1, x'[t]^2* f''[x[t]] + f'[x[t]] x''[t] ==0
} /. {x[t] -> y, x'[t] -> 1/f'[y], x''[t] -> -y^-2}






(* WRONG: convinced C[2] is 0 *)

s2 = form[[1,1]] == form[[2,1]] /. C[2] -> 0

(* so trying ndsolve... *)

sol[d_] := sol[d] = 
NDSolve[{x[0] == d, x'[0] == 0, x''[t] == -x[t]^-2}, x, {t,0,10^6}]

plot[d_] := Plot[sol[d][[1,1,2]][t], {t,0,sol[d][[1,1,2,1,1,2]]}]

Plot[4-sol[4][[1,1,2]][t], {t,0,sol[4][[1,1,2,1,1,2]]}]

(* compare 50 to 5 *)

Plot[sol[50][[1,1,2]][t], {t,0,sol[50][[1,1,2,1,1,2]]}]
Plot[sol[5][[1,1,2]][t], {t,0,sol[5][[1,1,2,1,1,2]]}]

scale = sol[50][[1,1,2,1,1,2]]/sol[5][[1,1,2,1,1,2]]
Plot[10*sol[5][[1,1,2]][t/scale], {t,0,sol[50][[1,1,2,1,1,2]]}]

Plot[{10*sol[5][[1,1,2]][t/scale], sol[50][[1,1,2]][t]},
{t,0,sol[50][[1,1,2,1,1,2]]}]

Plot[{10*sol[5][[1,1,2]][t/scale]- sol[50][[1,1,2]][t]},
{t,0,sol[50][[1,1,2,1,1,2]]}]

col[d_] := sol[d][[1,1,2,1,1,2]]

tab = Table[{d,col[d]},{d,2,1000}]

powers = Table[x^i,{i,0,10}]

g[x_] = Fit[tab,powers,x]

tabg = Table[{x,g[x]},{x,2,1000}]

diffs = Table[{x,tabg[[x,2]]-tab[[x,2]]}, {x,1,999}]

FindFit[tab, x^a, {a}, x]

Plot[{x^1.51575, col[x]}, {x,2,1000}]

Plot[Log[col[d]]/Log[d],{d,0,100}]

Plot[Log[col[d]]/Log[d],{d,0,10000}]

Solve[D[x^n,x,x] == (x^n)^-2,n]

NSolve[D[x^n,x,x] == (x^n)^-2 /. x -> 10 ,n]

Plot[{D[x^n,x,x]-(x^n)^-2} /. x->10,{n,0,2}]

FindRoot[D[x^n,x,x] == -(x^n)^-2 /. x -> 10 ,{n,-2,2}]



(* coll[d_] := FindRoot[sol[d][[1,1,2]][t]==0, {t,0,500}][[1,2]] *)


