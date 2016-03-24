(*

http://space.stackexchange.com/questions/14537/how-will-a-suborbital-flight-country-to-country-work

On a rotating spherical Earth with radius $r$, the Cartesian position
of a location with longitude $\theta$ and latitude $\lambda$ at time t
(given in sidereal days) is:

$
   \{r \cos (\lambda ) \cos (2 \pi  t-\theta ),-r \cos (\lambda ) \sin (2 \pi 
    t-\theta ),r \sin (\lambda )\}
$

By change of variable:

$t\to t+\frac{\theta }{2 \pi }+\frac{3}{4}$

we have:

$
   \{r \cos (\lambda ) \sin (2 \pi  t),r \cos (\lambda ) \cos (2 \pi  t),r \sin
    (\lambda )\}
$

(if the change of variable seems confusing, note that we are simply
rotating our axes so that the departure point has x=0 when t=0)

The velocity (ie, the derivative with respect to $t$) is then:

$
   \{2 \pi  r \cos (\lambda ) \cos (2 \pi  t),-2 \pi  r \cos (\lambda ) \sin (2
    \pi  t),0\}
$

Thus, if we impart initial velocity $\{\text{vx},\text{vy},\text{vz}\}$
to our flight (in addition to the velocity imparted by the Earth's
rotation), our initial velocity is:

$
   \{2 \pi  r \cos (\lambda ) \cos (2 \pi  t)+\text{vx},\text{vy}-2 \pi  r \cos
    (\lambda ) \sin (2 \pi  t),\text{vz}\}
$

Note that all of our coordinates so far are Earth-centric and do not
rotate with the Earth:

TODO: animation here

TODO: note that at t=0 and t=1/4 or whatever, axes point inwards, z not up

TODO: verbiage re why these dfq

$
   \{x(0),y(0),z(0)\}=\{r \cos (\lambda ) \cos (\theta ),r \cos (\lambda ) \sin
    (\theta ),r \sin (\lambda )\}
$

$
   \left\{x'(0),y'(0),z'(0)\right\}=\{2 \pi  r \cos (\lambda
    )+\text{vx},\text{vy},\text{vz}\}
$

Gravity acts towards the origin (center of the Earth), so it's direction is:

$\{-x(t),-y(t),-z(t)\}$

The magnitude of gravitational acceleration depends on the surface
gravity acceleration $g$ and the square of the distance from the
origin. Since we remain near the Earth's surface, we could estimate
gravitational acceleration as constant at $g$, but it turns out not to
help, so we'll give the magnitude of gravitational acceleration in its
full form:

$\frac{g r^2}{x(t)^2+y(t)^2+z(t)^2}$

Converting the direction of gravity to a unit vector and multiplying
by the magnitude, the gravitational acceleration is:

$
   \left\{-\frac{g r^2 x(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{g
    r^2 y(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{g r^2
    z(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}}\right\}
$

dfqs = {
 {x[0], y[0], z[0]} == 
  {0, r Cos[lambda], r Sin[lambda]},

 {x'[0], y'[0], z'[0]} == 
  {vx + 2 Pi r Cos[lambda], vy, vz},

 {x''[t], y''[t], z''[t]} ==
  {-((g*r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)), 
  -((g*r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)), 
  -((g*r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))}
}

To find the position of our flight at time t, we solve:


$
\left\{\{x(0),y(0),z(0)\}=\{0,r \cos (\lambda ),r \sin (\lambda
)\},\left\{x'(0),y'(0),z'(0)\right\}=\{2 \pi  r \cos (\lambda
)+\text{vx},\text{vy},\text{vz}\},\left\{x''(t),y''(t),z''(t)\right\}=\left\{
-\frac{g r^2 x(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{g r^2
y(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}},-\frac{g r^2
z(t)}{\left(x(t)^2+y(t)^2+z(t)^2\right)^{3/2}}\right\}\right\}
$

This differential equation has no closed form (not even if we'd
assumed gravitational acceleration was constant or made other
simplications), so we must solve numerically.

y-axis is west by rhr






 






TODO: choice of start time



TODO: close to earth = g constant


TODO: caveats re "through the Earth"

lon = -74.005970597623*Degree
lat = 40.7142723032398*Degree
emr = 6371000
arl = emr/2

g[t_] := Graphics3D[{
 Sphere[{0,0,0},emr],
 PointSize -> 0.1,
 Point[s[emr, t, lon, lat]],
 Arrow[{s[emr, t, lon, lat], s[emr, t, lon, lat] + {arl,0,0}}],
 Arrow[{s[emr, t, lon, lat], s[emr, t, lon, lat] + {0,arl,0}}],
 Arrow[{s[emr, t, lon, lat], s[emr, t, lon, lat] + {0,0,arl}}],
 Null
}];

tab = Table[Show[g[i]],{i,0,1,0.1}]
Export["/tmp/test.gif", tab]


TODO: mention traj file + this file

s[r_,t_,theta_,lambda_] = {
 r Cos[lambda] Sin[2 Pi t], r Cos[lambda] Cos[2 Pi t], r Sin[lambda]};



r*Cos[lambda]*Cos[theta-2*Pi*t],
r*Cos[lambda]*Sin[theta-2*Pi*t], r*Sin[lambda]}

TODO: make sure word "speed" not used unless correct

r=1;

g[t_] := Graphics3D[{
 Lighting -> {{"Directional", White, {0,-1,0}}},
 RGBColor[{1,1,1}],
 Sphere[{0,0,0},1],
 RGBColor[{1,0,0}],
 PointSize -> 0.1,
 Point[{0,1,0}],
 Point[s[t,0,0]]
}];

ani = Table[g[t],{t,0,1,.1}]
Export["/tmp/test.gif", ani]

ParametricPlot3D[s[t,0,0],{t,0,.15}]
Show[{g,%}, ViewPoint -> {0,-1,0}]
showit












TODO: disclaimers, non elliptical, 0 elevation, not an answer, will
crash, no air ressit (prob important because khan? line mentioned),
retrothrusters, accelerate gradually, control during = calc of
varations

*)

g = Graphics3D[{
 Lighting -> {{"Directional", Blue, {0,-1,0}}},
 RGBColor[{1,1,1}],
 Sphere[{0,0,0},1],
 RGBColor[{1,0,0}],
 PointSize -> 0.1,
 Point[{0,1,0}],
}];

Show[g, Boxed -> False]
showit

r = Sqrt[x[t]^2+y[t]^2+z[t]^2];

DSolve[{
 x''[t] == -g*((r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 y''[t] == -g*((r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 z''[t] == -g*((r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
}, {x[t],y[t],z[t]}, t]

DSolve[{
 x''[t] == -g*((r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 y''[t] == -g*((r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 z''[t] == -g*((r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
}, {x[t],y[t],z[t]}, t]

DSolve[{
 x''[t] == -g*x[t]/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2),
 y''[t] == -g*y[t]/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2),
 z''[t] == -g*z[t]/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)
}, {x[t],y[t],z[t]}, t]

DSolve[{
 x''[t] == x[t]/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2),
 y''[t] == y[t]/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2),
 z''[t] == z[t]/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)
}, {x[t],y[t],z[t]}, t]

(*

digression: gravity changes lat/lon how? surface equations for estimating?

TODO: above, use distance/direction and standard accel landing as
first estimate








*)
