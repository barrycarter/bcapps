(* TODO: note conversion is in x,t order *)

translate[v_,x_,t_] = {x-v*t, t-v*x}/Sqrt[1-v^2]

(*

[[image]]

You could argue that simultaneity is just a way to work around the
Lorentz contraction:

  - In the image above, a ship (Black) passes a planet (Red) traveling 0.8c.

  - At the instant they pass, they both set their clocks to t=0.

  - Both are seeing the light that left Earth in the year 1990.

  - Red notes the distance to Earth is 10 light years, and correctly
  concludes it is now 2000 on Earth. Since Earth and Red are in the
  same frame, they can agree it's 2000.

  - Red also notes that Black is traveling at 0.8c and will reach the
  Earth in t=12.5 years (10/0.8), or in the Earth year 2012.5, which
  is correct.

  - Black notes that, by the Lorentz contraction, Earth is only 10*0.6
  = 6 light years away, and incorrectly concludes that the Earth year
  must be 1996.

  - Black also notes that it will take him 6/0.8 or 7.5 years to reach
  Earth.  Of course, by time dilation, Earth clocks will experience
  7.5/0.6 or 12.5 years in that time.

  - Since Black believes it's 1996 on Earth now, and his trip will
  take 12.5 years Earth time, he incorrectly expects to arrive at
  2008.5.

What went wrong?

Although Black adjusted for the Lorentz contraction AND time dilation,
he didn't adjust for simultaneity.

To do this, let's look at the relativity transform from Red to Black:

$
   \{x,t\}\to \left\{\frac{x-t v}{\sqrt{1-v^2}},\frac{t-v
    x}{\sqrt{1-v^2}}\right\}
$

with $v$ equal to $0.8$.

Notes:

  - I am using the order (position, time). Some prefer the reverse order.

  - $t$ is in years, $x$ is in light years, and $v$ is given as a
  fraction of the speed of light. Since $c$ is $1$ in these units, it
  can be omitted from the equations.

In Red's frame, Earth is 10 light years away at the time Black passes
by. Since we decided to make that $t=0$, Red's coordinates for Earth
are $(10,0)$. Of course, Red isn't moving with respect to Earth, so
it's coordinates for Earth are $(10,t)$ for *any* value of $t$. This
will be important shortly.

Let's convert $(10,0)$ to Black's frame. Using the transform above, we
get $\{16.6667,-13.3333\}$.

In other words, in Black's frame, Earth was 16.6667 light years away
13.3333 years ago.

This isn't particularly helpful. We don't even know if Black was *in*
the spaceship 13.33 years ago.

Since Red's coordinates for Earth at $(10,t)$ for *any* value of $t$,
let's try converting that symbolically and see what happens:

$\{10,t\}\to \{16.6667\, -1.33333 t,1.66667 t-13.3333\}$

We note (or compute) that $t=8$ gives us $\{6,0\}$.

This means that, in order to use the Lorentz transform, Black *must*
assign Earth a time of $t=8$ or the year 2008, when he passes Red.

In other words, Black can't assign both Red and Earth the same time
$t=0$ (ie, the year 2000), because, as above, this would break the
Lorentz contraction (note that the Lorentz contraction, which deals
only with position, and the Lorentz transform, which deals with both
position and time, are different).

So, if Black decides that the Earth year is 2008 when he passes Red,
how do his computations go?:

  - Black still knows it will take him 7.5 years to reach Earth (his
  frame), which translates to 12.5 years in the Earth frame. 

TODO: this should be 2022.5, not 2020.5







TODO: maybe mention Fargo Fallacy; note acceleration, Andromeda paradox






  

  


circs = Table[{
 Circle[{10,0},i+1]
},{i,0,9}];

texts = Table[{
 Rotate[Text[Style[ToString[1990+i], FontSize -> 20], {i,0}], 90*Degree]
},{i,1,9}];

g2 = Graphics[{
 PointSize[.02], Arrowheads[.02],
 RGBColor[{0,0,1}], Point[{10,0}],
 RGBColor[{1,0,0}], Point[{0,0}],
 RGBColor[{0,0,0}], Point[{0,0.25}], 
 Arrow[{{0,.25},{.75,.25}}],
 Text[Style["0.8c", FontSize -> 20], {.75/2, .5}],
 Text[Style["Earth", FontSize -> 20], {10, .25}],
 Text[Style["2000", FontSize -> 20], {10, -.25}],
 Rotate[Text[Style["1990", FontSize -> 20], {-0.5, 0.125}], 90*Degree],
 Arrow[{{-0.5, 0.50},{0,1.5}}],
 Arrow[{{-0.5, -0.30},{0,-1.5}}],
 Arrowheads[{-.02,.02}],
 Arrow[{{0, 2},{10,2}}],
 Text[Style["10 light years", FontSize -> 30], {5, 2.3}],
 texts,
 RGBColor[{1,1,0}], circs

}];
Show[g2, AspectRatio -> Automatic, PlotRange -> {{-1,11}, {-2.5,2.5}}]
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



