(*

Graphs quora log stuff; to use "math -initfile quora-times.m"

*)

(* TODO: maybe put this in bclib.pl *)

unixToDate[time_] := ToDate[time+2208988800]

list2 = Table[{i[[1]]/10^6/86400, i[[2]]}, {i,quoratimes}];
list3 = Table[{i[[1]]/10^6/86400, Log[i[[2]]]}, {i,quoratimes}];

list4 = Table[{ToDate[N[i[[1]]/10^6]], Log[i[[2]]]}, {i,quoratimes}];

DateListPlot[list4]

f1 = Interpolation[N[list3]];

Plot[f1[x],{x,15025.8,16953}]

Fit[list3,{1,x},x]
-15.2222 + 0.00200801 x




