(*

Solves from first principles the best fit plane for n points in 3
space, both treating the points as functions of x,y and treating them
as raw points

TODO: handle or properly ignore case c=0 which may be vertical plane

TODO: fix d=1 and then ignore case d=0 

*)

assums = {Element[{x,y,z,x0,y0,a,b,c,d}, Reals], c!=0}

zplane[x_,y_] = z /. Solve[a*x + b*y + c*z == d, z][[1]]

pt2plane[x_,y_,z_,x0_,y0_,a_,b_,c_,d_] = FullSimplify[
 Norm[{{x-x0}, {y-y0}, {z-zplane[x0,y0]}}], assums]

sol = FullSimplify[Solve[{
 D[pt2plane[x,y,z,x0,y0,a,b,c,d], x0] == 0,
 D[pt2plane[x,y,z,x0,y0,a,b,c,d], y0] == 0
}, {x0,y0}, Reals]]

xclose = x0 /. sol[[1]]
yclose = y0 /. sol[[1]]

dist = FullSimplify[pt2plane[x,y,z,xclose,yclose,a,b,c,d]]

min = Minimize[{pt2plane[x,y,z,x0,y0,a,b,c,d], assums},{x0,y0},Reals]

dist = FullSimplify[pt2plane[x,y,z,xclose,yclose,a,b,c,d],assums]



Solve[{
 D[pt2plane[x,y,z,x0,y0,a,b,c,d], x0] == 0, x != x0
}, {x0,y0}, Reals]








f[x_,y_] = 3*x+2*y+15;

p0 = Plot3D[f[x,y], {x,-5,5}, {y,-5,5}, Mesh -> None,
 ColorFunction -> Function[{x,y,z}, Hue[1,0.5,1,0.2]]]

g0 = Graphics3D[{
PointSize[.02],
Point[{-2,-2,f[-2,-2]}],
Dashed,
Line[{{-2,-2,f[-2,-2]}, {-2,-2,45}}]
}]

Show[{p0,g0}, Boxed -> False, PlotRange -> {{-5,5},{-5,5},{-10,55}}]
showit
