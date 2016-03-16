pop2 = Table[{i[[1]], i[[2]]/10^9}, {i,pop}]

(*

Although this question isn't particularly well-phrased, the general
question here re data-fitting is semi-interesting, so I'll take a shot
at answering it.

TODO: mention world population clock: couldn't find a formula

https://www.census.gov/population/international/data/worldpop/table_population.php

Using https://www.census.gov/population/international/data/idb/ let's
plot the actual and estimated population for 1950-2050:

[[image4.gif]]

This looks almost linear, so we try a linear fit to get:

$\text{population}(y)=0.0737374 y-141.441$

Plotting this vs the actual numbers:



TODO: include plot

lp = ListPlot[pop2, PlotJoined -> True, 
 PlotLabel -> "World population (billions)",
 PlotMarkers -> Graphics[{RGBColor[1,0,1], PointSize -> 0.01, Point[{0,0}]}]
]

lin[x_] = Fit[pop2, {1,x}, x]

linx = Plot[lin[x],{x,1950,2050}, PlotStyle -> RGBColor[1,0,0]]

Show[lp,linx]

t2 = Table[{i,pop2[[i-1949]][[2]]-lin[i]}, {i,1950,2050}]

lp2 = ListPlot[t2, PlotJoined -> True, 
 PlotLabel -> 
  "World population Linear Approximation Goodness of Fit (billions)",
 PlotMarkers -> Graphics[{RGBColor[1,0,1], PointSize -> 0.01, Point[{0,0}]}]
]

est2[x_] = Fit[pop2, {1,x, x^2}, x]

(* for this file only, given a function, return useful things *)

helper[f_] := Module[{t, g1, g2, g3, g4, x},
 t = Table[{i,pop2[[i-1949]][[2]]-f[i]}, {i,1950,2050}];
 g1 = Plot[f[x],{x,1950,2050}, PlotStyle -> RGBColor[1,0,0]];
 
 (* below is actually constant, but I define it here to be safe *)
 g2 = ListPlot[pop2, PlotJoined -> True, 
 PlotLabel -> "World population (billions)", 
 PlotMarkers -> Graphics[{RGBColor[1,0,1], PointSize -> 0.01, Point[{0,0}]}]];

 g3 = Show[{g1,g2}];

 g4 = ListPlot[t, PlotJoined -> True, 
 PlotLabel -> "World population Approximation Residuals (billions)",
 PlotMarkers -> Graphics[{RGBColor[1,0,1], PointSize -> 0.01, Point[{0,0}]}]
];
 

 Return[{f,g3,g4}]
];

helper[Function[x,Evaluate[Fit[pop2, {1,x}, x]]]]

helper[Function[x,Evaluate[Fit[pop2, {1,x,x^2}, x]]]]

helper[Function[x,Evaluate[Fit[pop2, {1,x,x^2,x^3}, x]]]]

logpop2 = Table[{i[[1]],Log[i[[2]]]}, {i, pop2}]

