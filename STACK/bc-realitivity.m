(*

http://physics.stackexchange.com/questions/210794/

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
frame.

So the Lorentz contraction does not apply to the distance between E
and S (or the distance between S and X).

Time dilation, however, does still apply.

Let's look at the nth signal S sends out from S's perspective:

  - The signal is sent on day n.

  - The signal is sent when I am $0.8 n$ light days from X.

  - The signal is sent when I am $1728-0.8 n$ light days from Earth
  (I'm assuming 360 days/year for simplicity, so 4.8 light years =
  1728 light days).

  - Since I sent the signal on day n and it takes $1728-0.8 n$ days to
  get to Earth, Earth will see it $0.2 n+1728$ days from when I passed
  planet X.

Note that S sends out 2160 (number of days in 6 years) signals total.

The first signal arrives (in S's frame) on day 1728.

The last signal arrives (in S's frame) on day 2160, just as S passes Earth.

So, from S's perspective, Earth receives 2160 signals in 2160-1728 or
432 days, for a total of 5 signals/day.

Now, suppose I'm still in S's frame, but look at what Earth's clock
(which runs slower than my own) reads when my signal hits Earth.

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


