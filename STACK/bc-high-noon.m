(* 

astronomy.stackexchange.com/questions/1213/solar-noon-meridian-crossing-time-versus-time-of-maximum-elevation

refer: http://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time

As derived in http://astronomy.stackexchange.com/questions/14492, the
altitude of an object is:

$
   \tan ^{-1}\left(\sqrt{(\sin (\lambda ) \cos (t-\alpha (t)) \cos (\delta
    (t))-\cos (\lambda ) \sin (\delta (t)))^2+\sin ^2(t-\alpha (t)) \cos
    ^2(\delta (t))},\cos (\lambda ) \cos (t-\alpha (t)) \cos (\delta (t))+\sin
    (\lambda ) \sin (\delta (t))\right)
$

and the azimuth is:

$
   \tan ^{-1}(\cos (\lambda ) \sin (\delta (t))-\sin (\lambda ) \cos (t-\alpha
    (t)) \cos (\delta (t)),\sin (t-\alpha (t)) (-\cos (\delta (t))))
$

where:

  - $\alpha(t)$ is the right ascension of the object at sidereal time $t$

  - $\delta(t)$ is the declination of the object at sidereal time $t$

  - $\lambda$ is the latitude of the observer (which we assume is fixed)

  - $t$ is the current local sidereal time



$
   \frac{\cos (\delta ) \cos (\lambda ) \sin (\alpha -t)}{\sqrt{(\sin (\delta )
    \cos (\lambda )-\cos (\delta ) \sin (\lambda ) \cos (\alpha -t))^2+\cos
    ^2(\delta ) \sin ^2(\alpha -t)}}
$

Since we're only interested in the behavior when the sun is near the
meridian, we set $\alpha=t$ and the above simplifies considerably:



*)

