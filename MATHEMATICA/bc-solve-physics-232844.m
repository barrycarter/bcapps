(* 

Since you don't specify the speed of the plane, let's assume for the
moment that you can move 300 miles up from your current location
instantaneously.

To avoid the air/wind problem, let's also assume we are doing this on
an airless planet that is otherwise similar to Earth.

Finally, since you can "stand still in the air", we'll ignore the
effect of gravity as well.

However, since your launchpoint has an initial velocity of about
1000mph, so do you. Here's what would happen:

[[launch.gif]]

Of course, if your magic plane can move 300 miles in time $\epsilon$,
you could just as easily apply a westward thrust of ~1000mph to cancel
our your initial eastward velocity.

A plane as powerful as this, however, could probably travel anywhere
in the world rapidly, without help from the Earth's rotation.

For a slightly more realistic answer, consider my question/answer to
http://space.stackexchange.com/questions/13815/


TODO: how far and when it lines up

TODO: launch and land per other question

TODO: non infinite boost speed

TODO: mention this progs URL and others since I changed it

*)

(* Earth's equitorial radius, in km, and distance between points in km *)

eer = 6378.137;
dist = 4000*1.609344;
hi = 300*1.609344;
sidday = 86164.1
g = 9.8*10^-3

(* the start and end points at time t, given in seconds *)

st[t_] = eer*{Sin[2*Pi*t/sidday],Cos[2*Pi*t/sidday]};
en[t_] = eer*{Sin[2*Pi*t/sidday-dist/eer],Cos[2*Pi*t/sidday-dist/eer]};
cr[t_] = {t*st'[0][[1]], eer+hi}

(* actual time of being over target *)

t0 = 28911;

points[t_] := {PointSize[0.02], RGBColor[{1,0,0}], Point[st[t]], 
 RGBColor[{0,0,1}], Point[en[t]]};

lines[t_] := If[t>6*3600,{Dashed,Line[{{0,0}, en[t], cr[t]}]}];

craft[t_] := {PointSize[0.02], RGBColor[{0,0,0}], Point[cr[t]]}

earth = {Circle[{0,0}, eer]};

text[t_] := {Text[Style[ToString[N[t/3600]]<>" hours", "Large"], 
 {-1000,-1000}]}

gr[t_] := Graphics[{earth,points[t],craft[t],lines[t], text[t]}, 
 PlotRange -> {{-eer-300,17000}, {-eer-300,eer+hi+300}}]

(*

temporarily commenting out so I can -initfile

gr[360*25]
showit

tab = Table[gr[t],{t,0,t0+7200,360}];

Export["/tmp/launch.gif", tab, ImageSize -> {600,400}]

8.92635 appears to be the "magic number"

*)

(* NOTE: this is a hideously ugly function for one time use only *)

solve[v0_] := solve[v0] = Module[{res,t},
 res = NDSolve[{
  x[0] == 0, y[0] == eer,
  x'[0] == st'[0][[1]], y'[0] ==  v0,
  x''[t] == -g*((eer^2*x[t])/(x[t]^2 + y[t]^2)^(3/2)),
  y''[t] == -g*((eer^2*y[t])/(x[t]^2 + y[t]^2)^(3/2))
  }, {x,y}, {t,0,4*v0/g}];
  Return[res];
  Return[{res[[1,1,2]][#],res[[1,2,2]][#]} &];
]

distance[v0_] := distance[v0] = Module[{res,rc,root},
 res = solve[v0]; 
 rc[t_] = {res[[1,1,2]][t],res[[1,2,2]][t]};
 root = t /. FindRoot[rc[t][[2]] == eer, {t,2*v0/g}];

 (* return the vector angle between me and the target *)
 (* TODO: convert to miles to satisfy original user *)
 Return[{root,eer/1.609344*VectorAngle[rc[root],en[root]]}];
];

(*

tab1245 = Table[{v0, distance[v0][[2]]}, {v0,0,1,1/100}]

tab1245 = Table[{v0, distance[v0][[2]]}, {v0,0,10,1/10}]

tab1245 = Table[{v0, distance[v0][[2]]}, {v0,8.9,9.1,1/100}]

ListPlot[tab1245, PlotJoined->True]

tab1245 = Table[{v0, distance[v0][[2]]}, {v0,8.92,8.94,1/1000}]
ListPlot[tab1245]
showit

tab1245 = Table[{v0, distance[v0][[2]]}, {v0,8.9255,8.9265,1/10000}]
ListPlot[tab1245]
showit

ftomin[t_] := distance[t][[2]];

Plot[ftomin[u],{u,8.9255,8.9265}]

Plot[ftomin[u],{u,8.8,9.0}]

Minimize[ftomin[u], {u,8.9255,8.9265}]

ternary[8.92, 8.94, ftomin, 0.00001]


ParametricPlot[solve[9.8][u], {u,0,20000}]

*)

(*


Plot[rc[t][[2]] - eer, {t,0,20000}]

rocket[t_] := {PointSize[0.02], RGBColor[{0,0,0}], 
 Point[solve[8.92635][t]]};

Plot[If[Norm[rc[t]]>eer, Norm[rc[t]-en[t]], Null],{t,0,20000}]
showit

gr[t_] := Graphics[{earth,points[t],rocket[t],lines[t]}, 
 PlotRange -> {{-eer-300,eer+300}, {-eer-300,21000+eer}}]

tab = Table[gr[u],{u,0,20000,60}];

Export["/tmp/launch2.gif", tab, ImageSize -> {600,400}]

(* 13840.8s is about how long we want it in the air *)

*)
