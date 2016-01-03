(*

 http://physics.stackexchange.com/questions/48287/earth-moves-how-much-under-my-feet-when-i-jump and similar

 *)

p = ParametricPlot[{Sin[t],Cos[t] + Sin[t*180/35]}, {t,0,35*Degree},
 PlotStyle -> Red]

g0 = Graphics[{
 PointSize[Large],
 RGBColor[{1,0,0}],
 Point[{Sin[35*Degree],Cos[35*Degree]}]
}]


deg = 40*Degree;

g = Graphics[{
 Circle[{0,0},1, {0,90*Degree}], 
 Arrow[{{0,0},{Sqrt[2]/2,Sqrt[2]/2}}],
 Text[Style["r",Medium], {Sqrt[2]/4+.02,Sqrt[2]/4-.02}],
 PointSize[Large],
 RGBColor[{0,0,1}],
 Point[{0,1}],
 Text[Style["u(init)",Medium], {0.10,1.05}],
 Point[{Sin[deg],Cos[deg]}],
 Text[Style["u(final)",Medium], {Sin[deg]+0.10,Cos[deg]+0.05}]
}]

Show[p, g0, g,
Axes->True , AxesLabel->{x,y}, AxesStyle -> Medium,
     Ticks -> None, AxesOrigin -> {0,0}, PlotRange->All]



Show[ParametricPlot[#[[1]]*{Cos[\[Theta]],Sin[\[Theta]]}, {\[Theta],
 #[[2]], #[[3]]}, Axes -> False, PlotStyle -> #[[4]]] /.  Line[x_] :>
 Sequence[Arrowheads[{-0.05, 0.05}], Arrow[x]] & /@ {{1, 0 Degree, 90
 Degree, Red}, {1.25, 0 Degree, 270 Degree, Blue}, {1.5, 0 Degree, 180
 Degree, Green}}, PlotRange -> All]
