(* formulas start here *)

(* http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro *)

sh = Sin[ha];
ch = Cos[ha];
sd = Sin[dec];
cd = Cos[dec];
sl = Sin[lat];
cl = Cos[lat];

x = - ch * cd * sl + sd * cl;
y = - sh * cd;
z = ch * cd * cl + sd * sl;
r = Sqrt[x^2 + y^2];

az = ArcTan[x,y];
alt = ArcTan[r,z];

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, -Pi<ha<Pi, -Pi<lon<Pi};

raDecLatLonHA2az[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[ 
 az /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

raDecLatLonHA2alt[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[ 
 alt /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

Clear[sh, ch, sd, cd, sl, cl, x, y, z, r, az, alt];

(* TODO: is my condition for alpha bad below? *)

conds = {alpha > -Pi, alpha < Pi, delta > -Pi/2, delta < Pi/2, lambda > -Pi/2,
 lambda < Pi/2, psi > -Pi, psi < Pi, t > -Pi, t < Pi};

rise = FullSimplify[alpha - ArcCos[-(Tan[delta] Tan[lambda])],conds];
set = FullSimplify[alpha + ArcCos[-(Tan[delta] Tan[lambda])],conds];

riseAz=FullSimplify[raDecLatLonHA2az[alpha, delta, lambda, psi, rise], conds];
setAz=FullSimplify[raDecLatLonHA2az[alpha, delta, lambda, psi, set], conds];

(* 

formulas below are pre-simplification:

transAz=FullSimplify[raDecLatLonHA2az[alpha, delta, lambda, psi, alpha],conds];
nadirAz=FullSimplify[raDecLatLonHA2az[alpha,delta,lambda,psi,alpha+Pi],conds];

maxEl=Simplify[raDecLatLonHA2alt[alpha, delta, lambda, psi, alpha],conds];
minEl=Simplify[raDecLatLonHA2alt[alpha,delta,lambda,psi,alpha+Pi],conds];

*)

transAz = 
 Piecewise[{{delta>lambda, 0},{delta==lambda,"Zenith"},{delta<lambda,Pi}}];

nadirAz = 
Piecewise[{ {delta>-lambda, 0}, {delta==-lambda,"Nadir"}, {delta<-lambda,Pi}}];

maxEl = Pi/2-Abs[delta - lambda];
minEl = Abs[delta + lambda]-Pi/2;

(* formulas end here *)

(* functions that can be improved *)

(* nadirAz and transAz *)

Piecewise[{{delta>lambda, 0},{delta==lambda,"Zenith"},{delta<lambda,Pi}}]

Piecewise[{ {delta>-lambda, 0},
 {delta==-lambda,"Nadir"},
 {delta<-lambda,Pi}}]

(* maxEl and minEl *)

ArcTan[Abs[Sin[delta - lambda]], Cos[delta - lambda]]

Pi/2-Abs[delta - lambda]
Abs[delta + lambda]-Pi/2

ArcTan[Abs[Sin[delta + lambda]], -Cos[delta + lambda]]

Plot[{ArcTan[Abs[Sin[x]], Cos[x]], Pi/2-Abs[x]}, {x,-Pi,Pi}]
Plot[{ArcTan[Abs[Sin[x]], Cos[x]] -( Pi/2-Abs[x])}, {x,-Pi,Pi}]

Plot[{ArcTan[Abs[Sin[x]], -Cos[x]], Abs[x]-Pi/2}, {x,-Pi,Pi}]



(* most of this is from ../ASTRO/playground5.m *)

tab = {
 {"Event", "Time", phi, Z},

 {"Any", "t", raDecLatLonHA2az[alpha, delta, lambda,psi,t],
              raDecLatLonHA2alt[alpha, delta, lambda,psi,t]},

 {"Rise", rise, riseAz, 0},

 {"Transit", alpha, transAz, maxEl},

 {"Set", set, setAz, 0},

 {"Lowest Point", FullSimplify[alpha+Pi], nadirAz, minEl}

};

tab // TeXForm

(* ANSWER STARTS HERE *)

I'm not sure it qualifies as "simple", but, using
http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro (and some
additional calculations/simplifications):

$
   \begin{array}{|c|c|c|c|}
\hline
    \text{Event} & \text{Time} & \phi  & Z \\
\hline
    \text{Any} & \text{t} & \tan ^{-1}(\cos (\lambda ) \sin (\delta )-\cos
      (\delta ) \cos (\alpha -t) \sin (\lambda ),\cos (\delta ) \sin (\alpha
      -t)) & \tan ^{-1}\left(\sqrt{(\cos (\lambda ) \sin (\delta )-\cos (\delta
      ) \cos (\alpha -t) \sin (\lambda ))^2+\cos ^2(\delta ) \sin ^2(\alpha
      -t)},\cos (\delta ) \cos (\lambda ) \cos (\alpha -t)+\sin (\delta ) \sin
      (\lambda )\right) \\
\hline
    \text{Rise} & \alpha -\cos ^{-1}(-\tan (\delta ) \tan (\lambda )) & \tan
      ^{-1}\left(\sec (\lambda ) \sin (\delta ),\cos (\delta ) \sqrt{1-\tan
      ^2(\delta ) \tan ^2(\lambda )}\right) & 0 \\
\hline
    \text{Transit} & \alpha  & 
\begin{cases}
                   \delta >\lambda  & 0 \\
                   \delta =\lambda  & \text{Zenith} \\
                   \delta <\lambda  & \pi 
                  \end{cases}
    & \frac{\pi }{2}-\left| \delta -\lambda  \right| \\
\hline
    \text{Set} & \alpha +\cos ^{-1}(-\tan (\delta ) \tan (\lambda )) & \tan
      ^{-1}\left(\sec (\lambda ) \sin (\delta ),-\cos (\delta ) \sqrt{1-\tan
      ^2(\delta ) \tan ^2(\lambda )}\right) & 0 \\
\hline
    \text{Lowest Point} & \alpha +\pi  & 
\begin{cases}
                   \delta >-\lambda  & 0 \\
                   \delta =-\lambda  & \text{Nadir} \\
                   \delta <-\lambda  & \pi 
                  \end{cases}
    & \left| \delta +\lambda  \right|-\frac{\pi }{2} \\
\hline
   \end{array}
$

where:

  - $\phi$ is the azimuth of the object

  - $Z$ is the altitude of the object above the horizon

  - $\alpha$ is the right ascension of the object

  - $\delta$ is the declination of the object

  - $\lambda$ is the latitude of the observer

  - $t$ is the current local sidereal time

Note the two-argument form of arctangent is required so that the
results are in the correct quadrant:
https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent

Additional caveats:

  - If $\left| \delta -\lambda \right|>\frac{\pi }{2}$, the object is
  always below the horizon, and the equations for rising time and
  setting time will not work.

  - If $\left| \delta +\lambda \right|>\frac{\pi }{2}$, the object is
  always above the horizon (circumpolar), and the equations for rising
  and setting time will also not work.

  - The measurements above are in radians. You can convert $\pi \to
  180 {}^{\circ}$ for degrees.

  - Because we use the local sidereal time, the longitude doesn't
  appear in any of the formulas above. However, we do need it to find
  the local sidereal time, as below.

  - To find the local sideral time $t$ in radians, we use
  http://aa.usno.navy.mil/faq/docs/GAST.php and make some substitions
  to get:

$t = 4.894961212735792 + 6.30038809898489 d + \psi$

where $\psi$ is your longitude in radians, and $d$ is the number of
days (including fractional days) since "2000-01-01 12:00:00 UTC".

If you combine the formula for local sidereal time and
azimuth/altitude and assume excessive precision, you get my answer to
http://astronomy.stackexchange.com/a/8415/21

Additional computations for these results at:
https://github.com/barrycarter/bcapps/blob/master/STACK/bc-rst.m

ANSWER ENDS HERE



(* TODO: maybe add this section *)

<h3>Simpler Formulas?</h3>

If you look at the altitude of objects with various declinations over
the course of a day at $40 {}^{\circ}$ latitude, the results look
somewhat like a sine wave:



Are the formulas above really in simplest form?




TODO: examples for testing, ie Sirius over ABQ

(* join list of strings with character *)

joinStrings[list_, char_] := 
 StringJoin[Flatten[Table[{ToString[TeXForm[i]],char}, {i,list}]]];

joinStrings[list_, char_] := 
 Flatten[Table[{ToString[TeXForm[i]],char}, {i,list}]];

http://astronomy.stackexchange.com/questions/8390/cancelling-out-earth-rotation-speed-altazimuth-mount

TODO: mention this file

(* graph testing for simplifications *)

tab = Table[
 raDecLatLonHA2alt[0, n*Degree, 40*Degree, 0, t/12*Pi]/Degree,
{n, {-20, 0, 20}}]

Plot[tab, {t,-24,24}]
showit




showit

Plot[
 raDecLatLonHA2az[0, 10*Degree, 35*Degree, 0, t/12*Pi]/Degree, 
 {t,0,24}]
showit

TODO: graphics = show not sine wave or easy

