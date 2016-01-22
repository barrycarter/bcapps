(*

TODO: spell check

Barry, could you abuse this site's "answer your own question" feature
to answer the following question:

Two trains are approaching each either at high velocity but are still
quite far apart.

I throw a tennis ball at one of the trains so that it bounces off
(perfectly elastic collision), reverses direction, and then (some time
later) hits the train going the other direction, bounces off
elastically, and repeats the process indefinitely.

Ignoring air resistance, gravity, friction, etc, would this tennis
ball eventually be going arbitrarily fast as suggested by the comments
in: https://astronomy.stackexchange.com/questions/13302/

[ANSWER BELOW]

Summary: Yes, if the trains have sufficient mass (or can restore their
velocity after being struck by the tennis ball), the tennis ball can
go arbitrarily fast.

If an object with mass `m1` and velocity `v1` collides elastically
with an object of mass `m2` and velocity `v2`, both kinectic energy
and momentum are conserved.

If `u1` and `u2` are the post-collision velocities of `m1` and `m2`
respectively, we have:

$
   \text{m1} \text{v1}+\text{m2} \text{v2}=\text{m1} \text{u1}+\text{m2}
    \text{u2}
$

by conservation of momentum, and:

$
   \frac{\text{m1} \text{v1}^2}{2}+\frac{\text{m2}
    \text{v2}^2}{2}=\frac{\text{m1} \text{u1}^2}{2}+\frac{\text{m2}
    \text{u2}^2}{2}
$

by conservation of kinetic energy.

There are only two solutions to these simultaneous equations. One is
the initial conditions, and the other is:

$
   \left\{\left\{\text{u1}\to \frac{\text{m1} \text{v1}-\text{m2} \text{v1}+2
    \text{m2} \text{v2}}{\text{m1}+\text{m2}},\text{u2}\to \frac{2 \text{m1}
    \text{v1}-\text{m1} \text{v2}+\text{m2}
    \text{v2}}{\text{m1}+\text{m2}}\right\}\right\}
$

Since we expect `m1` (the mass of the tennis ball) to be small
compared to `m2` (the mass of the train), let's set `r=m1/m2` (which
we expect to be a small number) in the solution:

$
   \left\{\left\{\text{u1}\to \frac{\text{m2} r \text{v1}-\text{m2} \text{v1}+2
   \text{m2} \text{v2}}{\text{m2} r+\text{m2}},\text{u2}\to \frac{2 \text{m2} r
    \text{v1}-\text{m2} r \text{v2}+\text{m2} \text{v2}}{\text{m2}
    r+\text{m2}}\right\}\right\}
$

If we subtract these from the original velocities, we have:

$
   \left\{-\frac{2 (\text{v1}-\text{v2})}{r+1},\frac{2 r
    (\text{v1}-\text{v2})}{r+1}\right\}
$


When `r` is small, the change in the ball's speed is approximately $-2
(\text{v1}-\text{v2})$ and the change in the train's speed is
approximately 0.

If we throw the ball at 30 km/hr, it's velocity is -30 km/hr, since
we're throwing towards the train. If the train's velocity is +50
km/hr, the ball's change in velocity is `-2*(-30-50)` or 160
km/hr. Added to its original velocity of -30 km/hr, the ball's final
velocity if 130 km/hr.

This is consistent with https://en.wikipedia.org/wiki/Gravity_assist:

<blockquote>

A close terrestrial analogy is provided by a tennis ball bouncing off
the front of a moving train. Imagine standing on a train platform, and
throwing a ball at 30 km/h toward a train approaching at 50 km/h. The
driver of the train sees the ball approaching at 80 km/h and then
departing at 80 km/h after the ball bounces elastically off the front
of the train. Because of the train's motion, however, that departure
is at 130 km/h relative to the train platform; the ball has added
twice the train's velocity to its own.

</blockquote>
 
Now, what happens when the ball collides with the train coming the
other way? We'll give this train mass `m3` (which will be identical to
`m2` in our case) and `v3` (which will start out being `-v2` but will
change).








Elastic collisions and trains

*)

(* If an object with mass m1 and velocity v1 collides elastically with
an object of mass m2 and velocity v2, what are the velocities of the
two objects (u1 and u2) after the collision *)

colspeed[m1_,m2_,v1_,v2_] = {u1,u2} /. Solve[{
 m1*v1 + m2*v2 == m1*u1 + m2*u2,
 m1*v1^2/2 + m2*v2^2/2 == m1*u1^2/2 + m2*u2^2/2,
 u1 != v1, u2 != v2
}, {u1,u2}][[1]]

(* Our case: mass m1 and velocity v1 collides elastically with one
object of mass m2 at v2 and then another with mass m3 and velocity
v3; final velocities for all three objects *)

colspeed[m1,m2,v1,v2]

colspeed[m1, m3, colspeed[m1,m2,v1,v2][[1]], v3]

bouncespeed[m1_, m2_, m3_, v1_, v2_, v3_] = {

((m1 - m3)*(m1*v1 - m2*v1 + 2*m2*v2) + 2*(m1 + m2)*m3*v3)/((m1 + m2)*(m1 + m3))
,

(2*m1*v1 - m1*v2 + m2*v2)/(m1 + m2),

((2*m1*(m1*v1 - m2*v1 + 2*m2*v2))/(m1 + m2) - m1*v3 + m3*v3)/(m1 + m3)

};

(* sanity checking *)

bouncespeed[1, 1000, 1000, -10, 50, 50]

(* iteration *)

bs[{m1_, m2_, m3_, v1_, v2_, v3_}] = 
 Flatten[{m1, m2, m3, bouncespeed[m1, m2, m3, v1, v2, v3]}];

iter[0] = {m1,m2,m3,v1,v2,v3};

iter[n_] := iter[n] = bs[iter[n-1]];

conds = {m1 -> 1., m2 -> 1000., m3 -> 1000., v1 -> -10., v2 -> 50., v3 -> -50.}

iter[1] /. conds

(* specific case iteration *)

spec[0] = {1., 1000., 1000., -10., 50., -50.}

spec[n_] := spec[n] = bs[spec[n-1]]












