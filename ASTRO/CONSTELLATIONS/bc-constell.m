(* fun w/ constellations *)

Interpreter["Constellation"]["The Big Dipper"]["BoundaryLine"]
Interpreter["Constellation"]["The Big Dipper"]["Properties"]

Interpreter["Constellation"]

(* find boundaries of constellations to get formula *)

t0924 = EntityList["Constellation"]

t0925 = Table[i["BoundaryLine"], {i, t0924}]

ListPlot[t0925[[1,1]][[1]]]                                            


(* but should probably use my own list, B1875.0, "straighter" lines *)

t0937 = ReadList["/home/user/BCGIT/ASTRO/CONSTELLATIONS/bound_ed.dat",
 {String}];

(* convert strings used by bound_ed.dat into numbers *)

str2Dec[s_] := Total[ToExpression[StringSplit[s, ":"]]*{3600, 60, 1}]/3600

str2RA[s_] := Total[ToExpression[StringSplit[s, ":"]]*{3600, 60, 1}]/240

t0951 = Table[StringSplit[i, " "][[1]], {i, t0937}]


t0953 = Table[{str2RA[i[[1]]], str2Dec[i[[2]]], i[[3]]}, {i, t0951}]

t0954 = Split[t0953, #1[[3]] == #2[[3]] &]

(* DO NOT USE: t0956 = Gather[t0954, #1[[3]] == #2[[3]] &] *)

ListPlot[Transpose[Drop[Transpose[t0954[[87]]], -1]], PlotJoined->True]

Graphics[Polygon[Transpose[Drop[Transpose[t0954[[5]]],-1]]]]          

above works

t0957 = Region[Polygon[Transpose[Drop[Transpose[t0954[[5]]],-1]]]]

RegionPlot[t0957]                                                     

works and so does just t0957 (slightly different (but equal) results though)

Apply[LCM, Flatten[Denominator[t0954]]]

240

so everything is a mult of 1/240 deg (15 sec of arc)

{240*360, 240*180}

3.7GB of data

RegionMember[t0957, {x,y}]                                            

above is da bomb

constBounds[x_] := Module[{tr},
 tr = Transpose[x];
 {tr[[3,1]], RegionMember[Polygon[Transpose[Take[tr, 2]]]]}
];

constBounds[t0954[[8]]]

above works

constBounds[t0954[[8]]] [[2]][{x,y}]

above works

works, so...

constBounds[x_] := Module[{tr},
 tr = Transpose[x];
 {tr[[3,1]], RegionMember[Polygon[Transpose[Take[tr, 2]]]][{x,y}]}
];

constBounds[x_] := Module[{tr},
 tr = Transpose[x];
 {tr[[3,1]], Apply[RegionMemberFunction[Polygon[Transpose[Take[tr, 2]]]], 
 x, y]}
];


returning to..

constBounds[x_] := Module[{tr},
 tr = Transpose[x];
 {tr[[3,1]], RegionMember[Polygon[Transpose[Take[tr, 2]]]]}
];



t1052 = Table[{i[[1]], 
CForm[Simplify[constBounds[i][[2]][{x,y}], Element[{x,y}, Reals]]]
}, {i, t0954}]

(*

do not do below, icky additional condition

t1052 = Table[{constBounds[i][[1]], 
CForm[Simplify[constBounds[i][[2]][{x,y}]]]
}, {i, t0954}]

*)

actually do do above we can clean it up?

t1052 = Table[{constBounds[i][[1]], 
CForm[Simplify[constBounds[i][[2]][{x,y}]]]
}, {i, t0954}]

t1052 = Table[{constBounds[i][[1]], 
CForm[Simplify[constBounds[i][[2]][{x/240,y/240}]]]
}, {i, t0954}]

t1052 = Table[{constBounds[i][[1]], 
Simplify[constBounds[i][[2]][{x/240,y/240}]]
}, {i, t0954}]

(* cleanup the x and y condition *)

t1111 = Table[{i[[1]], 
 CForm[Simplify[i[[2]], Element[{x, y}, Reals]]]},
 {i, t1052}]

(* above takes too long, so lets just print indiv *)

printThing[i_] := Print["if (", 
 CForm[Simplify[i[[2]], Element[{x,y}, Reals]]],
 ") {return \"", i[[1]], "\"}"
]










printThing[t1052[[7]]]







(* TODO: remember the /240 *)


foo = t0954[[7]]                                                      


