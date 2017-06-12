f[a_,b_] := FindRoot[(a+b)^2 == a^x + b^x, {x,1}][[1,2]]

ContourPlot[f[a,b],{a,0,10},{b,0,10}]

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


TODO: from a>1, b>1 only

ContourPlot[f[a,b],{a,1,100},{b,1,100}, PlotLegends -> True, Contours -> 25,
 ColorFunction -> Hue]

ContourPlot[f[a,n*a],{a,1,100},{n,0,1}, PlotLegends -> True, Contours -> 25,
 ColorFunction -> Hue]


ContourPlot[f[a,b],{a,0,1},{b,0,1}, PlotLegends -> True, Contours -> 25,
 ColorFunction -> Hue]

ContourPlot[Log[f[a,b]]/f[a,b],{a,1,100},{b,1,100}, 
 PlotLegends -> True, Contours -> 64, ColorFunction -> Hue]

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

https://math.stackexchange.com/questions/2319162/a-mathmatical-way-to-solve-for-x-in-a-b2-ax-bx

Solve[(a+a)^2 == a^x + a^x, x][[1,1,2]]

Plot[2^(1/(f[x,x]-2))/x,{x,1,100}]

above is constantly 1

Plot[2^(1/(f[x,5*x]-2))/x,{x,1,100}]

Plot[2^(1/(f[x,5*x]-2))/x,{x,1,100}]

Plot[f[x,2*x]/f[x,x], {x,1,100}, PlotRange -> All]

Plot[f[x,1.01*x]/f[x,x], {x,1,100}, PlotRange -> All]

Plot[(1/(f[x,x]-2))/Log[x],{x,1,100}]                                 

above is also constant

In[230]:= Table[(f[2+h,2]-f[2,2])/h, {h,.001,.01,.001}]                         
shows derv in first is -1/E

same in second

f[2,2] == 3

ContourPlot[f[a,b]-(3-a/E-b/E),
 {a,1,100},{b,1,100}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[f[a,b]-(3-a/E-b/E),
 {a,1,1000},{b,1,1000}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[(f[a,b]-(3-a/E-b/E))/(a+b),
 {a,1,100},{b,1,100}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[(f[a,b]-(3-a/E-b/E)),
 {a,1,10},{b,1,10}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[(f[a,b]-(3-a/E-b/E))/Sqrt[(a^2+b^2)],
 {a,1,10},{b,1,10}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[3-f[a,b],
 {a,1,10},{b,1,10}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[(3-f[a,b])/Sqrt[a^2+b^2],
 {a,1,10},{b,1,10}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[f[a,b]-(2+Log[2]/Log[a]),
 {a,1,10},{b,1,10}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]

ContourPlot[f[a,b]-(2+Log[2]/Log[a]),
 {a,1,100},{b,1,100}, PlotLegends -> True, Contours -> 64,
 ColorFunction -> Hue]


