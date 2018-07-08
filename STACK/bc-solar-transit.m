(*

<writeup>

The time it takes the sun to cross the horizon is given at:

  - https://astronomy.stackexchange.com/questions/24304/

  - https://astronomy.stackexchange.com/questions/12824/

Re the time it takes to cross the transit line, this doesn't really answer your question, but, to a good approximation, the time varies between 128 seconds at the equinoxes and 140 seconds at the solstices, regardless of latitude or longitude.

More specifically, the formula is $\frac{128}{\cos (\text{dec})}$ seconds, where $\text{dec}$ is the Sun's declination. You can calculate the Sun's declination using the formulas at https://en.wikipedia.org/wiki/Position_of_the_Sun

The calculation here is relatively simple: 

  - The Sun travels $360 \cos (\text{dec})$ degrees in a 24-hour day, where $\text{dec}$ is the Sun's declination

  - When the Sun is transiting, the motion is perpendicular to the transit line (the Sun's motion is entirely in azimuth, not in altitude)

  - Therefore, all of the Sun's angular motion translates to motion across the transit line; in contrast, the Sun rises and sets a (non-perpendicular) angle (except at tropical latitudes on the two days where the Sun passes directly overhead), so sunsets and sunrises take longer than $\frac{128}{\cos (\text{dec})}$ seconds

  - Since the Sun has an angular diameter of 32 minutes or $\frac{8}{15}$ degrees, it takes $\frac{\frac{8}{15}}{360 \cos (\text{dec})}$ of a day for the Sun to cross the transit line

  - Since a day is 86400 seconds, this works out to $\frac{128}{\cos (\text{dec})}$ seconds.

Caveats and nitpicks:

  - I assume there are 86400 seconds between successive noons. This is incorrect for two reasons:

    - The time between noons is not exactly one day. The cumulative difference forms the [Equation of Time](https://en.wikipedia.org/wiki/Equation_of_time) but the day to day difference is quite small

    - The Earth's day is slightly longer than 86400 seconds, which is why we need [leap seconds](https://en.wikipedia.org/wiki/Leap_second)

  - The Sun's angular diameter actually varies based on Earth's distance from the Sun, but 32 minutes is a good approximation

  - I assume the Sun's altitude doesn't change while it's transiting. While this is a good approximation, the altitude does change slightly

  - I assume the Sun's declination doesn't change while it's transiting. The change in declination is very small, so this is a reasonable assumption

  - There are probably other assumptions I made implicitly that I am not noting here.

  - Refraction is not an issue, since the motion we are discussing is azimuthal and not in altitude.

  - I used the "one over cosine" form above to make things easier for non-mathematicians. The more compact form would use "secant".

  - The calculations I did for this problem are disorganized, but available at: https://github.com/barrycarter/bcapps/blob/master/STACK/bc-solar-transit.m

</writeup>


https://astronomy.stackexchange.com/questions/26875/how-to-calculate-the-time-for-the-solar-disk-to-pass-the-horizon-and-transits-l

math ~/BCGIT/ASTRO/bc-astro-formulas.m


*)

raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst]

HADecLat2azEl[ha,dec,lat]

raDecLatLonGMST2Az[ra, dec, lat, lon, gmst]

raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]

Solve[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst] == Pi, gmst]

D[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst], gmst]

Simplify[raDecLatLonGMST2Az[ra, dec, lat, lon, ra-lon], Reals]         

D[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst], gmst] /. gmst -> ra-lon

Simplify[
D[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst], gmst] /. gmst -> ra-lon
]

above is: -(Cos[dec] Csc[dec - lat])



Simplify[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst] /. gmst -> ra-lon,conds]

ArcTan[Abs[Sin[dec - lat]], Cos[dec - lat]]

Simplify[
Cos[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]] /. gmst -> ra-lon,
conds]

azChangeAtNoon[dec_, lat_] = -(Cos[dec] Csc[dec - lat])

FullSimplify[
azChangeAtNoon[dec, lat]*Cos[ArcTan[Abs[Sin[dec - lat]], Cos[dec - lat]]],
conds]

so it really is Cos[dec] radians per radian hour

2.13333 minutes at the equator

128 seconds

3h49m11s = radian hour







above is essentially lat-dec



