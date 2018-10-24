(*

 http://physics.stackexchange.com/questions/48287/earth-moves-how-much-under-my-feet-when-i-jump and similar

 *)

deg0 = 32*Degree

f[t_] = {Sin[t],Cos[t] + Sin[t*180/deg0*Degree]}
g[t_] = {Sin[t],Cos[t]}

(* p = ParametricPlot[f[t], {t,0,deg0}, PlotStyle -> Red] *)

tab0 = Table[f[t], {t, 0, 6*Degree, 1*Degree}]
tab1 = Table[f[t], {t, 6*Degree, 26*Degree, 1*Degree}]
tab3 = Table[f[t], {t, 26*Degree, 32*Degree, 1*Degree}]

deg = 40*Degree;

tab10 = Table[g[t], {t, 0, deg, 1*Degree}]

g0 = Graphics[{
 RGBColor[{0,0,1}],
 Thickness[.006],
 Arrow[{tab10}],
 Thickness[Medium],
 RGBColor[{0,0,0}],
 Circle[{0,0},1, {0,180*Degree}], 
 Arrow[{{0,0},{Sqrt[2]/2,Sqrt[2]/2}}],
 Text[Style["r",Medium], {Sqrt[2]/4+.02,Sqrt[2]/4-.02}],
 PointSize[Large],
 RGBColor[{1,0,1}],
 Point[{0,1}],
 RGBColor[{0,0,1}],
 Text[Style["t=0",Medium], {0.10,1.05}],
 Point[{Sin[deg],Cos[deg]}],
 Text[Style["u(final)",Medium], {Sin[deg]+0.10,Cos[deg]+0.05}],
 RGBColor[{1,0,0}],
 Arrow[{tab0}],
 Arrow[{tab1}],
 Arrow[{tab3}],
 PointSize[Large],
 Point[{Sin[deg0],Cos[deg0]}]
}]

Show[g0,
Axes->True , AxesLabel->{x,y}, AxesStyle -> Medium,
     Ticks -> None, AxesOrigin -> {0,0}, PlotRange->All,
 AspectRatio -> Automatic]



Show[ParametricPlot[#[[1]]*{Cos[\[Theta]],Sin[\[Theta]]}, {\[Theta],
 #[[2]], #[[3]]}, Axes -> False, PlotStyle -> #[[4]]] /.  Line[x_] :>
 Sequence[Arrowheads[{-0.05, 0.05}], Arrow[x]] & /@ {{1, 0 Degree, 90
 Degree, Red}, {1.25, 0 Degree, 270 Degree, Blue}, {1.5, 0 Degree, 180
 Degree, Green}}, PlotRange -> All]
