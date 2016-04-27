(* 

Is relativitiy really a geometric theory?

NOTE: time then distance

ANSWER STARTS HERE:

This may or may not be helpful.

[[image20.gif]]

The diagram above shows the following in the planet frame:

  - The solid blue line is Earth, which remains 8 light years distant from
  the planet at all times. I've drawn dots for t=-8 to t=10.

  - The solid green line is the planet, which remains at x=0 at all
  times. I've drawn dots for t=0 to t=18.

  - The solid red line is the ship, which travels from the planet to
  Earth in 10 years, covering 8 light years, at least in the planet's
  frame. Note that the dots are drawn every year of planet time, not
  every year of ship time.

  - The dashed blue lines are light-speed signals traveling from Earth
  to the planet, intersecting the ship as they pass.

  - The dashed red lines are light-speed signals traveling from the
  ship to Earth.

Caveats:

  - The x and t scale are not equal on this graph. Because we're
  dealing with a distance of 8 light years and a timeframe of 26
  years, I couldn't find a good way to create a graph with x and t
  scaled equally.

  - I chose x as horizontal and t as vertical. Some people do it the
  other way.

Things To Notice:

  - When the ship leaves the planet, it sees Earth's signal from t =
  -8. In other words, it sees the Earth as it looked at t = -8. This
  isn't the time it assigns Earth, it's just what Earth light it's
  currently receiving.

  - By the time the ship arrives, it sees Earth at t = 10. Again, this
  isn't the time it assigns Earth, just what it actually sees.

  - Thus, considering only the light actually reaching the ship, 18
  years passes on Earth during the ship's 10 year journey. Notice that
  this has nothing to do with dilation or contraction, it's pretty
  much just the Doppler Effect.

  - In your example, Earth only starts sending signals at t=0. In this
  case, the ship receives the first signal at about 4.44 years (still
  in the planet's frame), a little before it's halfway through it's
  journey.

  - Since the ship still receives the last signal at t=10, we note the
  ship receives 11 signals during its 10 year journey, but the first
  signal doesn't arrive until t = 4.4 (Earth time, not ship time), so
  it really receives the 11 signals in 5.56 years (one signal every
  0.505 years or so).

  - The first signal the ship sends doesn't arrive until Earth time t
  = 8. This makes sense, since, in this frame, the Earth is 8 light
  years away.

  - The last signal the ship sends arrives at t = 10 (just as the ship
  is landing). Thus, the Earth sees 10 signals arriving in the space
  of two years, one signal every 0.2 years.

Now, let's do a Minkowski transform into the ship's frame.

Just for fun, we'll animate the change as we move from the planet's
frame to the ship's frame.




TODO: animation and verbiage

[[image22.gif]]

While this diagram is important, let's zoom in a bit:

[[image23.gif]]

Notice what we see here:

  - The ship now remains at x=0 throughout its journey. In other
  words, we are now looking at things from the ship's point of view.

  - When the ship leaves, it still sees light from Earth at t = -8
  Earth time.

  - When the ship arrives, it still sees light from Earth at t = 10
  Earth time.

  - During its journey, the ship still sees 11 signals (if we ignore those
  where Earth t < 0).

  - The first signal the ship sends still arrives at Earth time t = 8,
  and the last signal still arrives at Earth time t = 10.

In other words, in terms of what the ship and Earth actually see,
nothing has changed.

The only difference is that we can now talk about ship time and ship
distance, instead of planet time and planet distance.

Note that if we look at t = 0, we see the Earth at x = 4.8 (the
Lorentz contraction) and at Earth time t = 6.4.

In some sense, however, this is artificial. The light from Earth at t
= 6.4 will still reach the ship at the same point it is journey as it
did before.

Further, the Earth that's 4.8 light years away is not Earth at t = 0,
but Earth at t = 6.4.

Ultimately, regardless of the coordinate system, an observer in a
given frame will see the same event at the same time and same
distance.

The Lorentz contraction and simultaneity are artificial constructs
that insures this happens.


*)

earth[t_][v_] = relativityMatrix[v].{8,t} 
star[t_][v_] = relativityMatrix[v].{0,t}
ship[t_][v_] = relativityMatrix[v].{0.8*t,t} 

earthpts[v_] = Table[earth[t][v], {t,-8,10}]
starpts[v_] = Table[star[t][v], {t,0,18}]
shippts[v_] = Table[ship[t][v], {t,0,10}]

earthline[v_] = Line[{earth[-8][v], earth[10][v]}];
starline[v_] = Line[{star[0][v], star[18][v]}];
shipline[v_] = Line[{ship[0][v], ship[10][v]}];

starcolor = RGBColor[0, 0.5, 0];

earthLightLines[v_] = Table[Line[{earth[t][v], star[t+8][v]}], {t,-8,10}];

starLightLines[v_] = Table[Line[{star[t][v], earth[t+8][v]}], {t,-8,10}];

shipLightLines[v_] = Table[Line[{ship[t][v], earth[8+0.2*t][v]}],
 {t, 0, 10}];

graphpaper = Table[{
 Line[{{i,-40}, {i,+40}}], Line[{{-40, i}, {40, i}}]},
 {i, -40, 40}
];

TODO: reinclude starlightlines later

earthtext[v_] = Table[Text[Style["t="<>ToString[t], FontSize->10], 
 {earth[t][v][[1]] + .3, earth[t][v][[2]]}],
 {t,-8,10}]

g2[v_] = Graphics[{
 RGBColor[0,0,1],
 PointSize[0.01],
 Point/@earthpts[v],
 earthline[v],
 earthtext[v],
 starcolor,
 Point/@starpts[v],
 starline[v],
 RGBColor[1,0,0],
 shipline[v],
 Point/@shippts[v],
 RGBColor[0.5,0.5,1],
 Dashed, RGBColor[0,0,1],
 earthLightLines[v],
 Dashed, RGBColor[1,0,0],
 shipLightLines[v],
}];

g1[v_] = Graphics[{
 RGBColor[0,0,1],
 PointSize[0.01],
 Point/@earthpts[v],
 earthline[v],
 starcolor,
 Point/@starpts[v],
 starline[v],
 RGBColor[1,0,0],
 shipline[v],
 Point/@shippts[v],
 RGBColor[0.5,0.5,1],
 Dashed, RGBColor[0,0,1],
 earthLightLines[v],
 Dashed, RGBColor[1,0,0],
 shipLightLines[v],
}];


xtics = Table[i, {i,-30,30}]
ytics = Table[i, {i,-30,30}]

start = Show[g2[0], Axes -> True, FrameTicks -> {All, All, All, All},
 AxesLabel -> {"x", "t"}, PlotRange -> {{0,8.5}, {-8,18}},
 Ticks -> {xtics, ytics}, AspectRatio -> 1]
showit

end = Show[g2[-0.8], Axes -> True, FrameTicks -> {All, All, All, All},
 AxesLabel -> {"x", "t"}, PlotRange -> {{-25,25}, {-25,30}},
 Ticks -> {xtics, ytics}, AspectRatio -> 1]
showit

end2 = Show[g2[-0.8], Axes -> True, FrameTicks -> {All, All, All, All},
 AxesLabel -> {"x", "t"}, PlotRange -> {{0,25}, {-25,6}},
 Ticks -> {xtics, ytics}, AspectRatio -> 1]
showit

TODO: disclaim non square

show[v_] = Show[g1[v], Axes -> True, AxesLabel -> {"x", "t"},
 PlotRange -> {{-25,25}, {-25, 30}}]

show[0]
showit

show[-.8]
showit

tab = Table[show[v], {v, 0, -0.8, -0.01}];
Export["/tmp/test.gif", tab, ImageSize -> {800,800}];



Show[g2[0], Axes -> True, AspectRatio -> 1, AxesLabel -> {"x", "t"}]

Show[g2[0], Axes -> True, AxesLabel -> {"x", "t"},
 PlotRange -> {{-25,15}, {-10, 30}}]

t3[v_] = {RGBColor[0,0,1], Dashed, 
 Table[Line[{pos[earth][t][v], pos[star][t+8][v]}], {t,0,10}]};

t[v_] = Table[Point[pos[i][t][v]], {i, {earth,star,ship}}, {t,0,10}];

star[v_] = Line[{pos[star][0][v], pos[star][20][v]}];


t2[v_] = {
 RGBColor[0,0,1],
 Line[{pos[earth][0][v], pos[earth][10][v]}],
 RGBColor[1,0,0],
 Line[{pos[ship][0][v], pos[ship][10][v]}],
};

t3[v_] = {RGBColor[0,0,1], Dashed, 
 Table[Line[{pos[earth][t][v], pos[star][t+8][v]}], {t,0,10}]};


Graphics[{t2[0], t[0]}, Axes -> True, AxesLabel -> {"x", "t"}]
showit

Graphics[{t2[0], t[0], t3[0], star[0]}, Axes -> True, AxesLabel -> {"x", "t"}]
showit

Graphics[{t2[-0.8], t[-0.8], t3[-0.8]}, Axes -> True, AxesLabel -> {"x", "t"}]
showit


m = relativityMatrix[.6];

t1 = Table[Arrow[{{t, 0}, temp1405.{t,0}}], {t,0,10}]

t2 = Table[Arrow[{{0, x}, temp1405.{0,x}}], {x,0,10}]

t3 = Table[Arrow[{{0, x}, temp1405.{0,x}-{0,x}}], {x,0,10}]

Graphics[Union[t1,t2]]

t = Table[{
 Line[{{0, i}, {10, i}}],
 Line[{{i, 0}, {i, 10}}],
 Line[{m.{0, i}, m.{10, i}}],
 Line[{m.{i, 0}, m.{i, 10}}]
}, {i,-10,10}];

t1 = Table[{
 Line[{{-10, i}, {10, i}}],
 Line[{{i, -10}, {i, 10}}]
}, {i,-10,10}];

t2 = Table[{
 Line[{m.{-20, i}, m.{20, i}}],
 Line[{m.{i, -20}, m.{i, 20}}]
}, {i,-20,20}];

g2 = Graphics[
 {
 RGBColor[1,0.5,0],
 Arrow[{{5,3}, {10,8}}],
 RGBColor[0,0,0], t1,
 RGBColor[1,0,0], t2,
 RGBColor[0,0,1],
 Line[{{0,0}, {10,6}}],
}]

Show[g2, Axes -> True, PlotRange -> 10]
showit



