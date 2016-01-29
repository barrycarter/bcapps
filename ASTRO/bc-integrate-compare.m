(*

Compares my dfq solutions to NASA's; to use: 

bc-header-values.pl > ! /tmp/math.txt

math -initfile ~/SPICE/KERNELS/ascp02000.431.bz2.* -initfile /tmp/math.txt
 -initfile ~/SPICE/KERNELS/ascp01000.431.bz2.*

*)

(*

This is one of many possible ways to solve these DFQs

(using easy solution for now for testing)

*)

planets = Table[planet[i],{i,0,9}]

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, AccuracyGoal -> 50]]

Table[plan[i][t_] = planet[i][t-2440400.5]*149597870.7 /. sol[[1]], {i,0,9}]



posxyz[2440400.500000000, mercury]





