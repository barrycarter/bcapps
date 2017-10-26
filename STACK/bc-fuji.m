(* FORMULAS START HERE *)

(* 

Convert from NESW frame (north = y axis) to lat/lon frame

frame2frame[lat_, lon_] =  Transpose[{
 {-Sin[lon], Cos[lon], 0},
 {-(Cos[lon] Sin[lat]), -(Sin[lat] Sin[lon]), Cos[lat]},
 {Cos[lat] Cos[lon], Cos[lat] Sin[lon], Sin[lat]}
}];

*)

frame2frame[lat_, lon_] = {{-Sin[lon], -(Cos[lon]*Sin[lat]), 
     Cos[lat]*Cos[lon]}, {Cos[lon], -(Sin[lat]*Sin[lon]), Cos[lat]*Sin[lon]}, 
    {0, Cos[lat], Sin[lat]}}

(*

direction of shadow cast by object, given az/el of sun, converted to
frame of lat/lon

shadowdir[az_,el_,lat_,lon_] = frame2frame[lat,lon].sph2xyz[az+Pi,el,1]


*)

shadowdir[az_, el_, lat_, lon_] = {Cos[lat]*Cos[lon]*Sin[el] + 
     Cos[el]*Cos[lon]*Sin[az]*Sin[lat] + Cos[az]*Cos[el]*Sin[lon], 
    -(Cos[az]*Cos[el]*Cos[lon]) + Cos[lat]*Sin[el]*Sin[lon] + 
     Cos[el]*Sin[az]*Sin[lat]*Sin[lon], -(Cos[el]*Cos[lat]*Sin[az]) + 
     Sin[el]*Sin[lat]}

(*

Given a point h above the unit sphere at lat lon, and a vector v, find
t such that h+t*v hits the sphere

shadowhitT[lat_, lon_, h_, v_] := 
 Solve[Norm[sph2xyz[lon, lat, 1+h] + t*v] == 1, t]

and then use that value to find lat/lon of shadow hit

shadowhitLL[h_, v_, t_] ....

*)

shadowhitT[lat_, lon_, h_, v_] := Solve[Norm[sph2xyz[lon, lat, 1 + h]
+ t*v] == 1, t]

(*

putting it together (shadow cast in opposite direction)

conds = {-Pi/2 < lat < Pi/2, -Pi < lon < Pi, -Pi/2 < el < Pi/2, -Pi < az < Pi}

frame2frame[lat_, lon_] = Simplify[{{-Sin[lon], -(Cos[lon]*Sin[lat]),
Cos[lat]*Cos[lon]}, {Cos[lon], -(Sin[lat]*Sin[lon]),
Cos[lat]*Sin[lon]}, {0, Cos[lat], Sin[lat]}}, conds]


v = Simplify[frame2frame[lat,lon].sph2xyz[az+Pi,el,1], conds]

tsol=t /. Simplify[Solve[Norm[sph2xyz[lat,lon,1+h] + v*t] == 1, t], conds][[1]]

xyz = Simplify[sph2xyz[lat,lon,1+h]+v*tsol,conds]

Simplify[xyz2sph[xyz],conds]

sol = xyz2sph[xyz]



solu[lat_, lon_, az_, el_, h_] = sol

rainier 14411 ft at 46°51#10#N 121°45#37#W

*)


(* 

These formulas generate the x y points below:

(* the y value for any x for line with angle theta *)

y[r_,h_,theta_,x_] = r+h-x*Tan[theta]

(* distance squared from origin for any x *)

dist2[r_,h_,theta_,x_] = x^2 + y[r,h,theta,x]^2

conds = {x > 0, theta > 0, theta < Pi/2, r > 0, h > 0, h < r}

(* the useful x solution to where the line hits the sphere *)

xsol[r_,h_,theta_] = Simplify[Solve[dist2[r,h,theta,x] == r^2, x,
Reals], conds][[1,1,2,1]]

(* and the y solution [implicit] *)

ysol[r_,h_,theta_] = Simplify[y[r,h,theta,xsol[r,h,theta]], conds]

*)

xsol[r_, h_, theta_] = Cos[theta]^2*((h + r)*Tan[theta] - 
     Sqrt[-(h*(h + 2*r)) + r^2*Tan[theta]^2])

ysol[r_, h_, theta_] = Cos[theta]*((h + r)*Cos[theta] + 
     Sin[theta]*Sqrt[-(h*(h + 2*r)) + r^2*Tan[theta]^2])

(* FORMULAS END HERE *)

(* now to rotate back into position *)

let's say lon is 122*Degree, and lat is 35*Degree

ptest = sph2xyz[122.*Degree, 35.*Degree, 1.]

rotationMatrix[z, 90*Degree-122*Degree].ptest


rotationMatrix[x, 35*Degree].rotationMatrix[z, 90*Degree-122*Degree].ptest

rotationMatrix[z, az]


rotationMatrix[z, 270*Degree-95*Degree].
 rotationMatrix[x, 35*Degree].
 rotationMatrix[z, 90*Degree-122*Degree].{0,0,1}


rotationMatrix[z, 3*Pi/2-az].rotationMatrix[x, lat].rotationMatrix[z, Pi/2-lon]

test1727[az_, lat_, lon_] = 
Simplify[Inverse[
rotationMatrix[z, 3*Pi/2-az].rotationMatrix[x, lat].rotationMatrix[z, Pi/2-lon]
]]


test1728 = {xsol[1,0.1,50*Degree], ysol[1,0.1,50*Degree], 0}

test1727[100*Degree, 35*Degree, -106.5*Degree].test1728

test1727[100*Degree, 35*Degree, -106.5*Degree].{0,1,0}

after azimuth rotation, north pole is in yz plane elev lat

so -lat around x axis brings it to z axis then a z rot by lon brings it std pos (with standard orientation)

so location is at {0,1,0} with north in yz plane, say 

{0, Cos[5*Degree], Sin[5*Degree]}

example w abq nm, in std pos:

sph2xyz[-106.5*Degree, 35.*Degree, 1]

{-0.232652, -0.785419, 0.573576} = pos

{0.232652, 0.785419, 0.426424} = dir to n pole (not unit vector)

above is wrong but lets proceed

rotationMatrix[z, 106.5*Degree-90*Degree].
 {-0.232652, -0.785419, 0.573576}

rotationMatrix[z, 106.5*Degree+90*Degree].
 {-0.232652, -0.785419, 0.573576}

rotationMatrix[z, 106.5*Degree+90*Degree].
 {0.232652, 0.785419, 0.426424}

rotationMatrix[x, 35*Degree].
 rotationMatrix[z, 106.5*Degree+90*Degree].
  {-0.232652, -0.785419, 0.573576}

rotationMatrix[x, 35*Degree].
 rotationMatrix[z, 106.5*Degree+90*Degree].
 {0.232652, 0.785419, 0.426424}

ok, sun shining from east 10 deg high on short height albq

xsol[1, 0.01, 10*Degree]
ysol[1, 0.01, 10*Degree]

{0.0710425, 0.997473, 0}

convert back to standard world coords

rotationMatrix[z, -(106.5*Degree+90*Degree)].
 rotationMatrix[x, -35*Degree].
 {0,1,0}

rotationMatrix[z, -(106.5*Degree+90*Degree)].
 rotationMatrix[x, -35*Degree].
 {0.0710425, 0.997473, 0} 

sph2xyz[-106.5*Degree, 36.*Degree, 1] -
sph2xyz[-106.5*Degree, 35.*Degree, 1]

xyz2sph[
sph2xyz[-106.5*Degree, 35.01*Degree, 1] -
sph2xyz[-106.5*Degree, 35.*Degree, 1]
]/Degree

{73.5, 54.995, 0.01}

so the direction I consider north is

sph2xyz[180*Degree-106.5*Degree, 90*Degree-35*Degree, 1]

or

{0.162905, 0.549956, 0.819152}

rotationMatrix[x, 35*Degree]. 
 rotationMatrix[z, 106.5*Degree+90*Degree]. 
  {-0.232652, -0.785419, 0.573576} 

rotationMatrix[x, 35*Degree]. 
 rotationMatrix[z, 106.5*Degree+90*Degree]. 
 {0.162905, 0.549956, 0.819152} 

NOT: yes, that is z axis after transform, but up is now y down ick

rotationMatrix[x, 180*Degree-35*Degree]. 
 rotationMatrix[z, 106.5*Degree-90*Degree]. 
  {-0.232652, -0.785419, 0.573576} 

rotationMatrix[x, 180*Degree-35*Degree]. 
 rotationMatrix[z, 106.5*Degree-90*Degree]. 
 {0.162905, 0.549956, 0.819152}  

rotationMatrix[x, 180*Degree-35*Degree]. 
 rotationMatrix[z, 106.5*Degree-90*Degree]. 
  {0.232652, 0.785419, -0.573576} 

rotationMatrix[z, 180*Degree].
 rotationMatrix[x, 180*Degree-35*Degree]. 
  rotationMatrix[z, 106.5*Degree-90*Degree]. 
  {0.232652, 0.785419, -0.573576} 

before y rotation I want...

{0,1,0} -> {Cos[lat] Cos[lon], Cos[lat] Sin[lon], Sin[lat]}

above is junk... the up vector points away from center anyway

rotationMatrix[x, 35*Degree]. 
 rotationMatrix[z, 106.5*Degree+90*Degree]. 
  {-0.232652, -0.785419, 0.573576} 

rotationMatrix[x, 35*Degree]. 
 rotationMatrix[z, 106.5*Degree+90*Degree]. 
 {0.162905, 0.549956, 0.819152} 


xsol[1,1/100, 10*Degree]
ysol[1,1/100, 10*Degree]

rotationMatrix[z, -(-lon+Pi/2)].
 rotationMatrix[x, -lat].
 {xsol[1,1/100, 10*Degree],ysol[1,1/100, 10*Degree],0}


xsol[1,1/10000, 10*Degree]
ysol[1,1/10000, 10*Degree]

rotationMatrix[z, -(-106*Degree+Pi/2)].
 rotationMatrix[x, -35*Degree].
 {xsol[1,1/10000, 10*Degree],ysol[1,1/10000, 10*Degree],0}

xsol[1,1/1000, 10*Degree]
ysol[1,1/1000, 10*Degree]

rotationMatrix[z, -(-106*Degree+Pi/2)].
 rotationMatrix[x, -35*Degree].
 {xsol[1,1/1000, 10*Degree],ysol[1,1/1000, 10*Degree],0}

test1938 = rotationMatrix[x, 35*Degree]. 
  rotationMatrix[z, 106.5*Degree+90*Degree]


test1941 = test1938.sph2xyz[{-106.5*Degree, 35*Degree, 1}]

test1938.sph2xyz[{-106.5*Degree, 36*Degree, 1}] - test1941

test1938.sph2xyz[{-106.5*Degree, 34*Degree, 1}] 

test1938.sph2xyz[{-105.5*Degree, 35*Degree, 1}] 

sph2xyz[-106.5*Degree, 35.*Degree, 1] - sph2xyz[-105.5*Degree, 35.*Degree, 1]

sph2xyz[-106.5*Degree, 35.*Degree, 1] - sph2xyz[-106.6*Degree, 35.*Degree, 1]

Table[{lon, 
 xyz2sph[sph2xyz[lon*Degree, 60*Degree, 1] - 
         sph2xyz[lon*Degree-.01*Degree, 60*Degree, 1]]/
 Degree}, {lon,-180,180,10}]

Table[{lat, 
 xyz2sph[sph2xyz[60*Degree, lat*Degree, 1] - 
         sph2xyz[60*Degree, (lat-.01)*Degree, 1]]/
 Degree}, {lat,-90,90,10}]

Table[{lat, 
 xyz2sph[sph2xyz[122*Degree, lat*Degree, 1] - 
         sph2xyz[122*Degree, (lat-.01)*Degree, 1]]/
 Degree}, {lat,-90,90,10}]

sph2xyz[lon, lat+Pi/2, 1]



east[lat_,lon_] = {-Sin[lon], Cos[lon], 0}

north[lat_,lon_] = {-(Cos[lon] Sin[lat]), -(Sin[lat] Sin[lon]), Cos[lat]}

up[lat_,lon_] = {Cos[lat] Cos[lon], Cos[lat] Sin[lon], Sin[lat]}

from std frame to my frame is just:

m[lat_,lon_] = Transpose[{
 {-Sin[lon], Cos[lon], 0},
 {-(Cos[lon] Sin[lat]), -(Sin[lat] Sin[lon]), Cos[lat]},
 {Cos[lat] Cos[lon], Cos[lat] Sin[lon], Sin[lat]}
}];

simple case:

m[30*Degree, 0].sph2xyz[0*Degree, 5*Degree, 1]



testing:

sph2xyz[0, 0, 1] should go to east

m[lat,lon].sph2xyz[0, 0, 1]

m[lat,lon].sph2xyz[90*Degree, 0, 1]

m[lat,lon].sph2xyz[0, 90*Degree, 1]

now that these work, lets run tests

obj = sph2xyz[-106.5*Degree, 35.1*Degree, 1]*1001/1000

dir = m[-106.5*Degree, 35.1*Degree].sph2xyz[0.*Degree, 5.*Degree, 1]

Solve[Norm[obj + t*dir] == 1, t]

t -> 0.0018595

xyz2sph[obj + 0.0018595*dir]/Degree

(* exact below *)

obj = sph2xyz[-106*Degree, 35*Degree, 1]*1001/1000

(* dir to sun is... *)

dir = m[-106*Degree, 35*Degree].sph2xyz[0*Degree, 5*Degree, 1]

t0 = t /. Solve[Norm[obj + t*dir] == 1, t][[2]]

Simplify[xyz2sph[obj + t0*dir]/Degree]

these do form a basis

the xy location direction of az, el is sph2xyz[az,el,1] in the "standard" frame

suppose az = 90, sun is elevtude 5 deg, object is 1/1000 earth rad and we are at 35.1/-106.5

obj = sph2xyz[-106.5*Degree, 35.1*Degree, 1]*1001/1000

direction to sun is

m[-106.5*Degree, 35.1*Degree].sph2xyz[90.*Degree, 5.*Degree, 1]

dir = {0.815036, -0.246256, 0.524475}

so shadow is neg that

Solve[Norm[obj + t*dir] == 1, t]

t -> -0.00329084

xyz2sph[obj + -0.00329084*dir]/Degree

with exacts

suppose az = 90, sun is elevtude 5 deg, object is 1/1000 earth rad and we are at 35/-106

obj = sph2xyz[-106*Degree, 35*Degree, 1]*1001/1000

(* dir to sun is... *)

dir = m[-106*Degree, 35*Degree].sph2xyz[90*Degree, 5*Degree, 1]

t0 = t /. Solve[Norm[obj + t*dir] == 1, t][[1]]

Simplify[xyz2sph[obj + t0*dir]/Degree]

with testing




















I want to map (giving up on below, it's unclean)

east -> {1,0,0}

north -> {0,0,1}

up -> {0,1,0}

but vector addition probably doesn't map like that (but it should since its a LINEAR transform)

Inverse is 

m = {
 {-Sin[lon], Cos[lon], 0},
 {Cos[lat] Cos[lon], Cos[lat] Sin[lon], Sin[lat]},
 {-(Cos[lon] Sin[lat]), -(Sin[lat] Sin[lon]), Cos[lat]}
};

mi[lat_,lon_] = FullSimplify[Inverse[m]]

mi[35*Degree, -106.5*Degree].sph2xyz[-106.5*Degree, 35*Degree, 1]

mi[35*Degree, -85*Degree].sph2xyz[-85*Degree, 35*Degree, 1]





































Pi-az


(*

https://astronomy.stackexchange.com/questions/23165/viewing-diamond-fuji

TODO: refraction, Earth's curvature, Earth's ellipticity, ask Japanese Twitter peeps, DEM files for viewer, historical images

TODO: similar mountains incl Rainier?

TODO: shape of sun shadow, general concept of non flat horizon

Earth orientation: "standard" pos:

{0,0,1}: north pole

{1,0,0}: prime meridian/equator

{0,1,0}: prime meridian/+90E

sph2xyz[0,90*Degree,1]
sph2xyz[0,0*Degree,1]
sph2xyz[90*Degree,0,1]

local at lat lon converted

test[lat_,lon_] = rotationMatrix[z,-lon].rotationMatrix[y,lat-Pi/2]

test[0,lon].{0,0,1}


test[45*Degree, 45*Degree].{0,0,1}

y = -Sin[5*Degree] + b (for example)


*)

(* some approximations *)

(* 

NOTES:

highest mountain in Japan at 3,776.24 m (12,389 ft)

35°21#29#N 138°43#52#ECoordinates: 35°21#29#N 138°43#52#E#[2]

so at 5 degrees...

tan 5 = height / dist so dist = height / tan 5 or 43.162 km

14km at 15 degrees

6.5km at 30 degrees

flon = (138+43/60+52/3600)*Degree
flat = (35+21/60+29/3600)*Degree

(* kilometers *)
fele = 3776240/1000000

sph2xyz[flon, flat, rad[flat]+fele]

6371.009km = assumed radius for now

-Sin[5*Degree]*x+6371.009+fele

Solve[(-Sin[5*Degree]*x+6371.009+fele)^2 + x^2 == 6371.009^2]

Solve[(-Sin[60*Degree]*x+6371.009+fele)^2 + x^2 == 6371.009^2]

y[x_, theta_] = -Sin[theta]*x + 1.1

(* er is earth radius *)

y[x_, theta_, er_, elev_] = -Sin[theta]*er + (er + elev)

Solve[x^2 + y[x,theta,er,elev]^2 == er^2, x]

y[x_, theta_] = -Sin[theta]*rad[flat] + rad[flat] + fele

Solve[x^2 + y[x,theta]^2 == rad[flat]^2, x]

conds = {x>0, m<0, b>r}
Solve[x^2 + (m*x+b)^2 == r^2, x]




g0 = Graphics[{
 Circle[{0,0},1],
 Line[{{0,1},{0,1.1}}],
 Line[{ {-1, y[-1, 30*Degree]}, {1, y[1,30*Degree]}}]
}]

Show[g0]
showit

Solve[x^2 + y[x,30*Degree]^2 == 1, x]






*)

(*

diamond fuji pics:

https://ca.wikipedia.org/wiki/Diamond_Fuji Catalan

https://commons.wikimedia.org/wiki/File:Diamond_Fuji.jpg#globalusage

convert from frame at lan/lon/el to "earth frame"

local frame: north is y axis (map style)

testing/guessing

test = rotationMatrix[z,lon].rotationMatrix[x,lat-Pi/2]

test.{0,1,0} /. lat -> 0

THIS IS WRONG!!

that takes north to

test.{0,1,0}

what we need

at lat/lon 0, {0,1,0} goes to {0,0,1}

anywhere on eq in fact


*)


solx[theta_] = Simplify[x /. Solve[dist2[x,theta] == er^2, x][[1]],conds]

soly[theta_] = Simplify[y[solx[theta],theta], conds]

(* need 90 minus below *)

dist[theta_] = FullSimplify[er*(Pi/2-ArcTan[soly[theta]/solx[theta]]), conds]

Plot[dist[theta] /.  {h -> 3776240/1000000, er -> 6371.009}, 
 {theta,3*Degree,15*Degree}]

if theta is ArcCos[r/(r+h)] we should have corner case




FullSimplify[Pi/2-ArcTan[soly[theta]/solx[theta]], conds] /. 
 {h -> 3776240/1000000, er -> 6371.009}



min touch angle should be ArcCos[r/(r+h)]

min angle is thus ArcCos[r/(r+h)]


g0 = Graphics[{
 Circle[{0,0},1],
 Arrowheads[{-0.02, 0.02}],
 Arrow[{{0,0}, {0,1}}],
 Text[Style["r", FontSize -> 25], {0.03,0.5}],
 Text[Style["\[Theta]", FontSize -> 10], {-0.10, 1.185}],
 Line[{{-1,0}, {1,0}}],
 Arrow[{{-1, 1.15+Tan[37*Degree]}, {1, 1.15-Tan[37*Degree]}}],
 Arrow[{{0,0}, {0.2368, 0.971558}}],
 Dashed,
 Line[{{0,1.15}, {-1,1.15}}],
 Dashing[{}],
 Brown,
 Arrow[{{0,1}, {0,1.15}}],
 Text[Style["h", FontSize -> 25*Sqrt[.15]], {0.03,1.075}],
}]

Show[g0, PlotRange -> {{-1.1, 1.1}, {0, 2}}, ImageSize -> {800,600}]
showit

1.15-Sin[15*Degree]*-1

Sin[15*Degree]
0.258819

x sols are 0.2368 and 0.868651

y sol is .971558


NOT: 0.163448 is x sol,
NOT: 0.986552 is y sol

(* point thru x1,y1,z1 and x2,y2,z2 is distance r from x3,y3,z3 when? *)

line[t_]= {x1+t*(x2-x1),y1+t*(y2-y1),z1+t*(z2-z1)}

t /. Solve[Norm[line[t]-{x3,y3,z3}] == r, t][[1]]

line[%]

simpler if x3=y3=z3=0?

line[t_]= {x1+t*(x2-x1),y1+t*(y2-y1),z1+t*(z2-z1)}

t /. Solve[Norm[line[t]] == r, t][[1]]

line[%]


