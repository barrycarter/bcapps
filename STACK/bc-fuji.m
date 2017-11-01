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
 If[el<ctheta[h,r], Return[]];
 Return[Take[newangles[h,r,el,az,lat,lon],2]];
];





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

conds = {h>0, r>0, h<r, 0 < theta < Pi/2, Element[x, Reals]}

z[theta_,x_] = -Tan[theta]*x + r + h

(*

precomp for speed, but this is how I genereated them:

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

newangles[h_, r_, theta_, az_, lat_, lon_] = 
 Simplify[xyz2sph[newcoords[h,r,theta,az,lat,lon]], conds]

*)

xsol[h_, r_, theta_] = (h + r)*Cos[theta]*Sin[theta] - 
    Sqrt[-(h*(h + 2*r)*Cos[theta]^4) + r^2*Cos[theta]^2*Sin[theta]^2]

zsol[h_, r_, theta_] = Sqrt[r^2 - (-((h + r)*Cos[theta]*Sin[theta]) + 
       Sqrt[-(h*(h + 2*r)*Cos[theta]^4) + r^2*Cos[theta]^2*Sin[theta]^2])^2]

ang[h_, r_, theta_] = ArcTan[((h + r)*Cos[theta]*Sin[theta] - 
      Sqrt[-(h*(h + 2*r)*Cos[theta]^4) + r^2*Cos[theta]^2*Sin[theta]^2])/
     Sqrt[r^2 - (-((h + r)*Cos[theta]*Sin[theta]) + 
         Sqrt[-(h*(h + 2*r)*Cos[theta]^4) + r^2*Cos[theta]^2*Sin[theta]^2])^2]]

dist[h_, r_, theta_] = 
   r*ArcTan[((h + r)*Cos[theta]*Sin[theta] - Sqrt[-(h*(h + 2*r)*Cos[theta]^4) + 
         r^2*Cos[theta]^2*Sin[theta]^2])/
      Sqrt[r^2 - (-((h + r)*Cos[theta]*Sin[theta]) + 
         Sqrt[-(h*(h + 2*r)*Cos[theta]^4) + r^2*Cos[theta]^2*Sin[theta]^2])^2]]

newcoords[h_, r_, theta_, az_, lat_, lon_] = 
   {Cos[theta]^2*(Cos[lon]*Sin[az]*Sin[lat] + Cos[az]*Sin[lon])*
      (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta]) + 
     Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
         (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2], 
    Cos[theta]^2*(Cos[az]*Cos[lon] - Sin[az]*Sin[lat]*Sin[lon])*
      (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
     Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
         (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2], 
    Cos[lat]*Cos[theta]^2*Sin[az]*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
       (h + r)*Tan[theta]) + Sin[lat]*
      Sqrt[r^2 - Cos[theta]^4*(Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - 
           (h + r)*Tan[theta])^2]}

newangles[h_, r_, theta_, az_, lat_, lon_] = 
   {ArcTan[Cos[theta]^2*(Cos[lon]*Sin[az]*Sin[lat] + Cos[az]*Sin[lon])*
       (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta]) + 
      Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
          (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2], 
     Cos[theta]^2*(Cos[az]*Cos[lon] - Sin[az]*Sin[lat]*Sin[lon])*
       (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
      Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
          (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]], 
    ArcTan[Sqrt[(Cos[theta]^2*(Cos[lon]*Sin[az]*Sin[lat] + Cos[az]*Sin[lon])*
          (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta]) + 
         Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2])^2 + 
       (Cos[theta]^2*(Cos[az]*Cos[lon] - Sin[az]*Sin[lat]*Sin[lon])*
          (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
         Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2])^2], 
     Cos[lat]*Cos[theta]^2*Sin[az]*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
        (h + r)*Tan[theta]) + Sin[lat]*
       Sqrt[r^2 - Cos[theta]^4*(Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - 
            (h + r)*Tan[theta])^2]], 
    Sqrt[Abs[Cos[theta]^2*(Cos[lon]*Sin[az]*Sin[lat] + Cos[az]*Sin[lon])*
          (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta]) + 
         Cos[lat]*Cos[lon]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]^2 + 
     Abs[Cos[lat]*Cos[theta]^2*Sin[az]*(-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + 
           (h + r)*Tan[theta]) + Sin[lat]*Sqrt[r^2 - Cos[theta]^4*
            (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]^2 + 
      Abs[Cos[theta]^2*(Cos[az]*Cos[lon] - Sin[az]*Sin[lat]*Sin[lon])*
          (-Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] + (h + r)*Tan[theta]) + 
         Cos[lat]*Sin[lon]*Sqrt[r^2 - Cos[theta]^4*
             (Sqrt[-(h + r)^2 + r^2*Sec[theta]^2] - (h + r)*Tan[theta])^2]]^2]}

(* critical theta = one solution only *)

ctheta[h_,r_] = ArcTan[Sqrt[h]*Sqrt[h+2*r]/r]

(* critical distance *)

cdist[h_,r_] = Simplify[dist[h,r,ctheta[h,r]],conds]

(* longitude, latitude and elevation of Mt Fuji *)

fuji[lon] = (138+43/60+52/3600)*Degree
fuji[lat] = (35+21/60+29/3600)*Degree
fuji[ele] = 3776240/1000000

</formulas>

TODO: slightly more accurate formula for rad

TODO: fourth powers of cosine scary!

TODO: convinced simpler answer

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

TODO: shadows "bend"

putting it together (shadow cast in opposite direction)

conds = {-Pi/2 < lat < Pi/2, -Pi < lon < Pi, -Pi/2 < el < Pi/2, -Pi <
az < Pi, h> 0}

frame2frame[lat_, lon_] = Simplify[{{-Sin[lon], -(Cos[lon]*Sin[lat]),
Cos[lat]*Cos[lon]}, {Cos[lon], -(Sin[lat]*Sin[lon]),
Cos[lat]*Sin[lon]}, {0, Cos[lat], Sin[lat]}}, conds]


v = FullSimplify[frame2frame[lat,lon].sph2xyz[az+Pi,el,1], conds]

(* fullsimplify hangs below as does simplify, limiting solution to
reals hangs *)

tsol = t /. 
 Simplify[Solve[Norm[sph2xyz[lat,lon,1+h] + v*t] == 1, t][[1]],conds]

tsol = -(Cos[lat]^2*Cos[lon]^2*Sin[el]) - h*Cos[lat]^2*Cos[lon]^2*Sin[el] + 
    Cos[az]*Cos[el]*Cos[lon]^2*Sin[lat] + h*Cos[az]*Cos[el]*Cos[lon]^2*
     Sin[lat] - Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] - 
    h*Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] - 
    Cos[az]*Cos[el]*Cos[lat]*Cos[lon]*Sin[lon] - h*Cos[az]*Cos[el]*Cos[lat]*
     Cos[lon]*Sin[lon] + Cos[el]*Cos[lat]*Sin[az]*Sin[lon] + 
    h*Cos[el]*Cos[lat]*Sin[az]*Sin[lon] - Sin[el]*Sin[lat]*Sin[lon] - 
    h*Sin[el]*Sin[lat]*Sin[lon] - Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*Sin[lon]- 
    h*Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] - 
    Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] - h*Cos[el]*Cos[lon]*Sin[az]*
     Sin[lat]^2*Sin[lon] - 
    Sqrt[-4*h*(2 + h) + 4*(1 + h)^2*(Cos[lat]^2*Cos[lon]^2*Sin[el] + 
          Sin[lat]*(-(Cos[az]*Cos[el]*Cos[lon]^2) + 
            (Sin[el] + Cos[el]*Cos[lon]*Sin[az]*Sin[lat])*Sin[lon]) + 
          Cos[lat]*(Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] + 
            Cos[el]*(Cos[lon]^2*Sin[az]*Sin[lat] + Cos[az]*Cos[lon]*Sin[lon] - 
              Sin[az]*Sin[lon])))^2]/2


(* fullsimplify hangs below *)

xyz = Simplify[sph2xyz[lat,lon,1+h]+v*tsol,conds]

xyz = {(1 + h)*Cos[lat]*Cos[lon] - (Cos[lat]*Cos[lon]*Sin[el] + 
    Cos[el]*(Cos[lon]*Sin[az]*Sin[lat] + Cos[az]*Sin[lon]))*
   (Cos[lat]^2*Cos[lon]^2*Sin[el] + h*Cos[lat]^2*Cos[lon]^2*Sin[el] - 
    Cos[az]*Cos[el]*Cos[lon]^2*Sin[lat] - h*Cos[az]*Cos[el]*Cos[lon]^2*
     Sin[lat] + Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] + 
    h*Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] + 
    Cos[az]*Cos[el]*Cos[lat]*Cos[lon]*Sin[lon] + h*Cos[az]*Cos[el]*Cos[lat]*
     Cos[lon]*Sin[lon] - Cos[el]*Cos[lat]*Sin[az]*Sin[lon] - 
    h*Cos[el]*Cos[lat]*Sin[az]*Sin[lon] + Sin[el]*Sin[lat]*Sin[lon] + 
    h*Sin[el]*Sin[lat]*Sin[lon] + Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*
     Sin[lon] + h*Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] + 
    Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] + 
    h*Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] + 
    Sqrt[-4*h*(2 + h) + 4*(1 + h)^2*(Cos[lat]^2*Cos[lon]^2*Sin[el] + 
          Sin[lat]*(-(Cos[az]*Cos[el]*Cos[lon]^2) + 
            (Sin[el] + Cos[el]*Cos[lon]*Sin[az]*Sin[lat])*Sin[lon]) + 
          Cos[lat]*(Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] + 
            Cos[el]*(Cos[lon]^2*Sin[az]*Sin[lat] + Cos[az]*Cos[lon]*Sin[
                lon] - Sin[az]*Sin[lon])))^2]/2), 
 (1 + h)*Cos[lon]*Sin[lat] + (-(Cos[az]*Cos[el]*Cos[lon]) + 
    (Cos[lat]*Sin[el] + Cos[el]*Sin[az]*Sin[lat])*Sin[lon])*
   (-(Cos[lat]^2*Cos[lon]^2*Sin[el]) - h*Cos[lat]^2*Cos[lon]^2*Sin[el] + 
    Cos[az]*Cos[el]*Cos[lon]^2*Sin[lat] + h*Cos[az]*Cos[el]*Cos[lon]^2*
     Sin[lat] - Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] - 
    h*Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] - 
    Cos[az]*Cos[el]*Cos[lat]*Cos[lon]*Sin[lon] - h*Cos[az]*Cos[el]*Cos[lat]*
     Cos[lon]*Sin[lon] + Cos[el]*Cos[lat]*Sin[az]*Sin[lon] + 
    h*Cos[el]*Cos[lat]*Sin[az]*Sin[lon] - Sin[el]*Sin[lat]*Sin[lon] - 
    h*Sin[el]*Sin[lat]*Sin[lon] - Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*
     Sin[lon] - h*Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] - 
    Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] - 
    h*Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] - 
    Sqrt[-4*h*(2 + h) + 4*(1 + h)^2*(Cos[lat]^2*Cos[lon]^2*Sin[el] + 
          Sin[lat]*(-(Cos[az]*Cos[el]*Cos[lon]^2) + 
            (Sin[el] + Cos[el]*Cos[lon]*Sin[az]*Sin[lat])*Sin[lon]) + 
          Cos[lat]*(Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] + 
            Cos[el]*(Cos[lon]^2*Sin[az]*Sin[lat] + Cos[az]*Cos[lon]*Sin[
                lon] - Sin[az]*Sin[lon])))^2]/2), 
 (1 + h)*Sin[lon] + (Cos[el]*Cos[lat]*Sin[az] - Sin[el]*Sin[lat])*
   (Cos[lat]^2*Cos[lon]^2*Sin[el] + h*Cos[lat]^2*Cos[lon]^2*Sin[el] - 
    Cos[az]*Cos[el]*Cos[lon]^2*Sin[lat] - h*Cos[az]*Cos[el]*Cos[lon]^2*
     Sin[lat] + Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] + 
    h*Cos[el]*Cos[lat]*Cos[lon]^2*Sin[az]*Sin[lat] + 
    Cos[az]*Cos[el]*Cos[lat]*Cos[lon]*Sin[lon] + h*Cos[az]*Cos[el]*Cos[lat]*
     Cos[lon]*Sin[lon] - Cos[el]*Cos[lat]*Sin[az]*Sin[lon] - 
    h*Cos[el]*Cos[lat]*Sin[az]*Sin[lon] + Sin[el]*Sin[lat]*Sin[lon] + 
    h*Sin[el]*Sin[lat]*Sin[lon] + Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*
     Sin[lon] + h*Cos[lat]*Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] + 
    Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] + 
    h*Cos[el]*Cos[lon]*Sin[az]*Sin[lat]^2*Sin[lon] + 
    Sqrt[-4*h*(2 + h) + 4*(1 + h)^2*(Cos[lat]^2*Cos[lon]^2*Sin[el] + 
          Sin[lat]*(-(Cos[az]*Cos[el]*Cos[lon]^2) + 
            (Sin[el] + Cos[el]*Cos[lon]*Sin[az]*Sin[lat])*Sin[lon]) + 
          Cos[lat]*(Cos[lon]*Sin[el]*Sin[lat]*Sin[lon] + 
            Cos[el]*(Cos[lon]^2*Sin[az]*Sin[lat] + Cos[az]*Cos[lon]*Sin[
                lon] - Sin[az]*Sin[lon])))^2]/2)}

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

TODO: refraction, Earth's curvature, Earth's ellipticity, ask Japanese Twitter peeps, DEM files for viewer, historical images, refraction of fuji too

TODO: similar mountains incl Rainier?

TODO: precision vs accuracy

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

