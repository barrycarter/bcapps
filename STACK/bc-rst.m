(* most of this is from ../ASTRO/playground5.m *)

By http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro (with
minor changes),

$
   \phi \to \tan ^{-1}(\sin (\delta ) \cos (\lambda )-\cos (\delta ) \sin
    (\lambda ) \cos (\alpha -t),\cos (\delta ) \sin (\alpha -t))
$

$
   Z\to \tan ^{-1}\left(\sqrt{(\sin (\delta ) \cos (\lambda )-\cos (\delta )
    \sin (\lambda ) \cos (\alpha -t))^2+\cos ^2(\delta ) \sin ^2(\alpha
    -t)},\cos (\delta ) \cos (\lambda ) \cos (\alpha -t)+\sin (\delta ) \sin
    (\lambda )\right)
$

where:

  - $\phi$ is the azimuth of the object

  - $Z$ is the altitude of the object above the horizon

  - $\alpha$ is the right ascension of the object

  - $\delta$ is the declination of the object

  - $\lambda$ is the latitude of the observer

  - $\psi$ is the longitude of the observer (we normally use $\phi$
  for longitude, but it was already taken by azimuth above)

  - $t$ is the current local sidereal time

Note the two-argument form of arctangent is required so that the
results are in the correct quadrant:
https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent

Using these, we see:

  - The object's transit time is $t=\alpha$, which is expected, since
  that's essentially the definition of right ascension.

  - At transit, the object's altitude is:

$\frac{\pi }{2}-\left| \delta -\lambda  \right|$

(you can substitute $\frac{\pi }{2}\to 90 {}^{\circ}$ if you're using degrees)


TODO: table

tab = {
 {"Event", "LST", "Azimuth", "Altitude"},

 {"any", "t", raDecLatLonHA2az[alpha, delta, lambda,psi,t],
              raDecLatLonHA2alt[alpha, delta, lambda,psi,t]},


};

Grid[tab, Frame -> All]
showit

(* join list of strings with character *)

joinStrings[list_, char_] := 
 StringJoin[Flatten[Table[{ToString[TeXForm[i]],char}, {i,list}]]];

joinStrings[list_, char_] := 
 Flatten[Table[{ToString[TeXForm[i]],char}, {i,list}]];






(* convert 2D table to TeX *)

tab2tex[t_] := 





TODO: explain LST, azimuth case if 180, degree transform

Pi/2 - Abs[delta-lambda]

this is correct:

ArcTan[Sqrt[(Cos[lambda]*Sin[delta] - Cos[delta]*Sin[lambda])^2], 
 Cos[delta]*Cos[lambda] + Sin[delta]*Sin[lambda]]

FullSimplify[ArcTan[Sqrt[(Cos[lambda]*Sin[delta] - Cos[delta]*Sin[lambda])^2], 
 Cos[delta]*Cos[lambda] + Sin[delta]*Sin[lambda]], conds]

ArcTan[Sqrt[Sin[delta - lambda]^2], Cos[delta - lambda]]

above is also correct

Plot[ArcTan[Sqrt[Sin[var]^2], Cos[var]] + var*Sign[var] - Pi/2, {var,-Pi,Pi}]

above is truly 0 in all cases

Pi/2 - (delta-lambda)*Sign[(delta-lambda)]

Piecewise[{delta < lambda, delta - lambda + Pi/2},
 {delta == lambda, Pi/2},
 {delta > lambda, -delta + lambda + Pi/2

Plot[ArcTan[Sqrt[Sin[var]^2], Cos[var]] + Abs[var] - Pi/2, {var,-Pi,Pi}]

Plot[{ArcTan[Sqrt[Sin[var]^2], Cos[var]], Pi/2-Abs[var]}, {var,-Pi,Pi}]




FullSimplify[%, lambda -> delta +var, conds]

ArcTan[Cot[delta - lambda]] <- when delta>lambda ONLY


$\frac{1}{2} \pi  \text{sgn}(\delta -\lambda )-\delta +\lambda$

where $\text{sgn}(\text{x})$ is +1 when x is positive, -1 when x is
negative, and 0 when x is 0. This can also be written:

ArcTan[Cot[delta - lambda]]


Simplify[raDecLatLonHA2alt[alpha,delta,lambda,psi,alpha],
{delta>lambda , delta<Pi/2, lambda<Pi/2, delta>-Pi/2, lambda>-Pi/2}]

TODO: non-conditional form

Plot[ArcTan[Cot[var]]+var-Pi/2, {var,0,Pi}] <- this is 0

Plot[ArcTan[Cot[var]]+var+Pi/2, {var,-Pi,0}] <- this is 0

Plot[ArcTan[Cot[var]]+var-Sign[var]*Pi/2, {var,-Pi,Pi}] <- this is 0

thus,

Sign[delta-lambda]*Pi/2 - (delta-lambda)

Piecewise[{
 {delta < lambda, -Pi/2 - (delta-lambda)}, 
 {delta == lambda,  Pi/2}, 
 {delta > lambda, Pi/2 - (delta-lambda)}
}];



TODO: degrees vs Pi

ArcTan[Cot[var]] == Sign[var]*Pi/2 - var

Plot[{ArcTan[Cot[var]], Sign[var]*Pi/2 - var}, {var,-Pi,Pi}]

Plot[{ArcTan[Cot[var]] - (Sign[var]*Pi/2 - var)}, {var,-Pi,Pi}]


$\tan ^{-1}(\left| \sin (\delta -\lambda ) \right|,\cos (\delta -\lambda ))$

Note that t


  - 

  - The object rises at 

http://astronomy.stackexchange.com/questions/8390/cancelling-out-earth-rotation-speed-altazimuth-mount

TODO: note impossible values

z = elevation above horizon

phi = azimuth

alpha = ra

delta = declination

lambda = latitude

psi = longitude (just me, normally also phi)

TODO: source http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro

TODO: if over 1 or under -1, then..

TODO: how to find sidereak time

http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro

sh = Sin[ha]
ch = Cos[ha]
sd = Sin[dec]
cd = Cos[dec]
sl = Sin[lat]
cl = Cos[lat]

x = - ch * cd * sl + sd * cl
y = - sh * cd
z = ch * cd * cl + sd * sl
r = Sqrt[x^2 + y^2]

az = ArcTan[x,y]
alt = ArcTan[r,z]

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, -Pi<ha<Pi, -Pi<lon<Pi}

raDecLatLonHA2az[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[ 
 az /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

raDecLatLonHA2alt[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[ 
 alt /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

(* pure comps end here *)


raDecLatLonHA2az[alpha_, delta_, lambda_, psi_, t_] = 
 ArcTan[Cos[lambda]*Sin[delta] - Cos[delta]*Cos[alpha - t]*Sin[lambda], 
 Cos[delta]*Sin[alpha - t]]

raDecLatLonHA2el[alpha_, delta_, lambda_, psi_, t_] =
 ArcTan[Sqrt[(Cos[lambda]*Sin[delta] - Cos[delta]*Cos[alpha - t]*Sin[lambda])^
    2 + Cos[delta]^2*Sin[alpha - t]^2], Cos[delta]*Cos[lambda]*Cos[alpha - t] 
+ Sin[delta]*Sin[lambda]]

subs = {lat -> lambda, dec -> delta, ha -> t - alpha}



radeclatlontime2el[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[
 alt /. {lat -> lambda, dec -> delta, ha -> t - alpha},
conds]



raDecLatLonHA2az[alpha_, delta_, lambda_, psi_, t_] = 
FullSimplify[
 az /. {lat -> lambda, dec -> delta, ha -> t - alpha},
conds]



