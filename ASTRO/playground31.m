(* oversimplified xy plane orbit to test some stuff *)

(* acceleration of v1 due to v2 (given masses, positions, grav constant) *)

a[v1_,v2_,m1_,m2_,g_] = (v2-v1)*g*m2/Norm[v1-v2]^3

p[t_] := {px[t],py[t]}
s[t_] := {sx[t],sy[t]}

sol = NDSolve[{p[0] == {1,0}, s[0] == {0,0}, p'[0] == {0,1}, s'[0] == {0,0},
 s''[t] == a[s[t],p[t],50,1,1],
 p''[t] == a[p[t],s[t],1,50,1]
}, {px,py,sx,sy},{t,0,10}]

ParametricPlot[{p[t],s[t]} /. sol[[1]],{t,0,5}]







