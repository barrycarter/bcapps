(*

http://physics.stackexchange.com/questions/244315/

Instead, let's assume the train is uniformly accelerated for one second.

== CUT HERE ==

This isn't an answer, but is too long for a comment.

To answer @anna-v's concerns:

I think the problem here is that there's no such thing as instant
acceleration, and you can derive contradictory results by assuming
there is.

Instead, let's break up a single instantaneous acceleration into two
smaller instantaneous accelerations. This is still incorrect, of
course, but gives an idea of what happens as we apply smaller
accelerations more frequently, as we would do in the real-life
limiting case of applying continuous non-instant acceleration over a
period of time.

Suppose two points $A$ and $B$ are already moving at $0.5 c$ in the
track reference frame, and are some non-zero distance $x$ apart in
that frame. Since we're debating the value of $x$, I'm not assigning
it a fixed number, just pointing out that it's greater than 0.

In the track frame, you now accelerate/push both points at the same
time. So, the time and distance between the two pushes in the track
frame is:

  - Time difference: 0 (you pushed them both at the same time)

  - Distance difference: x (they were some distance apart when you did
  this, but we don't know what this distance was)

We now use the matrix for $0.5 c$ to translate this vector $\{x,0\}$ to
point A's reference frame:

$
\left(
                  \begin{array}{cc}
                   \frac{1}{\sqrt{1-v^2}} & \frac{v}{\sqrt{1-v^2}} \\
                   \frac{v}{\sqrt{1-v^2}} & \frac{1}{\sqrt{1-v^2}} \\
                  \end{array}
                  \right).\{x,0\}
$

The result (for $v=0.5 c$) is: 
$\left\{\frac{2x}{\sqrt{3}},\frac{x}{\sqrt{3}}\right\}$

Note that the time difference is non-zero, since $x$ is non-zero.

In other words, as far as the points are concerned, they are being
pushed at different times, one more frequently than the other.

Thus, in their own reference frame, their distance is not constant.

Of course, if the points were coupled by the electromagnetic force (as
the the two ends of a train car would be), that force might be
sufficient to hold the points at an equal distance, at least for a
while.

Why this contradicts our relativistic "intuition":

A meter stick is smaller when it's moving at $0.5 c$ than when it's
not moving at all. Thus, if we take a meter stick and instantly change
its speed to $0.5 c$, we would expect it to shrink.

However, we can't really change its speed instantly. We have two
options for realistic continuous acceleration:

  - Have the meter stick accelerate at a fixed rate in its own
  reference frame. This is the normal definition of constant
  acceleration and yields the expected result of the meter stick
  shrinking.

  - Have the meter stick accelerate at a fixed rate in its original
  reference frame (ie, the "fixed" frame). This is what we're doing
  here, and it yields very different results.

http://physics.stackexchange.com/questions/240342

I would argue the phrase "instantaneous acceleration" is ambigious
since it could mean either of the above. I would suggest one of the
following:

  - Acceleration over time where the object's speed in its own
  reference frame increases uniformly. This is the "standard"
  definition of uniform acceleration, and an object can theoretically
  accelerate indefinitely by this definition.

  - Acceleration over time where the object's speed in a "fixed"
  reference frame increases uniformly. This is the definition being
  used here. In this case, the object must stop accelerating at some
  point since it's velocity can never exceed 'c'.
