(* fun with 2017 Aug solar eclipse *)

(*

The file /tmp/all.m is created as:

bzcat earth-on-eclipse-day.csv.bz2 | bc-horizons2math.pl --fields=0,2,3,4 --label=earth > ! /tmp/all.m

bzcat sun-on-eclipse-day.csv.bz2 | bc-horizons2math.pl --fields=0,2,3,4 --label=sun >> /tmp/all.m

bzcat moon-on-eclipse-day.csv.bz2 | bc-horizons2math.pl --fields=0,2,3,4 --label=moon >> /tmp/all.m

per https://ipnpr.jpl.nasa.gov/progress_report/42-196/196C.pdf errors for terresterial planets is few hundred meters.

NOTE TO SELF: /tmp/all.mx is the DumpSave version that's even faster

*)

(* below is in meters *)

au = 149597870700;

(* earth/moon/sun triaxial radii *)

er = 1000*{6378.14, 6378.14, 6356.752};

(* from https://nssdc.gsfc.nasa.gov/planetary/factsheet/moonfact.html *)

mr = 1000*{1738.1, 1738.1, 1736.0}

sr = 1000*{6.963*10^5, 6.963*10^5, 6.963*10^5}

(* position data per second *)

t0 = 4915973/2

Table[e[Round[(i[[1]]-t0)*86400]] = au*Take[i, {2,4}], {i, earth}];
Table[s[Round[(i[[1]]-t0)*86400]] = au*Take[i, {2,4}], {i, sun}];
Table[m[Round[(i[[1]]-t0)*86400]] = au*Take[i, {2,4}], {i, moon}];

gm[t_] := Graphics3D[Sphere[m[t], 10*mr[[1]]]];
sm[t_] := Graphics3D[Sphere[s[t], 10*sr[[1]]]];

Show[gm[43200], ViewVector -> {e[43200], s[43200]}, 
 ViewAngle -> 10*Degree]

Show[sm[43200], ViewVector -> {e[43200], s[43200]}, 
 ViewAngle -> 10*Degree]

Show[{gm[43200], sm[43200]}, ViewVector -> {e[43200], s[43200]}, 
 ViewAngle -> 10*Degree]

(*

revamped even tighter

Subject: Bug in (or my misunderstanding of) ViewAngle

While trying to clarify my question in https://mathematica.stackexchange.com/questions/153600/graphics3d-displays-spheres-individually-but-not-together I came across either a bug or a misunderstanding of `ViewAngle`:

(* here's a point p, a radius r, and a sphere s centered at p with radius r *)

p = {-303335746, 213871159, 489763}; 
r = 1738100;
s = Sphere[p, r];

(* what's the angular radius as viewed from the origin, in degrees? *)

N[ArcTan[r/Norm[p]]/Degree]

(* it comes out to about 0.268314 degrees *)

(* now, let's look at the sphere from the origin with a viewangle of 1
degree; it should fill about half the screen, since the angular
diameter is about .54 degrees *)

Show[Graphics3D[s], ViewAngle -> 1*Degree, ViewVector -> {0,0,0}]








question for mathematica.se revamped to centralize origin + details

I've found a simpler example that fails and am providing it below with more details on what I expect to see. I'm leaving my original question below for reference.

(* here are two 3D points *)

pt1 = {-303335746, 213871159, 489763};
pt2 = {-128868984574, 79336116609, -2720851};

(* as viewed from the origin, their angular distance is small *)

N[VectorAngle[pt1, pt2]/Degree]

(* yields 3.56925 degrees *)

(* now, two spheres of different sizes centered at these points *)

r1 = 1738100
r2 = 696300000

sph1 = Sphere[pt1, r1]
sph2 = Sphere[pt2, r2]

(* let's compute the angular diameter of these spheres as viewed from origin *)

N[2*ArcTan[r1/Norm[pt1]]/Degree]
N[2*ArcTan[r2/Norm[pt2]]/Degree]

(* the answers are 0.536627 degrees for sph1 and 0.527248 degrees for sph2 *)

(* now, let's look directly at pt1 with a 10 degree view angle; since
both spheres have the same angular diameter and are only 3 degrees
apart, we should see both *)

g0 = Graphics3D[{sph1,sph2}]
Show[g0, ViewVector -> { {0,0,0}, pt1}, ViewAngle -> 10*Degree]

(* but we only see sph2 [image below], why? *)

g0.gif





Graphics3D[sph1, ViewVector -> {0,0,0}, ViewAngle -> 0.01*Degree]






(* here are their spherical coordinates from the origin *)

N[CoordinateTransform["Cartesian" -> "Spherical", pt1]] // InputForm

{3.7115183863369983*^8, 1.5694767505698701, 2.5274760127257454}

N[CoordinateTransform["Cartesian" -> "Spherical", pt2]] // InputForm

{3.7115183863369983*^8, 1.5694767505698701, 2.5274760127257454}






sph1 = Sphere[{-303335746, 213871159, 489763}, 1738100]






end revamped question

*)











(*

question for mathematica.se

(* here are two spheres *)

sph1 = Sphere[{128940484175, -78312608306, -17241976}, 1738100]
sph2 = Sphere[{374835347, 809637144, -20452590}, 696300000]

(* and a fixed view vector and view angle *)

vv = {{129243819921, -78526479465, -17731739}, 
 {-128565648828, 79122245450, -3210615}}

va = 10*Degree

(* see below for results *)

(* this shows sph1, as expected *)
g1 = Graphics3D[sph1, ViewVector -> vv, ViewAngle -> va]

(* this shows sph2, as expected *)
g2 = Graphics3D[sph2, ViewVector -> vv, ViewAngle -> va]

(* this shows only sph2, why? *)
g3 = Graphics3D[{sph1, sph2}, ViewVector -> vv, ViewAngle -> va]

(* even reversed, this shows only sph2, why? *)
g4 = Graphics3D[{sph2, sph1}, ViewVector -> vv, ViewAngle -> va]

*)

g1: [[image]]

g2: [[image]]

g3: [[image]]

g4: [[image]]

I've tried many variants of the commands above, but get the same results.

My one thought: maybe I'm using such large and small quantities that the coordinates for sph1 are somehow obscuring the coordinates for sph2.

*)






g[t_] := Graphics3D[{
 Glow[Blue],
 Sphere[e[t], er[[1]]],
 Glow[Green],
 Sphere[m[t], mr[[1]]],
 Glow[Yellow],
 Sphere[s[t], sr[[1]]]
}];

g[t_] := Graphics3D[{
 Glow[Green],
 Sphere[m[t], mr[[1]]]
}];

g[t_] := Graphics3D[{
 Glow[Green],
 Sphere[m[t], mr[[1]]],
 Glow[Yellow],
 Sphere[s[t], sr[[1]]]
}];

mg[t_] := Graphics3D[{
 Green,
 Ball[m[t], mr[[1]]]
}];

sg[t_] := Graphics3D[{
 Yellow,
 Ball[s[t], sr[[1]]]
}];

mg[t_] := Graphics3D[{
 Green,
 Ball[m[t]-e[t], mr[[1]]]
}];

sg[t_] := Graphics3D[{
 Yellow,
 Ball[s[t]-e[t], sr[[1]]]
}];

test = Graphics3D[{
 Sphere[m[65000], mr[[1]]],
 Sphere[s[65000], sr[[1]]]
}]

Show[test, ViewVector -> {e[65000], m[65000]}, ViewAngle -> 3*Degree]


Show[mg[1], Lighting -> None, ViewVector -> {e[1], m[1]}, 
 ViewAngle -> 3*Degree]
showit

Show[sg[1], Lighting -> None, ViewVector -> {e[1], m[1]}, 
 ViewAngle -> 3*Degree]
showit

Show[g[6], Lighting -> None, ViewVector -> {e[6], s[6]}, 
 ViewAngle -> 3*Degree]
showit

Show[g[6], Lighting -> None, ViewVector -> {e[6], (m[6]-e[6])/10000}, 
 ViewAngle -> 30*Degree, SphericalRegion -> True]
showit

Show[g[6], Lighting -> None, ViewVector -> {e[6], m[6]-e[6]}, 
 ViewAngle -> 30*Degree]
showit

Show[g[6], Lighting -> None, ViewVector -> {e[6], m[6]-e[6]}, 
 ViewAngle -> 5*Degree]
showit

Show[g[6], Lighting -> None, ViewVector -> {e[6], s[6]-e[6]}, 
 ViewAngle -> 5*Degree]
showit

test = Graphics3D[{
 Sphere[{128312141025, -79366814300, -21372756}, 17381000]
}]

Show[test, ViewVector -> {




Graphics3D[{
 Sphere[{earth[[1]][[2]], earth[[1]][[3]], earth[[1]][[4]]}, er[[1]]]
}];

g = Graphics3D[{
 Glow[Blue],
 Ball[Take[earth[[1]], 3], er[[1]]],
 Glow[White],
 Ball[Take[moon[[1]], 3], mr[[1]]],
 Glow[Yellow],
 Ball[Take[sun[[1]], 3], sr[[1]]]
}];

Show[g, Lighting -> None, ViewPoint -> Take[earth[[1]],3]]







(* index 1,2,3 = x,y,z *)

tab[planet_, index_] := tab[planet, index] =
 Table[{Round[(i[[1]]-4915973/2)*86400], au*i[[index+1]]}, {i, planet}]

fit1[planet_, index_] := fit1[planet, index, t_] = 
 Fit[tab[planet,index], {1,t}, t];

fit2[planet_, index_] := fit2[planet, index, t_] = 
 Fit[tab[planet,index], {1,t,t^2}, t];

fit3[planet_, index_] := fit3[planet, index, t_] = 
 Fit[tab[planet,index], {1,t,t^2,t^3}, t];

fittab1[planet_, index_] := fittab1[planet, index] = 
 Table[fit1[planet, index, t],{t,0,86400}];



diff1[planet_, index_] := diff1[planet, index] = 
 Table[au*planet[[t+1, index+1]] - fit1[planet, index][t], {t,0,86400}];




earthx = Table[{Round[(i[[1]]-4915973/2)*86400], au*i[[2]]}, {i, earth}]

ex = Interpolation[earthx, InterpolationOrder -> 1]

f[t_] = Fit[earthx, {1,t,t^2,t^3}, t]










(*

testing:


light = Graphics3D[{Red, PointSize -> .05, Point[{2, 2, 2}], 
    Glow[Yellow], Opacity[.3], Sphere[{2, 2, 2}, 3]}, 
   Lighting -> {{"Point", Yellow, {2, 2, 2}}}];

ball = Graphics3D[{Ball[{0,0,0}, 1]}, Lighting -> None]


ball = Graphics3D[{Ball[{0,0,0}, 1]}, 
 Lighting -> {{"Point", Yellow, {2, 2, 2}}}];

ball = Graphics3D[{Sphere[{0,0,0}, 1]}, 
 Lighting -> {{"Point", Yellow, {2, 2, 2}}}];


ball = Graphics3D[{
 Sphere[{0,0,0}, 1], Sphere[{1,1,1}, .1]
}, Lighting -> {{"Point", Yellow, {2, 2, 2}}}];

ball = Graphics3D[{
 Sphere[{0,0,0}, 1], Sphere[{1,1,1}, .1]
}, Lighting -> {{"Point", Yellow, {2, 0, 2}}}];

ball = Graphics3D[{
 Ball[{0,0,0}, 1], Ball[{1,1,1}, .1]
}, Lighting -> {{"Point", Yellow, {2, 0, 2}}}];

ball = Graphics3D[{
 Ball[{0,0,0}, 1], Ball[{1,0,1}, .1]
}, Lighting -> {{"Point", Yellow, {2, 0, 2}}}];

ball = Graphics3D[{
 Ball[{0,0,0}, 1], Ball[{1,0,1}, .1]
}, Lighting -> {{"Point", Yellow, {2, 0, 2}}},
 ViewPoint -> {2,0,2}];


ball = Graphics3D[{
 Ball[{0,0,0}, 1], Ball[{1,0,1}, .5]
}, Lighting -> {{"Point", Yellow, {2, 0, 2}}},
 ViewPoint -> {2,2,2}];







light = Graphics3D[{Red, PointSize -> .05, Point[{2, 2, 2}], 
    Glow[Yellow], Opacity[.3], Sphere[{2, 2, 2}, 3]}, 
   Lighting -> {{"Point", Yellow, {2, 2, 2}}}];

light = Graphics3D[{Red, PointSize -> .05, Point[{2, 2, 2}], 
    Opacity[.3], Sphere[{2, 2, 2}, 3]}, 
   Lighting -> {{"Point", Yellow, {2, 2, 2}}}];



g = Graphics3D[{
 RGBColor[1,1,1],
 Ball[{1.5,0,0}, 0.1],
 Glow[Yellow],
 Ball[{0,0,0}, 1]
}]

g = Graphics3D[{
 RGBColor[1,1,1],
 Sphere[{1.5,0,0}, 0.1],
 Sphere[{0,0,0}, 1]
}]

g = Graphics3D[{
 Opacity[0.1],
 Sphere[{2.5,0,0}, 1],
 Opacity[1],
 Ball[{0,0,0}, 1],
}]

Show[g, Lighting -> {{"Point"}, RGBColor[0,1,0], {0,0,0}}];


g = Graphics3D[{
 Specularity[1],
 Glow[Yellow],
 Ball[{0,0,0}, 1],
 Glow[],
 Ball[{1.001,0,0}, 0.1]
}]

Show[g, Lighting -> {{"Ambient", RGBColor[1,1,0], {{0,0,0}}}}]

Show[g, Lighting -> {"Point", RGBColor[1,1,0], {{0,0,0}}}]
 
Show[g, Lighting -> None] 
showit 
]
showit

general notes:

Let S (source) be a sphere of radius rs at point s

Let B (block) be a sphere of radius rb at point b

Let T (target) be a sphere of radius rt at point t

parametrization of line from u to v

line[u_,v_,t_] = u + (v-u)*t

point on sphere surface located at p with radius r, given two angles

(* TODO: this is ugly for pointwise addition *)

point[p_List, r_, th_, ph_] := p + sph2xyz[th,ph,r]

conds = Element[{sx, sy, sz, bx, by, bz, tx, ty, tz, tm, th1, ph1, th2, ph2},
 Reals]

s = {sx,sy,sz}
b = {bx,by,bz}
t = {tx,ty,tz}

line[point[s, rs, th1, ph1], point[b, bs, th2, ph2], tm]

Solve[Norm[line[point[s, rs, th1, ph1], point[b, bs, th2, ph2], tm] -
t] == rt, tm]

(** writeup below, but may not actually submit to mathematica.SE **)

(* Let S (source), B (blocker), and T (target) be three spheres
centered as follows: *)

s = {sx,sy,sz}
b = {bx,by,bz}
t = {tx,ty,tz}

(* A point on a sphere's surface can be given by two angles, th and ph *)

point[p_List, r_, th_, ph_] := p + sph2xyz[th,ph,r]






Aug 21, 2017 at 15:46 UTC = eclipse start = 1503330360

so lets HORIZONS and look at 18:46 UTC

ascp1950.430.bz2.sun,earthmoon,moongeo.mx


(* TODO: RESTORE factor TO ONE WHEN FINAL *)

factor = 1000;

earth = {8.663956678832780*10^-01, -5.207951371991623*10^-01,
 -1.188740575217250*10^-04}/factor;

sun = {2.504271325669393*10^-03, 5.413709545349687*10^-03,
-1.366868862270140*10^-04}/factor;

moon = {8.642682707645408*10^-01, -5.195058046203309*10^-01,
-9.967783505380239*10^-05}/factor;

au = 149597870700;

mrad = 1737.4/au

erad = 6371.01/au

srad = 6.963*10^5/au

obj = {
 RGBColor[1,1,0],
 Ball[sun, srad],
 RGBColor[0,0,1],
 Ball[earth, erad],
 RGBColor[1,1,1],
 Ball[moon, mrad]
};

Graphics3D[obj]
Show[%, ViewPoint -> earth, ViewVector -> earth-sun, ImageSize -> {1024,768},
 ViewCenter -> Sun, SphericalRegion -> True, Lighting -> None]
showit



TODO: test vs horizons
