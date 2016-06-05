(*

Graphs quora log stuff; to use "math -initfile quora-times.m"

Subject: Quora log stats

[[image1.gif]]

The graph above shows the number of quora log entries over time.

A log entry occurs whenever anyone posts or edits something.

You can see your own log entries at https://www.quora.com/Barry-Carter/log substituting your own profile id for "Barry-Carter". If you don't know your profile id, you can click on your name at the top right corner of most pages, choose "Profile" and to get to https://www.quora.com/profile/Barry-Carter and then click on "Edits" on the left-hand bar to get to your log page.





If you visit your edits page by clicking on your name, then "Profile",
then "Edits" (my edits page is https://www.quora.com/Barry-Carter/log for example), you'll notice that each entry has a quora log number like #149368232.

You can see details on the log entry by visiting https://www.quora.com/log/revision/149368232 for example.

A log entry can be a question, an answer, a comment, a blog entry, or pretty much anything you can do on quora, plus any edits you've made to any of those things.

There are currently about 150 million log entries on quora. 

*)

(* TODO: maybe put this in bclib.pl *)

unixToDate[time_] := ToDate[N[time+2208988800]]

(* this removes a large ~232 day gap which may skew the stats *)

qt2 = Select[quoratimes, #[[1]] > 1300000000000000 &];

list5 = Table[{unixToDate[i[[1]]/10^6], i[[2]]/10^6}, {i,qt2}];

style = PlotMarkers -> 
 Graphics[{RGBColor[1,0,0], PointSize -> 0.01,  Point[{0,0}]}]

p1 = DateListPlot[list5, 
 PlotLabel -> "Quora Log Entries (millions) vs time", style]


p2= DateListLogPlot[list5, 
 PlotLabel -> "Quora Log Entries (millions) vs time, log scale", style]

list2 = Table[{i[[1]]/10^6/86400, i[[2]]/10^6}, {i,qt2}];

p3 = ListLogPlot[list2, PlotLabel -> 
 "Quora Log Entries (millions), log scale, vs time in Unix days", style];

p6 = ListPlot[list2, PlotLabel -> 
 "Quora Log Entries (millions) vs time in Unix days", style];


f[x_] = Exp[-15.1483 + 0.00200361*x]/10^6

p4 = LogPlot[f[x], {x,15257.6,16953}]

Show[{p3,p4}]

p5 = Plot[f[x], {x,15257.6,16953}]

Show[{p6,p5}]

list3 = N[Table[{i[[1]]/10^6/86400, Log[i[[2]]]}, {i,qt2}]];
Fit[list3,{1,x},x]

FindFit[qt2/10^9, a + b*Exp[c*x], {a,b,c}, x]

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
