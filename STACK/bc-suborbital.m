(* TODO: retroactively establish these formulas *)

launch[r_, p_, g_, phi_, vx_, vy_, vz_] := 
 launch[r,p,g,phi,vx,vy,vz] = Module[
 {s,site,root,dlat,dlon,garb,nsdist,ewdist,tdist,maxtime,maxheight,v0},

 v0 = Norm[{vx,vy,vz}];

 s[t_] = {x[t], y[t], z[t]} /. NDSolve[{
  x[0] == r*Cos[phi], y[0] == 0, z[0] == r*Sin[phi],
  x'[0] == vx, y'[0] == 2*Pi*r*Cos[phi]/p+vy, z'[0] == vz,
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

(* launch 2 assumes constant gravity wort distance *)

launch2[r_, p_, g_, phi_, vx_, vy_, vz_] := 
 launch[r,p,g,phi,vx,vy,vz] = Module[
 {s,site,root,dlat,dlon,garb,nsdist,ewdist,tdist,maxtime,maxheight,v0},

 v0 = Norm[{vx,vy,vz}];

 s[t_] = {x[t], y[t], z[t]} /. NDSolve[{
  x[0] == r*Cos[phi], y[0] == 0, z[0] == r*Sin[phi],
  x'[0] == vx, y'[0] == 2*Pi*r*Cos[phi]/p+vy, z'[0] == vz,
  x''[t] == -g*x[t]/r,
  y''[t] == -g*y[t]/r,
  z''[t] == -g*z[t]/r
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

(* TODO: 86400 not accurate, need siderial days *)

test0705 = launch[6371000, 86400, 9.8, 0*Degree, -2000, 5000, 0]

test0705 = launch2[6371000, 86400, 9.8, 0*Degree, -2000, 5000, 0]

Plot[{test0705[[1]]-test0705[[2]]}, {t,0,3300}]
ParametricPlot3D[{test0705[[2]]-test0705[[1]]}, {t,0,3300}]

ParametricPlot3D[{test0705[[2]]-test0705[[1]]}, {t,0,3300}, 
 ViewPoint -> {0,0, 6371}]

emr = 6371000

g[u_] = Graphics3D[{ 
 Arrow[{{-emr,0,0}, {emr,0,0}}],
 Arrow[{{0,-emr,0}, {0,emr,0}}],
 Arrow[{{0,0,-emr}, {0,0,emr}}],
 PointSize[0.01], 
 Point[test0705[[2]] /. t -> u],
 RGBColor[1,0,0],
 Point[test0705[[1]] /. t -> u]
}]


tab = Table[Show[g[i]], 
 {i,0, test0705[[3]], test0705[[3]]/20}]

Export["/tmp/test.gif", tab]
Run["animate -delay 15 /tmp/test.gif&"]

10717000 m to beijing from new york


(*

http://space.stackexchange.com/questions/14537/how-will-a-suborbital-flight-country-to-country-work

On a spherical Earth with radius $r$ and rotational period $p$
seconds, the Cartesian position of a location with longitude $\theta$
and latitude $\lambda$ at time t (in seconds) is:

TODO: move inline Mathematica elsewhere

$
  \left\{r \cos (\lambda ) \cos \left(\frac{2 \pi  t}{p}-\theta \right),-r \cos
    (\lambda ) \sin \left(\frac{2 \pi  t}{p}-\theta \right),r \sin (\lambda
    )\right\}
$

By change of variable:

$t\to \frac{p (t+\theta )}{2 \pi }$

we have:

pos[t_,p_] = {r*Cos[lambda]*Cos[t], -(r*Cos[lambda]*Sin[t]), r*Sin[lambda]}

$\{r \cos (\lambda ) \cos (t),-r \cos (\lambda ) \sin (t),r \sin (\lambda )\}$

(if the change of variable seems confusing, note that we are simply
rotating our axes so that the departure point has y=0 when t=0)

The velocity (ie, the derivative with respect to $t$) is then:

$\{-r \cos (\lambda ) \sin (t),-r \cos (\lambda ) \cos (t),0\}$

Thus, if we impart initial velocity $\{\text{vx},\text{vy},\text{vz}\}$
to our flight (in addition to the velocity imparted by the Earth's
rotation), our initial velocity is:

$\{\text{vx}-r \cos (\lambda ) \sin (t),\text{vy}-r \cos (\lambda ) 
 \cos(t),\text{vz}\}
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

dfqs[lambda_, vx_, vy_, vz_, g_, r_] = {
 {x[0], y[0], z[0]} == 
  {0, r Cos[lambda], r Sin[lambda]},

 {x'[0], y'[0], z'[0]} == 
  {vx + 2 Pi r Cos[lambda], vy, vz},

 {x''[t], y''[t], z''[t]} ==
  {-((g*r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)), 
  -((g*r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)), 
  -((g*r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))}
}



dfqs[lambda_, vx_, vy_, vz_, g_, r_, p_] = {
 x[0] == 0,
 y[0] == r*Cos[lambda],
 z[0] == r*Sin[lambda],

 x'[0] == vx + 2*Pi*r*Cos[lambda],
 y'[0] == vy,
 z'[0] == vz,

 x''[t] == -((g*r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 y''[t] == -((g*r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 z''[t] == -((g*r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
};

traj[lambda_, vx_, vy_, vz_, g_, r_] :=
 NDSolve[dfqs[lambda,vx,vy,vz,g,r], 
 {x[t],y[t],z[t]}, {t,0,86400}]

traj[0, 0, 0, 0, 9.8*86400*86400, 6371000][[1]]
x[t] /. %

Plot[{x[t],y[t],z[t]} /. %, {t,0,10000}]
showit

ParametricPlot3D[{x[t],y[t],z[t]} /. %[[1]], {t,0,1000}]


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

TODO: rocket fuel = accel varies too

TODO: choice of start time

TODO: close to earth = g constant


TODO: caveats re "through the Earth"

lon = -74.005970597623*Degree
lat = 40.7142723032398*Degree
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

Inputs:

r: radius of planet in meters

p: orbital period of planet in seconds

g: gravitational acceleration at surface in m/s^2



*)


$


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

(* a spherical approach *)

(* velocity *)

theta-phi-r is order, theta is xy plane

{r*Cos[theta]*Cos[phi], r*Sin[theta]*Cos[phi], r*Sin[theta]}

conds = {Element[{x,y,z,vx,vy,vz,dt,theta,phi}, Reals],r>0}

nudge = FullSimplify[
 (xyz2sph[{x + vx*dt, y + vy*dt, z + vz*dt}] -
 xyz2sph[{x,y,z}])/dt, 
 Element[{x,y,z,vx,vy,vz,dt}, Reals]]

nudge2 = nudge /. {
 x -> r*Cos[theta]*Sin[phi],
 y -> r*Sin[theta]*Sin[phi],
 z -> r*Sin[phi]
}

nudge3 = FullSimplify[nudge2,conds]





Limit[
 (xyz2sph[{x + vx*dt, y + vy*dt, z + vz*dt}] -  xyz2sph[{x,y,z}])/dt, 
 dt -> 0]




FullSimplify[xyz2sph[{vx*t, vy*t, vz*t}],{t>0, Element[{vx,vy,vz}, Reals]}]

  

x[0] == r*Cos[phi], y[0] == 0, z[0] == r*Sin[phi],
  x'[0] == vx, y'[0] == 2*Pi*r*Cos[phi]/p+vy, z'[0] == vz,
  x''[t] == -g*((r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
  y''[t] == -g*((r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
  z''[t] == -g*((r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
 }, {x[t],y[t],z[t]}, {t,0,4*v0/g}][[1]];
