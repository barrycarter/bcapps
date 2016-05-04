(*

http://astronomy.stackexchange.com/questions/14776/solar-elevation-angles-anomaly

[[image31]]

Your confusion may stem from the way we sometimes draw the Sun (not to
scale) as though it's close to the Earth.

In reality, as you note, the lines of vision to the Sun are nearly parallel:

[[image32]]

Note that the angles (measured from the red line, the horizon, to the
arrow) are still different, but for entirely different reasons.

I've actually stolen @Andy's answer (and @Tanenthor's comment), but
I'm hoping the diagram makes it easier to understand.

*)

eps = 0.2;

point1 = {-Sqrt[2]/2, Sqrt[2]/2};
point2 = {-Sqrt[2]/2, -Sqrt[2]/2};

g2 = Graphics[{
 Arrowheads[.02],
 RGBColor[0,0,1],
 Disk[{0,0},1],
 RGBColor[255/255,128/255,0],
 Disk[{-5,0}, 0.1],
 RGBColor[0,0,0],
 PointSize[.01],
 Point[{-1,0}],
 Point[point1],
 Point[point2],
 Arrow[{point1, {-5,0}}],
 Arrow[{point2, {-5,0}}],
 Arrow[{{-1,0}, {-5,0}}],
 Text[Style["This is wrong!", FontSize -> 100], {-2.05,1.5}],
 RGBColor[1,0,0],
 Line[{point1-{eps,eps}, point1+{eps,eps}}],
 Line[{point2+{eps,-eps}, point2+{-eps,eps}}],
 Line[{{-1,-Sqrt[2]*eps},{-1,Sqrt[2]*eps}}],
}];

Show[g2];
showit;

g3 = Graphics[{
 Arrowheads[.02],
 RGBColor[0,0,1],
 Disk[{0,0},1],
 RGBColor[0,0,0],
 PointSize[.01],
 Point[{-1,0}],
 Point[point1],
 Point[point2],
 Arrow[{point1, {point1[[1]]-5,point1[[2]]}}],
 Arrow[{point2, {point2[[1]]-5,point2[[1]]}}],
 Arrow[{{-1,0}, {point1[[1]]-5,0}}],
 RGBColor[1,0,0],
 Line[{point1-{eps,eps}, point1+{eps,eps}}],
 Line[{point2+{eps,-eps}, point2+{-eps,eps}}],
 Line[{{-1,-Sqrt[2]*eps},{-1,Sqrt[2]*eps}}],
}];

Show[g3];
showit



