(*

There's no really good answer to this, so let me give the slightly
ugly one.

Per Kepler's third law, `r^3/t^2` is constant for any satellite
orbiting the Earth, where `r` is the semimajor axis and `t` is the
orbital period.

Since geosynchronus satellites have an orbit of 42164km
(https://en.wikipedia.org/wiki/Geosynchronous_orbit#Orbital_characteristics),
and the Earth's sidereal day is 86164.1 seconds, this constant is
approximately 10096.5 km^3/s^2 for satellites orbiting the Earth.

Thus, for a satellite with semi-major axis of 9600 km, the orbital
period is about 9361 seconds (156 minutes and 1 second).

That means the satellite has already made one orbit in 90 minutes, and
is 3961 seconds into its second orbit.

If the satellite were in a circular orbit, it would be 3961/9361*360 =
152.33 degrees from its perigee. In other words, 152.33 degrees is the
"mean anomaly".

Computing the "true anomaly" from the "mean anomaly" isn't easy
(there's no closed form solution), but you can find it using numerical
methods as noted in https://en.wikipedia.org/wiki/Mean_anomaly#Formulae

Doing this, 

*)

er = 6371;

major = 9600;
minor = ellipseEA2B[major,.2]

s[t_] = {major*Cos[t], minor*Sin[t]};

g2 = ParametricPlot[s[t],{t,0,2*Pi}]

g1 = Graphics[{
 RGBColor[{0,0,1}],
 Disk[{0,0}, er],







}
];

Show[g1,g2]
