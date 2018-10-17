(* 

See also: http://www.stjarnhimlen.se/comp/ppcomp.html

3155716800 = 1 Jan 2000 at noon UTC

bc-make-planet-mag-files.pl creates ready to load files that contain
planet phase value, distance from Sun/Earth, and magnitude

*)

<formulas>

(* convert luminosity to magnitude and vice versa *)

lum2mag[lum_] = Log10[lum]*-5/2;

mag2lum[mag_] = 100^(-mag/5);

(* below directly from HORIZONS files *)

au = 149597870.700

</formulas>

planets = {"mercury", "venus", "moon", "mars", "jupiter", "saturn", "uranus",
	"neptune", "pluto"};

(* from https://nineplanets.org/data1.html, third param is visible magnitude at opposition *)

info[mercury] = {2440, 0.11, -1.9};
info[venus] = {6052, 0.65, -4.4};
info[mars] = {3397, 0.15  -2.0};
info[jupiter] = {71492, 0.52,  -2.7};
info[saturn] =  {60268, 0.47, 0.7};
info[uranus] = {25559, 0.51, 5.5};
info[neptune] =  {24766, 0.41, 7.8};
info[pluto] =  {1150, 0.55,  13.6};

Table[planet[i] = Import["/tmp/"<>i<>"-final.txt", "CSV"], {i, planets}];

(* area in arcsecond^2 of an object with radius r at distance d *)

arcarea[r_, d_] = Pi*((3600*ArcTan[r/d]/Degree)^2)

(* luminescence per arcsecond^2, adjusted for solar distance and albedo *)

test1919 = Table[{i[[4]], 
 lum2mag[
 mag2lum[i[[8]]] * i[[5]]^2/au^2 / 
 (Pi*(ArcTan[info[saturn][[2]]/i[[6]]])^2) /
 info[saturn][[2]]
 ]},
 {i, planet["saturn"]}];




venus = Import["/tmp/venus-final.txt", "CSV"];

(* have to use barycenter here *)

mars = Import["!bc-magnitude 4 | paste -d, - /tmp/mars.txt", "CSV"];

jup = Import["!bc-magnitude 5 | paste -d, - /tmp/jupiter.txt", "CSV"];

moon = Import["!bc-magnitude 301 | paste -d, - /tmp/moon.txt", "CSV"];

(* convert magnitude to luminosity, adjust for distances and albedo,
Venus = 0.689 *)

ven2 = Table[{i[[4]], 
 lum2mag[mag2lum[i[[8]]]*i[[5]]^2*i[[6]]^2/0.689/6052^2/au^4]},
 {i, venus}];

mars2 = Table[{i[[4]], 
 lum2mag[mag2lum[i[[8]]]*i[[5]]^2*i[[6]]^2/0.17/3397^2/au^4]},
 {i, mars}];

jup2 = Table[{i[[4]], 
 lum2mag[mag2lum[i[[8]]]*i[[5]]^2*i[[6]]^2/0.52/71492^2/au^4]},
 {i, jup}];

moon2 = Table[{i[[4]], 
 lum2mag[mag2lum[i[[8]]]*i[[5]]^2*i[[6]]^2/0.12/1738^2/au^4]},
 {i, moon}];

ven3 = Table[{i[[4]], 
 lum2mag[mag2lum[i[[8]]]*i[[5]]^2*i[[6]]^2/0.689/6052^2/au^4/(i[[4]]/Pi)]},
 {i, venus}];







data[planet_, t_] := Module[{hc, ec, mag},

 (* the coordinates of the Earth and planet *)

 hc = PlanetData[planet, 
  EntityProperty["Planet", "HelioCoordinates", {"Date" -> unix2Date[t]}]]/
   Quantity[1, "astronomical unit"];

 ec = PlanetData["Earth", 
  EntityProperty["Planet", "HelioCoordinates", {"Date" -> unix2Date[t]}]]/
      Quantity[1, "astronomical unit"];

 mag = PlanetData[planet, 
  EntityProperty["Planet", "ApparentMagnitude", {"Date" -> unix2Date[t]}]];

(*
 Return[{VectorAngle[-ec, hc-ec], mag2lum[mag]*Norm[hc]^2*Norm[hc-ec]^2}];
*)


 Return[{VectorAngle[ec, hc], mag2lum[mag]*Norm[hc]^2*Norm[hc-ec]^2}];
];

temp2048 = Table[data["Jupiter", t], {t, 0, 86400*1000, 86400*5}];

temp2048 = Table[data["Jupiter", t], {t, 0, 86400*365, 86400*15}];

temp2049 = Table[data["Venus", t], {t, 0, 86400*365*3, 86400*15}];

(* on 14 Oct 2018, consider phase angle vs central angle *)

(* cent angle is theta, a is earth dist, r is planet dist *)

conds = {a > 0, r >0, theta > 0}

earth = {a,0}

planet = r*{Cos[theta], Sin[theta]}

phi = Simplify[VectorAngle[planet, planet-earth], conds]

Plot[phi /. {a -> 1, r -> 5}, {theta,0,2*Pi}]

Simplify[D[phi, a], conds]

Simplify[D[phi, r], conds]














pos[planet_, t_] :=  PlanetData[planet, 
  EntityProperty["Planet", "HelioCoordinates", {"Date" -> unix2Date[t]}]];



HelioCoordinates[

EntityProperty["Jupiter", "ApparentMagnitude"]

temp2014 = PlanetData["Jupiter"]["Properties"]

PlanetData["Jupiter", {"ApparentMagnitude", {"Date" ->
ToDate[3155716800]}}]

mag[planet_, d1_, d2_] := 
 PlanetData[planet, 
  Table[EntityProperty["Planet", 
    "ApparentMagnitude", {"Date" -> DateObject[date]}], {date, 
    DateRange[d1, d2, "Week"]}]]

mag[planet_, d1_] :=
 PlanetData[planet, 
  EntityProperty["Planet", "ApparentMagnitude", 
  {"Date" -> unix2Date[d1]}]];

NMaximize[mag["Mercury", d], d]

Plot[mag["Mercury", d], {d, 0, 100*86400*366}]

Table[mag["Mercury", d], {d, 0, 86400*100, 86400}]

    Mercury:   -0.36 + 5*log10(r*R) + 0.027 * FV + 2.2E-13 * FV**6
    Venus:     -4.34 + 5*log10(r*R) + 0.013 * FV + 4.2E-7  * FV**3
    Mars:      -1.51 + 5*log10(r*R) + 0.016 * FV
    Jupiter:   -9.25 + 5*log10(r*R) + 0.014 * FV
    Saturn:    -9.0  + 5*log10(r*R) + 0.044 * FV + ring_magn
    Uranus:    -7.15 + 5*log10(r*R) + 0.001 * FV
    Neptune:   -6.90 + 5*log10(r*R) + 0.001 * FV

    Moon:      +0.23 + 5*log10(r*R) + 0.026 * FV + 4.0E-9 * FV**4

    ring_magn = -2.6 * sin(abs(B)) + 1.2 * (sin(B))**2

Here B is the tilt of Saturn's rings which we also need to compute. Then we start with Saturn's geocentric ecliptic longitude and latitude (los, las) which we've already computed. We also need the tilt of the rings to the ecliptic, ir, and the "ascending node" of the plane of the rings, Nr:

    ir = 28.06_deg
    Nr = 169.51_deg + 3.82E-5_deg * d

Here d is our "day number" which we've used so many times before. Now let's compute the tilt of the rings:

    B = asin( sin(las) * cos(ir) - cos(las) * sin(ir) * sin(los-Nr) )

bzcat jupiter-brightness.txt.bz2 | perl -F, -anle 'print $F[5]'|sort -nu|less

tab = {
 {"Sun", -26.78, -26.71},
 {"Mercury", -2.45, 5.58},
 {"Venus", -4.89, -3.82},
 {"Moon", -12.87, -3.76},
 {"Mars", -2.88, 1.84},
 {"Jupiter", -2.94, -1.66},
 {"Saturn", 0.42, 1.47},
 {"Uranus", 5.31, 5.95},
 {"Neptune", 7.80, 8.00},
 {"Pluto", 13.75, 15.96},
 {"Comet Halley", 2, 25.66},
 {"Tesla Roadster", 6.66, 29.29}
}

tab2 = Table[Flatten[{i, i[[3]]-i[[2]]}], {i, tab}]

tab3 = 
 Prepend[tab2, Table[Style[i, Bold], {i, {"Body", "Max", "Min", "Delta"}}]]

g = Grid[tab3, Frame -> All];

moon moves too fast, but 100y

files are avail

 max/min brightness

<answer>

$
\begin{array}{cccc}
                   \text{Body} & \text{Max} & \text{Min} & \text{Delta} \\
                   \text{Sun} & -26.78 & -26.71 & 0.07 \\
                   \text{Mercury} & -2.45 & 5.58 & 8.03 \\
                   \text{Venus} & -4.89 & -3.82 & 1.07 \\
                   \text{Moon} & -12.87 & -3.76 & 9.11 \\
                   \text{Mars} & -2.88 & 1.84 & 4.72 \\
                   \text{Jupiter} & -2.94 & -1.66 & 1.28 \\
                   \text{Saturn} & 0.42 & 1.47 & 1.05 \\
                   \text{Uranus} & 5.31 & 5.95 & 0.64 \\
                   \text{Neptune} & 7.8 & 8. & 0.2 \\
                   \text{Pluto} & 13.75 & 15.96 & 2.21 \\
                   \text{Comet Halley} & 2 & 25.66 & 23.66 \\
                   \text{Tesla Roadster} & 6.66 & 29.29 & 22.63 \\
                  \end{array}
$

The answer is Mercury (as above), subject to the proecedure/caveats below:

###Procedure###

  - I used HORIZONS to generate daily brightness data for a century for:

    - all the planets as viewed from Earth (except Earth itself)

    - the Sun, the Moon, Pluto, Comet Halley, and the Tesla Roadster

  - I then noted the minimum and maximum brigtness, along with the magnitude difference of these brightnesses, in the table above.

  - You can use HORIZONS to compute the results yourself, or view the results in the *-brightness.txt.bz2 files in https://github.com/barrycarter/bcapps/blob/master/ASTRO/

###Caveats###

  - Although Mercury's brightness changes more than Mars, the Sun's glare makes it impossible to see Mercury though Earth's atmosphere when Mercury's angular distance from the Sun is small. Therefore, Mars may be a better practical answer.

  - Because I used daily brightnesses, it's theoretically possible I missed absolute (intraday) minimums or maximums, especially for the Moon, whose brightness changes rapidly. However: 

    - I took 100 years worth of data, and the moon's brightness doesn't have a period that's a multiple of one day. Since the moon's synodic period is approximately 29.5 days, its brightness is almost periodic in 59 days (2 synodic periods), but it's far enough from 29.5 days that this shouldn't be too much of a problem.

    - The Moon isn't a planet: I just added it for reference

    - Unless the Moon's actual brightness difference was higher than 23.66 magnitudes (which is probably unlikely[?]), it would remain in 2nd place in terms of brightness change, so the exact value isn't as important.

  - Because I used only a 100 year period, I did not include a complete orbit for either Neptune or Pluto. This shouldn't be an issue because:

    - The synodic period of both planets is just over a year, and much of the brightness change comes from Earth's own orbit, not Neptune's or Pluto's.

    - Even if the maximum magnitude change were slightly higher than in the table, it wouldn't make much of a difference.

  - Note that "Max" and "Min" refer to brightness, which is ordered the opposite of magnitude: lower magnitude means greater brightness.

  - Because I used daily data, I missed rare events such as transits and eclipses. The table above is for an "average" orbit, excluding special cases.

  - In some cases, HORIZONS gives "n.a." for magnitude data. I ignore these "n.a." values.

  - Data for the Tesla Roadster is only available from 2018-Feb-07 03:00 UTC to 2090-Jan-01 23:00 UTC, not the entire century.
  
###Complexity###

The problem is nontrivial. As you correctly note, the planet's geocentric and heliocentric distance play into the formula, but there's more to it.

Quoting Oliver Montenbruck and Thomas Pfleger's "Astronomy on the Personal Computer" (https://books.google.com/books?id=nHUqBAAAQBAJ):

[[images]]

Paul Schlyter's http://www.stjarnhimlen.se/comp/ppcomp.html#15 provides similar nontrivial formulas.

TODO: how dark does the moon really get?

