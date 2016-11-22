(*

hoping to answer 
https://astronomy.stackexchange.com/questions/19126/exactly-how-elliptical-is-mercurys-orbit-visually-without-exaggeration/19127#19127

less incorrectly


START OF ANSWER:

[[image36.gif]]

The image above (Sun not to scale) shows the orbit of Mercury with the
Sun as the center. This agrees with two other images that are also
meant to show Mercury's orbit to scale:

  - https://www.reddit.com/r/askscience/comments/5e1zhy/what_does_mercurys_orbit_really_look_like/dab8g7q/ which links to:

http://i.imgur.com/HGXs0Qp.png

  - http://m.teachastronomy.com/astropedia/article/Mercurys-Orbit which embeds:

http://m.teachastronomy.com/astropediaimages/Vulcanoidorbits.png

Both of these look similar to my answer, so I'm reasonably confident
that I'm correct this
time. https://github.com/barrycarter/bcapps/blob/master/STACK/bc-mercury.m
if anyone wants to check my work

Things to note:

  - The primary effect of the eccentricity is that the center of
  Mercury's orbit is quite far from the Sun.

  - The orbit's center is about 0.0796 AU or 11.9 million km from the
  Sun, and the other focus is 23.8 million km from the Sun.

  - Mercury's semiminor axis is 97.86% the length of its semimajor
  axis, so is looks very much like a circle. To see this, we plot
  again, this time using the midpoint of the two foci as the origin:



*)

(* length of an AU from http://neo.jpl.nasa.gov/glossary/au.html in m *)

au = 149597870700;

(* data from Mathematica, converted to AU where appropriate *)

aph = AstronomicalData["Mercury","Apoapsis"]/au;
prh = AstronomicalData["Mercury","Periapsis"]/au;
ecc = AstronomicalData["Mercury","Eccentricity"];

(*

The values above are {0.46669835, 0.30749951, 0.20563069} matching the
values found at https://en.wikipedia.org/wiki/Mercury_%28planet%29

*)

(* semimajor axis *)

sma = (aph+prh)/2

(* use ecc to find semiminor axis [also in bclib.m] *)

smi = sma*Sqrt[1-ecc^2]

(* IF the origin were the midpoint of the foci, the parametric would be: *)

f[t_] = {sma*Cos[t], smi*Sin[t]}

ParametricPlot[f[t], {t,0,2*Pi}]

(* to make sun the center we note the sun is prh-sma (negative) to the
left of the axis above so we add (subtract) that value to get the
right curve *)

g[t_] = {sma*Cos[t]+prh-sma, smi*Sin[t]}

g1 = ParametricPlot[g[t], {t,0,2*Pi}, PlotStyle -> Pink]

g2 = ParametricPlot[f[t], {t,0,2*Pi}, PlotStyle -> Pink]

g3 = Graphics[{
 PointSize[3*AstronomicalData["Sun","Diameter"]/au/2],
 RGBColor[{255,255,0}],
 Point[{sma-prh,0}]
}]

Show[{g2,g3}, Axes -> True, Background -> Black, AxesStyle -> White]



g0 = Graphics[{
 PointSize[0.05],
 RGBColor[{255,255,0}],
 Point[{0,0}]
}]

Show[{g0,g1}, Axes -> True, Background -> Black, AxesStyle -> White]

AstronomicalData["Venus", "Periapsis"]
AstronomicalData["Venus", "Apoapsis"]






(*

TODO: note 97%, sun not to scale

TODO: http://m.teachastronomy.com/astropedia/article/Mercurys-Orbit and http://m.teachastronomy.com/astropediaimages/Vulcanoidorbits.png and https://www.reddit.com/r/askscience/comments/5e1zhy/what_does_mercurys_orbit_really_look_like/ and http://i.imgur.com/HGXs0Qp.png

TODO: further than all others? (check first)

*)


planets = AstronomicalData["Planet"]

Table[{i, AstronomicalData[i, "Apoapsis"] - AstronomicalData[i, "Periapsis"]},
 {i, planets}]

(* above is not interesting *)

