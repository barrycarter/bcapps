(* 

astronomy.stackexchange.com/questions/1213/solar-noon-meridian-crossing-time-versus-time-of-maximum-elevation

refer: http://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time

As derived in http://astronomy.stackexchange.com/questions/14492, the
altitude of a fixed declination object is:

$
   \tan ^{-1}\left(\sqrt{(\sin (\delta ) \cos (\lambda )-\cos (\delta ) \sin
    (\lambda ) \cos (\alpha -t))^2+\cos ^2(\delta ) \sin ^2(\alpha -t)},\cos
    (\delta ) \cos (\lambda ) \cos (\alpha -t)+\sin (\delta ) \sin (\lambda
    )\right)
$

where:

  - $\alpha(t)$ is the right ascension of the object at sidereal time $t$

  - $\delta(t)$ is the declination of the object at sidereal time $t$

  - $\lambda$ is the latitude of the observer (which we assume is fixed)

  - $t$ is the current local sidereal time

Note the two-argument form of arctangent is required so that the
results are in the correct quadrant:
https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent

Let's assume for a moment that the Sun's declination is fixed
(although the entire impetus behind this question is that it's not)
and that it's the vernal equinox. What's the sun's altitude at $40
{}^{\circ} N$ latitude 60 minutes before and after the Sun culminates?

Plot[raDecLatLonHA2alt[0,0,40*Degree,0,t/1440*2*Pi]/Degree, {t,-60,60}]
showit


Of course, in this case, we're interested in what happens because the
Sun's declination is *not* constant, which we will get to shortly.

First, let's look at a fixed object's altitude when it's close to the
meridian ($t=\alpha$).

Plot[{ 
 raDecLatLonHA2alt[0,0,0*Degree,0,t/1440*2*Pi]/Degree,
 raDecLatLonHA2alt[0,0,15*Degree,0,t/1440*2*Pi]/Degree,
 raDecLatLonHA2alt[0,0,30*Degree,0,t/1440*2*Pi]/Degree,
 raDecLatLonHA2alt[0,0,45*Degree,0,t/1440*2*Pi]/Degree,
 raDecLatLonHA2alt[0,0,60*Degree,0,t/1440*2*Pi]/Degree,
 raDecLatLonHA2alt[0,0,75*Degree,0,t/1440*2*Pi]/Degree,
 raDecLatLonHA2alt[0,0,90*Degree,0,t/1440*2*Pi]/Degree
}, {t,-60,60}, AxesOrigin -> {0,0}, PlotLegends -> 
 {HoldForm[0*Degree], 15*Degree, 30*Degree, 45*Degree, 60*Degree,
 75*Degree, 90*Degree}, 
PlotLabel -> "Altitude of 0 declination object"
]
showit

TODO: short answer


 by looking at the first non-zero term of the
power series expansion around $t=\alpha$:

$
   \sin ^{-1}(\cos (\delta -\lambda ))-\frac{(t-\alpha )^2 (\cos (\delta ) \cos
    (\lambda ))}{2 \left| \sin (\delta -\lambda ) \right|}
$





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

conds = {alpha > -Pi, alpha < Pi, delta > -Pi/2, delta < Pi/2, lambda > -Pi/2,
 lambda < Pi/2, psi > -Pi, psi < Pi, t > -Pi, t < Pi};

raDecLatLonHA2az[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[ 
 az /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

raDecLatLonHA2alt[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[ 
 alt /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

To find when the elevation is maximal, we take the derivative and set
equal to 0:

conds = {alpha[t] > -Pi, alpha[t] < Pi, delta > -Pi/2, delta[t] < Pi/2, 
 lambda > -Pi/2,
 lambda < Pi/2, psi > -Pi, psi < Pi, t > -Pi, t < Pi};



FullSimplify[raDecLatLonHA2az[alpha[t],delta[t],lambda,psi,t] ,conds]

FullSimplify[D[raDecLatLonHA2az[alpha[t],delta[t],lambda,psi,t],t],conds]

$
   \frac{\cos (\delta ) \cos (\lambda ) \sin (\alpha -t)}{\sqrt{(\sin (\delta )
    \cos (\lambda )-\cos (\delta ) \sin (\lambda ) \cos (\alpha -t))^2+\cos
    ^2(\delta ) \sin ^2(\alpha -t)}}
$

Since we're only interested in the behavior when the sun is near the
meridian, we set $\alpha=t$ and the above simplifies considerably:



*)

