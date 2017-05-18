https://astronomy.stackexchange.com/questions/20976/determining-sunrise-and-sunset-times-based-on-azimuth-and-elevation

https://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time/14508#14508

== ANSWER STARTS HERE ==

$
\cos ^{-1}\left(-\frac{\tan (\lambda ) (\cos (\lambda ) \cos (\phi ) \cos
(Z)+\sin (\lambda ) \sin (Z))}{\sqrt{(\cos (\lambda ) \sin (Z)-\sin (\lambda)
\cos (\phi ) \cos (Z))^2+\sin ^2(\phi ) \cos ^2(Z)}}\right)-\tan^{-1}
(\cos (\lambda ) \sin (Z)-\sin (\lambda ) \cos (\phi ) \cos (Z),\sin
(\phi ) (-\cos (Z)))
$

is the amount of time from now (see important notes below) a celestial object will set, where:

  - $\phi$ is the azimuth of the object
  - $Z$ is the altitude of the object above the horizon
  - $\lambda$ is the latitude of the observer

**Important notes (MUST READ!)**:

  - The result is in radians. To convert to sidereal hours, multiple by $\frac{12}{\pi }$

  - If the object has a fixed right ascension and declination, divide sidereal hours by 1.002737909350795 to get clock hours.

  - The time computed above is for **geometric midpoint** setting. In reality, refraction near the horizon means the object will set later. Additionally, for objects that have an angular diameter (eg, the Sun), setting usually means when the top edge disappears over the horizon, which will make the set time even later. Accounting for both effects should be possible, but might require numerical methods instead of a closed form formula as above.

  - For the Sun (which *doesn't* have fixed right ascension/declination), do NOT divide as above. By not dividing, you compensate for the Sun's change in right ascension.

  - For the Moon, see "**The Moon**" section below.

  - If the quantity inside the arccosine is greater than 1, the object is always in the sky and never sets or rises.

  - If the quantity inside the arccosine is less than -1, the object is never in the sky and thus also never sets or rises.

  - I did only minimal testing. As always, do not rely on my answers for anything important.

**The Moon**:

  - The Moon's right ascension and declination change rapidly, so this calculation does not work well for the moon.

  - You could compensate for the change in right ascension (and thus hour angle) by approximating the increase as 24 hours every 27.32158 days (its sidereal period) and do an iterative calculation.

  - An even better compensation for the change in right ascension would be to approximate the moon's movement in ecliptic longitude (which is more constant than its movement its right ascension) as 360 degrees per 27.32158 days and then project the ecliptic longitude back to right ascension, and then iterate.

  - Compensating for the moon's change in declination is more difficult. The moon's ecliptic latitude (which can be converted to declination) varies sinusoidally, but the equation $\sin (x)=a$ normally has two solutions. Unless you know whether the moon's ecliptic latitude is increasing or decreasing (ie, whether it's between ascending and descending nodes or vice versa), you won't know the direction of declination change.

**Less important notes (optional):**

  - See https://astronomy.stackexchange.com/questions/14492 for more general equations on when an object rises/sets/etc.

  - Calculations for this answer at: https://github.com/barrycarter/bcapps/blob/master/STACK/bc-object-riset-from-az-elt.m

  - Related calculations: https://github.com/barrycarter/bcapps/blob/master/STACK/bc-rst.m

  - Mathematica was unable to find a simpler form for the "time to set" above, though I sense a simpler form does exist (I could be wrong).

  - If you know the Sun's declination (which you can get from its azimuth and elevation as above), you can *almost* determine the date. However, the sun reaches a given declination twice a year (example: it reaches 0 degrees declination on both equinoxes, by definition), so you can only know it's one of two days.

**Solution notes:**

I learned quite a bit answering this question, and thought it was only solvable numerically until I figured out the shortcut:

  - To convert from the azimuth/elevation sphere to the hour angle/declination sphere, you just rotate around the y axis by $\frac{\pi }{2}-\lambda$ (90 degrees minus the latitude) and then rotate $pi$ (180 degrees) around the z axis.

  - Once you have the declination, computing the hour angle when an object sets is easy.

  - You then subtract the setting time from the current hour angle to get the answer.

**Visualization:**




maybe diagram

== ANSWER ENDS HERE ==

(* for the HA Rey style map, N is up *)

xy2AzEl[x_,y_] = {ArcTan[y,x], Pi/2*(1-Sqrt[x^2+y^2])}

latDec2TotalTimeUp[lat_,dec_] = 2*ArcCos[-Tan[lat]*Tan[dec]]

(* TODO: not fully happy w z rotation below-- why do I need it? *)

AzElLat2HADec[az_,el_,lat_] = FullSimplify[
 Take[xyz2sph[
  rotationMatrix[z,Pi].rotationMatrix[y,Pi/2-lat].sph2xyz[az,el,1]],
 2], conds];


xyLat2HADec[x_,y_,lat_] = AzElLat2HADec @@ Flatten[{xy2AzEl[x,y],lat}]

xyLat2TotalTimeUp[x_,y_,lat_] = latDec2TotalTimeUp[lat, 
 xyLat2HADec[x,y,lat][[2]]]

huehalf[x_] = Hue[3/4*(1-x)]

ContourPlot[xyLat2TotalTimeUp[x,y,35*Degree]/Pi*12, {x,-1,1}, {y,-1,1},
 ColorFunction -> huehalf, Contours -> 23, PlotLegends -> True, 
 ImageSize -> {800,600}]
showit

ContourPlot[xyLat2TotalTimeUp[x,y,35*Degree]/Pi*12, {x,-1,1}, {y,-1,1},
 ColorFunction -> huehalf, Contours -> 47, PlotLegends -> True, 
 ImageSize -> {1024,768}, AspectRatio -> 1]
showit

ContourPlot[xyLat2TotalTimeUp[x,y,35*Degree]/Pi*12, {x,-1,1}, {y,-1,1},
 ColorFunction -> huehalf, Contours -> 47, PlotLegends -> True, 
 ImageSize -> {1024,768}, AspectRatio -> 1]
showit

ContourPlot[xyLat2TotalTimeUp[x,y,35*Degree]/Pi*12, {x,-1,1}, {y,-1,1},
 ColorFunction -> huehalf, Contours -> 47, PlotLegends -> True, 
 ImageSize -> {1095,821}, AspectRatio -> 1]
showit

561 height and 561 width for above (1024,768)






 latDec2TotalTimeUp[lat, 
 azElLat2HADec[ArcTan[y,x],Pi/2-Sqrt[x^2+y^2],lat][[2]]];

ContourPlot[xyLat2TotalTimeUp[x,y,35*Degree], {x,-1,1}, {y,-1,1}]





(* convert AzElLat to HADec via y axis rotation of Lat degrees *)

conds = {-Pi < ha < Pi, -Pi/2 < dec < Pi/2, -Pi/2 < lat < Pi/2,
         -Pi < az < Pi, -Pi/2 < el  < Pi/2}

ContourPlot

ha[az_,el_,lat_] = AzElLat2HADec[az,el,lat][[1]]
dec[az_,el_,lat_] = AzElLat2HADec[az,el,lat][[2]]
time2Set[az_,el_,lat_]=ArcCos[-(Tan[dec[az,el,lat]]*Tan[lat])]-ha[az,el,lat]

time2Set2[az_,el_,lat_] = Piecewise[{
 {0, -(Tan[dec[az,el,lat]]*Tan[lat])<-1},
 {2*Pi, -(Tan[dec[az,el,lat]]*Tan[lat]) > 1},
 {ArcCos[-(Tan[dec[az,el,lat]]*Tan[lat])]-ha[az,el,lat], True}
}];

time2Set[phi,Z,lambda] // TeXForm

xyLat2Time2Set[x_,y_, lat_] = 
 Simplify[time2Set2[ArcTan[x,y], Pi/2-Sqrt[x^2+y^2], lat],conds]

img = ContourPlot[xyLat2Time2Set[x,y,35*Degree], {x,-1,1}, {y,-1,1}]

img = ContourPlot[xyLat2Time2Set[x,y,35*Degree], {x,-1,1}, {y,-1,1},
 PlotLegends -> True]

Show[ImageMultiply[img, ColorNegate@Graphics[Disk[{0, 0}, {1, 1}]]], 
 ImageSize -> {1,1}]

TODO: total timeup graph (declin based)

In[251]:= img = ContourPlot[xyLat2Time2Set[x,y,35*Degree], {x,-1,1}, {y,-1,1},  
 PlotLegends -> True, ImageSize -> {1024,768}, ColorFunction -> Hue, Contours ->
 25]                                                                            




(* Mathematica will not simplify! *)
FullSimplify[time2Set[az,el,lat], conds]

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]

ContourPlot[time2Set2[az*Degree,el*Degree,35*Degree]/Pi*12,
 {az,0,360},{el,0,90}, Contours -> 25, ColorFunction -> Hue,
 PlotLegends -> Automatic, ImageSize -> {800,600}]

ContourPlot[time2Set2[az*Degree,el*Degree,35*Degree]/Pi*12,
 {az,0,360},{el,0,90}, Contours -> 96,
 ColorFunction -> Hue, PlotLegends -> Automatic, ImageSize -> {800,600}]

t1838 = Table[
 Text[ToString[N[time2Set2[az*Degree,el*Degree,35*Degree]/Pi*12,3]],
 {az*Degree, el*Degree}], {az,0,360,10}, {el,0,90,10}]

t1847 = Table[
 Text[ToString[N[time2Set2[az*Degree,el*Degree,35*Degree]/Pi*12,3]],
 {(90-el)*Degree*Cos[az*Degree], (90-el)*Degree*Sin[az*Degree]}],
 {az,0,360,10}, {el,0,90,10}]

Show[Graphics[t1847], ImageSize -> {1024,768}]
showit


TODO: add visualization, perhaps polar plot



== MATHEMATICA.SE QUESTION STARTS HERE ==

Subject: Using "PlotLegends" makes plot much smaller

$Version
11.1.0 for Linux x86 (64-bit) (March 13, 2017)

(* a simple plot, turns out nice *)

t1 = Plot[x^2,{x,-5,5}];
Export["/tmp/test1.png", t1, ImageSize -> {800,600}];

(* let's add a legend, turns out small *)

t2 = Plot[x^2,{x,-5,5},PlotLegends -> {"x^2"}]
Export["/tmp/test2.png", t2, ImageSize -> {800,600}]

(* if we make image bigger, plot still turns out small *)

t3 = Plot[x^2,{x,-5,5},PlotLegends -> {"x^2"}]
Export["/tmp/test3.png", t3, ImageSize -> {800*2,600*2}]

test1.png from the above looks very nice and uses up the entire 800x600 canvas:

[[IMAGE]]

test2.png's plot uses up only a fraction of the 800x600 canvas:

[[IMAGE]]

test3.png has a larger canvas (2 times larger in each direction), but the plot is exactly the same size as in test2.png. I'd at least expect it to be two times bigger in each direction, even if it didn't use up the entire 1600x1200 canvas. My hope for test3.png was to create a larger image that didn't fill the canvas and then use ImageMagick to crop.

Why does this PlotLegends problem occur and how can I fix it?

I've skimmed similar questions on this site, but I don't think any address this issue exactly. Several of these questions suggest "homebrew" solutions, which I'd prefer to avoid if at all possible.

== MATHEMATICA.SE QUESTIONS ENDS HERE ==
