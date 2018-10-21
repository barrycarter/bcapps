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

{a0, b0, c0, d0} = {-3,-2,1,15}

{xp,yp,zp} = {-2,-2,25}

xclose0 = xclose /. {a->a0,b->b0,c->c0,d->d0,x->xp,y->yp,z->zp}
yclose0 = yclose /. {a->a0,b->b0,c->c0,d->d0,x->xp,y->yp,z->zp}
f[x_,y_] = zplane[x,y] /. {a -> a0, b -> b0, c -> c0, d -> d0}

p0 = Plot3D[f[x,y], {x,-5,5}, {y,-5,5}, Mesh -> None,
 ColorFunction -> Function[{x,y,z}, Hue[1,0.5,1,0.2]]]

g0 = Graphics3D[{
PointSize[.02],
Point[{xp,yp,zp}],
Point[{xp,yp,f[xp,yp]}],
Point[{xclose0,yclose0,f[xclose0,yclose0]}],
Dashed,
Line[{{xp,yp,f[xp,yp]}, {xp,yp,zp}}],
Line[{{xclose0,yclose0,f[xclose0,yclose0]}, {xclose0,yclose0,zp}}]
}]

Show[{p0,g0}, Boxed -> False, 
 PlotRange -> {{-10,55},{-10,55},{-10,55}},
 SphericalRegion -> True]
showit
