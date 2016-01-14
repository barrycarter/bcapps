(* http://physics.stackexchange.com/questions/228542/calculating-time-from-altitude-of-the-sun *)

(* If I know the angle between the sun and the horizon, the latitude
and longitude of the location, and the day, what equations are needed
to calculate the time *)

(*

TODO: mention git

**Summary**:

  - Compute the number of days since 31 December 1999 (or even
  December 31st of the previous year if you need less precision), call
  this `d`.

  - Compute the sun's declination:

$
   0.171144 \cos (2.6491\, -0.0516083 d)+0.381008 \cos (3.03481\, -0.0344047
    d)+23.258 \cos (2.97552\, -0.017203 d)+0.377319
$

  - Compute the sun's hour angle:

$
   12\pm \frac{1}{15} \cos ^{-1}(\sec (\text{dec}) \sec (\text{lat}) (\sin
    (\text{el})-\sin (\text{dec}) \sin (\text{lat})))
$

where `el` is your observed elevation of the sun, `dec` is the
declination you computed earlier, and `lat` is your latitude.

Note that the sun reaches the same elevation twice a day (eg, the
elevation is near 0 at both sunrise and sunset), so this calculation
will always give you 2 results. To determine which result is correct,
you need additional information, such as whether it's before or after
solar noon. There are many ways to do this (eg, see if the sun is
getting higher or lower in the sky by observing the length of a shadow
cast by a straight stick in the ground [shorter = sun's getting higher
so it's before solar noon, longer = sun's getting lower so it's after
solar noon]), but, since this information isn't given, we'll continue
to use both values.

  - Add the correction for the equation of time:

$
   0.166219 \cos (1.24548\, -0.0344057 d)+0.122628 \cos (1.64551\, -0.0172016
    d)+0.00877307
$

where `d` is the same `d` you computed in the first step.

  - Add the correction for standardized time zones:

$
   \text{Round}\left[\frac{\text{long}}{15}\right]-\frac{\text{long}}{15}
$

  - Add 1 hour for Daylight Saving Time, if applicable.

Precise astronomical calculations can be difficult, so I'm assuming
you're looking for an approximation to the current time, not something
that is to-the-second precise. In particular:

  - I'm assuming the Earth is a sphere, even though it's actually an ellipsoid.

  - I'm ignoring the effects of refraction, which can be considerable
  when the visible (refracted) sun is near the horizon.

  - I'm assuming you are at or near sea level, even if your
  latitude/longitude is for a city with a higher elevation.

**Detailed Steps**

We first calculate the sun's declination. In degrees, this is:

$
   0.171144 \cos (2.6491\, -0.0516083 d)+0.381008 \cos (3.03481\, -0.0344047
    d)+23.258 \cos (2.97552\, -0.017203 d)+0.377319
$

where `d` is the number of days since 1999 December 31 at 1200 GMT. Notes:

  - `d` represents the day of the year for 2000. For example `d=7`
  would be January 7th, 2000.

  - If you're willing to lose some precision in exchange for
  convenience, you can compute the day of the *current* year (instead
  of counting all the way back to 2000), since the sun's declination
  repeats yearly (roughly speaking).

  - To calculate the day of the year, remember that December 31st
  (noon) of the previous year is day 0. This means day 1 is January
  1st, and day 31 is January 31st. Day 31 is also "February 0", so if
  you need a date in February, just add. February 19th, for example,
  would be 31+19 or 50. Since February has 29 days this year, February
  29th would be day 31+29 or day 60, which is also "March 0". However,
  at our level of precision, it doesn't matter whether you could the
  leap day or not: the results will be approximately the same.

  - The formula above is accurate to about 0.1 degrees for this
  century. Since the sun's declination can change by as much as 0.4
  degrees in a day, this amount of precision should suffice.

  - Technically, the formula above computes the sun's declination at
  Greenwich noon for a given day, which is the time when most of the
  world is observing the same day. Again, the inaccuracies from using
  Greenwich noon (instead of the actual, as yet unknown, time) are
  small enough to ignore for our purposes.

If you know the declination `dec` of an object and your latitude
`lat`, you can compute its elevation as follows:

$
   \text{elevation}=\cos (\text{dec}) \cos (\text{ha}) \cos (\text{lat})+\sin
    (\text{dec}) \sin (\text{lat})
$

where ha is the "hour angle".

In our case, we already know the declination and latitude, and want
the hour angle. This is:

$
   \cos ^{-1}(\sec (\text{dec}) \sec (\text{lat}) (\sin (\text{el})-\sin
    (\text{dec}) \sin (\text{lat})))
$

An hour angle of 0 degrees represents noon, and an hour angle of 180
degrees represents midnight. Of course, in most of the world, the sun
won't be visible at midnight. To convert the formula above to 24-hour
clock time, we divide by 15 and add 12. Thus, the time is:

$
   12\pm \frac{1}{15} \cos ^{-1}(\sec (\text{dec}) \sec (\text{lat}) (\sin
    (\text{el})-\sin (\text{dec}) \sin (\text{lat})))
$

where fractional hours can be converted to minutes (60 minutes = 1 hour).

Technically, the hour angle measures sidereal hours, not clock hours,
but since we know the sun moves in right ascension and thus takes
closer to 24 hours (not 23 hours 56 minutes) from noon to noon, we can
use clock hours to increase our accuracy slightly here.

In theory, you could combine the formula for declination with the
formula for time, but you'd end up with:

$
   12\pm \frac{1}{15} \cos ^{-1}(\sec (\text{lat}) \sec (0.171144 \cos (2.6491\,
    -0.0516083 d)+0.381008 \cos (3.03481\, -0.0344047 d)+23.258 \cos (2.97552\,
    -0.017203 d)+0.377319) (\sin (\text{el})-\sin (\text{lat}) \sin (0.171144
    \cos (2.6491\, -0.0516083 d)+0.381008 \cos (3.03481\, -0.0344047 d)+23.258
    \cos (2.97552\, -0.017203 d)+0.377319)))
$

which doesn't really appear to be helpful.

You now have the local solar time, which is a good first approximation
to clock time.

However, the time between two noons isn't always exactly 86400 seconds
(1 clock day), so we can apply a correction in the form of the
Equation of Time (https://en.wikipedia.org/wiki/Equation_of_time).

To within about 1 minute accuracy for this century, the equation of
time in hours is:

$
   0.166219 \cos (1.24548\, -0.0344057 d)+0.122628 \cos (1.64551\, -0.0172016
    d)+0.00877307
$

where `d` is measured as above.

We now add this value to the local solar time we obtained earlier to
get mean local solar time.

To get the clock time, we need to adjust for timezones. Assuming you
are in the time zone closest to your meridian, this correction in hours is:

$
   \text{Round}\left[\frac{\text{long}}{15}\right]-\frac{\text{long}}{15}
$

where `long` is your longitude in degrees. Remember that longitudes
west of the prime meridian (where most of the USA is) are negative.

Finally, add 1 hour if Daylight Saving Time is in effect.

**Worked example** (the time and location below were chosen so that
each step above would be significant)

On October 15th 2016, the sun is 41.5 degrees high in Flagstaff, AZ
(latitude 35.198 degrees north, longitude 111.65 degrees west). What
time is it?

  - We first determine the number of days since 1999 December 31... or
  we can cheat and just count the number of days since December 31
  last year. This is:

<pre><code>
January 31 = February 0 = day 31
February 29 = March 0 = day 31+29 = day 60
March 31 = April 0 = day 60+31 = day 91
April 30 = May 0 = day 91+30 = day 121
May 31 = June 0 = day 121+31 = day 152
June 30 = July 0 = day 152+30 = day 182
July 31 = August 0 = day 182+31 = day 213
August 31 = September 0 = day 213+31 = day 244
September 30 = October 0 = day 244+30 = day 274
</code></pre>

Thus October 15th is 274+15 or day 289 (you can verify this result by
comparing the outputs of the Unix commands `cal -j 10 2016` and `cal
10 2016`)

  - We now compute the sun's declination in degrees using the formula
  above. The result is: -8.748 degrees.

  - We now compute the hour angle by plugging in the declination and
  latitude to get: $12\pm 1.44842$ hours.

  - The fractional part, 0.44842, is about 0.44842*60 = 27 minutes
  approximately.

  - This means that local solar time is 1h27m before or after noon. In
  other words, the local solar time is about 10:33am or 1:27pm.

  - Now, we apply the correction for the equation of time. This
  computes out to: -0.236 hours or about -14 minutes.

  - Adding in the correction, we now know the local mean solar time is
  either 10:19am or 1:13pm.

  - We now apply the correction for longitude, which works out to
  0.443 or about 27 minutes.

  - Adding this 27 minutes back in, we know the non-daylight-savings
  clock time is either 10:46am or 1:40pm

  - Although most of the United States will still be observing Daylight
  Saving Time on October 15, Arizona does not observe Daylight Saving
  Time at all, so we need make no further corrections.

As it turns out, or guess is good to the nearest minute (I turned off
"atmosphere effects" in Stellarium so the sun's elevation would be
visible more clearly):

[[IMAGE]]

*)


(* TODO: note not worth bounty, but still *)

(* daily solar declination this century *)

t[day_] = day*86400+AbsoluteTime[{2000,1,1}]-43200

sd = Table[AstronomicalData["Sun", {"Declination", DateList[t[i]]}],
 {i,1,36525}];

sd3 = Rationalize[sd,0];

(* then did superfour(sd3,3) to get below *)

dec[d_] = 0.37731921109319183 + 0.17114353969934407*
  Cos[2.6491014480640547 - 0.0516083217949086*d] + 
 0.381008013930157*Cos[3.03481263352109 - 0.03440467341653927*d] + 
 23.25797749077835*Cos[2.9755216847831316 - 0.017203031398896944*d];

el[dec_, lat_, ha_] = ArcSin[Cos[dec]*Cos[lat]*Cos[ha] + Sin[dec]*Sin[lat]]

(* this is really plus/minus, but Mathematica doesn't handle that
well, even with PlusMinus[] *)

ha[dec_, lat_, el_] = ArcCos[(Sin[el] - Sin[dec]*Sin[lat])/Cos[lat]/Cos[dec]]

solar[dec_, lat_, el_] = PlusMinus[12, ha[dec,lat,el]/Degree/15]

(* this is hideously ugly *)

sunalt[d_] := AstronomicalData["Sun", {"Altitude", DateList[t[d]],{0,0}},
TimeZone -> 0];

solarnoon[d_] := FindMaximum[sunalt[x], {x,d-.25,d+.25}][[2,1,2]]-d
solarnoons = Table[solarnoon[d],{d,1,36525}];

DumpSave["/home/barrycarter/MATH/solarnoons.mx", solarnoons];

solarnoons2 = 24*N[solarnoons];

eqoftime[d_] = Function[x$, 0.008773065586820438 + 0.16621863187369598*
   Cos[1.2454752262849815 - 0.03440567188713581*x$] + 
  0.12262766296036547*Cos[1.64550620256258 - 0.0172016184688075*x$]][d];
