(*

orthographic projection stuff

*)

(*

Earth as a sphere, looking from +x axis, so x=+2 is one plane, with
(3, 0, 0) being the eye line (for example)

x1 = distant point (focus)

x2 = nearer point (plane)

*)

(* the line *)

line[lng_, lat_, t_, x1_] = (1-t)*sph2xyz[lng, lat, 1]  + t*{x1, 0, 0}

t1831 = Solve[line[lng, lat, t, x1][[1]] == x2, t][[1,1,2]]

transform[lng_, lat_, x1_, x2_] = 
 Take[Simplify[line[lng, lat, t1831, x1]], {2,3}]

Table[transform[lng*Degree, lat*Degree, 3, 1], {lng, -90, 90, 10}, {lat,
-90, 90, 10}]


Plot[transform[lng*Degree, 45*Degree, 1, 3], {lng, -90, 90}]

ParametricPlot[transform[lng*Degree, 45*Degree, 1, 3], {lng, -90, 90}]

In[44]:= ListPlot[Table[transform[lng*Degree, lat*Degree, 3, 1], {lng, -90, 90, 
10}, {lat,  -90, 90, 10}] , AspectRatio -> 1]                                   
above works well

now, if we want a different center and north...

ListPlot[Table[transform
 [lng*Degree, lat*Degree, 3, 1], {lng, -90, 90, 10}, {lat, -90, 90, 10}],
AspectRatio -> 1]

ListPlot[Table[transform
 [lng*Degree, lat*Degree, 2, 1], {lng, -90, 90, 10}, {lat, -90, 90, 10}],
AspectRatio -> 1]

(* infinite distance? *)

Table[{Cos[lng*Degree], Sin[lat*Degree]}, {lng, -90, 90, 10}, {lat,
-90 ,90 ,10}]

Table[{Cos[lat*Degree]*Sin[lng*Degree], Sin[lat*Degree]}, {lng, -90,
90 , 10}, {lat, -90 ,90 ,10}]

ListPlot[Table[{Cos[lat*Degree]*Sin[lng*Degree], Sin[lat*Degree]},
{lng, -90, 90 , 10}, {lat, -90 ,90 ,10}], AspectRatio -> 1]

(* above works perfectly *)

(* now, what if we rotate *)

xyz2sph[rotationMatrix[z, theta].sph2xyz[lng, lat, 1]]

conds = {-Pi < lng, lng < Pi, -Pi/2 < lat, lat < Pi/2, -Pi < theta,
theta < Pi, -Pi < clng, clng < Pi, -Pi/2 < clat, clat < Pi/2};

simp = {ArcTan[y_, x_] -> ArcTan[x/y]}

FullSimplify[xyz2sph[rotationMatrix[z, theta].sph2xyz[lng, lat, 1]], conds]

Out[30]= {ArcTan[Cos[lng + theta], Sin[lng + theta]], lat, 1}

exactly as expected

FullSimplify[
xyz2sph[rotationMatrix[z, -clng].sph2xyz[clng, lat, 1]],
 conds]

FullSimplify[
xyz2sph[rotationMatrix[x, clat].sph2xyz[lng, clat, 1]],
 conds]

xyz2sph[rotationMatrix[x, -20*Degree].sph2xyz[lng, 20*Degree, 1]]

sph2xyz[0, 20*Degree, 1]

FullSimplify[
xyz2sph[rotationMatrix[y, -clat].sph2xyz[lng, clat, 1]],
 conds]

xyz2sph[rotationMatrix[y, -20*Degree].sph2xyz[0, 20*Degree, 1.]]

FullSimplify[xyz2sph[
rotationMatrix[y, -clat].rotationMatrix[z, -clng].
 sph2xyz[clng, clat, 1]], conds]

above works


what does it do to an arb point?

fs = FullSimplify[xyz2sph[
 rotationMatrix[y, -clat].rotationMatrix[z, -clng].
 sph2xyz[lng, lat, 1]], conds]

after simplification, we project ortho

FullSimplify[{Cos[fs[[2]]]*Sin[fs[[1]]], Sin[fs[[2]]]}, conds]

{-(Cos[lat]*Sin[clng - lng]), -(Cos[lat]*Cos[clng - lng]*Sin[clat]) + 
  Cos[clat]*Sin[lat]}

newX[lng_, lat_, clng_, clat_] = -(Cos[lat]*Sin[clng - lng]);

newY[lng_, lat_, clng_, clat_] = -(Cos[lat]*Cos[clng - lng]*Sin[clat]) + 
 Cos[clat]*Sin[lat];


ListPlot[Table[{newX[lng, lat, 0, 0], newY[lng, lat, 0, 0]},
{lng, -Pi/2, Pi/2, 10*Degree}, {lat, -Pi/2, Pi/2, 10*Degree}], 
 AspectRatio -> 1]

ListPlot[Table[{newX[lng, lat, 25*Degree, 0], newY[lng, lat, 25*Degree, 0]},
{lng, -Pi/2, Pi/2, 10*Degree}, {lat, -Pi/2, Pi/2, 10*Degree}], 
 AspectRatio -> 1]

ListPlot[Table[{newX[lng, lat, 0*Degree, 35*Degree], 
 newY[lng, lat, 0*Degree, 35*Degree]},
{lng, -Pi/2, Pi/2, 10*Degree}, {lat, -Pi/2, Pi/2, 10*Degree}], 
 AspectRatio -> 1]

ListPlot[Table[{Cos[lat*Degree]*Sin[lng*Degree], Sin[lat*Degree]},
{lng, -90, 90 , 10}, {lat, -90 ,90 ,10}], AspectRatio -> 1]

(* work below 16 Jun 2019 copied from ../MATHEMATICA/playground.m to start *)

(* Mercator stuff *)

(* below from bclib.pl, trying to find inverse *)

(* lat only, that's the hard one, first *)

slippy2lat[x_,y_,z_,px_,py_] =
 -90 + (360*ArcTan[Exp[Pi-2*Pi*((y+py/256)/2^z)]])/Pi

slippy2latrad[x_,y_,z_,px_,py_] = 
 FullSimplify[slippy2lat[x,y,z,px,py]/180*Pi]

slippy2lonrad[x_,y_,z_,px_,py_] = FullSimplify[(x+px/256)*2*Pi/2^z-Pi]

points[x_, y_, z_] = Flatten[Table[
 {slippy2lonrad[x, y, z, i, j], slippy2latrad[x, y, z, i, j]},
{j, {0,256}}, {i, {0,256}}], 1];


points[x_, y_, z_] = {
 {slippy2lonrad[x, y, z, 0, 0], slippy2latrad[x, y, z, 0, 0]},
 {slippy2lonrad[x, y, z, 256, 0], slippy2latrad[x, y, z, 256, 0]},
 {slippy2lonrad[x, y, z, 256, 256], slippy2latrad[x, y, z, 256, 256]},
 {slippy2lonrad[x, y, z, 0, 256], slippy2latrad[x, y, z, 0, 256]}
};

newX[lng_, lat_, clng_, clat_] = Cos[lat]*Sin[lng - clng];

newY[lng_, lat_, clng_, clat_] = Cos[lat]*Cos[lng - clng]*Sin[clat] + 
 Cos[clat]*Sin[lat];

newX[slippy2lonrad[x, y, z, px, py], slippy2latrad[x, y, z, px, py],
 clng, clat]

newY[slippy2lonrad[x, y, z, px, py], slippy2latrad[x, y, z, px, py],
 clng, clat]











