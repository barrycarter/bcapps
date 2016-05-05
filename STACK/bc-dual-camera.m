(*

http://photo.stackexchange.com/questions/6073/measuring-angular-distance-with-photographs

TODO: red/blue 3D?

*)

obj = {.1,2.5};

g2 = Graphics[{
 Arrowheads[0.02],
 PointSize[.02],
 Line[{{-1,1}, {1,1}}],
 Point[obj],
 RGBColor[1,0,0],
 Point[{-1/2,0}],
 Arrow[{{-1/2,0}, {-1/2,1}}],
 RGBColor[0,0,1],
 Point[{1/2,0}],
 Arrow[{{1/2,0}, {1/2,1}}],
 Thickness[0.1],
 Line[{{-.5,1}, {-0.26,1}}],
 Line[{{.5,1}, {0.34,1}}],
 Thin, Dashed,
 Arrow[{{1/2,0}, obj}],
 RGBColor[1,0,0], 
 Arrow[{{-1/2,0}, obj}],

 Point[{-0.26,1}],
 Point[{0.34,1}]
}]

Show[g2, Axes -> True];
showit

