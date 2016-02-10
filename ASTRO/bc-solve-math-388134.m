(*

The area swept out from the center of an ellipse is $a b \theta$ where
$\theta$ is the central angle, `a` is the semimajor axis, and `b` is
the seminor axis:

*)

a=2; b=1;

ang = 45*Degree;

RegionPlot[{x<a*Cos[ang] && y<b*Sin[ang]}, {x,0,2},{y,0,1}]

g1 = Graphics[{
 Circle[{0,0}, {a,b}],
 Line[{{-a,0}, {a,0}}],
 Line[{{0,-b}, {0,b}}],
 RGBColor[{1,0,0}],
 Line[{{0,0}, {a*Cos[ang], b*Sin[ang]}}]
}]


