(*

Attempt to create silly graph(s) re https://www.quora.com/Do-pure-mathematicians-find-mathematical-statistics-ugly/answer/Donald-Blood/comment/25152005

*)

BarChart[{1, 2, 3,-5}, ChartLabels -> {a,b,c,d}, BarOrigin -> Left]


BarChart[{1, 2, 3,-5}, ChartLabels -> {a,b,c,d}, BarOrigin -> Left,
 ChartStyle -> {Red, Green, Blue, Red}, ChartLegends -> {Red, Green, Blue}]

BarChart[{1, 2, 3,-5}, ChartLabels -> {a,b,c,d}, BarOrigin -> Left,
 ChartStyle -> {Red, Green, Blue, Red}, 
 ChartLegends -> {"red", "green", "blue"}, PlotLabel -> "foo"]

BarChart[{1, 2, 3,-5}, ChartLabels -> {a,b,c,d}, BarOrigin -> Left,
 ChartStyle -> {Red, Green, Blue, Red}, 
 ChartLegends -> {"red", "green", "blue"}, 
 PlotLabel -> "PSV Modification by Nation"]

data = {
 {"France", 85},
 {"Germany", 25},
 {"USA", 0},
 {"UK", -15},
 {Superscript["Canada", "*"], 1},
 {"Australia", 15},
 {"Belgium", 32},
 {Superscript["Kazakhstan", \[Dagger]], 11}

};

data2 = Sort[data, #1[[2]] < #2[[2]] &]

keys = Transpose[data2][[1]]
values = Transpose[data2][[2]]

colors = {RGBColor[.5,0,0], RGBColor[0,.5,.5], RGBColor[.5,.5,0]}
cnames = {"maroon", "teal", "mustard"}
label = "PSV Delta by Nation"

BarChart[values, ChartLabels -> keys, BarOrigin -> Left, 
 ChartStyle -> colors, ChartLegends -> cnames, PlotLabel -> label]










