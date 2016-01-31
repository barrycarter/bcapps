(* 

Since you don't specify the speed of the plane, let's assume for the
moment that you can move 300 miles up from your current location
instantaneously.

To avoid the air/wind problem, let's also assume we are doing this on
an airless planet that is otherwise similar to Earth.

Finally, since you can "stand still in the air", we'll ignore the
effect of gravity as well.

However, since your launchpoint has an initial velocity of about
1000mph, so do you.

TODO: launch and land per other question

TODO: non infinite boost speed

TODO: cancel horizontal velocity if you can warp

*)

(* Earth's equitorial radius, in km, and distance between points in km *)

eer = 6378.137;
dist = 4000*1.609344;
hi = 300*1.609344;
sidday = 86164.1

(* the start and end points at time t, given in seconds *)

st[t_] = eer*{Sin[2*Pi*t/sidday],Cos[2*Pi*t/sidday]};
en[t_] = eer*{Sin[2*Pi*t/sidday-dist/eer],Cos[2*Pi*t/sidday-dist/eer]};

points[t_] := {PointSize[0.02], RGBColor[{1,0,0}], Point[st[t]], 
 RGBColor[{0,0,1}], Point[en[t]]};

craft[t_] := {PointSize[0.02], RGBColor[{0,0,0}], 
 Point[{t*st'[0][[1]], eer+hi}]}

earth = {Circle[{0,0}, eer]};

gr[t_] := Graphics[{earth,points[t],craft[t]}]

gr[3600]
showit

tab = Table[gr[t],{t,0,3600*8,600}];



conds = {
 x[0] == 0, y[0] == 0, y''[0] == -9.8, x''[0] == 1000, x'[0] == 0, 
 y'[0] == 10};

NDSolve[conds,{x,y},t]
