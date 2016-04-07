(*

http://physics.stackexchange.com/questions/210794/
http://physics.stackexchange.com/questions/246165/

<section name = "justAMT">

journey is from t=0 to t=7.5 AMT time or t=0 to t=12.5 earth time)

dist2Earth[t_] = If[t<0, 10, 6-0.8*t]
earthTime[t_] = If[t<0, 0, 8+0.6*t]
seeTime[t_] = If[t<0, -10, 3*t-10]

Plot[{earthTime[t], seeTime[t], dist2Earth[t], t}, {t,-0.5,7.5}, 
 AxesOrigin -> {-0.5,0},
 PlotLegends -> {"EarthTime", "EarthClock", "EarthDist", "MeTime"}]
showit

(* below is Terran view *)

dist2Ship[t_] = If[t<0, 10, 10-0.8*t]
shipTime[t_] = If[t<0, t, 0.6*t]
seeTimeShip[t_] = If[t<0, t-10, 3*t-30]

Plot[{shipTime[t], seeTimeShip[t], dist2Ship[t], t}, {t,-0.5,12.5}, 
 AxesOrigin -> {-0.5,0},
 PlotLegends -> {"ShipTime", "ShipClock", "ShipDist", "MeTime"}]
showit
 

seetime(t + dist2Ship(t)) = shiptime(t)

t + (10 - 0.8*t) -> 0.6*t

0.2*t + 10 -> 0.6*t

t -> (u-10)*5


seetime(t + dist2Earth[t]) -> earthTime[t]

seetime(t + 6 - 0.8t) -> 8 + 0.6*t

seetime (.2t + 6) -> 8 + 0.6t

u = .2t*6, so t = 5*(u-6)


Plot[{earthTime[t], dist2Earth[t]}, {t,-0.5,7.5}, AxesOrigin -> {-0.5,0},
 PlotRange -> All,
 PlotLegends -> {"EarthTime", "EarthDist"}]
showit








</section>



<section name="accel0">

earth dist (no stillhereia, just accel0; t=0 now means land time)

dist2Earth[t_] = 0.8*t
earthTime[t_] = 0.6*t
seeTime[t_] = t*3

-7.5 6ly from earth, seeing -4.5, 

seetime(t + 0.8*t) = 0.6*t




Plot[{earthTime[t], seeTime[t], dist2Earth[t]}, {t,-7.5,0}, 
 PlotLegends -> {"Assumed", "Eyeball", "Distance"}]
showit

seetime(t - 0.8*t)



Accel0 (A) and Stillhereia (S)

view for accel0

epiphany: transform between NMT and Earth must be affine, not linear, so we translate only between NMT and AMT

(* this is how AMT sees NMT's clock and Earth's clock [and actually
vice versa too] *)

time1[t_] = 0.6*t
dist1[t_] = 0.8*t

time i will see 0.6*t is 0.6*t + Abs[0.8*t]

so

seetime(t + Abs[0.8*t]) == 0.6*t

seetime[t_] = If[t>0, t/3, t*3]

time2[t_] = time1[t] - Abs[dist1[t]]


Plot[{time1[t],seetime[t],dist1[t]}, {t,0,7.5}, 
 PlotLegends -> {"Assumed", "Eyeball", "Distance"}]
showit

now from earth

time2[t_] = 0.6*t
dist2[t_] = 0.8*t-6

seetime2(t + Abs[0.8*t-6]) = 0.6*t



ok...

AMT at -20, then NMT at -12, at distance 16 so assume 4

AMT at t, NMT at 0.6*t, at distance -0.8*t so assume 0.2*t

Plot[time1[t], {t,-30,7.5}]







dist1[t_] = 6-0.8*t

(* -30 -> 30, 0 -> 6, 

timereal[t_] = -10 + 5/3*t

Plot[timereal[t], {t,-30,7.5}]
showit

Plot[{real1[t],fake1[t]}, {t,-30,7.5}]
showit



</section>


rennie:

t=0 is when guy arrives at Earth, so pre-accel:

(-10, -12.5)

after accel:

(-6, -16.5)

lets try w arb t where 2000 is null

(10, u-10)

(6, u-6)

choosing 2018 as t=0

choosing 2000 as t=0

(10, 0)

(6, 4)

<section name="106">

<h2>The 10/6 Conundrum</h2>

Consider this event:  a beam of light leaves Earth in the year 2000.

Before I accelerate, this event occurs 10 light years away from me 10
years ago (since I am just now seeing this light beam). In other
words, my coordinates for this event are $\{10,-10\}$ (note: I've
re-oriented the x axis to face Earth, since that's the direction I
will be traveling, but the conundrum occurs regardless of x axis
orientation).

After I accelerate, I'm seeing the same light beam (roughly speaking),
but the Earth is now only 6 light years away. I thus conclude the
light beam left Earth 6 years ago (in my reference frame). Thus, my
coordinates for this event are $\{6,-6\}$.

I suspect there's something wrong with my setup above, but can't
figure out what it is.

Why am I suspicious? If the above is correct, the Lorentz transform
for $0.8 c$ should convert between the two coordinate systems, but it
doesn't.

Instead, it converts $\{10,-10\}$ to $\{30.,-30.\}$ (this is the same
answer as @WillO gets), which says that, in the new, accelerated,
frame, the light beam left Earth 30 light years away from my frame 30
years ago. Of course, I wasn't in this frame at the time: I only
entered the frame in the year 2010 at t=0.

Oddly enough, it turns out the Lorentz transform for $-\frac{8 c}{17}$
*does* convert $\{10,-10\}$ to $\{6,-6\}$, but I have no idea how that
velocity (a little less than $0.5 c$ and going in the opposite "wrong"
direction [ie, away from Earth]) enters the picture.

Changing our definition of t=0 doesn't appear to help either. The $0.8
c$ Lorentz transform of $\{10,u-10\}$ is $\left\{30-\frac{4
u}{3},\frac{5 u}{3}-30\right\}$. There is no value for $u$ which
yields $\{6,-6\}$.

Setting $u=18$ yields $\{6,0\}$ (which is interesting) giving us the
correct distance, and setting $u=\frac{72}{5}$ yields
$\left\{\frac{54}{5},-6\right\}$ giving us the time, but neither of
these yields $\{6,-6\}$

Again, I feel I've done something wrong in setting up the above.

On the one hand, I have two reference frames, and the Lorentz
transform should be able to convert between them, since it accounts
for time dilation, Lorentz contraction *and* simultaneity.

On the other hand, well, it doesn't seem to actually do that.

<section name="fargo">

<h2>The Fargo Fallacy</h2>

This section is in response to @WillO's and @hypnosifl's "driving to
Fargo" analogy.

[[image16.gif]]

@WillO states 

<blockquote>

I am driving north toward Fargo. I say "Fargo is straight ahead, and
always has been". Now I make a left and say "Fargo is to my right, and
always has been".

Do you really not understand that this is shorthand for "Fargo is in
the direction i now call right and always has been?" Or that my
previous reckoning of Fargo as straight ahead has now become
completely irrelevant? Or that if I continue to rely onthat [sic] reckoning,
I'm going to get lost?

</blockquote>

The statement **"Fargo is to my right, and always has been** is
fundamentally inaccurate and can not be justified as shorthand.

Suppose I'm in Aberdeen and want to know where I was two hours ago
(each arrow represents one hour). Using @WillO's logic, I must assume
that Fargo was always to my right, and I was thus in Green Bay two
hours ago.

In reality, my previous reckoning of Fargo *is* relevant. Here are
some legitimate statements I could make:

  - For one hour, I was traveling from St Louis to Minneapolis, and
  Fargo was (pretty much) straight ahead.

  - For one hour, I was traveling from Minneapolis to Aberdeen, and
  Fargo was (pretty much) to my right.

  - If someone else had been traveling the Minneapolis-Aberdeen path
  an hour before I got there, arrived at Minneapolis at the same time
  I did, and was traveling at the same constant speed as I am
  traveling, they would have been in Green Bay when I was in St Louis.

  - Another way to say it: one hour after starting out, I hopped on to
  a ghost train that is doomed to travel forward westward at constant
  speed. I hopped on the train at Minneapolis and it took me an hour
  to get to Aberdeen. I can thus conclude the train was in Green Bay
  one hour ago, when I was in St Louis.

Converting any of these statements to **Fargo is to my right, and
always has been** isn't "shorthand", it's simply false.

Fundamentally, the Fargo Fallacy confuses the history of an observer
and the history of a reference frame. The "ghost train" in my example
above is a reference frame: it always travels in the same direction at
the same speed. However, the observer (me) wasn't on the train before
it arrived at Minneapolis. In fact, it's possible that there was no
one at all on the train on its journey from Green Bay to Minneapolis.

Once we understand this difference, and note that reference frames can
exist without anyone in them, we can solve the problem. Ideally, we
could solve this problem without using unpopulated reference frames
(no ghost trains) at all. I'm checking to see if this may be possible,
more details if that pans out.

As @hypnosifl notes, **bringing "north" into it breaks the analogy
because "north" has some objective definition that doesn't depend on
our choice of coordinate system**. If we **did** have such a "north"
in relativity, everything would be a lot easier, because we wouldn't
have to rely on relative directions. Unforunately, the entire concept
of special relativity is that all frames are relative.

The Fargo Fallacy also appears in
http://physics.stackexchange.com/questions/210794: if two objects are
8 light years apart when at rest and approach each other, there is no
frame of reference in which they will ever be more than 8 light years
apart. However, one of the answers states:

<blockquote>
when the light signal was sent, I was not just 4.8 light years away; I
was 4.8 plus another (10.67 x .8) light years away --- a total of
about 13.33 light years.
</blockquote>

Once again, the confusion is between observers ("I") and reference
frames. It was the reference frame that was 13.33 light years away,
not the observer (who was never more than 8 light years away).

</section>




Grid[{
 {"Time","Earth distance","Earth Time","Light Travel Time","Earth Eyeball"},

 {0, "8 ly", 0, 8, -8},

 {1s, "4.8 ly", 3.2, 4.8, -1.6},

 {3y, "2.4 ly", 5, 2.4, 2.6}

 {6y, 0, 6.8, 0, 6.8}

 {end, 0, 10, 0, 10}
}

Someone moving away at 0.8c, standard sync

d(t) = 0.8*t

observed d(t) = t/1.8

f(t + .8*t) = .8t -> f(t) = t*.8/1.8

time(t) = 0.6*t

observed time(t) = t/3

t=10 actual time =6 distance = 8; at 18, I see 6

t=20 actual time =12; dsitance = 16; at 36, I see 12

f(t + .8*t) = .6*t -> f(1.8*t) = .6*t -> f(t) = t/3

d(t) = v*t

d(0) = 0

d(1) = v; seen at v+1, so d(v+1) = v

d(2) = 2*v, seen at 2+2v so d(2+2v) = 2v

d(3) = 3*v, seen at 3+3v so d(3+3v) = 3v

d(t) = tv/(1+v)

time(0) = 0

time(1) = gamma, so 1+v -> gamma

time(2) = 2*gamma, so 2+2v -> 2*gamma

time(t) = t*Sqrt[(1-v)/(1+v)]











I'm hoping to post a more detailed answer later, but thought I'd post
a summary just to stop the endless trail of comments.

In this problem, we're assuming the ship accelerates instantly and/or
that we can ignore the effects of acceleration.

In real life, ships can't accelerate instantly, and it turns out to be
messy in theory as well.

Instead, we'll have the ship accelerate from 0 to $0.8 c$ in 1
second. It will turn out this 1 second makes a profound difference.

**DISCLAIMER: I haven't done the math yet, so these numbers could be
off, potentially even WAY off. For now, please consider this a random
thought posted as an answer**

From the ship's point of view:

  - I start out on Planet X, 8 light years from Earth, at rest with
  respect to both the Earth and to Planet X.

  - I accelerate for 1 second and am now traveling $0.8 c$. I traveled
  a little bit during my acceleration, but not very much, since I was
  only accelerating for one second. Despite this, the Earth is now
  only 4.8 light years away, not 8.

  - I now travel the 4.8 light years in about 6 years (it's a little
  less because I crossed some of that distance while accelerating and
  will cross some when I decelerate in a moment).

  - I decelerate for 1 second so I am now stationary with respect to
  both the Earth and Planet X once again.

From the Earth's point of view:

  - The ship starts off on Planet X, 8 light years from us.

  - The ship then accelerates 












======== CUT HERE ===========

To avoid the problems of instant acceleration, let's assume the ship
(S) was already traveling at $0.8 c$ when it passed planet X, and
starts sending signals at that time (which the ship calls t=0).

As you note, from the ship's point of view, E (Earth) and X are 4.8
light years apart, and, since the ship is traveling $0.8 c$, the ship
will indeed fly past Earth in 6 years.

From E and X's viewpoints, E and X are 8 light years apart and the
ship will take 10 years to make the flight.

Remember that the Lorentz contraction only applies to the distance
between **two** objects in another reference frame. It does **not**
apply to the distance between you and an object in another reference
frame. I believe this is the crux of the fallacy.

So the Lorentz contraction does NOT apply to:

  - the distance from E to X as measured from either E or X (they're
  in the same inertial frame)

  - the distance from E to S as 

 the distance between E
and S (or the distance between S and X).

Time dilation, however, does still apply.

Let's look at the nth signal S sends out from S's perspective:

  - The signal is sent on day n ship time.

  - The signal is sent when I am $0.8 n$ light days from X (ship distance)

  - The signal is sent when I am $1728-0.8 n$ light days from Earth
  (I'm assuming 360 days/year for simplicity, so 4.8 light years =
  1728 light days).

  - Since I sent the signal on day n and it takes $1728-0.8 n$ days to
  get to Earth, Earth will see it $0.2 n+1728$ days from when I passed
  planet X (ship time).

Note that S sends out 2160 (number of days in 6 years) signals total.

The first signal arrives (in S's frame) on day 1728.

The last signal arrives (in S's frame) on day 2160, just as S passes Earth.

So, from S's perspective, Earth receives 2160 signals in 2160-1728 or
432 days, for a total of 5 signals/day.

1.6 years Earth time when first signal gotten?

Now, let's see how the Earth's nth-day outbound signal looks:

  - The signal is sent on day n Earth time.

  - The signal is sent when the ship is $0.8 n$ light days from X
  (Earth distance, since the ship is traveling at $0.8 c$ in Earth's
  reference frame as well).

  - The signal is sent when the ship is $2880-0.8 n$ light days from
  Earth (Earth distance). Note that this is different from how the
  ship measures position. Lorentz contraction applies for the ship
  since it's measuring the distance between X and Earth, two objects
  in the same inertial reference frame, but an inertial reference
  frame different from its own. Earth, however, is only looking at the
  distance to one object (the ship), so there is no Lorentz
  contraction.


Now, suppose I'm still in S's frame, but look at what Earth's clock
(which runs slower than my own) reads when each signal hits Earth.

relativityMatrix[.8].{n,0}




If my clock reads $0.2 n+1728$ days when my nth signal hits Earth,
Earth's clock must read $0.6 (0.2 n+1728)$ when the nth signal
hits. Simplifying, this is $0.12 n+1036.8$.

So, Earth sees my first (zeroth) signal 1036.8 days after it sees me
pass Planet X. It sees my 2160th and final signal 



TODO: GRAPH?

Plot[{1728-0.8*n, 1728+0.2*n}, {n,1,2160}, PlotRange -> All]



From S's perspective, S is sending out its nth signal on day n, when
it is $\frac{0.8 n}{360}$ light years from X and $8-\frac{0.8 n}{360}$
light years from E. In total, S sends out 

  - I am sending out 1 signal per day and moving at a constant
  velocity of $0.8 c$. 



TODO: diagram, planet X to the left

TODO: 360/year disclaimer





IGNORE BELOW, QUESTION IS CLOSED ANYWAY:



Concrete example: ships A and B are at rest, 20,000 light seconds
apart, with their clocks synchronized. At precisely noon by both
clocks, they immediately start traveling towards each other at .995c
until they meet in the middle (point C), at which point they abruptly
stop.

Before any acceleration takes place, we have the following (declaring
the line from A to B to be the direction of the positive x axis):

  - Ship A: point C is at x=10000 and point B is at x=20000


(*

Subject: Rapid (ac/de)celeration in relativity does what to inertial clocks?

Summary: if I accelerate to $0.8 c$ in 1 second, how much time passes
for observers in my starting inertial reference frame?

This seems like a simple question that has probably been answered, but
I couldn't find a simple answer for what appears to be a simple question:

I start 8 light years from Earth, at rest with respect to Earth, and
observe Earth's time is t=0. Of course, technically, it will take me
8 years to know this (speed of light travel time), but I believe
special relativity is OK with my saying "it's currently t=0 on Earth",
since I'm in the same frame as Earth.

Keeping an eye on Earth's clock, I accelerate to $0.8 c$ in 1
second. Because I'm accelerating, I know Earth's clock will go faster
than mine. The question is: how much faster, and where will they end
up after I've finished my one second of acceleration to $0.8 c$?

At $0.8 c$ the distance to Earth is now 4.8 light years (minus the
little bit I traveled during acceleration). Earth's clock now runs
slower than mine by time dilation. So, when 6 of my years have passed,
fewer than 6 years have passed on Earth's clock.

As I get close to Earth, I "decelerate" to the Earth's reference frame
so that I will be at rest when I actually arrive at Earth. Of course,
deceleration is just acceleration in a different direction, so, once
again, Earth's clocks run faster than mine.

And, once again, the question is: in that 1 second of deceleration,
how much time elapsed on Earth's clocks?

What vexes me about this problem: 

  - In the 6 years I was traveling at $0.8 c$, Earth's clocks ticked
  off only 3.6 years by time dilation.

  - By the time I arrive at Earth, Earth's clocks must have ticked off
  10 years, since they say me traveling at 0.8c for (most of the) 8
  light years.

  - The only way I can reconcile these numbers (10 years minus 3.6
  years, or 6.4 years) is that my 1 second of acceleration and
  deceleration each took 3.2 Earth years (about 10^8 seconds).

  - This seems high, and I can't get the numbers/formulas to yield
  this, but...

  - On the other hand, it seems somewhat reasonable that the amount of
  time that passes depends only on my final velocity ($0.8 c$) and not
  how fast I reached that velocity.

Note that I don't think there's a simultaneity issue here, since I
start and end in Earth's reference frame.

*)

4.8 ly in 6 years my time = 3.6 years earth time

general case of above:

earth clock starts at 0, ends at 1 (as it must)

ignoring acceleration, I travel distance gamma (eg 0.6) in time
v/gamma (eg, 0.6/0.8); earth's clock runs slower so gamma^2/v has
passed on earth

thus: (t= total accel, not each)

Solve[t + (Sqrt[1-v^2])^2/v == 1,t]

1+v-1/v





1/v = time passes on Earth for my journey

Sqrt[1-v^2] = time I see passing on earth for most of my journey (dilation)

Sqrt[1-v^2] = distance to earth for most of my journey

Sqrt[1-v^2]/v = how long it takes me (my frame) to get to earth

example for .99 c?

takes me (1/7)/.99 years to get there, I watch earth clock tick off
(1/49)/.99 years

Earth clock must read 1 at end so..




WRONG: below is total time that passed during my two accelerations

WRONG: Solve[t + Sqrt[1-v^2] == 1/v,t]

WRONG: t -> v^(-1) - Sqrt[1 - v^2]

WRONG: t[v_] = v^(-1) - Sqrt[1 - v^2] 

(* TODO: need to figure out a sign convention and stick with it *)

translate[v_,x_,t_] = {x-v*t, t-v*x}/Sqrt[1-v^2]

earth now 6 ly away, still seeing it at -10 (ie 2000) so assign it t=-6

so if earth is my direction of travel (x,t)

10,-10 ==> 6,-6

-8/17

Solve[translate[v,10,-10] == {6,-4}]
Solve[translate[v,10,-10] == {6,-6}]

re-tooled:

earth in 2000 is 10, 0 [because I move towards it]
me in 2010 is 0, 10 [because I'm 10 years ahead]

event Earth clock reads 2000: 10, 0

at .8c, 

from constant 0.8c frame: I see 2000 when I'm 6ly away, so I say Earth
time is 2006

my space time coords for earth: (6, -4) when they are (0,0) for me

earth clock reads 2010: 10, 0

passing observer syncs







translating into 0.8c

should be: earth is 6, 

earth is: {16.6667, -13.3333} 16 ly ahead 13.3 years ago
old me is: {-13.3333, 16.6667} ... not relevant?



(*

EDIT (to answer @WillO's second answer
http://physics.stackexchange.com/a/246655/854):

  - There's nothing wrong with using diagrams, provided we understand
  the math behind the diagrams. If there's a disagreement about values
  (as there is here), we should settle the disagreement using hard
  (meaning solid, not difficult) math. I appreciate your putting your
  answer in mathematical terms so we can do this.

  - I've always seen the Lorentz transform written as $\gamma (x-t v)$
  and $\gamma (t-v x)$ with negative signs, and never with positive
  signs as you wrote it. It would be nice to see a reference that uses
  positive signs, but I'm actually OK with this since it depends on
  the sign of the velocity and how you orient your x axes.

  - I believe our entire disagreement in this question and others
  hinges on these sign changes. Your transformations (for v = 0.8 and
  rationalizing to avoid decimals) is:

$x'=(x+tv)/\sqrt{1-v^2} \to \frac{1}{3} (5 x +4 t)$

$t'=(t+xv)/\sqrt{1-v^2} \to  \frac{1}{3} (5 t+4 x)$

whereas I believe the correct transformations are:

$x'=(x-tv)/\sqrt{1-v^2} \to \frac{1}{3} (5 x-4 t)$

$t'=(t-xv)/\sqrt{1-v^2} \to \frac{1}{3} (5 t-4 x)$

  - Why I believe this: The ship first sees Earth at the year 2000 and arrive
  at the year 2022.5. I claim we should never see an intermediate year
  outside these values (your answers are 10 years earlier, but the
  same principle applies). Note that @john-rennie's answer also
  mentions a 22.5 year time frame.

  - The ship starts out 10 light years away from Earth and end up 0 light
  years away from Earth. I claim we should never see an intermediate
  distance of more than 10 light years.

  - With your sign usage, both of the above occur. You have both x and
  t at -30 at one point in your answer, meaning your answer spans 30
  years time and 30 light years distance.

  - Let's see what happens when we use the other sign convention.

  - First, let me re-note the events (correcting the 10-year glitch),
  and add an event E (I think you might've meant for Event D to be
  when the ship lands on Earth, which 2022.5, not 2018, but I'll leave
  it as is for now and just add an extra event):

    - Event A: The spaceship suddenly accelerates to earth, with its
  clock saying 2010.

    - Event B: A clock on earth says 2000

    - Event C: A clock on earth says 2010.

    - Event D: A clock on earth says 2018.

    - Event E: The ship lands, and a clock on Earth says 2022.5.

  - Event A occurs at x=0, t=0 ship frame. We agree that no matrix can
  transform this to anything other than x=0, t=0, so it always remains
  x=0, t=0 in any frame.

  - Event B occurs at x=-10 and t=-10 in Frame I, which translates to
  x=-3.33 and t=-3.33 meaning the event occurred 3.33 years ago and
  3.33 light years away. 



TODO: other problems

*)

delta = 0.07;
g2 = Graphics[{
 Arrowheads[{.02}],
 PointSize[.02],
 Arrow[{{0,0},{0,1}}],
 Arrow[{{0,1},{-1,1}}],
 Point[{-0.5,1.5}],
 Point[{0,0}],
 Point[{0,1}],
 Point[{-1,1}],
 Text[Style["Minneapolis (M)", FontSize->25], {0,1+delta}],
 Text[Style["St Louis (S)", FontSize->25], {3.5*delta,0}],
 Text[Style["Aberdeen (A)", FontSize->25], {-1,1+delta}],
 Text[Style["Fargo (F)", FontSize->25], {-0.5,1.5+delta}],
 RGBColor[{1,0,0}],
 Dashed,
 Arrow[{{0,1},{1,1}}],
 Point[{1,1}],
 Text[Style["Green Bay (G)", FontSize->25], {1,1+delta}],
}]
showit

