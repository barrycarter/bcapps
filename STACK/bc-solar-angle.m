(*

http://astronomy.stackexchange.com/questions/14776/solar-elevation-angles-anomaly

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


