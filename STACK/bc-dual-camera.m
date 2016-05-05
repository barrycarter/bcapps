(*

http://photo.stackexchange.com/questions/6073/measuring-angular-distance-with-photographs

TODO: red/blue 3D?

TODO: mention using two separate units

TODO: mention z axis which I do not draw

zeta pixels per distance of camera (at distance of camera) (px/d)

TODO: hills, bumpy roads = x not horizontal always

*)

{-.5+x1/zeta,z1} pixel dist from center

{-.5,0} = red camera

conds = {zeta > 0, Member[{x1,x2,z1,z2}, Reals], x1 != 0, x2 != 0, 
z1 != 0, z2 != 0 , t > 0, u > 0}

r[t_] = {-1/2 + t*x1/zeta, t, t*z1/zeta}

b[t_] = {1/2 + t*x2/zeta, t, t*z2/zeta}

r[t][[1]] == b[t][[1]]

t -> zeta/(x1-x2)

r[zeta/(x1-x2)]


FullSimplify[Reduce[Norm[r[t]-b[u]]==0, t, Reals],conds]

FullSimplify[Reduce[Norm[r[t]-b[u]]==0, {u,t}, Reals],conds]

Out[301]= t x1 == u x2 + zeta && x2 z1 != x1 z2 && z1 (u x2 + zeta) == u x1 z2

FullSimplify[Reduce[Norm[r[t]-b[u]]==0, u, Reals],conds]

t x1 != zeta && t x1 == u x2 + zeta && t x2 z1 + z2 zeta == t x1 z2

Solve[Norm[r[t]-b[u]]==0, t]

Solve[z1 (u x2 + zeta) == u x1 z2, u]

below is u

-((z1*zeta)/(x2*z1 - x1*z2))
 
b[-((z1*zeta)/(x2*z1 - x1*z2))]



obj = {.1,2.5};

eps = .05;

g2 = Graphics[{

 Arrowheads[0.02],
 PointSize[.02],
 Line[{{-1,1}, {1,1}}],
 Point[obj],

 Text[Style["A", FontSize->20], {-.5-eps,0+eps}],
 Text[Style["B", FontSize->20], {.5+eps,0+eps}],
 Text[Style["C", FontSize->20], {-.5-eps,1+eps}],
 Text[Style["D", FontSize->20], {-.26+eps,1+eps}],
 Text[Style["E", FontSize->20], {.34-eps,1+eps}],

 Text[Style["F", FontSize->20], {.5+eps,1+eps}],
 Text[Style["G", FontSize->20], obj+{eps,eps}],

 RGBColor[1,0,0],
 Point[{-1/2,0}],
 Arrow[{{-1/2,0}, {-1/2,1}}],
 Point[{-0.26,1}],

 RGBColor[0,0,1],
 Point[{0.34,1}],
 Point[{1/2,0}],
 Arrow[{{1/2,0}, {1/2,1}}],

 Thickness[0.01],
 RGBColor[1,.5,.5],
 Line[{{-.5,1}, {-0.26,1}}],
 RGBColor[.5,.5,1],
 Line[{{.5,1}, {0.34,1}}],
 Thin, Dashed,
 Arrow[{{1/2,0}, obj}],
 RGBColor[1,0,0], 
 Arrow[{{-1/2,0}, obj}],
}]

Show[g2, Axes -> True];
showit

