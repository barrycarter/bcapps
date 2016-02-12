Plot3D[0, {x,0,1}, {y,0,1}, ColorFunction -> Function[{x,y,z}, Hue[x,y,1]]]

ContourPlot[0,{x,0,1}, {y,0,1}, ColorFunction -> Function[{x,y,z}, Hue[x,y,1]]]

RegionPlot[True,{x,0,1}, {y,0,1}, ColorFunction -> Function[{x,y}, Hue[x,y,1]]]

RegionPlot[True,{x,-1,1},{y,-1,1},ColorFunction -> Function[{x,y}, Hue[x,y,1]]]

Solve[x^4+y^4==1,x]

(a+b*I)^4 + (c+d*I)^4

real[a_,b_,c_,d_] = a^4 - 6*a^2*b^2 + b^4 + c^4 - 6*c^2*d^2 + d^4

imag[a_,b_,c_,d_] = 4*a^3*b - 4*a*b^3 + 4*c^3*d - 4*c*d^3

Solve[{real[a,b,c,d] == 1, imag[a,b,c,d]==0}, d, Reals]

sol[z_] = w /. Solve[z^4+w^4 == 1, w, Complexes][[1]]

f[a_,b_] = y /. Solve[(a+b*I^4) + y^4 == 1, y][[1]]

nf[a_,b_] = Norm[f[a,b]]
af[a_,b_] = Arg[f[a,b]]

RegionPlot[True, {a,-2,2}, {b,-2,2}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b]]]]

RegionPlot[True, {a,-.01,.01}, {b,-.01,.01}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b], 1]]]

RegionPlot[True, {a,-1,1}, {b,-1,1}, ColorFunction -> 
 Function[{x,y} -> Hue[af[x,y]]]]

RegionPlot[True, {a,-1,1}, {b,-1,1}, ColorFunction -> 
 Function[{x,y} -> Hue[nf[x,y]]]]

Plot3D[nf[a,b],{a,-1,1},{b,-1,1}]

RegionPlot[True, {a,-1,1}, {b,-1,1}, ColorFunction -> 
 Function[{x,y} -> Hue[nf[x,y]]]]

Plot3D[nf[a,b],{a,-1,1},{b,-1,1}, ColorFunction ->
 Function[{x,y,z} -> Hue[nf[x,y]]]]

Plot3D[nf[x,y],{x,-1,1},{y,-1,1}, 
ColorFunction -> Function[{x,y,z} -> Hue[z]]]

(* fail case for post *)

Plot3D[Sin[x y], {x, 0, 3}, {y, 0, 3}, 
 ColorFunction -> Function[{x, y, z}, Hue[z]]]

Plot3D[nf[x,y], {x, -1, 1}, {y, -1, 1}, 
 ColorFunction -> Function[{x, y, z}, Hue[z]]]




