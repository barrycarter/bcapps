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
   \cos ^{-1}(\sec (\text{dec}) \sec (\text{lat})
    (\text{elevation}-\sin (\text{dec}) \sin (\text{lat})))
$




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

(* This list has 0's with different *10^n *)

test0 = Fourier[sd];

(* this is needed to avoid loss of precision; note that 6 digits adds
excessive precision, but Wolfram has too little *)

sd2 = N[Rationalize[sd,0],6];

sd3 = Rationalize[sd,0];









(* tropical year from http://hpiers.obspm.fr/eop-pc/models/constants.html *)

tyear = 365.242190402;

(* NOTE: this should work without Date[] but doesn't *)

AstronomicalData["Sun", {"Declination", Date[]}]

start = AbsoluteTime[{2016,1,1}]
end = AbsoluteTime[{2017,1,1}]

t[day_] = day*86400+AbsoluteTime[{2016,1,1}]-43200

(* TODO: explain my day convention *)

Plot[AstronomicalData["Sun", {"Declination", DateList[t[day]]}],
 {day,1,366}]

sundec[d_] := AstronomicalData["Sun", {"Declination", DateList[t[d]]}];
sunra[d_] := AstronomicalData["Sun", {"RightAscension", DateList[t[d]]}];

res  = NIntegrate[Exp[2*Pi*I*x/tyear]*sundec[x],{x,0,tyear}]

(* res = -4184.99 + 729.51 I *)

amp = Norm[res]/tyear*2

phase = Arg[res]/Degree

Plot[{amp*Cos[2*Pi*x/tyear-phase*Degree],sundec[x]},{x,0,tyear}]

(* about 0.8 degree accuracy *)

Plot[{amp*Cos[2*Pi*x/tyear-phase*Degree]-sundec[x]},{x,0,tyear*10}]

Plot[fakederv[sunra,d,.01],{d,0,tyear}]

Plot[If[sunra[d]>sunra[0],sunra[d]-24,sunra[d]],{d,0,tyear}]

