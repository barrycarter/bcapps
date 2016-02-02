(* 

Summary: It's not a great idea. It will take you over 8 hours, and
you'll end up 5400+ miles above your destination. Details follow
image.

[[launch.gif]]

Since you don't specify the speed of the plane, let's assume for the
moment that you can move 300 miles up from your current location
instantaneously.

To avoid the air/wind problem, let's also assume we are doing this on
an airless planet that is otherwise similar to Earth.

Finally, since you can "stand still in the air", we'll ignore the
effect of gravity as well.

Since your starting point is rotating, its (x,y) position in the diagram
above is modeled as:

$
  \left\{\text{eer} \sin \left(\frac{2 \pi  t}{\text{sidday}}\right),\text{eer}
    \cos \left(\frac{2 \pi  t}{\text{sidday}}\right)\right\}
$

where `t` is the time in seconds since the "launch", `eer = 6378.137`
is the Earth's equitorial radius in kilometers and `sidday = 86164.1`
is the length of the sidereal day in seconds.

And your destination is:

$
   \left\{-\text{eer} \sin \left(\frac{\text{dist}}{\text{eer}}-\frac{2 \pi 
    t}{\text{sidday}}\right),\text{eer} \cos
    \left(\frac{\text{dist}}{\text{eer}}-\frac{2 \pi 
    t}{\text{sidday}}\right)\right\}
$

where `dist = 4000*1.609344` is the distance to your destination in kilometers.

Since your launchpoint has an initial velocity of about 1000mph, so do
you. This means your position at time t is:

$\left\{\frac{2 \pi  \text{eer} t}{\text{sidday}},\text{eer}+\text{hi}\right\}$

where `hi= 300*1.609344` is your initial height in kilometers.

With these conditions, you will be over your destination about 28911
seconds after you start (8 hours, 1 minute and 51 seconds), at a
height of about 8718 kilometers (about 5417 miles).

Your average surface velocity would be right around 500 miles per
hour, slower than a supersonic airplane, and even slower if you
include the time to ascend 300 miles at the start and descend 5417
miles at the end.

Of course, if your magic plane can move 300 miles in time $\epsilon$,
you could just as easily apply a westward thrust of ~1000mph to cancel
our your initial eastward velocity, in which case your calculations
would be correct.

A plane as powerful as this, however, could probably travel anywhere
in the world rapidly, without help from the Earth's rotation, so you'd
be best off aiming it west, just as you would a normal airplane.

I toyed with the idea that you could launch at a high velocity and
land back on Earth at your destination purely due to gravity (albeit
at a very high speed) as per:

http://space.stackexchange.com/questions/13815

but haven't been able to get the numbers to work. My work on the
high-velocity launch idea is at:

https://github.com/barrycarter/bcapps/blob/master/MATHEMATICA/bc-solve-physics-232844.m

--- answer ends here ---

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
