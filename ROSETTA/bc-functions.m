(* a bunch of closed form functions I may convert to multiple languages and post to astronomy.stackexchange.com *)

(* TODO: disclaim ugliness and lack of testing *)

(* TODO: specify input/output units in documentation *)

(* TODO: source each function *)

(* TODO: approximate forms *)

(* TODO: note closed form and edited, so requres work to get from source *)

(* J2000 = 1999 Dec 31 12:00:00 GMT = JD 2451545.0 = millenium (not correct but), t is unix time, millDays, TODO: mark some funcs as helpers *)

(* order is lat, lon, t and ra, dec, t *)

(* TODO: maybe let precision be a var *)

http://aa.usno.navy.mil/faq/docs/GAST.php

t2millDays[t_] = (t-946641600)/86400

rad2Hour[rad_] = N[Mod[rad*12/Pi, 2*Pi],20]

hour2Rad[hour_] = N[hour/12*Pi, 20]

deg2Rad[deg_] = N[deg*Degree, 20]

rad2Deg[rad_] = N[deg/Degree, 20]

millDays2GMST[d_] = Expand[
 hour2Rad[Rationalize[18.697374558 + 24.06570982441908*d,0]]]

t2GMST[t_] = 










<formula>
</formula>
