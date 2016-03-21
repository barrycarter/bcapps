(*

http://physics.stackexchange.com/questions/210794/

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


