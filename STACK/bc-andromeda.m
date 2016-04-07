(* TODO: note conversion is in x,t order *)

translate[v_,x_,t_] = {x-v*t, t-v*x}/Sqrt[1-v^2]

(*

[[image]]

You could argue that simultaneity is just a way to work around the
Lorentz contraction:

  - In the image above, a ship (Black) passes a planet (Red) traveling 0.8c. 

  - Both are seeing the light that left Earth in the year 2000.

  - Red notes the distance to Earth is 10 light years, and correctly
  concludes it is now 2010 on Earth.

  - Black notes that, by the Lorentz contraction, Earth is only 6
  light years away, and incorrectly concludes that the Earth year must
  be 2006.

  


circs = Table[{
 Circle[{10,0},i+1]
},{i,0,9}];

texts = Table[{
 Rotate[Text[Style[ToString[2000+i], FontSize -> 20], {i,0}], 90*Degree]
},{i,1,9}];

g2 = Graphics[{
 PointSize[.02], Arrowheads[.02],
 RGBColor[{0,0,1}], Point[{10,0}],
 RGBColor[{1,0,0}], Point[{0,0}],
 RGBColor[{0,0,0}], Point[{0,0.25}], 
 Arrow[{{0,.25},{.75,.25}}],
 Text[Style["0.8c", FontSize -> 20], {.75/2, .5}],
 Text[Style["Earth", FontSize -> 20], {10, .25}],
 Text[Style["2010", FontSize -> 20], {10, -.25}],
 Rotate[Text[Style["2000", FontSize -> 20], {-0.5, 0.125}], 90*Degree],
 Arrow[{{-0.5, 0.50},{0,1.5}}],
 Arrow[{{-0.5, -0.30},{0,-1.5}}],
 texts,
 RGBColor[{1,1,0}], circs

}];
Show[g2, AspectRatio -> Automatic, PlotRange -> {{-1,11}, {-2,2}}]
showit

Suppose an observer B passes another observer C traveling at 0.8c. At
the point they meet, they see light waves from a planet 50 ly away. The light waves were sent in the year 

Consider the following paradox (for this example, we will use a high
relative velocity):


TODO: summarize v*x, note rotation of earth/remote planet

TODO: note how far he'd drive in time given v*x

Let's suppose the events we are watching in the Andromeda Galaxy are
at rest with respect to the stationary person on the sidewalk. This is
highly unrealistic




TODO: address unreality



(* suppose andromeda galaxy is at rest wrt nonwalking guy; dist 2.5 M ly *)

translate[v, x, 0]

Solve[translate[v,x,t][[2]] == 0,t]



