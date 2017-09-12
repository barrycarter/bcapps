(*

I'm posting this new answer instead of editing my original because this answer serves a different purpose. My original answer used LaTeX and Greek letters to create really fancy looking, but not really very usable, formulas.

In this answer I: 

  - provide formulas that can be computed, not just LaTeX

  - use more familiar abbreviations instead of Greek letters

  - use more familiar units instead of using radians everywhere

  - break down the formulas into sections instead of placing them all in one table.

  - don't provide intermediate calculations or sources, but these are available at https://github.com/barrycarter/bcapps/blob/master/STACK/bc-rst2.m


  - ******BRAG****

Of course, it's impossible to avoid all the ugliness of astronomical calculations, but I've tried to simplify as much as possible.

Additionally, these results are not high-precision. Please see the list of disclaimers at the end of this answer for some (not all) reasons why.

For the answers below:

  - d is the number of days since J2000.0, which is 1200 UTC on 1 Jan 2000.

  - ra is right ascension, in hours

  - dec is declination, in degrees

  - lat is latitude, in degrees

  - lon is longitude, in degrees

*)

conds = {0 < ra < 24, -90 < dec < 90, -90 < lat < 90, -180 < lon < 180}

pi = N[Pi, 20];

degree = N[Degree, 20];

deg2hr[d_] = d/15;

deg2rad[d_] = d*degree;

hr2rad[h_] = h*pi/12

(* low-precision formula from http://aa.usno.navy.mil/faq/docs/GAST.php *)

gmst[d_] = 18.697374558 + 24.06570982441908*d

(* local sidereal time, in hours *)

lst[d_, lon_] = gmst[d] + deg2hr[lon]

(* hour angle, in hours *)

ha[d_, lon_, ra_] = lst[d,lon] - ra

(* azimuth, in degrees *)

HADecLat2azEl[hr2rad[ha[d,lon,ra]], dec*degree, lat*degree][[1]]

(* objects elevtude in degrees *)




TODO: worry about time at 24 and time zones (and disclaim some ugliness still exists)

TODO: ask mr x if I can name him as inspriation

TODO: mention this file, no intermediate

TODO: sources

NOTE: refractions, etc, not taken into account, "geometric"

TODO: disclaim approximations, geometric

TODO: time above x degrees, 

TODO: the brag stuff (bc-mini-astro-lib.*)

TODO: unit testing/testing

TODO: sun simplify eq time, dec, ra?

TODO: keep everything in floats for translates (not doing this now for precision, but worry about it later)

TODO: precision issues?

TODO: elevation vs altitude, or .. elevtude

TODO: pi isn't Pi

TODO: impurify all formulas, but at last minute
