(*

Graphs quora log stuff; to use "math -initfile quora-times.m"

*)

(* TODO: maybe put this in bclib.pl *)

unixToDate[time_] := ToDate[N[time+2208988800]]

(* this removes a large ~232 day gap which may skew the stats *)

qt2 = Select[quoratimes, #[[1]] > 1300000000000000 &];

list5 = Table[{unixToDate[i[[1]]/10^6], i[[2]]/10^6}, {i,qt2}];

style = PlotMarkers -> 
 Graphics[{RGBColor[1,0,0], PointSize -> 0.01,  Point[{0,0}]}]


p1 = DateListPlot[list5, PlotLabel -> "Quora Log Entries (millions)", style]

 PlotMarkers -> Graphics[{RGBColor[1,0,0], PointSize -> 0.01,  Point[{0,0}]}]]

p2= DateListLogPlot[list5, 
 PlotLabel -> "Quora Log Entries (millions), log scale"]

list2 = Table[{i[[1]]/10^6/86400, i[[2]]/10^6}, {i,qt2}];

p3 = ListLogPlot[list2, PlotLabel -> 
 "Quora Log Entries (millions), log scale, Unix days"];
showit

list3 = N[Table[{i[[1]]/10^6/86400, Log[i[[2]]]}, {i,qt2}]];
Fit[list3,{1,x},x]

FindFit[qt2/10^9, a + b*Exp[c*x], {a,b,c}, x]

f[x_] = Exp[-15.1483 + 0.00200361*x]/10^6

p4 = LogPlot[f[x], {x,15257.6,16953}]

Show[{p4,Graphics[{RGBColor[1,0,0],p3}]}]


list2 = Table[{i[[1]]/10^6/86400, i[[2]]}, {i,quoratimes}];
list3 = Table[{i[[1]]/10^6/86400, Log[i[[2]]]}, {i,quoratimes}];
list4 = Table[{unixToDate[i[[1]]/10^6], Log[i[[2]]]}, {i,quoratimes}];

f1 = Interpolation[N[list3]];

Plot[f1[x],{x,15025.8,16953}]

Fit[list3,{1,x},x]
-15.2222 + 0.00200801 x




TODO: note gappiness
TODO: raw data link and regression against unix time
TODO: note no auth req
