(* http://physics.stackexchange.com/questions/228542/calculating-time-from-altitude-of-the-sun *)

(* If I know the angle between the sun and the horizon, the latitude
and longitude of the location, and the day, what equations are needed
to calculate the time *)

(*

Precise astronomical calculations can be difficult, so I'm assuming
you're looking for an approximation to the current time, not something
that is to-the-second precise.

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










Cos[dec] Cos[lat] Cos[ha] + Sin[dec] Sin[lat]

goodness of fit, daily motion




TODO: solar noon, high low declination, formula, 23h56m days,work example off meridian, not abq


*)


(* TODO: note not worth bounty, but still *)

(* TODO: explain lack of precision *)

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

(* modified from
https://www.wolfram.com/mathematica/new-in-10/symbolic-dates-and-times/do-celestial-time-calculations.html
*)

sunaz[d_] := AstronomicalData["Sun", {"Azimuth",
DateList[t[d]],{0,0}}, TimeZone -> 0];

FindRoot[sunaz[d] == 180, {d,7.5,8.5}]

sunalt[d_] := AstronomicalData["Sun", {"Altitude", DateList[t[d]],{0,0}}];

Plot[AstronomicalData["Sun", {"Azimuth", DateList[t], {0,0}}], {t,0,86400}]

sunpos = SunPosition[GeoPosition[{0, 0}], 
   DateRange[DateObject[{2014, 1, 1, 12, 0}, TimeZone -> 0], 
    DateObject[{2014, 12, 31, 12, 0}, TimeZone -> 0], 10], 
   CelestialSystem -> "Equatorial"];
stime = SiderealTime[GeoPosition[{0, 0}], 
   DateRange[DateObject[{2014, 1, 1, 12, 0}, TimeZone -> 0], 
    DateObject[{2014, 12, 31, 12, 0}, TimeZone -> 0], 10]];
equationoftime = 
  TimeSeriesThread[
   With[{diff = First[#][[1]] - Last[#]}, 
     UnitConvert[
      Mod[diff, Quantity[24, "HoursOfRightAscension"], 
       Quantity[-12, "HoursOfRightAscension"]], 
      "MinutesOfRightAscension"]] &, {sunpos, stime}];
DateListPlot[equationoftime, PlotLabel -> "Equation of Time", 
 Axes -> True]

AstronomicalData[ 
     "Sun", {"Azimuth", {2008, 1, 5, 12, 1, 1}, {0, 0}}, TimeZone -> 0]

AstronomicalData[ 
     "Sun", {"Azimuth", DateList[t[4.7]], {0, 0}}, TimeZone -> 0]

positions = Table[{
    AstronomicalData[
     "Sun", {"Azimuth", {2008, 1, i, 8.5}, {40.1, -88.2}}, 
     TimeZone -> -5], 
    AstronomicalData[
     "Sun", {"Altitude", {2008, 1, i, 8.5}, {40.1, -88.2}}, 
     TimeZone -> -5]}, {i, 1, 365.25, 5}];

Graphics[{Orange, Point[QuantityMagnitude@positions]}, Frame -> True, 
 FrameLabel -> {"azimuth", "altitude"}]
