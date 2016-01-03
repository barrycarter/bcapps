(*

Generalized version of the projectile-on-planet question in 3D
<h>(just like Nature Trail To Hell)</h>

TODO: allow for angular launches (not straight up?)

TODO: subscript v0?

NOTE: I intentionally didn't mention phi in the statement of the
problem as a way of noting that solutions sometimes depend on extra
parameters.

Question:

You launch a projectile upwards at velocity v0 on a airless spherical
planet with a radius of r, a rotation period of p, and a surface
acceleration of g.

1. Set up differential equations to find how far from the launch point
the projectile will land? You may ignore the planet's revolution
around its primary (if any), in your calculations.

2. Numerically solve these differential equations in some interesting cases.

Answer:

Without loss of generality, we can draw our axes so the projectile's
initial position is in the xz plane.

Solution:

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
r from the planet's center, and is thus (r/d)^2 at distance d from the
planet (provided that d > r, which it is in our problem). Using the
distance formula, the magnitude of gravity at time t is:

$\frac{r^2}{x(t)^2+y(t)^2+z(t)^2}$

Thus, the vector of acceleration due to gravity is:

$
   \left\{-\frac{r^2 x(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{r^2
    y(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{r^2
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

orbit[r_, p_, g_, phi_] := NDSolve[{
 x[0] == r*Cos[phi], y[0] == 0, z[0] == r*Sin[phi],
 x'[0] == v0*Cos[phi], y'[0] == 2*Pi*r*Cos[phi]/p, z'[0] == v0*Sin[phi],
 x''[t] == -((r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 y''[t] == -((r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 z''[t] == -((r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
}, {x[t],y[t],z[t]}, {t,0,4*v0/g}]
 

phi = "\[Phi]" 
r[x_,y_,z_] = Sqrt[x^2+y^2+z^2];

assums = {
 Element[x[t],Reals],
 Element[y[t],Reals],
 Element[z[t],Reals]
}

(* break equations into position, velocity and acceleration *)

eqn0 = {x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi]};
eqn1 = {x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi]};
eqn2 = {
x''[t] == -g0*x[t]/r[x[t],y[t],z[t]],
y''[t] == -g0*y[t]/r[x[t],y[t],z[t]],
z''[t] == -g0*z[t]/r[x[t],y[t],z[t]]
};

DSolve[{eqn2}, {x[t],y[t],z[t]}, t]

NDSolve[{eqn0,eqn1,eqn2}, {x[t],y[t],z[t]}, t]

orbit[g0_, phi_, v0_] :=
 NDSolve[{
x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi],
x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi],
x''[t] == -g0*x[t]/Norm[{x[t],y[t],z[t]}],
y''[t] == -g0*y[t]/Norm[{x[t],y[t],z[t]}],
z''[t] == -g0*z[t]/Norm[{x[t],y[t],z[t]}]
}, {x[t],y[t],z[t]}, {t,0,10}];

orbit2[g0_, phi_, v0_] :=
 NDSolve[{
x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi],
x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi],
x''[t] == -g0*x[t]/Norm[{x[t],y[t],z[t]}]^3,
y''[t] == -g0*y[t]/Norm[{x[t],y[t],z[t]}]^3,
z''[t] == -g0*z[t]/Norm[{x[t],y[t],z[t]}]^3
}, {x[t],y[t],z[t]}, {t,0,10}];

(* 1200 m/s at 45N for example *)

(* 1200 m/s * 86400 s/ day * 1 earth radius/6371000m = 16.2737 earth rad/day *)

(* 9.8 m/s/s * 86400*86400*s*s/day*day * 1 earth radius/6371000m = 11482.8 *)

orbit3[r_, rot_, g0_, phi_, v0_] :=
 NDSolve[{
x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi],
x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi],
x''[t] == -g0*x[t]/Norm[{x[t],y[t],z[t]}]^3,
y''[t] == -g0*y[t]/Norm[{x[t],y[t],z[t]}]^3,
z''[t] == -g0*z[t]/Norm[{x[t],y[t],z[t]}]^3
}, {x[t],y[t],z[t]}, {t,0,10}];







eqnsfake = {
x[0] == Cos[phi], y[0] == 0, z[0] == Sin[phi],
x'[0] == v0*Cos[phi], y'[0] == Cos[phi], z'[0] == v0*Sin[phi],
x''[t] == 0,
y''[t] == 0,
z''[t] == 0
}







