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

plan[1][2440400.500000000]
posxyz[2440400.500000000, mercury]

Plot[Norm[plan[1][j]-posxyz[j,mercury]], {j,2440400.5-366*50,2440400.5+366*50}]

Plot[Norm[plan[1][j]-posxyz[j,mercury]], {j,2440400.5-66467,2440400.5+66467}]
Plot[Norm[plan[2][j]-posxyz[j,venus]], {j,2440400.5-66467,2440400.5+66467}]
Plot[Norm[plan[4][j]-posxyz[j,mars]], {j,2440400.5-66467,2440400.5+66467}]
Plot[Norm[plan[5][j]-posxyz[j,jupiter]], {j,2440400.5-66467,2440400.5+66467}]
Plot[Norm[plan[6][j]-posxyz[j,saturn]], {j,2440400.5-66467,2440400.5+66467}]
Plot[Norm[plan[7][j]-posxyz[j,uranus]], {j,2440400.5-66467,2440400.5+66467}]
Plot[Norm[plan[0][j]-posxyz[j,sun]], {j,2440400.5-66467,2440400.5+66467}]

ParametricPlot3D[plan[1][j]-posxyz[j,mercury],
 {j,2440400.5-20000, 2440400.5+20000}]

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->100000, PrecisionGoal -> 50]]

Table[plan[i][t_] = planet[i][t-2440400.5]*149597870.7 /. sol[[1]], {i,0,9}]

Plot[Norm[plan[1][j]-posxyz[j,mercury]], {j,2440400.5-66467,2440400.5+66467}]

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->20000, AccuracyGoal -> Infinity]]

Table[plan[i][t_] = planet[i][t-2440400.5]*149597870.7 /. sol[[1]], {i,0,9}]

Plot[Norm[plan[1][j]-posxyz[j,mercury]], {j,2440400.5-13000,2440400.5+13000}]

AbsoluteTiming[sol = NDSolve[{posvel,accels},planets,{t,-366*500,366*500}, 
 MaxSteps->20000, AccuracyGoal -> 20, WorkingPrecision -> 20]]




