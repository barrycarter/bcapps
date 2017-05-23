(* formulas start here *)

(* kludge for 'display' fuckery *)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, -Pi<ha<Pi};

az[ha_, dec_, lat_] = ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat], 
    -(Cos[dec]*Sin[ha])]

el[ha_, dec_, lat_] = ArcTan[Sqrt[Cos[dec]^2*Sin[ha]^2 + 
      (Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat])^2], 
    Cos[dec]*Cos[ha]*Cos[lat] + Sin[dec]*Sin[lat]]

r[ha_, dec_, lat_]= FullSimplify[Cot[el[ha,dec,lat]],conds]

theta[ha_, dec_, lat_] = az[ha,dec,lat]+Pi

x[ha_, dec_, lat_] = FullSimplify[r[ha,dec,lat]*Cos[theta[ha,dec,lat]],conds]

y[ha_, dec_, lat_] = FullSimplify[r[ha,dec,lat]*Sin[theta[ha,dec,lat]],conds]

dx[ha_, dec_, lat_] = FullSimplify[D[x[ha,dec,lat],ha],conds]

dy[ha_, dec_, lat_] = FullSimplify[D[y[ha,dec,lat],ha],conds]

ds2[ha_, dec_, lat_] = FullSimplify[dx[ha,dec,lat]^2 + dy[ha,dec,lat]^2,conds]

ds[ha_,dec_,lat_] = FullSimplify[Sqrt[ds2[ha,dec,lat]], conds]

(* NOTE: stop cut/paste here for now *)

(* NOTE:

In[128]:= FullSimplify[FullSimplify[D[ds[ha,dec,lat],dec],conds] /. dec -> 0,con
ds]                                                                             
ContourPlot[ds[ha,dec,35*Degree], {ha,-1,1}, {dec,-1,1}]


*)


(* TODO: 2 eyes *)







cleanup = {ha -> omega, dec -> delta, lat -> phi}

ha2ha[h_] = h/12*Pi-Pi

azh[h_,dec_,lat_] = az[ha2ha[h],dec,lat]
elh[h_,dec_,lat_] = el[ha2ha[h],dec,lat]

(* TODO: angular radius is 16' per sunset formula *) 

(* TODO: no refraction *)

(* TODO: the whole 12/Pi thing is now obsolete *)

rplot[h_,dec_,lat_] := Max[0, r[h,dec,lat]]
xplot[h_,dec_,lat_] := rplot[h,dec,lat]*Cos[theta[h,dec,lat]]
yplot[h_,dec_,lat_] := rplot[h,dec,lat]*Sin[theta[h,dec,lat]]

(* formulas end here *)

dx[h_,dec_,lat_] = FullSimplify[D[x[h,dec,lat],h], conds]
dy[h_,dec_,lat_] = FullSimplify[D[y[h,dec,lat],h], conds]

ds[h_,dec_,lat_] = FullSimplify[Sqrt[dx[h,dec,lat]^2 + dy[h,dec,lat]^2], conds]


https://en.wikipedia.org/wiki/Visual_acuity#Motion_acuity

0.0275 rad/s

0.003 radian/sec (0.171887 deg/sec or 10.3'/sec)

(at a dist of 1m, that would be 3mm/s)

0.0087 rad/s

http://jov.arvojournals.org/article.aspx?articleid=2122525

looming threshold

http://journals.sagepub.com/doi/abs/10.1177/1071181312561146

below is at summer solstice noon diff lats

Plot[ds[0,23.5*Degree,lat],{lat,30*Degree,50*Degree}]

about 0.4 to 0.9 (meters per hour if stick is 1m)

111-250 micrometers per second

lower number is 247 times too slow to see (at 1m)

Maximize[{ds[h,dec,lat], el[h,dec,lat]>15*Degree}, h]

Solve[elh[h,dec,lat] == 15*Degree, h]

Solve[elh[h,23.5*Degree,40*Degree] == 15*Degree, h]

TODO: near sigtedness

Plot[elh[h,23.5*Degree,40*Degree]/Degree, {h,12,20}]

h -> 17.9864

ds[17.9864, 23.5*Degree,40*Degree]

2.898 per hour

805 micrometers per second

FindRoot[elh[h,23.5*Degree,40*Degree] == 15*Degree,{h,18}]
h -> 17.9864

FindRoot[elh[h,0*Degree,40*Degree] == 15*Degree,{h,18}]
h -> 16.6835

ds[16.6835, 0*Degree, 40*Degree]
2.99365

FindRoot[elh[h,-23.5*Degree,40*Degree] == 15*Degree,{h,18}]
h -> 14.8559

ds[14.8559,-23.5*Degree,40*Degree]
2.08454

Plot3D[ds[12,dec*Degree,lat*Degree],{dec,-23.5,+23.5}, {lat,30,50}]

Plot3D[ds[15,dec*Degree,lat*Degree],{dec,-23.5,+23.5}, {lat,30,50}]


x[h_,dec_,lat_] = FullSimplify[r[h,dec,lat]*Cos[theta[h,dec,lat]], conds]

y[h_,dec_,lat_] = FullSimplify[r[h,dec,lat]*Sin[theta[h,dec,lat]], conds]

r[h_,dec_,lat_] = FullSimplify[Cot[elh[h,dec,lat]], conds]

theta[h,dec,lat] = FullSimplify[3*Pi/2-azh[h,dec,lat],conds]

https://www.e-education.psu.edu/eme810/node/575

(*

http://astronomy.stackexchange.com/questions/19619/how-to-make-motion-of-the-sun-more-apparent-at-seconds-scale

TODO: SUMMARY ANSWER HERE

TODO: 15 deg cutoff 3.73205

(* ANSWER STARTS HERE *)

We know from https://astronomy.stackexchange.com/a/14508/21 that the Sun's azimuth and elevation at any given time is:

$
   \text{azimuth}=\tan ^{-1}(\sin (\delta ) \cos (\phi )-\cos (\delta ) \cos 
    (\omega ) \sin (\phi ),-\cos (\delta ) \sin (\omega ))
$
$
\text{elevation}=\tan ^{-1}\left(\sqrt{(\sin (\delta ) \cos (\phi )-\cos 
    (\delta ) \cos (\omega ) \sin (\phi ))^2+\cos ^2(\delta ) \sin ^2(\omega 
    )},\cos (\delta ) \cos (\omega ) \cos (\phi )+\sin (\delta ) \sin (\phi 
    )\right) 
$

where:

  - $\delta$ is the Sun's declination
  - $\phi$ is the observer's latitude
  - $\omega$ is the Sun's "hour angle":
    - $\omega$ is zero at local solar noon
    - $\omega$ is $15 {}^{\circ}$ or $\frac{\pi }{12}$ 1 hour after local solar noon (ie, 1pm on a sundial)
    - $\omega$ is $-15 {}^{\circ}$ or $-\frac{\pi }{12}$ 1 hour before local solar noon (ie, 11am on a sundial)
    - $\omega$ is $\pm180 {}^{\circ}$ or $\pm\pi$ at local solar midnight
    - $\omega$ is $-90 {}^{\circ}$ or $-\frac{\pi }{2}$ 6 hours before local solar noon (ie, 6am on a sundial), and so on.
    - Conversely, $\omega$ is $1$ 3h49m11s after noon (that's $\frac{24}{2 \pi }$ converted to hms). This quantity is important and I'll refer to it as the "radian hour" below (this is nonstandard terminology).

Of course, this applies only to the center of the Sun, ignores the fact the Sun is a disk, and also ignores refraction.

To compensate for the Sun being a disk, we will note those numbers are ***PUT SYMBOL HERE*** +- 16 minutes of arc (about 0.004654 radians).  ***** MY PLAN HERE *****

Since we won't be dealing the Sun near the horizon, we can ignore refraction, which is small away from the horizon.

Now, consider a stick placed vertically into the ground with a height of 1m (any unit would do, just using 'm' for convenience). We will assume the stick is transparent with an infinitesimally small opaque point at the top.

The direction in which the stick's shadow points ($\theta$) is opposite the Sun's azimuth. For example, if the Sun is due south, the shadow will point due north:

$
   \theta (\omega ,\delta ,\phi )=\tan ^{-1}(\sin (\delta ) \cos (\phi )-\cos
    (\delta ) \cos (\omega ) \sin (\phi ),-\cos (\delta ) \sin (\omega ))+\pi
$

The length of a the stick's shadow ($r$) is the cotangent of the Sun's elevation, which "simplifies" to:

$
   r(\omega ,\delta ,\phi )=\frac{\sqrt{(\sin (\delta ) \cos (\phi )-\cos
    (\delta ) \cos (\omega ) \sin (\phi ))^2+\cos ^2(\delta ) \sin ^2(\omega
    )}}{\cos (\delta ) \cos (\omega ) \cos (\phi )+\sin (\delta ) \sin (\phi )}
$

Note that this formula only makes sense when $r$ is nonnegative.

Although we could continue working in polar coordinates, it might be easier to convert to Cartesian coordinates. Using the standard transformation formulas, the x and y positions of the tip of the stick's shadow (where north is the positive x axis and west is the positive y axis) is:

$
   x(\omega ,\delta ,\phi )=\frac{\cot (\delta ) \cos (\omega ) \sin (\phi
    )-\cos (\phi )}{\cot (\delta ) \cos (\omega ) \cos (\phi )+\sin (\phi )}
$
$
   y(\omega ,\delta ,\phi )=\frac{1}{\tan (\delta ) \csc (\omega ) \sin (\phi
    )+\cot (\omega ) \cos (\phi )}
$

Of course, we're interested in the speed of the shadow, so we differentiate with respect to $\omega$, the Sun's hour angle, which we're using to measure time:

$
   \frac{\partial x(\omega ,\delta ,\phi )}{\partial \omega }=-\frac{\cot
    (\delta ) \sin (\omega )}{(\cot (\delta ) \cos (\omega ) \cos (\phi )+\sin
    (\phi ))^2}
$

$
  \frac{\partial y(\omega ,\delta ,\phi )}{\partial \omega }=\frac{\csc (\omega
    ) (\tan (\delta ) \cot (\omega ) \sin (\phi )+\csc (\omega ) \cos (\phi
    ))}{(\tan (\delta ) \csc (\omega ) \sin (\phi )+\cot (\omega ) \cos (\phi
    ))^2}
$

Finally, using the Pythagorean Theorem for differentials, we can find the total speed, which we'll refer to as $\text{ds}$:

$
   \text{ds}(\omega ,\delta ,\phi )=\sqrt{\left(\frac{\partial x(\omega ,\delta
   ,\phi )}{\partial \omega }\right)^2+\left(\frac{\partial y(\omega ,\delta
   ,\phi )}{\partial \omega }\right)^2}=\sqrt{\frac{\cot ^2(\delta ) \left(\cos
    (\omega ) \left(\cot (\delta ) \sin (2 \phi )+\cos (\omega ) \sin ^2(\phi
    )\right)+\cot ^2(\delta ) \cos ^2(\phi )+\sin ^2(\omega )\right)}{(\cot
    (\delta ) \cos (\omega ) \cos (\phi )+\sin (\phi ))^4}}
$

Note the unit here is meters per radian hour (with radian hour defined as above).

(* TODO: I may have dec backwards somewhere, winter should have later riset *)
(* no, its just that 0h = culmination = noon, fixed by change of range *)


dsMod1[ha_,dec_,lat_] = If[
 el[ha,dec,lat] < 0 || Abs[dratio[ha,dec,lat]] > .1, 0,
 ds[ha,dec,lat]];

Plot[ds[ha/12*Pi, 23.5*Degree, 35*Degree], {ha,-12,12}]

Plot[ds[ha/12*Pi, -23.5*Degree, 35*Degree], {ha,0,24}]

Plot[dsMod1[ha/12*Pi, 23.5*Degree, 35*Degree], {ha,-12,12}]

Plot[{dsMod1[ha/12*Pi, 23.5*Degree, 35*Degree], 
 dsMod1[ha/12*Pi, -23.5*Degree, 35*Degree],
 dsMod1[ha/12*Pi, 10^-9*Degree, 35*Degree]},  {ha,-12,12}, PlotRange -> All]


ContourPlot[ds[ha/12*Pi,dec*Degree,35*Degree],{ha,-6,6},{dec,-23.5,23.5}, 
 PlotLegends -> True]


Limit[ds[omega,delta,phi],delta -> 0]

el2SunWidthDiam[el_] = Cot[el-16/60*Degree]-Cot[el+16/60*Degree]

Plot[el2SunWidthDiam[el*Degree], {el,0,45}]


(* below not valid for el near 90 degrees or 0 degrees *)

width[ha_,dec_,lat_] = Simplify[Cot[el[ha,dec,lat]-16/60*Degree] - 
 Cot[el[ha,dec,lat]+16/60*Degree], conds]

dwidth[ha_,dec_,lat_] = Simplify[D[width[ha,dec,lat],ha],conds]

dratio[ha_,dec_,lat_] = Simplify[dwidth[ha,dec,lat]/ds[ha,dec,lat],conds]

Plot[dratio[ha/12*Pi,23.5*Degree,35*Degree],{ha,-12,12}]
Plot[dratio[ha/12*Pi,23.5*Degree,35*Degree],{ha,-7,7}]

Plot[dratio[ha/12*Pi,23.5*Degree,35*Degree],{ha,7,8}]

ContourPlot[dsMod1[ha/12*Pi,dec*Degree,35*Degree],{ha,-12,12},{dec,-23.5,23.5},
PlotLegends -> True]





Plot[width[ha/12*Pi, 0*Degree, 35*Degree], {ha,-12,12}]








x+16/60*Degree]-Cot[x-16/60*Degree],{x,0,90*Degree}]



HoldForm[ds[omega,delta,phi]] == Sqrt[HoldForm[D[x[omega,delta,phi],omega]]^2 +
 HoldForm[D[y[omega,delta,phi],omega]]^2] == ds[omega,delta,phi] // TeXForm




HoldForm[D[x[omega,delta,phi],omega]] == dx[omega,delta,phi]

HoldForm[D[y[omega,delta,phi],omega]] == dy[omega,delta,phi]


HoldForm[x[omega,delta,phi]] == x[omega,delta,phi] // TeXForm

HoldForm[y[omega,delta,phi]] == y[omega,delta,phi] // TeXForm






HoldForm[theta[omega,delta,phi]] == theta[omega,delta,phi] // TeXForm

REMINDER: ha -> omega, dec -> delta, lat -> phi








To make things slightly easier, let's convert $\omega$ to $h$, something closer to clock time. After this conversion, we have:

$

   \text{azimuth}=\tan ^{-1}\left(\cos (\text{dec}) \cos \left(\frac{\pi 
    h}{12}\right) \sin (\text{lat})+\sin (\text{dec}) \cos (\text{lat}),\cos
    (\text{dec}) \sin \left(\frac{\pi  h}{12}\right)\right)
$
$
   \text{elevation}=\tan ^{-1}\left(\sqrt{\left(\cos (\text{dec}) \cos
    \left(\frac{\pi  h}{12}\right) \sin (\text{lat})+\sin (\text{dec}) \cos
    (\text{lat})\right)^2+\cos ^2(\text{dec}) \sin ^2\left(\frac{\pi 
    h}{12}\right)},\sin (\text{dec}) \sin (\text{lat})-\cos (\text{dec}) \cos
    \left(\frac{\pi  h}{12}\right) \cos (\text{lat})\right)
$

where the angles are now measured in radians and:

  - $h$ is 12 at local solar noon
  - $h$ is 1 when it's 1 hour after local solar noon (ie, 1pm on a sundial)
  - $h$ is 11 when it's 1 hour before local solar noon (ie, 11am on a sundial)
  - $h$ is 0 or 24 at local solar midnight
  - $h$ is 6 when it's 6 hours before local solar noon (ie, 6am on a sundial), and so on.

The direction $\theta$ in which a vertical stick's shadow points is opposite the Sun's azimuth. For example, if the Sun is due south, the shadow will point due north. For plotting purposes, we'd like north to be the positive y axis (as on standard maps), which we can achieve by adding $\frac{3 \pi }{2}$. This gives us:

$
  \theta =\frac{3 \pi }{2}-\tan ^{-1}\left(\cos (\delta ) \cos \left(\frac{\pi 
    h}{12}\right) \sin (\phi )+\sin (\delta ) \cos (\phi ),\cos (\delta ) \sin
    \left(\frac{\pi  h}{12}\right)\right)
$




The length of a vertical stick's shadow ($r$) is the cotangent of the Sun's elevation, or:

$
   r=\frac{\sqrt{\left(\cos (\delta ) \cos \left(\frac{\pi  h}{12}\right) \sin
    (\phi )+\sin (\delta ) \cos (\phi )\right)^2+\cos ^2(\delta ) \sin
    ^2\left(\frac{\pi  h}{12}\right)}}{\sin (\delta ) \sin (\phi )-\cos (\delta
    ) \cos \left(\frac{\pi  h}{12}\right) \cos (\phi )}
$

Note that this formula only makes sense when $r$ is nonnegative, and we are defining the stick's length as 1 unit.

Although we could continue working in polar coordinates, it might be easier to convert to Cartesian coordinates. Using the standard transformation formulas, the x and y positions of the tip of a vertical stick's shadow (where north is the positive y axis and east is the positive x axis, as on a map) is:

$
   x=\frac{1}{\cot \left(\frac{\pi  h}{12}\right) \cos (\phi )-\tan (\delta )
    \csc \left(\frac{\pi  h}{12}\right) \sin (\phi )}
$
$
   y=\frac{\cot (\delta ) \cos \left(\frac{\pi  h}{12}\right) \sin (\phi )+\cos
    (\phi )}{\cot (\delta ) \cos \left(\frac{\pi  h}{12}\right) \cos (\phi
    )-\sin (\phi )}
$

Plotting this:

versa vs recta

TODO: math porn warning

TODO: unhappy using r==0 as test of whether to plot or not

(* we want to put points everywhere EXCEPT on the hour where we use
text, and, of course, not when sun is down *)

tab[dec_,lat_] := Select[Table[i,{i,0,24,1/4}], 
 !IntegerQ[#] && rplot[#,dec,lat] > 0 &]

(* the text points are the hours when sun is up *)

txtpts[dec_,lat_] := Select[Table[i,{i,0,24}], rplot[#,dec,lat] > 0 &]

(* the graphics points for a given dec/lat, per tab above *)

pts[dec_,lat_] := Table[
 Point[{xplot[h,dec,lat],yplot[h,dec,lat]}],
 {h, tab[dec,lat]}]

txt[dec_,lat_] := 
 Table[Text[Style[ToString[h], FontSize -> 10], 
 {xplot[h,dec,lat], yplot[h,dec,lat]}, {0,0}],
 {h,txtpts[dec,lat]}];

graphics[dec_,lat_] := Graphics[{pts[dec,lat], txt[dec,lat]}]

testlat = 40*Degree

g = Graphics[{
 txt[0,testlat],
 txt[23.5*Degree, testlat],
 txt[-23.5*Degree, testlat],
 Hue[0], pts[23.5*Degree, testlat],
 Hue[2/3], pts[-23.5*Degree, testlat],
 Hue[1/3],
 pts[0,testlat]
}]

Show[g, Axes -> True, PlotRange -> {{-5,5},{-2,4}}, AspectRatio -> 1,
 Ticks -> False]
showit




Show[gtest, PlotRange->{{-3,3},{-1,1}}, Axes->True, AspectRatio -> 1]
showit




gtest = Show[{
 Graphics[pts[23.5*Degree, 40*Degree]],
 Graphics[txt[23.5*Degree, 40*Degree]]
}, Axes -> True, PlotRange -> {-4,4}, AspectRatio -> 1/4]
showit




gtest = Show[{
 Graphics[pts[23.5*Degree, 40*Degree]],
 Graphics[txt[23.5*Degree, 40*Degree]]
}, PlotRange -> {{-4,4},{0,1}}, Axes -> True, AspectRatio -> 16]

 
 ListPlot[pts[23.5*Degree, 35*Degree]],
 Graphics[txt[23.5*Degree, 35*Degree]]
}]



TODO: INSERT IMAGE

TODO: Moon as exercise, Venus???


TODO: http://paulscottinfo.ipage.com/making/ch41trig/ch41trigD.html




TODO: references section

https://www.google.com/search?q=sundial+time+lapse&ie=utf-8&oe=utf-8

TODO: consistently use elevation not altitude

TODO: tilting stick top will just be the same as shorter stick (but if looking at wedge, might be different)

TODO: where I get these formulas

az[ha_, dec_, lat_] = HADecLat2azEl[ha, dec, lat][[1]]
el[ha_, dec_, lat_] = HADecLat2azEl[ha, dec, lat][[2]]

TODO: graphics here re why its 1/Tan[el]

gnomr[ha_,dec_,lat_] = FullSimplify[1/Tan[el[ha,dec,lat]], conds]

(* adjustment below because we want north = up *)

gnomt[ha_,dec_,lat_] = 3*Pi/2-az[ha,dec,lat]

(* the xy point for a given ha/dec/lat, but origin if r<0 *)

xy[ha_,dec_,lat_] = FullSimplify[
 Max[gnomr[ha,dec,lat],0]*
 {Cos[gnomt[ha,dec,lat]], Sin[gnomt[ha,dec,lat]]}, conds];




dec0 = 23.5*Degree
lat0 = 35*Degree

tab0 = Table[{gnomt[ha, dec0, lat0], gnomr[ha, dec0, lat0]}, 
 {ha, -Pi/2, Pi/2, 0.01}]





TODO: simulate as animated GIF

TODO: tall building

TODO: elecbill stuff

TODO: back of envelope -- 15 deg/hour, at 45 elev?

TODO: sun has angular width, and oblong at horizon

TODO: horizon = bad

TODO: note when setting, asymptotic to infinity

TODO: note ra/dec fixed is reasonable

TODO: link to formulas

TODO: sid day length and fixed ra cancel each other out

TODO: can't make fixed dec assumption for other problem sun max height

TODO: perhaps use ELECBILL pics to show motion of sun but not this is vertical not horizontal

TODO: consider angled stick

conds = {-Pi/2 < dec < Pi/2, 0 < ha < 2*Pi, -Pi/2 < lat < Pi/2};

az[dec_,ha_,lat_] = FullSimplify[decHaLat2azEl[dec,ha,lat][[1]],conds]
el[dec_,ha_,lat_] = FullSimplify[decHaLat2azEl[dec,ha,lat][[2]],conds]

(* angle and radius, using north as up, east as right *)

(* NOTE: 'rad' is already in use by bclib.m *)

(* TODO: this simplifies)

radi[dec_,ha_,lat_] = FullSimplify[Cot[el[dec,ha,lat]],conds]
ang[dec_,ha_,lat_] = 3*Pi/2-az[dec,ha,lat]

(* xy coords at given time *)

xy[dec_,ha_,lat_]=  radi[dec,ha,lat]*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}

txt[dec_,lat_] = 
 Table[Text[Style[ToString[Mod[ha-12,24]], FontSize -> 5], 
 xy[dec,ha,lat], {0,0}],
 {ha,0,24,1}];

(* we want to put points everywhere EXCEPT on the hour where we use text *)

t = Select[Table[i,{i,0,24,1/4}], !IntegerQ[#] &]
t = Table[i,{i,0,24,1/4}]

pts[dec_,lat_] = 
 Table[
 Point[{Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, el[dec,ha/12*Pi,lat]/Degree}], 
 {ha,t}];



xyt[dec_,lat_] = Table[xy[dec,ha/12*Pi,lat], {ha,0,24,1/4}]

ListPlot[xyt[23.5*Degree,35*Degree]]

pts[dec_,lat_] = 
 Table[
 Point[{Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, el[dec,ha/12*Pi,lat]/Degree}], 
 {ha,t}];

pts2[dec_,lat_] = 
 Table[
 {Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, el[dec,ha/12*Pi,lat]/Degree}, 
 {ha,t}];

(* the stick length at various times and azimuths *)

pts3[dec_,lat_] = 
 Table[
 {Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, Cot[el[dec,ha/12*Pi,lat]]}, 
 {ha,t}];

xtics = Table[i,{i,0,360,30}];
ytics = Table[i,{i,-90,90,10}];

ytics3 = Table[i,{i,0,5,.5}];

g2 = ListLogPlot[{
 pts3[0,35*Degree], pts3[23.5*Degree,35*Degree], pts3[-23.5*Degree,35*Degree]
}, Ticks -> {xtics, Automatic}, PlotLegends -> {"Equinox", "Summer Solstice", 
   "Winter Solstice"}, PlotMarkers -> {Automatic, 2}, PlotRange -> {0,5},
 PlotRangeClipping -> True]

g2 = ListPlot[{
 pts3[0,35*Degree], pts3[23.5*Degree,35*Degree], pts3[-23.5*Degree,35*Degree]
}, Ticks -> {xtics, ytics3}, PlotLegends -> {"Equinox", "Summer Solstice", 
   "Winter Solstice"}, PlotMarkers -> {Automatic, 2}, PlotRange -> {0,5}]

g0 = ListPlot[{
 pts2[0,35*Degree], pts2[23.5*Degree,35*Degree], pts2[-23.5*Degree,35*Degree]
}, Ticks -> {xtics, ytics}, PlotLegends -> {"Equinox", "Summer Solstice", 
   "Winter Solstice"}, PlotMarkers -> {Automatic, 2}]

g1 = Graphics[{
 txt[0, 35*Degree], txt[-23.5*Degree, 35*Degree], txt[23.5*Degree, 35*Degree]
}];

Show[{g0,g1}]
showit

TODO: consider projecting at an angle instead of flat surface, and note sun is not a point light source, but has width

Graphics[{txt[0,35*Degree], txt[23.5*Degree, 35*Degree],
          txt[-23.5*Degree, 35*Degree]}]
showit


ListPlot[{t0717[0,35*Degree], t0717[23.5*Degree, 35*Degree], 
         t0717[-23.5*Degree,35*Degree]}]
showit

TODO: mention this file



ParametricPlot[{az[tdec,ha,tlat], el[tdec,ha,tlat]}, {ha,-Pi,Pi}]

(* radius and angle of gnomon; note 'rad' is existing function, sigh *)

(* and the corresponding xy point *)

xy[dec_,ha_,lat_]=  radi[dec,ha,lat]*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}

xyfake[dec_,ha_,lat_]=  1*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}

xy[dec_,ha_,lat_]=  {
 radi[dec,ha,lat]*Cos[ang[dec,ha,lat]],
 radi[dec,ha,lat]*Sin[ang[dec,ha,lat]]
};

xy[dec_,ha_,lat_]=  {
 radi[dec,ha,lat]*Sin[ang[dec,ha,lat]],
 radi[dec,ha,lat]*Cos[ang[dec,ha,lat]]
};







t2244 = Table[xy[0,ha,35*Degree], {ha,-Pi/4,Pi/4,Pi/48}]





tdec = 0
tlat = 35*Degree;

Plot[Cot[el[tdec,ha,tlat]], {ha,-Pi,Pi}]



decHaLat2azEl[dec,ha,lat]

decHaLat2azEl[dec,0,lat]

D[decHaLat2azEl[dec,ha,lat],ha]

FullSimplify[% /. ha -> 0]

{-(Cos[dec] Csc[dec - lat]), 0}

Solve[D[-Cos[dec]*Csc[dec-lat],dec]==0, dec]

decHaLat2azEl[dec,ha,lat]

decHaLat2azEl[0,ha,35*Degree]

ParametricPlot[decHaLat2azEl[0,ha,35*Degree], {ha,-Pi,Pi}]

ParametricPlot[decHaLat2azEl[0,ha,35*Degree]/Degree, {ha,-Pi,Pi}]

TODO: actually list parametric plot so we can see distances and stuff

helper function below makes az range 0-360 because we want center

fix[pair_] := {Mod[pair[[1]],2*Pi], pair[[2]]}

t = Table[N[fix[decHaLat2azEl[0,ha,35*Degree]]]/Degree,{ha,-Pi,Pi,2*Pi/48}]
ListPlot[t, PlotRange -> {{0,360}, {-55,55}}]
showit

t = Table[N[fix[decHaLat2azEl[0,ha,35*Degree]]]/Degree,{ha,-Pi,Pi,2*Pi/48}]
ListPlot[t, PlotRange -> {{0,360}, {-55,55}}]
showit

tab[dec_] = Table[N[fix[decHaLat2azEl[dec,ha,35*Degree]]]/Degree,
 {ha,-Pi,Pi,2*Pi/48}];

(* hours and degrees *)

fix[pair_] := {Mod[pair[[1]]/Pi*180,360], pair[[2]]/Degree}

tab[dec_] = Table[fix[decHaLat2azEl[dec,ha,35*Degree]], {ha,-Pi,Pi,2*Pi/48}];

pts[dec_] = Table[
 Text[ToString[Mod[ha/Pi*12+12,24]],
 fix[decHaLat2azEl[dec,ha,35*Degree]]], {ha,-Pi,Pi,2*Pi/24}];
Graphics[pts[0]]
showit

g1 = ListPlot[{tab[-23.5*Degree], tab[0*Degree], tab[23.5*Degree]}];
g2 = Graphics[{pts[-23.5*Degree], pts[0*Degree], pts[23.5*Degree]}];
Show[{g1,g2}]
showit

TODO: label points with hours!

Plot[-Cot[(el+16/60)*Degree]+Cot[el*Degree],{el,0,90}, ImageSize -> {800,600}]



*)

TODO: refraction formula

https://en.wikipedia.org/wiki/Atmospheric_refraction

Atmospheric refraction of the light from a star is zero in the zenith, less than 1# (one arc-minute) at 45apparent altitude, and still only 5.3# at 10altitude; it quickly increases as altitude decreases, reaching 9.9# at 5altitude, 18.4# at 2altitude, and 35.4# at the horizon;[4] all values are for 10  and 1013.25 hPa in the visible part of the spectrum.

TODO: this is also the page that mentions multiple sunrises

TODO: Stellarium sanity check (not best way, but fun)

TODO: convert refraction ha to hg geometric?

(* using ela instead of wp's ha to avoid hour angle conflict *)

(* precision not really there, but Mathematica likes it

ref[ela_] = Cot[(ela/Degree + (731/100/(ela/Degree+44/10)))*Degree]/60*Degree

ela - ref[ela] == geomel

Series[1/ref[ela], {ela, 0, 2}]


TODO: plot umbra recta/versa per minute or something? (umbra centra vs average of two?)

TODO: ignoring decl changs, so insane precision = bad?

3 deg for Stellarium to show problems

