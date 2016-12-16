(* After running "math -initfile bc-integrate-init.m" *)

(* epoch = 1969-Jun-28 00:00:00.0000 Julian day 2440400.500000000 =
Unix second -16156800 = Unix day -187 *)

planets = Table[planet[i],{i,0,9}]

sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
	      MaxSteps->100000, AccuracyGoal -> 50, Method -> Adams]

sol = NDSolve[{posvel,accels},planets,{t,366*500,366*750}, 
	      MaxSteps->100000, AccuracyGoal -> 50, Method -> Adams]


AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, AccuracyGoal -> 50]]


(* 

This command:

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, AccuracyGoal -> 50]]

will compute from {-66467.1, 66699.3} in 21.188135s

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->200000, AccuracyGoal -> 50]]

above {-131963., 132535.} in 66.325977s

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*5000,366*5000}, 
 MaxSteps->500000, AccuracyGoal -> 50]]

fails with memory shutdown

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, AccuracyGoal -> 10]]

above {-93760.8, 101108.} in 19.773867s

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, AccuracyGoal -> 15]]

above {-65967.6, 66002.8} in 33.133700s

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,366*5000,366*10000}, 
 MaxSteps->100000, AccuracyGoal -> 15]]

No solution data was computed between t == 1.83 10^6  and t == 3.66 10^6 .

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->200000, AccuracyGoal -> Infinity]]

above {{{-131963., 132535.} in 43.004933s

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->200000, AccuracyGoal -> Infinity, InterpolationOrder -> All]]

above memory shutdown

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, AccuracyGoal -> Infinity, InterpolationOrder -> All]]

above memory shutdown

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->20000, AccuracyGoal -> Infinity, InterpolationOrder -> All]]

above {-13287.5, 13118.2} in 5.283234s

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->20000, AccuracyGoal -> Infinity, InterpolationOrder -> 1]]

above {-13287.5, 13118.2} in 4.246432s

*)

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


