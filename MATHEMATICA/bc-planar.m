(*

Solves from first principles the best fit plane for n points in 3
space, both treating the points as functions of x,y and treating them
as raw points

*)

f[x_,y_] = 3*x+2*y+15;

p0 = Plot3D[f[x,y], {x,-5,5}, {y,-5,5}, Mesh -> None,
 ColorFunction -> Function[{x,y,z}, Hue[1,0.5,1,0.2]]]

g0 = Graphics3D[{
PointSize[.02],
Point[{-2,-2,f[-2,-2]}],
Arrow[Tube[{{-2,-2,f[-2,-2]}, {-2,-2,25}},.05]]
}]

Show[{p0,g0}, Boxed -> False, PlotRange -> {{-5,5},{-5,5},{-10,55}}]
showit
