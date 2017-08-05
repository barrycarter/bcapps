(* fun with 2017 Aug solar eclipse *)

(*

testing:

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
