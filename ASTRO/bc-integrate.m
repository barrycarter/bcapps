(* After running "math -initfile <output of bc-header-values.pl>" *)

(* epoch = 1969-Jun-28 00:00:00.0000 Julian day 2440400.500000000 =
Unix second -16156800 = Unix day -187 *)

planets = Table[planet[i],{i,0,9}]

sol = NDSolve[{posvel,accels},planets,{t,-366*100,366*100}, MaxSteps->100000]

Table[plan[i] = planet[i] /. sol[[1]], {i,0,9}]

Table[plan[1][t],{t,0,360*20,360}] // TableForm

(* last value above is: 0.121448     -0.377519    -0.214545 *)

sol2 = NDSolve[{posvel,accels},planets,{t,-366*100,366*100}, MaxSteps->100000,
 AccuracyGoal -> 50]

Table[plan[i] = planet[i] /. sol2[[1]], {i,0,9}]

Table[plan[1][t],{t,0,360*20,360}] // TableForm

(* last value above is: 0.174976      -0.350809    -0.205831 *)

(* NASA says: 1.764338998100163E-01 -3.499459824403553E-01
-2.055213183324884E-01 *)


