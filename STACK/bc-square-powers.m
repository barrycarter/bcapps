f[a_,b_] := FindRoot[(a+b)^2 == a^x + b^x, {x,1}][[1,2]]

ContourPlot[f[a,b],{a,0,10},{b,0,10}]

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


TODO: from a>1, b>1 only

ContourPlot[f[a,b],{a,1,100},{b,1,100}, PlotLegends -> True, Contours -> 25,
 ColorFunction -> Hue]


ContourPlot[f[a,b],{a,0,1},{b,0,1}, PlotLegends -> True, Contours -> 25,
 ColorFunction -> Hue]

ContourPlot[f[a,b],{a,1,100},{b,1,100}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

Plot[1/({f[x,x], f[x,2*x], f[x,3*x]}-2),{x,2,500}, 
 PlotRange -> All, ImageSize -> {800,600}]

Plot[Exp[{f[x,x], f[x,2*x], f[x,3*x]}-2],{x,2,500}, 
 PlotRange -> All, ImageSize -> {800,600}]

Plot[{f[x,x], f[x,2*x], f[x,3*x]}, {x,2,500}, 
 PlotRange -> All, ImageSize -> {800,600}]

t2132 = Table[{x,f[x,2*x]},{x,2,500}];

Fit[t2132, {1,1/x}, x]




