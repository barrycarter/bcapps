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

g[t_] := Graphics[{
 Inset[AstronomicalData["Ganymede","Image"], {Cos[t], Sin[t]}]
}, PlotRange -> {{-1,1}, {-1,1}}];

Animate[g[t], {t, 0, 2*Pi}];



mAU[m_] := UnitConvert[Quantity[m], "astronomical units"]
g[t_] := Graphics[{
  Inset[AstronomicalData["Jupiter", "Image"], {0, 0}, {60, 60}, 
 0.00092478589001735036058905616495516069], 
  Inset[AstronomicalData["Io", "Image"], 
 0.00281958254656494920284985044127453753*{Cos[
  1.1584636556134366200816584401469*^-7], 
 Sin[1.1584636556134366200816584401469*^-7]}, {60, 60}, 
 0.00002435328780384840063101245731835139],
  Inset[AstronomicalData["Ganymede", "Image"], 
 0.00715518810180498110525579825079766062*{Cos[
  7.272174515109138088166778306604*^-8], 
 Sin[7.272174515109138088166778306604*^-8]}, {60, 60}, 
 0.00003517697127222546757812910501539645],
  Inset[AstronomicalData["Europa", "Image"], 
 0.00448622461040149015971254729753913729*{Cos[
  9.184051552071659768631868188859*^-8], 
 Sin[9.184051552071659768631868188859*^-8]}, {60, 60}, 
 0.00002086660716087317946030096804044952],
  Inset[AstronomicalData["Callisto", "Image"], 
 0.01258541675437095643099952209812423322*{Cos[
  5.483287522242554363618080689843*^-8], 
 Sin[5.483287522242554363618080689843*^-8]}, {60, 60}, 
 0.00003222372068160726835799809281643739]},
 PlotRange -> {{-0.01, 0.01}, {-0.01, 0.01}}, Background -> Black]

Animate[g[t], {t, 0, Infinity*Pi}];

mAU[m_] := UnitConvert[Quantity[m], "astronomical units"]
g[t_] := Graphics[{
  Inset[AstronomicalData["Jupiter", "Image"], {0, 0}, {60, 60}, 
 0.00092478589001735036058905616495516069], 
  Inset[AstronomicalData["Io", "Image"], 
 0.00281958254656494920284985044127453753*{Cos[
  1.1584636556134366200816584401469*^-7*t], 
 Sin[1.1584636556134366200816584401469*^-7*t]}, {60, 60}, 
 0.00002435328780384840063101245731835139],
  Inset[AstronomicalData["Ganymede", "Image"], 
 0.00715518810180498110525579825079766062*{Cos[
  7.272174515109138088166778306604*^-8*t], 
 Sin[7.272174515109138088166778306604*^-8*t]}, {60, 60}, 
 0.00003517697127222546757812910501539645],
  Inset[AstronomicalData["Europa", "Image"], 
 0.00448622461040149015971254729753913729*{Cos[
  9.184051552071659768631868188859*^-8*t], 
 Sin[9.184051552071659768631868188859*^-8*t]}, {60, 60}, 
 0.00002086660716087317946030096804044952],
  Inset[AstronomicalData["Callisto", "Image"], 
 0.01258541675437095643099952209812423322*{Cos[
  5.483287522242554363618080689843*^-8*t], 
 Sin[5.483287522242554363618080689843*^-8]*t}, {60, 60}, 
 0.00003222372068160726835799809281643739]},
 PlotRange -> {{-0.01, 0.01}, {-0.01, 0.01}}, Background -> Black]

mAU[m_] := UnitConvert[Quantity[m], "astronomical units"]
g[t_] := Graphics[{
  Inset[AstronomicalData["Jupiter", "Image"], {0, 0}, {60, 60}, 
 0.00092478589001735036058905616495516069], 
  Inset[AstronomicalData["Io", "Image"], 
 0.00281958254656494920284985044127453753*{Cos[
  1.1584636556134366200816584401469*^-7*t], 
 Sin[1.1584636556134366200816584401469*^-7*t]}, {60, 60}, 
 0.00002435328780384840063101245731835139],
  Inset[AstronomicalData["Ganymede", "Image"], 
 0.00715518810180498110525579825079766062*{Cos[
  7.272174515109138088166778306604*^-8*t], 
 Sin[7.272174515109138088166778306604*^-8*t]}, {60, 60}, 
 0.00003517697127222546757812910501539645],
  Inset[AstronomicalData["Europa", "Image"], 
 0.00448622461040149015971254729753913729*{Cos[
  9.184051552071659768631868188859*^-8*t], 
 Sin[9.184051552071659768631868188859*^-8*t]}, {60, 60}, 
 0.00002086660716087317946030096804044952],
  Inset[AstronomicalData["Callisto", "Image"], 
 0.01258541675437095643099952209812423322*{Cos[
  5.483287522242554363618080689843*^-8*t], 
 Sin[5.483287522242554363618080689843*^-8]*t}, {60, 60}, 
 0.00003222372068160726835799809281643739]},
 PlotRange -> {{-0.01, 0.01}, {-0.01, 0.01}}, Background -> Black]
