(* 3D diagrams to answer math/astro question *)

sph = Graphics3D[{Opacity[0.1], Sphere[{0,0,0},1]}];
c1 = ParametricPlot3D[{Cos[theta],Sin[theta],0.7},{theta,0,2*Pi}]
pl = Graphics3D[InfinitePlane[{{0,0,0},{1,0,0},{0,1,0}}]]

Show[sph,c1,Boxed->False,Lighting->None]
