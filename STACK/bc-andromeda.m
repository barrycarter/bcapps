(* TODO: note conversion is in x,t order *)

translate[v_,x_,t_] = {x-v*t, t-v*x}/Sqrt[1-v^2]

(*

DISCLAIMER: This argument may be considered non-standard.

You could argue that simultaneity is just a way to work around the
Lorentz contraction.

circs = Table[{
 Circle[{10,0},i+1, {135*Degree, 225*Degree}]
},{i,0,9}];

texts = Table[{
 Rotate[Text[Style[ToString[2000+i], FontSize -> 20], {i,0}], 90*Degree]
},{i,1,9}];

g2 = Graphics[{
 PointSize[.02], Arrowheads[.02],
 RGBColor[{0,0,1}], Point[{10,0}],
 RGBColor[{1,0,0}], Point[{0,0}],
 RGBColor[{0,0,0}], Point[{0,0.2}], 
 Arrow[{{0,.2},{.98,.2}}],
 Text[Style["0.8c", FontSize -> 15], {.49, .4}],
 texts,
 RGBColor[{1,1,0}], circs

}];
Show[g2, AspectRatio -> 1, PlotRange -> {{0,10}, {-2,2}}]
showit

Suppose an observer B passes another observer C traveling at 0.8c. At
the point they meet, they see light waves from a planet 50 ly away. The light waves were sent in the year 

Consider the following paradox (for this example, we will use a high
relative velocity):


TODO: summarize v*x, note rotation of earth/remote planet

Let's suppose the events we are watching in the Andromeda Galaxy are
at rest with respect to the stationary person on the sidewalk. This is
highly unrealistic




TODO: address unreality



(* suppose andromeda galaxy is at rest wrt nonwalking guy; dist 2.5 M ly *)

translate[v, x, 0]

Solve[translate[v,x,t][[2]] == 0,t]



