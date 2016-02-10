(*

The area swept out from the center of an ellipse is $a b \theta$ where
$\theta$ is the central angle, `a` is the semimajor axis, and `b` is
the seminor axis:

*)

a=2; b=1;

ang = 45*Degree;

f = Sqrt[a^2-b^2];

pp = RegionPlot[Norm[{x,y}-{-f,0}]+Norm[{x,y}-{f,0}] <= 4 && y/x<b/a*Tan[ang],
 {x,0,2}, {y,0,1}, ColorFunction -> Function[{x,y}, RGBColor[{1,0,0,0.1}]]]


RegionPlot[{x<a*Cos[ang] && y<b*Sin[ang]}, {x,0,2},{y,0,1}]

pp = RegionPlot[{y/x < b/a*Tan[ang]}, {x,0,a*Cos[ang]},{y,0,b*Sin[ang]}]

Graphics[Disk[{0,0}, {a,b}, {0,ang}]]


g1 = Graphics[{
 RGBColor[{1,0,0,0.1}],
 Disk[{0,0}, {a,b}, {0,ang}],
 RGBColor[{0,0,0}],
 Circle[{0,0}, {a,b}],
 Line[{{-a,0}, {a,0}}],
 Line[{{0,-b}, {0,b}}],
 RGBColor[{1,0,0}],
 Line[{{0,0}, {a*Cos[ang], b*Sin[ang]}}]
}]

Show[g1,pp]


