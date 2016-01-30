(* http://astronomy.stackexchange.com/questions/10979/moons-orbit-around-the-sun *)

earth[t_] = 150*{Cos[t], Sin[t]};
earthc = RGBColor[0,0,0];
earths = PointSize[0.02];

moon1[t_] = earth[t] + 3*{Cos[12*t], Sin[12*t]}; 
moon2[t_] = earth[t] + 10*{Cos[12*t], Sin[12*t]}; 
moon3[t_] = earth[t] + 30*{Cos[12*t], Sin[12*t]}; 
moons = PointSize[0.01];

moon1c = RGBColor[1,0,0];
moon2c = RGBColor[0,0,1];
moon3c = RGBColor[1,0,1];

g = ParametricPlot[earth[t], {t, 0, 2*Pi}, PlotStyle -> earthc];
g1 = ParametricPlot[moon1[t], {t, 0, 2*Pi}, PlotStyle -> moon1c];
g2 = ParametricPlot[moon2[t], {t, 0, 2*Pi}, PlotStyle -> moon2c];
g3 = ParametricPlot[moon3[t], {t, 0, 2*Pi}, PlotStyle -> moon3c];

plot[t_] := Show[g,g1,g2,g3, Graphics[{
 Line[{earth[t],moon3[t]}],
 earthc, earths, Point[earth[t]],
 moon1c, moons, Point[moon1[t]],
 moon2c, moons, Point[moon2[t]],
 moon3c, moons, Point[moon3[t]]
}], PlotRange->All]

t = Table[plot[t],{t,0,2*Pi,0.01}];

Export["/tmp/trimoon.gif",t]

