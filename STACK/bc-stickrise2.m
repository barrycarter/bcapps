<formulas>

conds = {w > -Pi, w < Pi, d > -Pi/2, d < Pi/2, p > -Pi/2, p < Pi/2};

a[w_, d_, p_] = ArcTan[-Cos[d]*Cos[w]*Sin[p] + Cos[p]*Sin[d], -Cos[d]*Sin[w]];

e[w_, d_, p_] = ArcTan[Sqrt[(-Cos[d]*Cos[w]*Sin[p] + Cos[p]*Sin[d])^2
+ Cos[d]^2*Sin[w]^2], Cos[d]*Cos[p]*Cos[w] + Sin[d]*Sin[p]];

</formulas>

(*

Variable definitions:

a = azimuth

e = elevation

r = radius of stick shadow

t = angle of stick shadow

x, y = x and y coordinates of stick shadow

dx, dy = change in x and y over time

ds, ds2 = movement of shadow (and movement of shadow squared)

d = sun's declination

p = observer's latitude

w = sun's hour angle

<answer>

This is not an answer, but may be helpful.

Using https://astronomy.stackexchange.com/a/14508/21 and converting Greek letters to English (for programming ease), we see that the Sun's azimuth and elevation at any given time is:

$
a(w,d,p)=\tan ^{-1}(\sin (d) \cos (p)-\cos (d) \sin (p) \cos (w),-\cos
(d) \sin (w))
$

$
e(w,d,p)=\tan ^{-1}\left(\sqrt{(\sin (d) \cos (p)-\cos (d) \sin (p)
   \cos (w))^2+\cos ^2(d) \sin ^2(w)},\cos (d) \cos (p) \cos (w)+\sin
   (d) \sin (p)\right)
$

where:

  - $a$ is the Sun's azimuth
  - $e$ is the Sun's altitude
  - $d$ is the Sun's declination
  - $p$ is the observer's latitude
  - $w$ is the Sun's "hour angle":
    - $w$ is zero at local solar noon
    - $w$ is $15 {}^{\circ}$ or $\frac{\pi }{12}$ 1 hour after local solar noon (ie, 1pm on a sundial)
    - $w$ is $-15 {}^{\circ}$ or $-\frac{\pi }{12}$ 1 hour before local solar noon (ie, 11am on a sundial)
    - $w$ is $\pm180 {}^{\circ}$ or $\pm\pi$ at local solar midnight
    - $w$ is $-90 {}^{\circ}$ or $-\frac{\pi }{2}$ 6 hours before local solar noon (ie, 6am on a sundial), and so on.
    - Conversely, $w$ is equal to $1$ when it is 3h49m11s after noon (that's $\frac{24}{2 \pi }$ converted to hms). This quantity is important and I'll refer to it as the "radian hour" below (this is nonstandard terminology).

</answer>

<work>

ParametricPlot[{a[w, 0, 40*Degree], e[w, 0, 40*Degree]}, {w, 0, 2*Pi}]


</work>
