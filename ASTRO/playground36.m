(*

Generalized version of the projectile-on-planet question in 3D
<h>(just like Nature Trail To Hell)</h>

TODO: subscript v0?

TODO: compute highest elevation reached!

NOTE: I intentionally didn't mention phi in the statement of the
problem as a way of noting that solutions sometimes depend on extra
parameters.

Subject: Trajectory of projectile launched from planet's surface

Say, Barry, can you abuse this site's "answer your own question"
feature to provide insight into this oft-asked question (in various
different forms):

You launch a projectile upwards at velocity v0 on a airless spherical
planet with a radius of r, a rotation period of p, and a surface
acceleration of g.

1. Set up differential equations to find how far from the launch point
the projectile will land? You may ignore the planet's revolution
around its primary (if any), in your calculations.

2. Numerically solve these differential equations in some interesting cases.

Ways to make this problem harder:

  - Allow for directional launches, not just straight up
  launches. This is probably the easiest and most obvious improvement
  to the question.

  - Allow for ellipsoid planets, where the radius varies with
  latitude, and the surface normal ("up" direction) is not exactly
  opposite to the pull of gravity ("down" direction)

Answer:

Without loss of generality, we can draw our axes so the projectile's
initial position is in the xz plane.

Allowing `phi` to be the launch site's latitude, the projectile's
initial position is:

$\{r \cos (\phi ),0,r \sin (\phi )\}$

The launch site completes a rotation in time p, so its position
at time t is:

$
   \left\{r \cos (\phi ) \cos \left(\frac{2 \pi  t}{p}\right),r \cos (\phi )
    \sin \left(\frac{2 \pi  t}{p}\right),r \sin (\phi )\right\}
$

Differentiating, we have the site's velocity as:

$   
   \left\{-\frac{2 \pi  r \cos (\phi ) \sin \left(\frac{2 \pi 
    t}{p}\right)}{p},\frac{2 \pi  r \cos (\phi ) \cos \left(\frac{2 \pi 
    t}{p}\right)}{p},0\right\}
$

In particular, the velocity at time 0 is:

$\left\{0,\frac{2 \pi  r \cos (\phi )}{p},0\right\}$

Thus, the projectile's starting velocity will be `v0` plus the
velocity imparted from the launch site, as above.

Excluding the site velocity for a moment, the launch will be away from
the center of the planet, and thus in the direction:

$\{\cos (\phi ),0,\sin (\phi )\}$

Since this is a unit vector, the launch velocity (excluding the launch site's velocity for the moment) is:

$\{\text{v0} \cos (\phi ),0,\text{v0} \sin (\phi )\}$

Adding the launch site's initial velocity back in, we have the
projectile's initial velocity as:

$
   \left\{\text{v0} \cos (\phi ),\frac{2 \pi  r \cos (\phi )}{p},\text{v0} \sin
    (\phi )\right\}
$

To simplify, we write separate equations for the x, y, and z
components of the projectile. From the above, we have:

$x(0)=r \cos (\phi )$

$y(0)=0$

$z(0)=r \sin (\phi )$

$x'(0)=\text{v0} \cos (\phi )$

$y'(0)=\cos (\phi )$

$z'(0)=\text{v0} \sin (\phi )$

Acceleration acts towards the center of the planet, so the direction
of acceleration at time t is:

$\{-x(t),-y(t),-z(t)\}$

Converting this to a unit vector:

$
\left\{-\frac{x(t)}{\sqrt{x(t)^2+y(t)^2+z(t)^2}},-\frac{y(t)}{\sqrt{x(t)^2+y(
t)^2+z(t)^2}},-\frac{z(t)}{\sqrt{x(t)^2+y(t)^2+z(t)^2}}\right\}
$

The acceleration due to gravity is g at the surface, which is distance
r from the planet's center, and is thus g*(r/d)^2 at distance d from the
planet (provided that d > r, which it is in our problem). Using the
distance formula, the magnitude of gravity at time t is:

$\frac{g r^2}{x^2+y^2+z^2}$

Thus, the vector of acceleration due to gravity is:

$
   \left\{-\frac{g r^2 x(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{g
    r^2 y(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{g r^2
    z(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}}\right\}
$

Since we'll be solving these equations numerically, we need to limit
the values of t. We obviously want to start at t=0, but where to end? 

Roughly speaking, if an object has initial velocity v0 and accelerates
at g (in the negative direction), it will reach 0 velocity at time
v0/g, and will return to its initial position at time
2*v0/g. Therefore, computing until t=4*v0/g should be sufficient.

(of course, this entire problem is about refining the "roughly
speaking" paragraph above)

Note that simply finding the approximate function for the projectile's
position is only step 1. We then need to find when the projectile
lands back on the planet: in other words, when it's distance from the
center is once again r.

Mathematica code follows.

*)

(* TODO: I am not returning functions properly here *)

(* 

This module returns (in this order):

s[t]: the xyz position of the projectile at time t, 0 < t < root

site[t]: the position of the launch site at time t, just as a reminder
that the planet is rotating.

root: The time at which the projectile lands

dlat: The projectile's change in latitude (radians)

dlon: The projectile's change in longitude (radians)

nsdist: north/south distance traveled by projectile

ewdist: east/west distance traveled by projectile

tdist: total distance traveled by projectile (on surface of sphere)

Some helper functions used below are found in:

https://github.com/barrycarter/bcapps/blob/master/bclib.m

*)

launch[r_, p_, g_, phi_, v0_] := launch[r,p,g,phi,v0] = Module[
 {s, site, root, dlat, dlon, garb, nsdist, ewdist, tdist, maxtime, maxheight},

s[t_] = {x[t], y[t], z[t]} /. NDSolve[{
 x[0] == r*Cos[phi], y[0] == 0, z[0] == r*Sin[phi],
 x'[0] == v0*Cos[phi], y'[0] == 2*Pi*r*Cos[phi]/p, z'[0] == v0*Sin[phi],
 x''[t] == -g*((r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 y''[t] == -g*((r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 z''[t] == -g*((r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
}, {x[t],y[t],z[t]}, {t,0,4*v0/g}][[1]];

maxtime = FindMaximum[Norm[s[t]]-r,{t,v0/g}];
maxheight = maxtime[[2,1,2]];
maxtime = maxtime[[1]];

site[t_] = r*{Cos[2*Pi*t/p]*Cos[phi], Sin[2*Pi*t/p]*Cos[phi], Sin[phi]};
root = t /. FindRoot[Norm[s[t]]-Norm[s[0]], {t, 2*v0/g}];
{dlon,dlat,garb} = xyz2sph[s[root]]-xyz2sph[site[root]];
{nsdist, ewdist} = {dlat*r, Cos[phi+dlat]*dlon*r};
tdist = 2*r*ArcSin[Norm[s[root]-site[root]]/2/r];
Return[{s[t], site[t], root, dlat, dlon, nsdist, ewdist, tdist, maxtime,
 maxheight}];
];

(*

Now, let's use this code to answer some existing questions:

  - http://physics.stackexchange.com/questions/48287/

To jump for 1 second, I need an initial velocity of 4.9m/s, so we compute

`launch[6371000, 86400, 9.8, 0*Degree, 4.9]`

The jump takes 1.003 seconds (3 milliseconds longer than expected),
and I land 116 micrometers west of my original position (no change in
my north/south position, since I started at the equator).

To check @NowIGetToLearnWhatAHe's answer: jumping 1m on Earth requires
an initial velocity of 4.43 m/s, so we run

`launch[6371000, 86400, 9.8, 45*Degree, 4.43]`

The jump lasts 0.9053 seconds, and I land 6.9mm south and 62.5
micrometers west of where I started, verifying
@NowIGetToLearnWhatAHe's answers up to roundoff errors.

This effectively also answers
http://physics.stackexchange.com/questions/80090/ if we assume jumping
1m up and hovering 1 second is close enough to the cases above.

It unfortunately doesn't answer
http://physics.stackexchange.com/questions/89276 Even though the
train's ceiling is probably no more than 1m higher than the thrower's
hand, the 600mph velocity of the train might be sufficient to affect
the equation.

<added>

  - https://physics.stackexchange.com/questions/214008

Let's solve the problem at 45 degrees north latitude, where the
bullet's motion is greatest:

`launch[6371000, 86400, 9.8, 45*Degree, 1200]`

The bullet will land 249.148 seconds later, 507m west and 1260m south
of its original position, reaching a maximum height of 74455m at the
halfway point in its journey (124.574s)

</added>

  - http://physics.stackexchange.com/questions/226882 actually asks
  about air resistance, so my answer explicitly doesn't apply, but
  let's run the numbers anyway. I did

`launch[3389500, 88643, 3.711, 0*Degree, v0]`

with various v0's to see how fast the coin must be flipped to miss the
flipper's hand (assuming hand radius of 12cm).

At the Martian equator, you would have to flip a coin at 25.9m/s for
it to miss your hand on the way down. This is equivalent to flipping a
coin at 9.8m/s (about 22 miles per hour) on Earth, so, yes, you could
concievably flip a coin fast enough that it would miss your hand on
the way down.

At 45 degrees latitude on Mars, we have:

`launch[3389500, 88643, 3.711, 45*Degree, v0]`

and it turns out an initial velocity of 10m/s (equivalent to 3.76m/s
or 8.5 mph on Earth) would suffice to have the coin miss your hand.

  - Other questions this helps answers (which don't have numerical
  quantities in the question):

    - http://physics.stackexchange.com/questions/166853
    - http://physics.stackexchange.com/questions/174385
    - http://physics.stackexchange.com/questions/137191
    - http://physics.stackexchange.com/questions/14993
    - http://physics.stackexchange.com/questions/126469
    - http://physics.stackexchange.com/questions/148008
    - http://physics.stackexchange.com/questions/7479
    - http://physics.stackexchange.com/questions/20424
    - http://physics.stackexchange.com/questions/136351
    - https://physics.stackexchange.com/questions/12766

  - It doesn't answer the following questions, but may have enough
  relevance that they're worth linking to this answer:

    - http://physics.stackexchange.com/questions/16390
    - http://physics.stackexchange.com/questions/133801
    - https://physics.stackexchange.com/questions/214614

We can also use this code to get an idea of how much accounting for
gravity and rotation affects trajectory at different initial
velocities.

For the below, I use:

`launch[6371000, 86400, 10, 45*Degree, v0]`

estimating Earth's surface gravity at 10m/s^2 for convenience.

  - Landing time (in seconds):

[[landtime.jpg]]

The red line represents t/5, the landing time we'd expect if the Earth
didn't rotate and gravity didn't decrease with distance.

The blue line represents actual landing time.

  - Landing spot how far west of launch site (in meters):

[[landwest.jpg]]

  - Landing spot how far south of launch site (in meters):

[[landsouth.jpg]]

  - The total distance between landing spot and launch site mirrors
  the graph above, since most of the motion is north-south.

  - The apparent surface velocity of the projectile: ie, the distance
  traveled on the surface divided by the landing time (in meters/second):

[[landvel.jpg]]

Notes:

  - Mathematica can't solve the differential equation when the initial
  velocity exceeds 7000m/s, possibly since that's fairly close to the
  velocity required to achieve Earth orbit (though not enough to
  escape the Earth's gravitational pull entirely, which would require
  a velocity of 11186 m/s)

  - Longer-term, I'd like to work out first-order approximations to
  the quantities above.
