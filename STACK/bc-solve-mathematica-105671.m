(*

TODO: add summary

As I note in http://mathematica.stackexchange.com/questions/105671,
Mathematica no longer provides planetary moon positions, and doesn't
even provide enough elliptical elements to compute a position.

However, it's still possible with outside sources. I will compute the
position of Ganymede with respect to Jupiter on 29 Feb 2016 12:00:00
UTC as an example:

If you use HORIZONS (http://ssd.jpl.nasa.gov/horizons.cgi)
with settings similar to these:

[[0216-1]]

(adjusted for other moons/planets of course)

you can get the elliptical (or "osculating") elements. A portion of
the result:

<pre><code>
2457388.500000000 = A.D. 2016-Jan-01 00:00:00.0000 (TDB)
 EC= 1.658392962325793E-03 QR= 1.068876735013875E+06 IN= 1.403251967462928E-01
 OM= 3.957676907575823E+01 W = 3.060595759260307E+02 Tp=  2457385.575825638603
 N = 5.821462833039293E-04 MA= 1.470784812196361E+02 TA= 1.471815853553566E+02
 A = 1.070652297248730E+06 AD= 1.072427859483585E+06 PR= 6.184012684180441E+05
2457754.500000000 = A.D. 2017-Jan-01 00:00:00.0000 (TDB)
 EC= 1.417624128220784E-03 QR= 1.068832723774260E+06 IN= 1.396453833192574E-01
 OM= 3.784135743085589E+01 W = 2.915684013347826E+02 Tp=  2457757.291248716880
 N = 5.823928591346913E-04 MA= 2.195478730926201E+02 TA= 2.194445801162809E+02
 A = 1.070350077870292E+06 AD= 1.071867431966324E+06 PR= 6.181394472021540E+05

Symbol meaning  

    JDTDB    Epoch Julian Date, Barycentric Dynamical Time
      EC     Eccentricity, e                                                   
      QR     Periapsis distance, q (km)                                        
      IN     Inclination w.r.t xy-plane, i (degrees)                           
      OM     Longitude of Ascending Node, OMEGA, (degrees)                     
      W      Argument of Perifocus, w (degrees)                                
      Tp     Time of periapsis (Julian day number)                             
      N      Mean motion, n (degrees/sec)                                      
      MA     Mean anomaly, M (degrees)                                         
      TA     True anomaly, nu (degrees)                                        
      A      Semi-major axis, a (km)                                           
      AD     Apoapsis distance (km)                                            
      PR     Sidereal orbit period (sec)                                       
</code></pre>

This isn't a perfect solution, since the ellipse isn't stable: the
eccentricity, periapsis distance, inclination, etc, all change
slightly over the course of 1 year.

Of course, the mean anomaly and true anomaly also change, but that's
expected, since they vary continuously as Ganymede orbits Jupiter.

And, since the "time of periapsis" is different for each orbit, that
change is also expected.

Finally, the information provided is redundant. For example, you can
compute the "time of periapsis" from the mean anomaly and the mean
motion.

Note that
http://nssdc.gsfc.nasa.gov/planetary/factsheet/joviansatfact.html also
provides Jupiter's moon's orbital parameters (second half of page) as
fixed values, but 1) these are less accurate, and 2) since they don't
provide a mean anomaly for any specific time, they are not sufficient
to compute the moon's position.

Since 29 Feb 2016 is closer to 1 Jan 2016, I will use those orbital
elements to compute Ganymede's position:

  - First, we copy the elements (with minor adjustments for Mathematica).

<pre><code>
ec= 1.658392962325793*10^-03
qr= 1.068876735013875*10^+06
in= 1.403251967462928*10^-01*Degree
om= 3.957676907575823*10^+01*Degree
w = 3.060595759260307*10^+02*Degree
tp=  2457385.575825638603
n = 5.821462833039293*10^-04*Degree
ma= 1.470784812196361*10^+02*Degree
ta= 1.471815853553566*10^+02*Degree
a = 1.070652297248730*10^+06
ad= 1.072427859483585*10^+06
pr= 6.184012684180441*10^+05
</code></pre>

We won't actually use all of these numbers, and other sources often
provide only a subset of these numbers. I will try to use a subset
that is common to most sources.

TODO: large amount data = mail

Uses http://mathematica.stackexchange.com/questions/19268/creating-a-simulation-of-our-solar-system to help solve http://mathematica.stackexchange.com/questions/105671/3d-orbits-of-moons-around-their-respective-planets

 *)

