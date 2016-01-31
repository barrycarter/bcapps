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

t0 = 28911

points[t_] := {PointSize[0.02], RGBColor[{1,0,0}], Point[st[t]], 
 RGBColor[{0,0,1}], Point[en[t]]};

lines[t_] := If[t>6*3600,{Dashed,Line[{{0,0}, en[t], cr[t]}]}];

craft[t_] := {PointSize[0.02], RGBColor[{0,0,0}], Point[cr[t]]}

earth = {Circle[{0,0}, eer]};

text[t_] := {Text[Style[ToString[N[t/3600]]<>" hours", "Large"], 
 {-1000,-1000}]}

gr[t_] := Graphics[{earth,points[t],craft[t],lines[t], text[t]}, 
 PlotRange -> {{-eer-300,17000}, {-eer-300,eer+hi+300}}]

gr[360*25]
showit

tab = Table[gr[t],{t,0,t0+7200,360}];

Export["/tmp/launch.gif", tab, ImageSize -> {600,400}]

(* using bc-trajectory.m *)

v0 = 9.25;

test = NDSolve[{
 x[0] == 0, y[0] == eer,
 x'[0] == st'[0][[1]], y'[0] ==  v0,
 x''[t] == -g*((eer^2*x[t])/(x[t]^2 + y[t]^2)^(3/2)),
 y''[t] == -g*((eer^2*y[t])/(x[t]^2 + y[t]^2)^(3/2))
}, {x,y}, {t,0,4*v0/g}]

Plot[test[[1,2,2]][t]-eer, {t,0,86400/6.}]
showit

ParametricPlot[{test[[1,1,2]][t], test[[1,2,2]][t]}, {t,0,4*v0/g}]
showit



(* magnitude of gravity at x[t], y[t] *)

mag = g*eer^2/(x^2+y^2)

magx = mag*x/Sqrt[x^2+y^2]

