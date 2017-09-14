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

(* sidereal multiplier *)

sm = Rationalize[1.002737909350795,0]

unix2d[unix_] = (unix-946728000)/86400

deg2hr[d_] = d/15;

deg2rad[d_] = d*Degree;

hr2rad[h_] = h*Pi/12

rad2hr[r_] = 12*r/Pi

hms2dml[h_,m_,s_] = h+m/60+s/3600

dml2hms[h_] = {Floor[h], Mod[Floor[h*60],60], Mod[Floor[h*3600],60]}

(* "proper" time zone for longitude, excludes DST and shifting lines *)

lon2tz[lon_] = Floor[(lon+15/2)/15]

(* low-precision formula from http://aa.usno.navy.mil/faq/docs/GAST.php *)

gmst[d_] = Rationalize[18.697374558 + 24.06570982441908*d,0]

(* local sidereal time, in hours *)

lst[d_, lon_] = gmst[d] + deg2hr[lon]

(* hour angle, in hours *)

ha[d_, lon_, ra_] = lst[d,lon] - ra

(* azimuth, in degrees *)

az[d_, lon_, lat_, ra_, dec_] = 

ArcTan[Cos[Degree*lat]*Sin[dec*Degree] - Cos[dec*Degree]*Sin[Degree*lat]*
    Sin[Degree*lon + (8475931*Pi)/145848699 + (424749743*d*Pi)/211794996 - 
      15*Degree*ra], Cos[dec*Degree]*Cos[Degree*lon + (8475931*Pi)/145848699 + 
     (424749743*d*Pi)/211794996 - 15*Degree*ra]]/Degree

(* elevation, in degrees *)

el[d_, lon_, lat_, ra_, dec_] = 

ArcTan[Sqrt[Cos[dec*Degree]^2*Cos[Degree*lon + (8475931*Pi)/145848699 + 
        (424749743*d*Pi)/211794996 - 15*Degree*ra]^2 + 
    (Cos[Degree*lat]*Sin[dec*Degree] - Cos[dec*Degree]*Sin[Degree*lat]*
       Sin[Degree*lon + (8475931*Pi)/145848699 + (424749743*d*Pi)/211794996 - 
         15*Degree*ra])^2], Sin[dec*Degree]*Sin[Degree*lat] + 
   Cos[dec*Degree]*Cos[Degree*lat]*Sin[Degree*lon + (8475931*Pi)/145848699 + 
      (424749743*d*Pi)/211794996 - 15*Degree*ra]]/Degree

(* time above horizon, in hours *)

timeAboveHorizon[lat_, dec_] = 
 2*rad2hr[ArcCos[-Tan[deg2rad[dec]]*Tan[deg2rad[lat]]]]/sm

(* this is the "first" culmination, rise, and set, in UTC hours *)

firstCulmination[lon_, ra_] = 
 -128347191211217552/6883244157459373 - (141196664*lon)/2123748715 + 
 (423589992*ra)/424749743


firstRise[lon_, lat_, ra_, dec_] = 
 -128347191211217552/6883244157459373 - (141196664*lon)/2123748715 + 
 (423589992*ra)/424749743 - 
 (7319365776*ArcCos[-(Tan[dec*Degree]*Tan[Degree*lat])])/(25484047*Pi)


firstSet[lon_, lat_, ra_, dec_] = 
 -128347191211217552/6883244157459373 - (141196664*lon)/2123748715 + 
 (423589992*ra)/424749743 + 
 (7319365776*ArcCos[-(Tan[dec*Degree]*Tan[Degree*lat])])/(25484047*Pi)


(* if something occurs at time b and then every time k after that, when is the first time it occurs AFTER time d *)

b + k*Ceiling[n /. Solve[b + k*n == d, n][[1]]]

bkAfterD[b_,k_,d_] = b + k*Ceiling[(-b + d)/k]

(* this is culmination after a given day, result adjusted for timezone *)

(* TODO: convert to hms excessive? *)

culmination[d_, lon_, ra_] = 
 ExpandAll[bkAfterD[firstCulmination[lon,ra], 24/sm, d*24]+lon2tz[lon]]




















Solve[ha[d,lon,ra]==0, d]

(* time an object culminates, general solution *)

nthCulmination[lon_, ra_, n_] = 
 d /. Expand[Solve[ha[d,lon,ra] == 24*n, d]][[1]]

(* culmination "on" day d, but not necessarily an integer *)

Solve[nthCulmination[lon,ra,n] == d, n]

(* culmination occuring after day d *)

nthCulminationAfterTime[lon_, ra_, d_] = 
 Floor[(80216994507010970 + 103248662361890595*Floor[d] + 
286018746493613*lon - 4290281197404195*ra)/102966748737700680]+1

(* time of culmination after day d *)

timeCulmination[lon_, ra_, d_] =  Expand[FullSimplify[
24*(nthCulmination[lon, ra, nthCulminationAfterTime[lon, ra, d]]-Floor[d])
, conds]]



















Solve[el[d,lon,lat,ra,dec] == 0, d]




(* this is midnight today (for me) *)

az[unix2d[1505196000], -106.5, 35, 0, 0]

az[unix2d[1505196000+3600], -106.5, 35, 0, 0]

az[unix2d[1505196000+3600], -106.5, 35, 0, 10]

FullSimplify[
HADecLat2azEl[hr2rad[ha[d,lon,ra]], dec*Degree, lat*Degree][[1]]/Degree,
conds]

FullSimplify[
HADecLat2azEl[hr2rad[ha[d,lon,ra]], dec*Degree, lat*Degree][[2]]/Degree,
conds]



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

TODO: order lat/lon ra/dec in pairs in args when both needed

TODO: remember arctan stupidity

TODO: disclaim arctan weirdness

TODO: list sources tou can test, stellarium/planetarium, HORIZONS etc

TODO: disclaim for fixed object only (but...)

TODO: update other answers where I give formulae
