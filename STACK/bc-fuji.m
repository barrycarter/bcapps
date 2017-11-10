TODO: not JUST methodology, actual answer

TODO: better formulas

[[image40]]

Given the sun's elevation $\theta$, we draw the Earth as a sphere of radius $r$ and choose our coordinate system such that:

  - the mountain's location is {0,0,1}

  - the sun is shining from the -x axis

yielding the diagram above (note that we are looking at x (horizontal) and z (vertical) axes in the xz plane).

The line connecting the incoming sunlight to the mountain has a slope of $-\tan (\theta )$ and intercepts the z axis at $z=h+r$. The formula of the line is thus:

$z(x)=h+r-x \tan (\theta )$

We want to find where this line intersects our sphere. This occurs when it's distance from the origin is $r$, so we solve:

$\sqrt{x^2+z(x)^2}=r$

The number of solutions depends on the value of $\theta$. The "critical" value of theta is $\tan ^{-1}\left(\frac{\sqrt{h} \sqrt{h+2 r}}{r}\right)$:

  - If $\theta$ is less than this critical value, there is no solution and the mountaintop's shadow never hits the Earth at all.

  - If $\theta$ is greater than this critical value, there are two solutions, and the mountaintop shadow hits the Earth at the lower of the two x values. This will be our primary case.

  - If $\theta$ is exactly equal to the critical value:

    - There is exactly one solution
    - The shadow hits at a distance of $r \tan ^{-1}\left(\frac{\sqrt{h (h+2 r)}}{r}\right)$ from the mountaintop
    - This is the maximum distance the shadow can fall
    - Since this also represents the maximum distance one can see from the mountaintop, it agrees with [Wikipedia's exact horizon formula](https://en.wikipedia.org/wiki/Horizon#Geometrical_model)

Returning to our primary case, we find the lower value of $x$ and the correspoing $z$ by solving $\sqrt{x^2+z(x)^2}=r$ as above. The results:

$
   x=\cos ^2(\theta ) \left((h+r) \tan (\theta )-\sqrt{r^2 \sec ^2(\theta
    )-(h+r)^2}\right)
$

$
   z=\sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}-(h+r)
    \tan (\theta )\right)^2}

$

Noticing the tangent of the central angle is $\frac{x}{z}$, we can take the arctangent to find the central angle:

$
   \tan ^{-1}\left(\frac{\cos ^2(\theta ) \left((h+r) \tan (\theta )-\sqrt{r^2
   \sec ^2(\theta )-(h+r)^2}\right)}{\sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2
    \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)^2}}\right)
$

and multiply it by r to find the great circle distance:

$
  r \tan ^{-1}\left(\frac{\cos ^2(\theta ) \left((h+r) \tan (\theta )-\sqrt{r^2
   \sec ^2(\theta )-(h+r)^2}\right)}{\sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2
   \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)^2}}\right)
$

This is essentially the solution: the shadow lands in the direction opposite to where the Sun is shining at the distance above.

Of course, we'd probably like the answer in latitude and longitude, so we perform 3 rotations on the x and z coordinates above:

  - If we rotate by the sun's azimuth (hereafter az), north points towards the negative x axis. To make things cleaner, we rotate by $\text{az}+90$ degrees, so north becomes the positive y axis

  - We now rotate by $\text{lat}-90$ degrees around the y axis, where $\text{lat}$ is the latitude of our mountain. The coordinates of the North Pole are now $\{0,0,1\}$.

  - Finally we rotate by $\text{lon}$ degrees where $\text{lon}$ is the longitude of our mountain, so that the spherical coordinates now represent latitude and longitude. More specifically, in this final coordinate system:

    - The longitude of $\{x,y,z\}$ is $\tan ^{-1}(x,y)$, using the [two argument form of tangent](https://en.wikipedia.org/wiki/Atan2)

    - The latitude is $\tan ^{-1}\left(\sqrt{x^2+y^2},z\right)$, also using the two argument form of tangent.

After these transformations, our mountain's coordinates are:

$
   \left\{\cos ^2(\theta ) (\sin (\text{az}) \sin (\text{lat}) \cos
    (\text{lon})+\cos (\text{az}) \sin (\text{lon})) \left(\sqrt{r^2 \sec
    ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)+\cos (\text{lat}) \cos
    (\text{lon}) \sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2 \sec ^2(\theta
   )-(h+r)^2}-(h+r) \tan (\theta )\right)^2},\cos ^2(\theta ) (\cos (\text{az})
    \cos (\text{lon})-\sin (\text{az}) \sin (\text{lat}) \sin (\text{lon}))
    \left((h+r) \tan (\theta )-\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}\right)+\cos
    (\text{lat}) \sin (\text{lon}) \sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2
    \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)^2},\sin (\text{az})
   \cos (\text{lat}) \cos ^2(\theta ) \left((h+r) \tan (\theta )-\sqrt{r^2 \sec
    ^2(\theta )-(h+r)^2}\right)+\sin (\text{lat}) \sqrt{r^2-\cos ^4(\theta )
    \left(\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta
    )\right)^2}\right\}

$

Our shadow thus falls on the following longitude:

$
   \tan ^{-1}\left(\cos ^2(\theta ) (\sin (\text{az}) \sin (\text{lat}) \cos
    (\text{lon})+\cos (\text{az}) \sin (\text{lon})) \left(\sqrt{r^2 \sec
    ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)+\cos (\text{lat}) \cos
    (\text{lon}) \sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2 \sec ^2(\theta
   )-(h+r)^2}-(h+r) \tan (\theta )\right)^2},\cos ^2(\theta ) (\cos (\text{az})
    \cos (\text{lon})-\sin (\text{az}) \sin (\text{lat}) \sin (\text{lon}))
    \left((h+r) \tan (\theta )-\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}\right)+\cos
    (\text{lat}) \sin (\text{lon}) \sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2
    \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)^2}\right)
$

and the following latitude:

$
   \tan ^{-1}\left(\sqrt{\left(\cos ^2(\theta ) (\sin (\text{az}) \sin
    (\text{lat}) \cos (\text{lon})+\cos (\text{az}) \sin (\text{lon}))
    \left(\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)+\cos
    (\text{lat}) \cos (\text{lon}) \sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2
   \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta )\right)^2}\right)^2+\left(\cos
    ^2(\theta ) (\cos (\text{az}) \cos (\text{lon})-\sin (\text{az}) \sin
    (\text{lat}) \sin (\text{lon})) \left((h+r) \tan (\theta )-\sqrt{r^2 \sec
    ^2(\theta )-(h+r)^2}\right)+\cos (\text{lat}) \sin (\text{lon})
    \sqrt{r^2-\cos ^4(\theta ) \left(\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}-(h+r)
    \tan (\theta )\right)^2}\right)^2},\sin (\text{az}) \cos (\text{lat}) \cos
    ^2(\theta ) \left((h+r) \tan (\theta )-\sqrt{r^2 \sec ^2(\theta
    )-(h+r)^2}\right)+\sin (\text{lat}) \sqrt{r^2-\cos ^4(\theta )
    \left(\sqrt{r^2 \sec ^2(\theta )-(h+r)^2}-(h+r) \tan (\theta
    )\right)^2}\right)
$

******* STOP WRITING HERE, more functions

A celestial object's altazimuthal path through the sky is determined by two factors: (TODO: position?)

  - the object's declination
  - the observer's latitude


newangles[h, r, theta, az, lat, lon]

finalpos[h_, r_, ha_, dec_, lat_, lon_] =
 newangles[h, r, HADecLat2azEl[ha, dec, lat][[2]], 
 HADecLat2azEl[ha, dec, lat][[1]], lat, lon]

test1748 = Table[{ha, 
 N[finalpos[fuji[ele], rad[fuji[lat]], ha*Pi/12, ecliptic, fuji[lat],
fuji[lon]]/Degree]}, {ha,0,24,0.25}]

Transpose[Take[Transpose[Transpose[test1748][[2]]],2]]

(* dislike writing this as a module, but easier because of checks *)

shadowLatLon[h_, r_, ha_, dec_, lat_, lon_] := Module[{az,el},
 {az,el} =  HADecLat2azEl[ha, dec, lat];
 If[el<ctheta[h,r], Return[{0,0}]];
 Return[Take[newangles[h,r,el,az,lat,lon],2]];
];

test1833 = Table[{ha, 
 shadowLatLon[fuji[ele], rad[fuji[lat]], ha*Pi/12, ecliptic, fuji[lat],
fuji[lon]]/Degree}, {ha,-12,12,0.25}]

Transpose[Take[Transpose[Transpose[test1833][[2]]],2]]

Export["/tmp/temp.csv", %]



N[finalpos[fuji[ele], rad[fuji[lat]], 7/12*Pi, ecliptic, fuji[lat],
fuji[lon]]/Degree]

N[finalpos[fuji[ele], rad[fuji[lat]], -7/12*Pi, ecliptic, fuji[lat],
fuji[lon]]/Degree]

HADecLat2azEl[0, ecliptic, flat]

HADecLat2azEl[Pi/2, ecliptic, flat]

HADecLat2azEl[7/12*Pi, ecliptic, flat]

newangles[fuji[ele], rad[flat], 78*Degree, 180*Degree, flat, flon]/Degree

newangles[fuji[ele], rad[flat], 13.3081*Degree, -70.5272*Degree, flat, flon]/Degree

newangles[fuji[ele], rad[flat], 2.09319*Degree, -62.4753*Degree, flat, flon]/Degree

TODO: fuji peak lat/lon not certain

NOTE: google maps: lat, lon other way fails


TODO: note no solution when deg low enough

TODO: Test

fuji: 

flon = (138+43/60+52/3600)*Degree
flat = (35+21/60+29/3600)*Degree

(* kilometers *)
fele = 3776240/1000000

6371.02

newangles[fuji[ele], rad[flat], 3*Degree, 155*Degree, flat, flon]/Degree

N[{xsol[fuji[ele], rad[flat], 3*Degree],0,zsol[fuji[ele], rad[flat], 3*Degree]}]

rotationMatrix[z, 155*Degree + Pi/2].
 N[{xsol[fuji[ele], rad[flat], 3*Degree],0,zsol[fuji[ele], rad[flat], 3*Degree]}]

rotationMatrix[y, flat-Pi/2].
 rotationMatrix[z, 155*Degree + Pi/2].
 N[{xsol[fele, rad[flat], 3*Degree],0,zsol[fele, rad[flat], 3*Degree]}]


TODO: easier, not sure this answer is right, hyper discliam?

TODO: elevation

TODO: reference this file, sloppy degrees/radians

TODO: no hit case

TODO: spherical earth assum

TODO: make sure I have the correct hitting point

TODO: why azel not SPICE (refraction)

<formulas>

conds = {h>0, r>0, h<r, 0 < theta < Pi/2, Element[x, Reals], -Pi/2 <
lat < Pi/2, -Pi < lon < Pi}

z[theta_,x_] = -Tan[theta]*x + r + h

(*

precomp for speed, but this is how I generated them:

xsol[h_,r_,theta_] = 
FullSimplify[Simplify[Solve[z[theta,x]^2 + x^2==r^2, x, Reals],conds]
 [[1,1,2,1]],conds]

zsol[h_,r_,theta_] = FullSimplify[Sqrt[r^2-xsol[h,r,theta]^2], conds]

ang[h_,r_,theta_] = 
 FullSimplify[ArcTan[xsol[h,r,theta]/zsol[h,r,theta]], conds]

dist[h_,r_,theta_] = FullSimplify[r*ang[h,r,theta], conds]

newcoords[h_, r_, theta_, az_, lat_, lon_] = 
FullSimplify[rotationMatrix[z, lon].
 rotationMatrix[y, lat-Pi/2].
  rotationMatrix[z, az+Pi/2].
  {xsol[h,r,theta], 0, zsol[h,r,theta]}, conds]

newcoords[h_, r_, theta_, az_, lat_, lon_] = 
FullSimplify[rotationMatrix[z, lon-Pi/2].
 rotationMatrix[x, Pi/2-lat].
  rotationMatrix[z, -az+Pi/2].
  {xsol[h,r,theta], 0, zsol[h,r,theta]}, conds]

newangles[h_, r_, theta_, az_, lat_, lon_] = 
 Simplify[xyz2sph[newcoords[h,r,theta,az,lat,lon]], conds]

*)

xsol[h_, r_, theta_] = Cos[theta]^2*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
     (h + r)*Tan[theta])

zsol[h_, r_, theta_] = 
   Sqrt[r^2 - Cos[theta]^4*(Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - 
        (h + r)*Tan[theta])^2]

ang[h_, r_, theta_] = 
   ArcTan[(Cos[theta]^2*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
       (h + r)*Tan[theta]))/
     Sqrt[r^2 - Cos[theta]^4*(Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - 
          (h + r)*Tan[theta])^2]]

dist[h_, r_, theta_] = 
   r*ArcTan[(Cos[theta]^2*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
        (h + r)*Tan[theta]))/Sqrt[r^2 - Cos[theta]^4*
         (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]

newcoords[h_, r_, theta_, az_, lat_, lon_] = 
   {Cos[theta]^2*(Cos[az]*Cos[lon]*Sin[lat] + Sin[az]*Sin[lon])*
      (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
     Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
         (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2], 
    Cos[theta]^2*(-(Cos[lon]*Sin[az]) + Cos[az]*Sin[lat]*Sin[lon])*
      (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
     Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
         (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2], 
    -(Cos[az]*Cos[lat]*Cos[theta]^2*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
        (h + r)*Tan[theta])) + Sin[lat]*
      Sqrt[r^2 - Cos[theta]^4*(Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - 
           (h + r)*Tan[theta])^2]}

newangles[h_, r_, theta_, az_, lat_, lon_] = 
   {ArcTan[Cos[theta]^2*(Cos[az]*Cos[lon]*Sin[lat] + Sin[az]*Sin[lon])*
       (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
      Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
          (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2], 
     Cos[theta]^2*(-(Cos[lon]*Sin[az]) + Cos[az]*Sin[lat]*Sin[lon])*
       (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
      Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
          (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]], 
    ArcTan[Sqrt[(Cos[theta]^2*(Cos[az]*Cos[lon]*Sin[lat] + Sin[az]*Sin[lon])*
          (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
         Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2])^2 + 
       (Cos[theta]^2*(-(Cos[lon]*Sin[az]) + Cos[az]*Sin[lat]*Sin[lon])*
          (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
         Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2])^2], 
     -(Cos[az]*Cos[lat]*Cos[theta]^2*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
         (h + r)*Tan[theta])) + Sin[lat]*
       Sqrt[r^2 - Cos[theta]^4*(Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - 
            (h + r)*Tan[theta])^2]], 
    Sqrt[Abs[Cos[theta]^2*(Cos[az]*Cos[lon]*Sin[lat] + Sin[az]*Sin[lon])*
          (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
         Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]^2 + 
     Abs[Cos[az]*Cos[lat]*Cos[theta]^2*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
           (h + r)*Tan[theta]) - Sin[lat]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]^2 + 
      Abs[Cos[theta]^2*(-(Cos[lon]*Sin[az]) + Cos[az]*Sin[lat]*Sin[lon])*
          (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
         Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
             (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]^2]}

(* critical theta = one solution only *)

ctheta[h_,r_] = ArcTan[Sqrt[h]*Sqrt[h+2*r]/r]

(* critical distance *)

cdist[h_,r_] = Simplify[dist[h,r,ctheta[h,r]],conds]

(* longitude, latitude and elevation of Mt Fuji *)

fuji[lon] = N[(138+43/60+52/3600)*Degree,20]
fuji[lat] = N[(35+21/60+29/3600)*Degree,20]
fuji[ele] = N[3776240/1000000,20]

</formulas>

TODO: slightly more accurate formula for rad

TODO: fourth powers of cosine scary!

TODO: convinced simpler answer

(* 

TODO: shadows "bend"

putting it together (shadow cast in opposite direction)

rainier 14411 ft at 46°51#10#N 121°45#37#W

*)


(* 


(*

https://astronomy.stackexchange.com/questions/23165/viewing-diamond-fuji

TODO: refraction, Earth's curvature, Earth's ellipticity, ask Japanese Twitter peeps, DEM files for viewer, historical images, refraction of fuji too

TODO: similar mountains incl Rainier?

TODO: precision vs accuracy

TODO: shape of sun shadow, general concept of non flat horizon

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


(*

original approach again, but make the diagram the x and z axes

rotated so sun is coming from "west" (technically, no directions at
north pole, but we will compensate when rotating)

conds = {r>0, h<r, h>0, 0 < theta < Pi, Element[{x,z}, Reals]}

z = r+h-Tan[theta]*x

always taking first solution might be mistake

zsol[theta_] = z /. FullSimplify[Solve[x^2 + z^2 == r^2, x][[1]], conds]

xsol[theta_] = FullSimplify[Sqrt[r^2-zsol[theta]^2], conds]

for our example 3 degree elevation

r = 6371
h = 4

N[zsol[3*Degree]]

N[xsol[3*Degree]]

direction change

sun is coming from -x direction, which we want to be "west" we thus rotateon the z axis by solar azimuth plus 90 to make -x the west axis

vec = N[{xsol[3*Degree], 0, zsol[3*Degree]}]

az = -107*Degree

vec2 = rotationMatrix[z, az+Pi/2].vec

(seems reasonable)

we now rotate along the y axis to restore latitude.. by 90-lat (which is negative here)

lat = 35*Degree

vec3 = rotationMatrix[y, lat-Pi/2].vec2

finally, we restore longitude

rotationMatrix[z,lon]







Pi/2-FullSimplify[ArcTan[zsol/xsol], conds]

phi = FullSimplify[Pi/2-ArcTan[zsol/xsol], conds]

dist2 = FullSimplify[r*phi, conds]

phi = (Pi - 2*ArcTan[(Cos[theta]*((h + r)*Cos[theta] + 
          Sqrt[-(h + r)^2 + r^2*Sec[theta]^2]*Sin[theta]))/
        Sqrt[r^2 - Cos[theta]^2*((h + r)*Cos[theta] + 
             Sqrt[-(h + r)^2 + r^2*Sec[theta]^2]*Sin[theta])^2]])/2

dist2 = 
   (r*(Pi - 2*ArcTan[(Cos[theta]*((h + r)*Cos[theta] + 
           Sqrt[-(h + r)^2 + r^2*Sec[theta]^2]*Sin[theta]))/
         Sqrt[r^2 - Cos[theta]^2*((h + r)*Cos[theta] + Sqrt[-(h + r)^2 + 
                 r^2*Sec[theta]^2]*Sin[theta])^2]]))/2

dist[r_, h_, theta_] = dist2

dist[6371.009, 3776240/1000000., 2*Degree]

dist[6371.009, 3776240/1000000., 1.97223*Degree] is about 218.731km

we now convert to std coords

sun is coming from -x direction, which we want to be "west" we thus rotateon the z axis by solar azimuth plus 90 to make -x the west axis

rotationMatrix[z, Pi/2+az]

we now rotate along the y axis to restore latitude.. by 90-lat (which is negative here)

rotationMatrix[y, lat-Pi/2]

finally, we restore longitude

rotationMatrix[z,lon]

lets try with some real numbers:

-12° 20' 51" = todays solar dec

decl = (-12-20/60-51/3600)*Degree

lat = 35.1*Degree

lon = -106.5*Degree



Plot[HADecLat2azEl[ha/12*Pi, decl, lat][[2]]/Degree, {ha,0,24}]

FindRoot[HADecLat2azEl[ha, decl, lat][[2]] == 3*Degree, {ha,Pi/4}]

ha -> 1.34967

HADecLat2azEl[1.34967, decl, lat]/Degree

{-107.371, 2.99986}

ok, setting sun.. lets do the math

testing:

cirital theta?

cthet = FullSimplify[1/ArcTan[Sqrt[(r+h)^2-r^2]/(r+h)],conds]

the +- on the two sols is

test1359 = Simplify[Solve[z[theta,x]^2 + x^2==r^2, x, Reals],conds]

Simplify[test1359[[1,1,2,1]] + test1359[[2,1,2,1]],conds]

Simplify[(test1359[[1,1,2,1]] + test1359[[2,1,2,1]])/2,conds]

answer: (h + r) Sin[2 theta]

unchaning term below?

half that is: (h + r) Cos[theta] Sin[theta]

FullSimplify[(test1359[[1,1,2,1]] - test1359[[2,1,2,1]])/2,conds]


cos(theta) = sin(90-theta) = r/(r+h)

sin(theta) = cos(90-theta) = Sqrt[(r+h)^2-r^2]

(* general case: when does line hit circle *)

lhc[m_, b_, cx_, cy_, r_] =
 Solve[Sqrt[(m*x+b-cy)^2 + (x-cx)^2] == r, x, Reals]

test0921[m_, b_, r_] =
 Solve[Sqrt[x^2 + (m*x+b)^2] == r, x, Reals]

test0902[m_, b_, r_] =
 Simplify[Solve[x^2 + (m*x+b)^2 == r^2, x, Reals], {r>0, r>b, b>0}]

Solve[x^2 + (m*x + 1/10)^2 == 1, x, Reals]


(1+m^2)*x^2 + 2bm*x + (b^2-r^2) = 0

(2*b*m)^2 - 4*(b^2-r^2)*(1+m^2)

i lose the negative solution, so let's try

Simplify[Solve[x^2 + (-m*x+b)^2 == r^2, x, Reals],conds]

the deter is

x^2 + (-m*x+b)^2-r^2

A = 1+m^2
C = b^2 - r^2

B = -2*b*m

Simplify[Solve[x^2 + (-2*x+b)^2 == r^2, x, Reals],conds]

Simplify[Solve[Norm[{x, m*x+b}] == r, x, Reals], {r>b,r>0,b>0,m<0}]

Solve[(1+m^2)*r^2-b^2==0, m]

Simplify[Solve[Norm[{x, -5*x+b}] == r, x, Reals], {r>b,r>0,b>0,m<0}]



test0848 = Simplify[lhc[m,b,0,0,r], {conds, b<r}]

Simplify[(test0848[[1,1,2]]+test0848[[2,1,2]])/2]

test0849 = Simplify[(test0848[[1,1,2]]-test0848[[2,1,2]])/2]

Simplify[Solve[test0849 == 0, m]]

let's use r = 1, b=0.1

test0853 = lhc[m, 1/10, 0, 0, 1]

Simplify[(test0853[[1,1,2]]+test0853[[2,1,2]])/2]

Simplify[(test0853[[1,1,2]]-test0853[[2,1,2]])/2]





the solutions become one when

(1+m^2)*r^2 - b^2 is 0

test0847 = Solve[(1+m^2)*r^2 - b^2 == 0, m]

or when slope is Sqrt[b^2-r^2]/r



in my case

ArcTan[(h^2-r^2)/r]

maybe not

Simplify[(lhc[m,b,0,0,r][[1,1,2]] + lhc[m,b,0,0,r][[2,1,2]])/2]

that's -b*m/(1+m^2)

Simplify[(lhc[m,b,0,0,r][[1,1,2]] - lhc[m,b,0,0,r][[2,1,2]])/2]

test = Simplify[lhc[Sqrt[b^2-r^2]/r, b, 0, 0, r]]

yes, one solution only, 

r*Sqrt[b^2-r^2]/b

Sqrt[(h^2-r^2)]/r 

Simplify[
Reduce[{x^2+y^2 == r^2, y == m*x+b}, x, Reals], m<0]

x^2 + (m*x+b)^2 - r^2

C = b^2 - r^2

B = 2*b*m

A = 1+m^2

(2*b*m)^2 - 4*(1+m^2)*(b^2-r^2)

Reduce[(2*b*m)^2 - 4*(1+m^2)*(b^2-r^2) == 0, m]

x^2 + (m*x+1/10)^2 - 1^2

(little b is 1/10, r is 1)

C = -99/100 (consistent w/ above)

B = m/5 (consistent w/ above)

A = 1 + m^2 (consistent w/ above)

m/5^2 - 4*(-99/100)*(1+m^2)

Solve[x^2 + (Sqrt[r^2-b^2]/r*x + b)^2 == r^2, x]

derv is 0 at

-b*m/(1+m^2)

dist at that point is

xmin = -b*m/(1+m^2)

Simplify[xmin^2 + (m*xmin+b)^2]

b^2/(1+m^2)

single solution when that distance is r^2

Solve[b^2/(1+m^2) == r^2, m]

Solve[b^2/n == r^2, n]

n -> b^2/r^2

Solve[1+m^2 == b^2/r^2, m]

b^2/r^2-1

Plot[x^2 + (5-3*x)^2, {x,-5,5}]

3/2 is min poit

Plot[x^2 + (5-3*x)^2, {x,1,2}]

TODO: re read and consistent on mountain/earth/etc

TODO: flat earth leewhere
As per the diagram, this occurs at two points. We want the solution with the lower x value:

TODO: no moon diamond

TODO: answer is wrong

test1116 = GeoPosition[{fuji[lat]/Degree, fuji[lon]/Degree}]

GeoElevationData[test1116]

(* elevation in feet, lat lon in degrees *)

elev[lat_,lon_] := elev[lat, lon] = 
 GeoElevationData[GeoPosition[{lat,lon}]][[1]]

ContourPlot[elev[lat,lon], {lat,35,35.2}, {lon, -106.6, -106.4}]

ContourPlot[elev[lat,lon], {lat,35.09,35.11}, {lon, -106.51, -106.49}]


ContourPlot[elev[lat,lon], {lat,35.09,35.11}, {lon, -106.51, -106.49},
 PlotPoints -> 5]

GeoElevationData[GeoPosition[{{34, -107}, {36, -105}}]]

test1146 = GeoElevationData[{GeoPosition[{34, -107}], GeoPosition[{36, -105}]}]

test1147 = Normal[test1146];

test1147[[5,1]] is 6968.5 feet

ListContourPlot[test1147]

ListContourPlot[test1147, Contours -> 255, ColorFunction -> Hue]

test1158 = GeoElevationData[{GeoPosition[{35.03, -106.7}], 
 GeoPosition[{35.20, -106.4}]}]

ListContourPlot[test1158]

ListContourPlot[test1158, Contours -> 255, ColorFunction -> Hue]

ListContourPlot[test1158, Contours -> 255, ColorFunction -> Hue,
 PlotLegends -> True]

Actual observations:

Diamond Fuji, the sunset over the summit of Mt. Fuji, is observed on November 8,... [year is 2012]

http://www.gettyimages.fr/%C3%A9v%C3%A9nement/diamond-fuji-observed-156231577

Diamond Fuji photo taken Feb. 17, 2011

https://www.garyjwolff.com/diamond-fuji-viewing-spots-dates-and-times-in-tokyo.html

from the shore of Lake Yamanakako, one of Fuji's 5 Lakes.


Photo: "Diamond Fuji - 2014/11/15 - 3:27pm"
From Review: Lake Yamanaka of Lake Yamanaka

https://www.tripadvisor.com/LocationPhotoDirectLink-g1104179-d1369080-i115862499-Lake_Yamanaka-Yamanakako_mura_Minamitsuru_gun_Yamanashi_Prefecture_Chub.html

AstronomicalData["Sun", {"Declination", {2014, 11, 15}}]
AstronomicalData["Sun", {"Declination", {2014, 11, 14, 18, 27}}]        

-18.41902 degrees

newangles[fuji[ele], rad[fuji[lat]], 11.76*Degree, 109.02*Degree, fuji[lat],
 fuji[lon]]/Degree

{138.541, 35.4114, 365032.}



SunPosition[GeoPosition[{fuji[lat], fuji[lon]}], 
 DateObject[{2014, 11, 15, 15, 27}, TimeZone -> +9]]

SunPosition[GeoPosition[{fuji[lat], fuji[lon]}], 
 DateObject[{2014, 11, 15, 6, 27}, TimeZone -> 0]]

SunPosition[GeoPosition[{fuji[lat], fuji[lon]}/Degree], 
 DateObject[{2014, 11, 15, 15, 27}, TimeZone -> +9]]

{236.30 degrees, 12.47 degrees}

SunPosition[GeoPosition[{fuji[lat], fuji[lon]}/Degree], 
 DateObject[{2014, 11, 15, 15, 28}, TimeZone -> +9]]

{236.47 degrees, 12.30 degrees}

newangles[fuji[ele], rad[fuji[lat]], 12.30*Degree, 236.47*Degree, fuji[lat],
 fuji[lon]]/Degree

{138.891, 35.4445} is 1m later

{138.889, 35.4437} was original

newangles[fuji[ele], rad[fuji[lat]], 12.47*Degree, 236.30*Degree, fuji[lat],
 fuji[lon]]/Degree



SunPosition[GeoPosition[{fuji[lat], fuji[lon]}], 
 DateObject[{2014, 11, 15, 15, 27}, TimeZone -> +9],
 CelestialSystem -> "Horizon", AltitudeMethod -> "TrueAltitude"]

Out[67]= {109.02 degrees, 11.76 degrees}

Entity["Lake", "Yamanka"]

test0815 = WolframAlpha["Lake Yamanka latitude longitude"]

35Â° 25'N, 138Â° 52' 30"E

unix2Date[t_] := ToDate[t+2208988800]


postime[t_] := Module[{d, s, n},
 d = ToDate[t+2208988800];
 s = SunPosition[GeoPosition[{fuji[lat], fuji[lon]}], d];
 If[s[[2,1]] < 0, Return[]];
 n = newangles[fuji[ele], rad[fuji[lat]], s[[2,1]]*Degree, s[[1,1]]*Degree, 
  fuji[lat], fuji[lon]];
 If[Im[n[[1]]] > 0, Return[]];
 Return[Take[n,2]/Degree];
]



TODO: how well does flat approx work? 

test1126 = GeoPosition[{fuji[lat]/Degree, fuji[lon]/Degree}]

test1127 = GeoElevationData[test1126]

test1129 = GeoPosition[{fuji[lat]/Degree, fuji[lon]/Degree, test1127}]


test1128 = GeoElevationData[{
 GeoPosition[{fuji[lat]/Degree-0.001, -107}], GeoPosition[{36, -105}]}]

GeoPositionENU[{0, 0, Quantity[10, "Kilometers"]}, 
 Entity["City", {"NewYork", "NewYork", "UnitedStates"}]]

GeoPosition[%]

GeoPositionENU[{Quantity[100, "Kilometers"], 0, 0}, 
 Entity["City", {"NewYork", "NewYork", "UnitedStates"}]]

for every 1km of travel:

-Tan[el] downwards, Cos[az] north, Sin[az] east

(* travel distance d in az/el direction from lat/lon, assuming az 0 =
east and counting counterclockwise [just for now and for this function] *)

travel[lat_, lon_, az_, el_, d_] := GeoPosition[
 GeoPositionENU[
  Quantity[d,"kilometer"]*{Cos[az] Cos[el], Cos[el] Sin[az], Sin[el]},
 GeoPosition[{lat/Degree, lon/Degree}]]];

travel[35*Degree,-106.5*Degree, 0, -1*Degree, 10]

travel[35*Degree,-106*Degree, 0, -1*Degree, 10]

Plot[travel[35*Degree,-106.5*Degree, 0, 1*Degree, x][[1,3]],
 {x,0,10^3}]

GeoDistance[{35, -106.5}, {35, -106.39}]

(* includes height, d in km, h in m *)

travel2[lat_, lon_, h_, az_, el_, d_] := Module[{elev1, pos1, pos2, elev2},
 pos1 = GeoPosition[{lat, lon}];
 elev1 = GeoElevationData[pos1];
 pos1 = GeoPosition[{lat, lon, elev1[[1]] + h}];
 pos2 = GeoPosition[GeoPositionENU[
  Quantity[d,"km"]*{Cos[az] Cos[el], Cos[el] Sin[az], Sin[el]}, pos1]];
 elev2 = GeoElevationData[pos2];
 Return[Flatten[{Take[pos2[[1]],2], pos2[[1,3]]-elev2[[1]]}]]
]

Plot[travel2[fuji[lat],fuji[lon],0,0,-1*Degree,d][[3]], {d,0,10}]

delta = 1/100000;

ContourPlot[GeoElevationData[GeoPosition[{lat, lon}]],
 {lat, fuji[lat]/Degree-delta, fuji[lat]/Degree+delta},
 {lon, fuji[lon]/Degree-delta, fuji[lon]/Degree+delta}]

delta = 1/1000;


35.362884, 138.730904 is much closer per google maps

temp start HERE

fuji[lat] = 35.362884
fuji[lon] = 138.730904
delta = 0.01;


test0939 = GeoPosition[{fuji[lat]-delta, fuji[lon]-delta}]
test0940 = GeoPosition[{fuji[lat]+delta, fuji[lon]+delta}]
test0941 = GeoElevationData[{test0939, test0940}, Automatic, "GeoPosition"]
arr = Flatten[test0941[[1]],1]

ListContourPlot[arr, Contours -> 16, ColorFunction -> GrayLevel,
 PlotLegends -> True, ContourLines -> True]
Show[%, ImageSize -> {800,600}]
showit

elev = Interpolation[arr, InterpolationOrder -> 10]

ContourPlot[elev[lat,lon], {lat, fuji[lat]-delta, fuji[lat]+delta},
{lon, fuji[lon]-delta, fuji[lon]+delta}, Contours -> 16, ColorFunction -> 
GrayLevel, PlotLegends -> True, ContourLines -> True ]
Show[%, ImageSize -> {800,600}]
showit

test1142 = GeoElevationData[{
 GeoPosition[{32,135}],  GeoPosition[{39,142}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 9];

Length[test1142[[1]]]

test1147 = GeoElevationData[{
 GeoPosition[{32,135}],  GeoPosition[{32.1,135.1}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 9];

Length[test1147[[1]]]

test1152 = GeoElevationData[{
 GeoPosition[{32,135}],  GeoPosition[{32.5,135.5}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 12];

Length[test1152[[1]]]

(above takes about 4s, returns 1456x1456 array)

test1152 = GeoElevationData[{
 GeoPosition[{32,135}],  GeoPosition[{33,136}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 12];

Length[test1152[[1]]]

(above takes about 12s, returns 2912x2912 array)

test1152 = GeoElevationData[{
 GeoPosition[{32,135}],  GeoPosition[{34,137}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 12];

Length[test1152[[1]]]

(above takes about 48s, returns 5825x5825 array)

test1152 = GeoElevationData[{
 GeoPosition[{32,135}],  GeoPosition[{39,142}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 12];

Length[test1152[[1]]]

GeoServer::maxtl: Number of requested tiles, 6400, is too large.

GeoElevationData::data: 
   Unable to download elevation data for ranges {{32., 39.}, {135., 142.}}
     and zoom level 12.

GeoServer::maxtl: Number of requested tiles, 6400, is too large.

GeoElevationData::data: 
   Unable to download elevation data for ranges {{32., 39.}, {135., 142.}}
     and zoom level 12.




delta = 1/1000;


ListContourPlot[arr, Contours -> 16, ColorFunction -> Hue,
 PlotLegends -> True, ContourLines -> False]
Show[%, ImageSize -> {800,600}]

test0941 = GeoElevationData[{test0939, test0940}]


test1030 = Table[Flatten[i], {i,test0941[[1]]}]

test1018 = Table[{{i[[1]], i[[2]]}, i[[3]]}, {i, test0941[[1,1]]}]




ListContourPlot[arr, Contours -> 256, ColorFunction -> Hue,
 PlotLegends -> True, ContourLines -> False]


ListContourPlot[test0941, Contours -> 16, ColorFunction -> Hue,
 PlotLegends -> True, ContourLines -> False]

elev = Table[{lat, lon, GeoElevationData[GeoPosition[{lat,lon}]]},
 {lat, fuji[lat]-1, fuji[lat]+1, .2}, 
 {lon, fuji[lon]-1, fuji[lon]+1, .2}];



ListContourPlot[test0941, Contours -> 255, ColorFunction -> Hue,
 PlotLegends -> True, ContourLines -> False]

ListContourPlot[test0941, Contours -> 16, ColorFunction -> Hue,
 PlotLegends -> True, ContourLines -> False]


test0938 = GeoElevationData[

travel2[35,-106, 4000, 0, 1*Degree, 1]

travel2[35,-106, Quantity[2, "miles"], 0, 1*Degree, Quantity[500, "feet"]]

test1 = GeoPosition[{35, -106, Quantity[4000, "meters"]}]

test2 = GeoPosition[GeoPositionENU[Quantity[2, "km"]*{1,2,3}, test1]]

test3 = GeoElevationData[test2]

test4 = Flatten[{Take[test2[[1]], 2], test2[[1,3]]-test3[[1]]}]




  Quantity[5,"km"]*{Cos[az] Cos[el], Cos[el] Sin[az], Sin[el]}, pos1]];
 elev2 = GeoElevationData[{pos2[[1,1]], pos2[[1,2]]}];
 Return[{pos2[[1,1]], pos2[[1,2]], pos2[[1,3]]-Quantity[elev2, "meters"]}];

above MAY be wrong, so lets try more direct


point = {35,-106};
test0925 = GeoPosition[Flatten[{point, GeoElevationData[point]}]]

 
(* this is truly hideous *)

elevFunc[lat_, lon_] := elevFunc[lat, lon] = 
 Interpolation[Flatten[GeoElevationData[
  {GeoPosition[{lat,lon}], GeoPosition[lat+1,lon+1]}, Automatic, "GeoPosition"
 ][[1]],1], InterpolationOrder -> 1];

elevFunc[lat_, lon_] := elevFunc[lat, lon] = 
 Interpolation[Flatten[GeoElevationData[
  {GeoPosition[{lat,lon}], GeoPosition[{lat+1,lon+1}]}, 
  Automatic, "GeoPosition", GeoZoomLevel -> 13
 ][[1]],1]]

elev[lat_, lon_] := elevFunc[Floor[lat], Floor[lon]][lat,lon]

elev[32.1,103.1]

GeoElevationData[GeoPosition[{32.1,103.1}]]

Flatten[GeoElevationData[
  {GeoPosition[{32.1-5/3600,103.1-5/3600}], 
   GeoPosition[{32.1+5/3600,103.1+5/3600}]}, 
  Automatic, "GeoPosition", GeoZoomLevel -> 12][[1]],1]


Flatten[GeoElevationData[
  {GeoPosition[{32.1-2/3600,103.1-2/3600}], 
   GeoPosition[{32.1+2/3600,103.1+2/3600}]}, 
  Automatic, "GeoPosition", GeoZoomLevel -> 12][[1]],1]

GeoElevationData[
  {GeoPosition[{32.1-1/3600,103.1-1/3600}], 
   GeoPosition[{32.1+1/3600,103.1+1/3600}]}, 
  Automatic, "GeoPosition", GeoZoomLevel -> 12] // FullForm

GeoElevationData[GeoPosition[{32.100162506103516`, 103.09999465942383`}]]
GeoElevationData[GeoPosition[{32.09981918334961`, 103.09999465942383`}]]

TODO: report possible bug, use $Version

Is GeoElevationData[] inconsistent?

<pre><code>

(* the version I am running *)

In[1]:= $Version

Out[1]= 11.1.0 for Linux x86 (64-bit) (March 13, 2017)

(* get elevation data for a very small rectangle w/ only 2 values *)

In[2]:= GeoElevationData[
 {GeoPosition[{32.1-1/3600,103.1-1/3600}],
 GeoPosition[{32.1+1/3600,103.1+1/3600}]},
 Automatic, "GeoPosition", GeoZoomLevel -> 12] // FullForm             

Out[2]//FullForm= 
    GeoPosition[List[List[List[32.100162506103516`, 103.09999465942383`,
    3071.465259638845`]], List[List[32.09981918334961`, 
    103.09999465942383`, 3076.4657749984644`]]]]






</code></pre>
