s[x_] = y /. Solve[x^4 + y^4 == 1, y]

VectorPlot[{Re[s[a+b*I][[1]]],Im[s[a+b*I][[1]]]}, {a,-2,2}, {b,-2,2}]

VectorPlot[{Re[s[a+b*I][[2]]],Im[s[a+b*I][[2]]]}, {a,-2,2}, {b,-2,2}]

VectorPlot[{Re[s[a+b*I][[3]]],Im[s[a+b*I][[3]]]}, {a,-2,2}, {b,-2,2}]

VectorPlot[{
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[1]]]}, 
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[2]]]}, 
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[3]]]}, 
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[4]]]}
},
{a,-2,2}, {b,-2,2}, VectorStyle -> Arrowheads[0.01]]


VectorPlot[{
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[1]]]}+ 
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[2]]]}+
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[3]]]}+ 
 {Re[s[a+b*I][[1]]],Im[s[a+b*I][[4]]]}
}, 
{a,-2,2}, {b,-2,2}]


ds[x_] = D[s[x],x]

VectorPlot[{Re[ds[a+b*I][[1]]],Im[ds[a+b*I][[1]]]}, {a,-2,2}, {b,-2,2}]

dds[x_] = D[s[x],x,x]

VectorPlot[{Re[dds[a+b*I][[1]]],Im[dds[a+b*I][[1]]]}, {a,-2,2}, {b,-2,2}]

VectorPlot[{
{Re[s[a+b*I][[1]]],Im[s[a+b*I][[1]]]},
{Re[ds[a+b*I][[1]]],Im[ds[a+b*I][[1]]]}
}, {a,-2,2}, {b,-2,2}]

VectorPlot[{
{Re[s[a+b*I][[1]]],Im[s[a+b*I][[1]]]},
{Re[s[a+b*I][[1]]],Im[s[a+b*I][[1]]]} + 0.5*
{Re[ds[a+b*I][[1]]],Im[ds[a+b*I][[1]]]}
}, {a,-2,2}, {b,-2,2}]

RegionPlot[True, {a,-2,2}, {b,-2,2}, ColorFunction -> Function[{a,b},
Hue[Arg[s[a+b*I][[1]]], 1, Norm[s[a+b*I][[1]]]]]]

RegionPlot[True, {a,-2,2}, {b,-2,2}, ColorFunction -> Function[{a,b},
Hue[Norm[s[a+b*I][[1]]], 1, Norm[s[a+b*I][[1]]]]]]


RegionPlot[True, {a,-2,2}, {b,-2,2}, ColorFunction -> Function[{a,b},
Hue[Norm[s[a+b*I][[1]]], 1, 1]]]


RegionPlot[True, {a,0.9,1.1}, {b,-0.1,0.1}, ColorFunction -> Function[{a,b},
Hue[Arg[s[a+b*I][[1]]], 1, Norm[s[a+b*I][[1]]]]]]

RegionPlot[True, {a,-2,2}, {b,-2,2}, ColorFunction -> Function[{a,b},
Hue[1, 1, Norm[s[a+b*I][[1]]]]]]

Plot3D[Norm[s[a+b*I][[1]]], {a,-2,2}, {b,-2,2}]

Plot3D[Norm[s[a+b*I][[2]]], {a,-2,2}, {b,-2,2}]

Plot3D[Norm[s[a+b*I][[3]]], {a,-2,2}, {b,-2,2}]

Plot3D[Norm[s[a+b*I][[4]]], {a,-2,2}, {b,-2,2}]

Plot3D[Norm[s[a+b*I][[1]]], {a,-.05,.05}, {b,.95,1.05}]

ContourPlot[Norm[s[a+b*I][[1]]], {a,-2,2}, {b,-2,2}]


Hue[af[a,b], nf[a,b], 1]]]

(* A point in 2 space that moves with time *)

point[a_,b_,t_] = {a,b} + 



(a+b*I)^4 + (c+d*I)^4

real[a_,b_,c_,d_] = a^4 - 6*a^2*b^2 + b^4 + c^4 - 6*c^2*d^2 + d^4

imag[a_,b_,c_,d_] = 4*a^3*b - 4*a*b^3 + 4*c^3*d - 4*c*d^3

Solve[{real[a,b,c,d] == 1, imag[a,b,c,d]==0}, d, Reals]

sol[z_] = w /. Solve[z^4+w^4 == 1, w, Complexes][[1]]

g[a_,b_] = y /. 

f[a_,b_] = y /. Solve[(a+b*I)^4 + y^4 == 1, y][[1]]

Plot3D[Norm[f[a,b]],{a,-1,1},{b,-1,1}]

Plot3D[Norm[f[a,b]],{a,-10,10},{b,-10,10}]

Plot3D[Norm[g[a,b][[1]]], {a,-1,1}, {b,-1,1}]

ContourPlot[Norm[g[a,b][[1]]], {a,-1,1}, {b,-1,1}]

VectorPlot[{Re[f[a,b]],Im[f[a,b]]}, {a,-2,2}, {b,-2,2}]

t = Table[{Re[g[a,b][[i]]], Im[g[a,b][[i]]]}, {i,1,4}]

VectorPlot[t, {a,-2,2}, {b,-2,2}]

VectorPlot[

VectorPlot[{Re[f[a,b]],Im[f[a,b]]}, {a,-2,2}, {b,-2,2}]


nf[a_,b_] = Norm[f[a,b]]
af[a_,b_] = Arg[f[a,b]]

RegionPlot[True, {a,-1,1}, {b,-1,1}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b], 1]]]

Plot3D[nf[a,b],{a,-10,10},{b,-10,10}]

Plot[{
 Norm[f[a,a]], Norm[f[a,0]], Norm[f[a,2*a]], Norm[f[a,10*a]]
}, {a,-100,100}]



RegionPlot[True, {a,-2,2}, {b,-2,2}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b]]]]

RegionPlot[True, {a,0,1}, {b,0,1}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b]]]]

RegionPlot[True, {a,0,10}, {b,0,10}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b]]]]

RegionPlot[True, {a,-.01,.01}, {b,-.01,.01}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b], 1]]]

RegionPlot[True, {a,-1,1}, {b,-1,1}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b], 1]]]

RegionPlot[True, {a,-1,1}, {b,-.01,.01}, 
 ColorFunction -> Function[{a,b}, Hue[af[a,b], nf[a,b], 1]]]

RegionPlot[True, {a,-1,1}, {b,-1,1}, ColorFunction -> 
 Function[{x,y}, Hue[af[x,y]]]]

RegionPlot[True, {a,-1,1}, {b,-1,1}, ColorFunction -> 
 Function[{x,y}, Hue[nf[x,y]]]]

Plot3D[nf[a,b],{a,-1,1},{b,-1,1}]

Plot3D[nf[a,b],{a,-.1,.1},{b,-.1,.1}]

Plot3D[nf[a,b],{a,-.2,.2},{b,-.2,.2}]

Plot3D[nf[a,b],{a,-.3,.3},{b,-.3,.3}]

Plot3D[nf[a,b],{a,-.1,1},{b,-1,1}]

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




