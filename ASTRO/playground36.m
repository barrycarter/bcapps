(*

Generalized version of the projectile-on-planet question in 3D
<h>(just like Nature Trail To Hell)</h>

TODO: allow for angular launches (not straight up?)

Question:

You launch a projectile upwards at velocity v0 on a spherical planet
with a surface acceleration of g0. How far from the launch point will
the projectile land? Solve the problem in two ways:

  - 1. Assume the projectile remains close enough to the planets surface
  that acceleration is constant in magnitude.

  - 2. Allow for the change in acceleration magnitude as the
  projectile gets further away from the planet's center.

In both cases, you may ignore the planet's revolution around its primary.

Answer:

Without loss of generality:

  - We can measure distances in planetary radii, so the planet's
  radius is 1 by definition.

  - We can measure times in planetary rotations ("days"), so the
  planet's rotation period is 1 by definition.

  - We can draw our axes so the projectile's initial position is in
  the xz plane.

Solution:

TODO: move the mathematica stuff around a bit

phi = "\[Phi]"

Allowing $\Phi$ to be the launch site's latitude, the projectile's
initial position is:

{Cos[phi], 0, Sin[phi]}

The launch site completes a rotation in 1 time unit, so its position
at time t is:

site[t] = {Cos[phi]*Cos[t], Cos[phi]*Sin[t], Sin[phi]}

Differentiating, we have the site's velocity as:

site'[t] = {-Cos[phi]*Sin[t], Cos[phi]*Cos[t], 0}

In particular:

site'[0] = {0, Cos[phi], 0}

Thus, the projectile's starting velocity will be `v0` plus the
velocity imparted from the launch site, as above.

Excluding that component, the launch will be away from the center of
the planet, and thus in the direction:

{Cos[phi], 0, Sin[phi]}

Since this is a unit vector, the launch velocity (excluding the launch site's velocity for the moment) is:

{v0*Cos[phi], 0, v0*Sin[phi]}

Adding the launch site's initial velocity, we have the projectile's
initial velocity as:

{v0*Cos[phi], Cos[phi], v0*Sin[phi]}

To simplify, we break the projectile's position into x, y, and z
components. From the above, we have:

x[0] = Cos[phi]
y[0] = 0
z[0] = Sin[phi]

x'[0] = v0*Cos[phi]
y'[0] = Cos[phi]
z'[0] = v0*Sin[phi]

Acceleration acts towards the center of the planet, so the direction
of acceleration at time t is:

{-x[t],-y[t],-z[t]}

Converting this to a unit vector, we briefly allow:

r[t] = Sqrt[x[t]^2+y[t]^2+z[t]^2]

Thus, the unit vector is:

{-x[t]/r[t], -y[t]/r[t], -z[t]/r[t]}

To solve the first part of the problem, we assume the magnitude of
acceleration is g0, so the acceleration vector is:

{-g0*x[t]/r[t], -g0*y[t]/r[t], -g0*z[t]/r[t]}

TODO: TeX check

*)

phi = "\[Phi]" 
r[x_,y_,z_] = Sqrt[x^2+y^2+z^2];

assums = {
 Element[x[t],Reals],
 Element[y[t],Reals],
 Element[z[t],Reals]
}

eqns = {
x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi],
x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi],
x''[t] == -g0*x[t]/r[x[t],y[t],z[t]],
y''[t] == -g0*y[t]/r[x[t],y[t],z[t]],
z''[t] == -g0*z[t]/r[x[t],y[t],z[t]]
};

eqnsfake = {
x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi],
x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi],
x''[t] == 0,
y''[t] == 0,
z''[t] == 0
}

DSolve[eqns, {x[t],y[t],z[t]}, t]

DSolve[eqns, {x,y,z}, t]









