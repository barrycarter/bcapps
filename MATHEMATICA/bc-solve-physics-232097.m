(*

See also:

http://physics.stackexchange.com/questions/14700/the-time-that-2-masses-will-collide-due-to-newtonian-gravity

*)

DSolve[{
 x1[0] == 0, x2[0] == d, x1'[0] == 0, x2'[0] == 0,
 x1''[t] == 1/(x1[t]-x2[t])^2,
 x2''[t] == -1/(x2[t]-x1[t])^2
}, {x1[t],x2[t]}, t]

DSolve[{
 x1''[t] == 1/(x1[t]-x2[t])^2,
 x2''[t] == -1/(x1[t]-x2[t])^2
}, {x1[t],x2[t]}, t]

sol[g_, d_] :=
NDSolve[{
 x1[0] == 0, x2[0] == d, x1'[0] == 0, x2'[0] == 0,
 x1''[t] == g/(x1[t]-x2[t])^2,
 x2''[t] == -g/(x2[t]-x1[t])^2
}, {x1,x2}, {t,0,50}]

test[t_] = sol[1,10][[1,1,2]][t]

DSolve[{x[0] == d, x'[0] == 0, x''[t] == x[t]^-2}, x, t]
DSolve[{x''[t] == x[t]^-2}, x, t]

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




