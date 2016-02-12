(*

There's no really good answer to this, so let me give the slightly
ugly one.

Per Kepler's third law, $\frac{r^3}{t^2}$ is constant for any
satellite orbiting the Earth, where $r$ is the semimajor axis and $t$
is the orbital period.

Since geosynchronus satellites have an orbit of 42164km
(https://en.wikipedia.org/wiki/Geosynchronous_orbit#Orbital_characteristics),
and the Earth's sidereal day is 86164.1 seconds, this constant is
approximately $\frac{10096.5 \text{km}^3}{s^2}$ for satellites
orbiting the Earth.

Thus, for a satellite with semi-major axis of 9600 km, the orbital
period is about 9361 seconds (156 minutes and 1 second).

That means the satellite has already made one orbit in 90 minutes, and
is 3961 seconds into its second orbit. [TODO: this is wrong!!!!]

Per Kepler's second law, this means it's traced out
$\frac{3961}{9361}$ of the area of its elliptical orbit from the focus
of its orbit.

The total area of an ellipse is $2 \pi a b$ where $a$ and $b$ are the
semimajor and semiminor axes respectively.

We don't have $b$, the length of the semiminor axis, but can find it
from the eccentricity:

$b=a \sqrt{1-e^2}$

In this case, that gives us a semiminor axis of about 9406km, and a
total ellipse area of about 283679500 $\text{km}^2$.

Since the satellite has traced out 3961/6391 of this area, it has traced out 

If the satellite were in a circular orbit, it would be 3961/9361*360 =
152.33 degrees from its perigee. In other words, 152.33 degrees is the
"mean anomaly".

Computing the "true anomaly" from the "mean anomaly" isn't easy
(there's no closed form solution), but we can use my answer to
http://math.stackexchange.com/a/1651008/2469 to find a numerical
solution:

  


you can find it using numerical
methods as noted in https://en.wikipedia.org/wiki/Mean_anomaly#Formulae

Doing this, 

*)

er = 6371;

a = 9600;
b = ellipseEA2B[major,.2]
f = Sqrt[a^2-b^2]

er3t2 = 42164^3/86164.1^2

t = temp /. Solve[{a^3/temp^2 == er3t2, temp>0}, temp][[1,1]]

time = 90*60;

final = ellipseMA2XY[a,b,time/t*2*Pi]

s[t_] = {major*Cos[t], minor*Sin[t]};

g2 = ParametricPlot[s[t],{t,0,2*Pi}]

g1 = Graphics[{
 PointSize[.02],
 Point[{a,0}],
 Point[{0,0}],
 Line[{{0,0},final}],
 Circle[{0,0}, {a,b}],
 Arrow[{{0,0}, {a,0}}],
 Point[{final}],
 RGBColor[{0,0,1, 0.2}],
 Disk[{f,0}, er],
 RGBColor[{0,0,1,1}],
 Point[{f,0}]

,}]


Show[g1]
showit
