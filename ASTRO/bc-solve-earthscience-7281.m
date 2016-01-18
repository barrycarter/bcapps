(* attempts to solve http://earthscience.stackexchange.com/questions/7281/what-is-the-moons-distance-from-viewer-at-horizon *)

(*

TODO: summarize answer, ignoring refraction, not to scale

Per Wikipedia (https://en.wikipedia.org/wiki/Moon) the moon's average
apogee is 405400km and the average perigee is 362600km.

The time between two perigees is 27.554551 days, or one anomalistic month:

https://en.wikipedia.org/wiki/Lunar_month#Anomalistic_month

Thus, a rough formula for the moon's distance is:

$384000+21400 \sin \left(\frac{2 \pi  x}{27.5546}\right)$

where t is measured in days, and t=0 is between a perigee and an
apogee, when the moon is at average distance. The graph looks like
this:

[[image1.jpg]]

The change in the moon's distance (also known as the moon's "radial
velocity", ie, it's velocity towards or away from us) is the
derivative of this function, which is:

$\frac{21400\ 2 \pi  \cos \left(\frac{2 \pi  t}{27.5546}\right)}{27.5546}$

or

$4879.78 \cos (0.228027 t)$

When t=0, the moon's radial velocity reaches a maximum of 4879.78 km
per day or about 203 km per hour.

When the moon is at the horizon, it's distance from you can be
computed using this image:






*)


f[t_] = 384000 + 21400*Sin[2*Pi*t/27.554551]

earth = {RGBColor[0,0,1], Circle[{0,0}, 1]};

moons = {
 {Circle[{-1.5,1}, 0.1], AxesOrigin->{0,0}},
 {Circle[{0,1.8}, 0.1]} 
};

you = {RGBColor[1,0,0], Circle[{1,0}, 0.1]}

arrows = {
 Line[{{0,0}, {-1.5,1}}],
 Arrow[{{0,1}, {-1.5,1}}],
 Line[{{0,0}, {0,1}}],
 Arrow[{{0,1}, {0,1.8}}]
};

Graphics[{earth,moons,arrows,you}]
showit

