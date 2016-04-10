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

  - At transit, the object's altitude is $\delta -\lambda$

TODO: is this rightg?!!

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


If you know the current local sidereal time, $t$, and are willing to
ignore refraction, these calculations are fairly easy:

  - The objects transit time is when $t=\alpha$, where $\alpha$ is the
  right ascension.

  - The object's altitude at transit is 

delta = declination
lambda = latitude

  - The object remains above the horizon for 

TODO: if over 1 or under -1, then..

TODO: how to find sid time

pos[theta_,dec_] = {-Cos[theta]*Cos[dec], -Sin[theta]*Cos[dec], Sin[dec]};

pos2[theta_,dec_,lat_] = FullSimplify[
rotationMatrix[y,lat-Pi/2].pos[theta,dec],Element[{theta,dec,lat},Reals]]

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
; now get Alt, Az

http://en.wikipedia.org/wiki/Atan2 notes Mathematica oddness (which I
have to re-reverse, urk?)

az = ArcTan[y,x]
alt = ArcTan[z,r]

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, -Pi<ha<Pi, -Pi<lon<Pi}

az2 = FullSimplify[az, conds]
alt2 = FullSimplify[alt, conds]



Simplifying conditions



bad = alt[[1]]^2

radeclatlontime2az[ra_,dec_,lat_,lon_,s_] = az /. ha -> lst-ra

radeclatlontime2el[ra_,dec_,lat_,lon_,s_] = alt /. ha -> lst-ra

(* t is local sidereal time *)

faz = raDecLatLonHA2az
fel = raDecLatLonHA2el

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



