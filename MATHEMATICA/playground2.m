(* Graphics[Disk[{0,0},1]] *)

(*

g[t_] := Graphics[Disk[{Cos[t],Sin[t]}, .01]];
Show[g[Pi/4], PlotRange->{0,1}]
tab = Table[g[t],{t,0,2*Pi,.1}]

*)

g[t_] := Graphics[{
 {
  Texture[AstronomicalData["Ganymede","Image"]],
  Circle[{Cos[t], Sin[t]}, .05]
 },
 RGBColor[{1,0,0}],
 Disk[0.5*{Cos[t/1.2], Sin[t/1.2]}, .05]
},
 PlotRange -> {{-1, 1}, {-1, 1}}];

Graphics[{Texture[AstronomicalData["Ganymede","Image"]]}]

Graphics3D[{Texture[AstronomicalData["Ganymede","Image"]], 
 Sphere[{0,0,0},1]}]

Graphics[{Texture[ExampleData[{"ColorTexture", "Kingwood"}]],
 Circle[{0,0},1]}]

Graphics[AstronomicalData["Ganymede","Image"]]

Animate[g[t], {t, 0, 2*Pi}];



