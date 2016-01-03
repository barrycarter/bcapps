(*

 http://physics.stackexchange.com/questions/48287/earth-moves-how-much-under-my-feet-when-i-jump and similar

 *)

opts = {Axes->True, AxesLabel->{x,y}, AxesStyle -> Medium, Ticks -> None};

p = ParametricPlot[{Sin[t],Cos[t]-(t-10*Degree)^2+(10*Degree)^2},
 {t,0,20*Degree}, {Axes->True , AxesLabel->{x,y}, AxesStyle -> Medium,
 Ticks -> None}]

p = ParametricPlot[{Sin[t],Cos[t]-(t-10*Degree)^2+(10*Degree)^2}, 
 {t,0,20*Degree}, Flatten[opts]]


g = Graphics[{
 Circle[{0,0},1], 
 Arrow[{{0,0},{Sqrt[2]/2,Sqrt[2]/2}}],
 Text[Style["r",Medium], {Sqrt[2]/4+.02,Sqrt[2]/4-.02}],
 PointSize[Large],
 RGBColor[{0,0,1}],
 Point[{0,1}],
 Text[Style["u(init)",Medium], {0.10,1.05}],
 Point[{Sin[25*Degree],Cos[25*Degree]}],
 Text[Style["u(final)",Medium], {Sin[25*Degree]+0.10,Cos[25*Degree]+0.05}]
}
,opts]

Show[p,g]


Show[ParametricPlot[#[[1]]*{Cos[\[Theta]],Sin[\[Theta]]}, {\[Theta],
 #[[2]], #[[3]]}, Axes -> False, PlotStyle -> #[[4]]] /.  Line[x_] :>
 Sequence[Arrowheads[{-0.05, 0.05}], Arrow[x]] & /@ {{1, 0 Degree, 90
 Degree, Red}, {1.25, 0 Degree, 270 Degree, Blue}, {1.5, 0 Degree, 180
 Degree, Green}}, PlotRange -> All]
