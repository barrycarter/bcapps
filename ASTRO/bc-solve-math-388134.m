(*

The area swept out from the center of an ellipse is $a b \theta$ where
$\theta$ is the central angle, `a` is the semimajor axis, and `b` is
the seminor axis:

*)

a=2; b=1;

ang = 45*Degree;

f = Sqrt[a^2-b^2];

g1 = Graphics[{
 RGBColor[{1,0,0,0.1}],
 Disk[{0,0}, {a,b}, {0,ang}],
 RGBColor[{0,0,0, 1}],
 Text[Style["\[Theta]", Large], {a/7.5,b/15}],
 Text[Style["\[Theta]ab", FontSize->50], {1,0.25}],
 Text[Style["a", FontSize->50], {1,-0.07}],
 Text[Style["b", FontSize->50], {-0.07,0.5}],
 Circle[{0,0}, {a,b}],
 Circle[{0,0}, a/10., {0,ArcTan[a*Cos[ang], b*Sin[ang]]}],
 Line[{{-a,0}, {0,0}}],
 Line[{{0,-b}, {0,0}}],
 Arrowheads[{-.02,.02}],
 Arrow[{{0,0}, {a,0}}],
 Arrow[{{0,0}, {0,b}}],
 RGBColor[{1,0,0}],
 Line[{{0,0}, {a*Cos[ang], b*Sin[ang]}}],
}]

Show[g1]
showit

g2 = Graphics[{
 RGBColor[{0,0,1,0.1}],
 Polygon[{{0,0}, {Sqrt[a^2-b^2], 0}, {a*Cos[ang], b*Sin[ang]}}],
 RGBColor[{1,0,0,0.1}],
 Disk[{0,0}, {a,b}, {0,ang}],
 RGBColor[{0,0,0, 1}],
 Text[Style["\[Theta]", Large], {a/7.5,b/15}],
 Text[Style["\[Theta]ab", FontSize->50], {1,0.25}],
 Text[Style["a", FontSize->50], {1,-0.07}],
 Text[Style["b", FontSize->50], {-0.07,0.5}],
 Circle[{0,0}, {a,b}],
 Circle[{0,0}, a/10., {0,ArcTan[a*Cos[ang], b*Sin[ang]]}],
 Line[{{-a,0}, {0,0}}],
 Line[{{0,-b}, {0,0}}],
 Arrowheads[{-.02,.02}],
 Arrow[{{0,0}, {a,0}}],
 Arrow[{{0,0}, {0,b}}],
 RGBColor[{1,0,0}],
 Line[{{0,0}, {a*Cos[ang], b*Sin[ang]}}],
}]


