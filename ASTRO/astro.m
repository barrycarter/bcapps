(* Mathematica versions of some astro formulas to resolve:
 http://astronomy.stackexchange.com/questions/937/ and similar
 *)

(* 

Elevation of object at given time and latitude, where ha[t] is the
hour angle and dec[t] is the declination at time t

*)

elev[t_,lat_] = 
ArcSin[Sin[lat]*Sin[dec[t]]+Cos[lat]*Cos[dec[t]]*Cos[ha[t]]];

(*

To determine ha[t] and dec[t], I choose t=0 when the moon's
declination and hour angle are both 0 [such a time must exist]

Local sidereal time increases by 366.2425/365.2425*360 degrees per
calendar day.

The moon's RA increases 360 degrees every lunar sidereal month or
360/27.321582 degrees per day.

The moon's hour angle thus increases
366.2425/365.2425*360-360/27.321582 (LST-RA) per day

The moon's declination is a sinusoidal wave whose average declination
is 0, and whose period is the moon's sidereal period (27.321582 days);
the moon's maximal inclination is 28.58 degrees. This gives us the
sinusoidal equation below.

t is measured in calendar days

*)

ha[t_] = (366.2425/365.2425*360-360/27.321582)*Degree*t
dec[t_] = 28.58*Sin[2*Pi*(t/27.321582)]





(* I choose t=0 when the moon's declination and hour angle are both 0
[such a time must exist] *)

(* 

elevdt[t_,lat_] = D[elev[t,lat],t]

Solve[TrigExpand[elevdt[t,lat]==0,t]]

sol = Solve[TrigExpand[elevdt[t,lat]==0,t]][[1]]

dec[t_] = c4*Cos[c5*t+c6]

(* fill in some constants, where t = sidereal month *)

(* moon makes one extra rotation every sidereal month *)
c1 = 360*Degree*(27.321582+1)

(* moons declination varies through a sidereal month *)
c5 = 2*Pi

(* inclination to ecliptic, max, though never reached *)
c4 = 28.58*Degree


sol /. {lat -> 60 Degree, dec -> 15 Degree}

sol /. {ha[t] -> c1*t+c2, ha'[t] -> c1}

Solve[Sin[ha[t]] == ((Tan[lat] - Cos[ha[t]] Tan[dec[t]]) dec'[t])/ha'[t],t]

Numerator[elevdt[t,lat]]

Solve[Numerator[elevdt[t,lat]]==0,t]

(* 

Moon increases RA 1/375699 radian per second
hour angle for fixed RA increases 1/13713.4 radians per second
so moon's HA increases 1/13230.5 radians per second

Moon increases DEC as fast as 1/793326 radians per second

*)

elev[c1+dr*t, c2+dd*t, lat]


elevdha[ha_,dec_,lat_] = D[elev[ha,dec,lat],ha]
elevddec[ha_,dec_,lat_] = D[elev[ha,dec,lat],dec]

elevdha[ha,dec,lat]/elevddec[ha,dec,lat]

elevdt[ha_,dec_,lat_,t_] = D[elev[ha[t],dec[t],lat],t]

Solve[elevdt[ha,dec,lat,t]==0]

Sin[ha] -> Cos[ha] Tan[dec] - Tan[lat]



D[elev[c+(30/31)*t, dec,lat],t]

D[elev[c+(30/31)*t, dec,lat],t] /. lat -> 60 Degree


Solve[D[elev[c+(30/31)*t, dec,lat],t]==1/60]

Solve[elevdha[ha,dec,lat]==elevddec[ha,dec,lat]]

Sin[ha] -> Cos[ha] Tan[dec] - Tan[lat]

Solve[Sin[ha]==Cos[ha] Tan[dec] - Tan[lat]]

(* at ha==0, the above is just dec==+-lat *)

Solve[Sin[1] == Cos[1]*Tan[dec] - Tan[50. Degree]]

(* a 75 degree object at 50 lat *)

Plot[elev[t,75 Degree,50 Degree],{t,0,2*Pi}]
Plot[elevdha[ha,75 Degree,50 Degree], {ha,0,2*Pi}]

Plot[elev[t*(30/31),0,60 Degree],{t,0,2*Pi}]

