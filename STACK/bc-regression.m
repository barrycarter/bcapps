(*

Although this question isn't particularly well-phrased, the general
question here re data-fitting is semi-interesting, so I'll take a shot
at answering it.

TODO: include plot

pop2 = Table[{i[[1]], i[[2]]/10^9}, {i,pop}]

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


