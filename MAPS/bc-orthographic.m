(* orthographic projection stuff *)

<formulas>

greatCircleDistance[lng1_, lat1_, lng2_, lat2_] = 
 ArcCos[Cos[lat1]*Cos[lat2]*Cos[lng1 - lng2] + Sin[lat1]*Sin[lat2]];

lngLat2CenterLngLat[lng_, lat_, clng_, clat_] = 
{ArcTan[Cos[clat]*Cos[lat]*Cos[clng - lng] + Sin[clat]*Sin[lat], 
  -(Cos[lat]*Sin[clng - lng])], 
 ArcTan[Sqrt[(Cos[clat]*Cos[lat]*Cos[clng - lng] + Sin[clat]*Sin[lat])^2 + 
    Cos[lat]^2*Sin[clng - lng]^2], -(Cos[lat]*Cos[clng - lng]*Sin[clat]) + 
   Cos[clat]*Sin[lat]]}

slippyDecimal2LngLat[x_, y_, z_] = 
 {x/2^z*2*Pi-Pi, Gudermannian[Pi - 2^(1 - z)*Pi*y]};

(* This is in standard projection; TODO: -1,-1 is a bad choice *)

lngLat2OrthoXY[lng_, lat_] = 
 If[Abs[lng] > Pi/2, {-1, -1}, {Cos[lat] Sin[lng], Sin[lat]}];

conds = {-Pi < lng, lng < Pi, -Pi/2 < lat, lat < Pi/2, -Pi < theta,
 theta < Pi, -Pi < clng, clng < Pi, -Pi/2 < clat, clat < Pi/2, d > 0,
 d < Pi, lat1 > -Pi/2, lat1 < Pi/2, lat2 > -Pi/2, lat2 < Pi/2,
 lng1 > -Pi, lng1 < Pi, lng2 > -Pi, lng2 < Pi
};

</formulas>

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

lngLat2CenterLngLat[lng_, lat_, clng_, clat_] = 
{ArcTan[Cos[clat]*Cos[lat]*Cos[clng - lng] + Sin[clat]*Sin[lat], 
  -(Cos[lat]*Sin[clng - lng])], 
 ArcTan[Sqrt[(Cos[clat]*Cos[lat]*Cos[clng - lng] + Sin[clat]*Sin[lat])^2 + 
    Cos[lat]^2*Sin[clng - lng]^2], -(Cos[lat]*Cos[clng - lng]*Sin[clat]) + 
   Cos[clat]*Sin[lat]]}


lngLat2CenterLngLat[lng, lat, 0, 0]



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
 FullSimplify[slippy2lat[x,y,z,(px+1/2),(py+1/2)]/180*Pi]

slippy2lonrad[x_,y_,z_,px_,py_] = FullSimplify[(x+(px+1/2)/256)*2*Pi/2^z-Pi]

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

slippyDecimal2LngLat[x_, y_, z_] = 
 {x/2^z*2*Pi-Pi, Gudermannian[Pi - 2^(1 - z)*Pi*y]};

lngLat2OrthoXY[lng_, lat_, clng_, clat_] = {
 Cos[lat]*Sin[lng - clng], Cos[lat]*Cos[lng - clng]*Sin[clat] +  
 Cos[clat]*Sin[lat]}

(* TODO: figure out how to avoid "through the Earth" crap *)

lngLat2OrthoXY[lng_, lat_, clng_, clat_] = {
 Cos[lat]*Sin[lng - clng], Cos[lat]*Cos[lng - clng]*Sin[clat] +  
 Cos[clat]*Sin[lat]};

lngLatTable = Flatten[Table[{lng, lat}, 
 {lng, -180*Degree, 180*Degree, 10*Degree},
 {lat, -90*Degree, 90*Degree, 10*Degree}], 1];

ListPlot[Table[lngLat2CenterLngLat[i[[1]], i[[2]], 0, 0], {i, lngLatTable}],
 AspectRatio -> 1]

ListPlot[Table[lngLat2CenterLngLat[i[[1]], i[[2]], 0, 40*Degree], 
 {i, lngLatTable}],  AspectRatio -> 1]

(* below, each line of longitude is separateish color *)

ListPlot[Partition[Table[lngLat2CenterLngLat[i[[1]], i[[2]], 0, 0], {i,
 lngLatTable}], 19], AspectRatio -> 1]

ListPlot[Partition[Table[lngLat2CenterLngLat[i[[1]], i[[2]], 0, 45*Degree], {i,
 lngLatTable}], 19], AspectRatio -> 1]

ListPlot[Table[lngLat2OrthoXY[i[[1]], i[[2]], 0, 0], {i, lngLatTable}], 
 AspectRatio -> 1]

slippyDecimal2OrthoXY[x_, y_, z_, clng_, clat_] = lngLat2OrthoXY[
 slippyDecimal2LngLat[x,y,z][[1]], slippyDecimal2LngLat[x,y,z][[2]],
 clng, clat];

ListPlot[
Flatten[Table[
 slippyDecimal2OrthoXY[x, y, 5, 0, 0], {x, 0, 31}, {y, 0, 31}], 
 1], AspectRatio -> 1]

ParametricPlot[lngLat2OrthoXY[lng, lat, 0, 0], {lng, -Pi, Pi}, {lat,
-Pi/2, Pi/2}]

(* work below starts 6/17/19 *)


ParametricPlot[slippyDecimal2OrthoXY[x, y, 4], {x, 0, 1}, {y, 0, 1}]

ParametricPlot[lngLat2OrthoXY[lng, lat, 0, 0], 
 {lng, -90*Degree, -80*Degree}, {lat, 20*Degree, 30*Degree},
 PlotRange -> {-1, 1}]


ParametricPlot[lngLat2OrthoXY[lng, lat, 0, 0], 
 {lng, -90*Degree, -80*Degree}, {lat, 20*Degree, 30*Degree}]


p1141 = ParametricPlot[lngLat2OrthoXY[lng, lat, 0, 0], 
 {lng, -90*Degree, -80*Degree}, {lat, 45*Degree, 55*Degree}]

p1142 = ParametricPlot[lngLat2OrthoXY[lng, lat, 0, 20*Degree], 
 {lng, -90*Degree, -80*Degree}, {lat, 45*Degree, 55*Degree}]

N[lngLat2OrthoXY[-90*Degree, 45*Degree, 0, 20*Degree]]

N[lngLat2OrthoXY[-90*Degree, 55*Degree, 0, 20*Degree]]

N[lngLat2OrthoXY[-80*Degree, 55*Degree, 0, 20*Degree]]

N[lngLat2OrthoXY[-80*Degree, 45*Degree, 0, 20*Degree]]

left slope is 0.788491

right slope is 0.740359

g1137 = Graphics[{
 Polygon[ { {-0.707107, 0.664463}, {-0.573576, 0.769751}, 
            {-0.564863, 0.803817}, {-0.696364, 0.706459} }]

}];

Show[{p1142, g1137}]

now, can we find the +- 90 degree stuff

lngLat2CenterLngLat[lng, lat, clng, clat][[1]]

Solve[lngLat2CenterLngLat[lng, lat, clng, clat][[1]] == Pi/2, lng]

ParametricPlot[lngLat2OrthoXY[lng, lat], {lng, -80*Degree,
-70*Degree}, {lat, 20*Degree, 30*Degree}]

f1706[lng_, lat_, clng_, clat_] =
FullSimplify[Apply[lngLat2OrthoXY, lngLat2CenterLngLat[lng, lat, clng, clat]],
 conds];

ParametricPlot[f1706[lng, lat, 0*Degree, 20*Degree], 
 {lng, -80*Degree, -70*Degree}, {lat, 20*Degree, 30*Degree}]


ParametricPlot[f1706[lng, lat, 0*Degree, 20*Degree], 
 {lng, -50*Degree, -40*Degree}, {lat, 50*Degree, 60*Degree}]

lngLat2OrthoXY[
lng, lat], {lng, -80*Degree,
-70*Degree}, {lat, 20*Degree, 30*Degree}]

(* on 20 Jun 2019, which lons at lat lat2 are d dist from lat1? *)

(* great circle formula (why don't I have this already??) *)

dist[lng1_, lat1_, lng2_, lat2_] = 
   ArcCos[Cos[lat1]*Cos[lat2]*Cos[lng1 - lng2] + Sin[lat1]*Sin[lat2]]

Solve[dist[0, lat1, lng2, lat2] == d, lng2]

FullSimplify[Solve[dist[0, lat1, lng2, lat2] == d, lng2], conds]

-ArcCos[Cos[d] Sec[lat1] Sec[lat2] - Tan[lat1] Tan[lat2]]

(* what %age of earth do we see at angle theta from distance d? *)

f1837[t_, d_, theta_] = {-d-1+t, t*Tan[theta]}

at high zoom it would be (where 1 is earth rad)

2*(d-1)*Tan[theta/2]

(* work below on 22 Jun 2019 *)

Solve[greatCircleDistance[0, lat1, lng2, lat2] == d, lng2]

temp1024 = 
(Solve[{d>0, d<Pi, dist[0, lat1, lng2, lat2] == d}, lng2] /. C[1] -> 0)[[
 2,1,2,1]];

temp1028 =
 (FullSimplify[Solve[greatCircleDistance[0, lat1, lng2, lat2] == d, lng2],
 conds] /. C[1] -> 0)[[2,1,2]];









(* the range of longitudes at lat2 that are dist d from
latitude lat1 and longitude 0 (translateable to any longitude) *)

latsDist2LngRange[lat1_, lat2_, d_] = 
 ArcCos[Cos[d] Sec[lat1] Sec[lat2] - Tan[lat1] Tan[lat2]];




