(* attempts to solve http://earthscience.stackexchange.com/questions/7281/what-is-the-moons-distance-from-viewer-at-horizon *)

(*

TODO: summarize answer, ignoring refraction, not to scale, spellcheck

[[moon-at-horizon.jpg]]

When the moon is at your horizon (as above and ignoring refraction),
you can compute its distance using the Pythagorean Theorem as
$\sqrt{m^2-r^2}$ where `r` is the Earth's radius, and `m` is the
moon's distance from the center of the Earth.

[[moon-at-zenith.jpg]]

When the moon is overhead (as above), its distance from you is simply
`m-r`, with `m` and `r` the same as above.

The moon's average distance from the center of the Earth is 384399 km,
and the Earth's average radius is 6371 km.

Plugging these in, we see that the moon is about 384346 km from you
when it's at the horizon, and about 378028 km from you when it's
overhead. So, the horizon moon is, on average, about 6318km or about
1.64% further away than the zenith moon.

However, the moon's orbit isn't perfectly circular. It's distance from
the Earth's center varies from about 362600 km to 405400 km every
month, sometimes more (356400 km and 406700 km are the absolute
limits).

If the horizon moon is at perigee 362600 km away from the Earth's
center, its distance from you is about 362544 km.

And, if the zenith moon is at apogee 405400 km away from the Earth's
center, its distance from you is about 399029 km, which is 36485 km or
9.1% further away than the horizon moon.

While this answer is technically correct, it's a bit unsatisfying,
since it takes the moon about 13.78 days to go from perigee to
apogee. In other words, the zenith moon *today* can be further away
than the horizon moon *2 weeks from now*.

Presumably, we want to know if the moon at moonrise is further away
than the moon later *on the same day*, so we turn to the more general
situation:

[[moon.jpg]]

When the moon is $\theta$ degrees above your horizon and distance `m`
from the Earth's center, its distance from you (by lemma 1 at end of
answer) is:

$
   \sqrt{m^2-r \left(\sin (\theta ) \sqrt{4 m^2-2 r^2 \cos (2 \theta )-2 r^2}+r
    \cos (2 \theta )\right)}
$

where `r` is the Earth's radius.

The Earth's radius is fairly constant, so the two things that change
this distance are the moon's elevation in the sky $\theta$ and the
distance from the center of the Earth to the moon, `m`.

How does this distance change with respect to $\theta$? Taking the
partial derivative of the formula above with respect to $\theta$, we get:

$
   -\frac{r \left(\frac{2 \sqrt{2} \cos (\theta ) \left(m^2-r^2 \cos (2 \theta
    )\right)}{\sqrt{2 m^2-r^2 \cos (2 \theta )-r^2}}-2 r \sin (2 \theta
    )\right)}{2 \sqrt{m^2-r \left(\sin (\theta ) \sqrt{4 m^2-2 r^2 \cos (2
    \theta )-2 r^2}+r \cos (2 \theta )\right)}}
$

and with respect to `m`:

$
   \frac{2 m-\frac{4 m r \sin (\theta )}{\sqrt{4 m^2-2 r^2 \cos (2 \theta )-2
    r^2}}}{2 \sqrt{m^2-r \left(\sin (\theta ) \sqrt{4 m^2-2 r^2 \cos (2 \theta
    )-2 r^2}+r \cos (2 \theta )\right)}}
$

Since we're primarily interested in the horizon, let's simplify the
above formulas by setting $\theta$ to 0. In other words, let's look at
the instantaneous rate at which the moon's distance changes from you
when the moon is at the horizon.

For $\theta$, this simplifies to simply `-r`, where `r` is the Earth's
radius. In other words, the rising moon gets 1 Earth radius closer to
us for each radian it rises.

Putting this in more familiar terms, this is 6371 km/radian or 111.2
km/degree. In other words, if the moon's orbit around the Earth's
center was perfectly circular, it would get 111.2 kilometers closer to
us for every degree it rose above the horizon.

Note that this is an *instantaneous* rate. As we saw earlier, 






TODO: Lemma 1



  - Note that your position on the Cartesian grid is `(0,r)` where
  `r` is the Earth's radius.

  - The line between you and the moon can be parametrized as $\{-t
  \cos (\theta ),\text{r}+t \sin (\theta )\}$ for t > 0

  - The distance of this line from the origin (not from you) at time t
  is simply it's norm or $\sqrt{\text{r}^2+2 \text{r} t \sin (\theta )+t^2}$

  - This parametrizated line hits the moon when its distance from the Earth's center is `m`, which is when t = $\sqrt{m^2-\frac{1}{2} r^2 \cos (2 \theta )-\frac{r^2}{2}}-r \sin (\theta )$ and 










Per Wikipedia (https://en.wikipedia.org/wiki/Moon) the moon's average
apogee is 405400km and the average perigee is 362600km.

The time between two perigees is 27.554551 days, or one anomalistic month:

https://en.wikipedia.org/wiki/Lunar_month#Anomalistic_month

Thus, a rough formula for the moon's distance is:

$384000+21400 \sin \left(\frac{2 \pi  x}{27.5546}\right)$

where t is measured in days, and t=0 is between a perigee and an
apogee, when the moon is at average distance. The graph looks like
this:

[[image1.jpg]]

The change in the moon's distance (also known as the moon's "radial
velocity", ie, it's velocity towards or away from us) is the
derivative of this function, which is:

$\frac{21400\ 2 \pi  \cos \left(\frac{2 \pi  t}{27.5546}\right)}{27.5546}$

or

$4879.78 \cos (0.228027 t)$

When t=0, the moon's radial velocity reaches a maximum of 4879.78 km
per day or about 203 km per hour.

The moon's distance from you can be computed using this image:

[[image2]]

When the moon is at the horizon (ignoring refraction), it's distance
from you, via the Pythagorean Theorem is:

$\sqrt{\text{OS}^2-\text{OU}^2}$

where OS is the distance from the Earth's center to the moon, and OU
is the Earth's radius.

When the moon is overhead, it's distance from you is simply OE-OU,
where OE is the distance from the Earth's center to the moon. Note
that OE may be different from OS since, as above, the moon's distance
from the center of the Earth is not constant.

How much closer does the moon get from the time it rises to the time
it's overhead? We subtract the two quantities above to get:

$-\text{OE}+\sqrt{\text{OS}^2-\text{OU}^2}+\text{OU}$


TODO: glue this stuff to above



*)


(* Math starts here *)

(* these conditions help Mathematica simplify expressions, and simply
state the Earth's radius is positive and the moon is further from the
center of the Earth than the Earth's own surface [interestingly, the
Earth-Moon barycenter does NOT meet this condition, and is closer to
the Earth's center than the Earth's surface, but that's not relevant
here] *)

(* TODO: theta > 0 not necessarily true due to refraction *)

conds = r>0 && m>r && x>0 && m>0 && theta> 0 && theta <= Pi/2 && theta >= -Pi/2

(* the line from you to the moon has slope Tan[theta] and y-intercept
r, so its formula is... *)

y[x_] = r + x*Tan[theta]

(* For any given value of x, it's distance squared from the origin
is x^2+y^2, and the distance from you is x^2+(y-r)^2 since you are at y=r *)

distsquared[x_] = x^2+y[x]^2

(* For what value of x is this equal to m^2 *)

x0 = Solve[distsquared[x] == m^2 && conds, x, Reals]

x1 = x0[[1,1,2,1]]

distfromyousquared[x_] = x^2+(y[x]-r)^2

distsq1 = distfromyousquared[x1]

dist[r_,theta_,m_] = Sqrt[m^2 - r*(r*Cos[2*theta] + Sqrt[4*m^2 - 2*r^2
- 2*r^2*Cos[2*theta]]*Sin[theta])];

dt[r_,theta_,m_] = -(r*((2*Sqrt[2]*Cos[theta]*(m^2 -
r^2*Cos[2*theta]))/ Sqrt[2*m^2 - r^2 - r^2*Cos[2*theta]] -
2*r*Sin[2*theta]))/ (2*Sqrt[m^2 - r*(r*Cos[2*theta] + Sqrt[4*m^2 -
2*r^2 - 2*r^2*Cos[2*theta]]* Sin[theta])])

dm[r_,theta_,m_] = D[dist[r,theta,m],m]

Solve[dm[r,theta,m] == dt[r,theta,m], {m,theta}]

Plot[{dist[6371, theta*Degree, 362600], dist[6371, theta*Degree, 384399], 
 dist[6371, theta*Degree, 405400]}, {theta,-90,90}]

Plot[{dt[6371, theta*Degree, 362600], dt[6371, theta*Degree, 384399], 
 dt[6371, theta*Degree, 405400]}, {theta,-1.5,1.5}]







(* Math ends here *)





normsquared[x_] = FullSimplify[x^2+y[x]^2,conds]

solve = Solve[normsquared[x] == m^2, x][[2,1,2]]

solve2 = FullSimplify[solve, conds]

solve3 = FullSimplify[solve2^2+(y[solve2]-1)^2,conds]

line[t_] = {-t, r+t*Tan[theta]}



nline[t_] = FullSimplify[Norm[line[t]],conds]

solve0 = Solve[{Norm[line[t]]==m , conds}, t, Reals];

solve = FullSimplify[solve0[[1,1,2,1]], conds];



(* loophole graphics *)

moon = {5,5};

lh = {

 (* the Earth *)
 {RGBColor[0,0,1], Circle[{0,0}, 1]},

 (* the viewer *)
 {RGBColor[1,0,0], Disk[{0,1}, 0.03]},

 (* viewer text *)
 Text["(0,r)", {-0.2,1.08}],

 (* viewer horizon *)
 {RGBColor[1,0,0], Line[{{0,1}, {moon[[1]],1}}]},

 (* the moon *)
 {Disk[moon, 0.03]},

 (* geocenter to you *)
 {Line[{{0,0},{0,1}}]},

 (* geocenter to moon *)
 {Dashed, Line[{{0,0},moon}]},

 (* text for geocenter to moon *)
 Text[Style["m", Large], {3,2.8}],

(* {Circle[{0,0},Norm[moon]]}, *)

 (* moon to axes *)
(* {Dashed, Line[{moon, {0, moon[[2]]}}]}, *)

 (* you to moon *)
 {Line[{{0,1},moon}]},

 (* angle label *)
 Text[Style["\[Theta]", Large], {0.50,1.20}],

 (* angle symbol *)
 {Circle[{0,1}, 0.25, {0, ArcTan[4/5]}]},


  (* the null at the end is so I can end every line above w a comma *)

{}};

(* special case, horizon *)

moon2 = {5,1};

lh2 = {

 (* the Earth *)
 {RGBColor[0,0,1], Circle[{0,0}, 1]},

 (* the viewer *)
 {RGBColor[1,0,0], Disk[{0,1}, 0.03]},

 (* the moon *)
 {Disk[moon2, 0.03]},

 (* geocenter to you *)
 {Line[{{0,0},{0,1}}]},

 (* geocenter to moon *)
 {Line[{{0,0},moon2}]},

 (* text for geocenter to moon *)
 Text[Style["m", Large], {2.5,0.3}],

 Text[Style["d", Large], {2.5,1.15}],

 Text[Style["r",Large],{-.1,.5}],

 (* you to moon *)
 {Line[{{0,1},moon2}]},

 (* the null at the end is so I can end every line above w a comma *)

{}};

Graphics[lh2]
showit;

moon3 = {0,5};

lh3 = {

 (* the Earth *)
 {RGBColor[0,0,1], Circle[{0,0}, 1]},

 (* the viewer *)
 {RGBColor[1,0,0], Disk[{0,1}, 0.03]},

 (* the moon *)
 {Disk[moon3, 0.03]},

 (* geocenter to you *)
 {Line[{{0,0},{0,1}}]},

 (* geocenter to moon *)
 {Line[{{0,0},moon3}]},

 (* text for geocenter to moon *)
 Text[Style["m", Large], {-0.25,2.5}],

 Text[Style["d", Large], {0.25,3}],

 Text[Style["r",Large],{0.25,.5}],

 (* you to moon *)
 {Line[{{0,1},moon3}]},

 (* distance arrow for d *)
 {Dashed, Arrowheads[{-.05, .05}], Arrow[{{0.1,1},{0.1,moon3[[2]]}}]},
 {Arrowheads[{-.05, .05}], Arrow[{{0.1,0},{0.1,1}}]},
 {Arrowheads[{-.05, .05}], Arrow[{{-0.1,0},{-0.1,moon3[[2]]}}]},

 (* the null at the end is so I can end every line above w a comma *)

{}};

Graphics[lh3, Axes -> True, Ticks -> None]
showit;

f[t_] = 384000 + 21400*Sin[2*Pi*t/27.554551]

moonhor = Sqrt[OS^2-OU^2]

moonhigh = OE-OU

moonhor - moonhigh /. {OU -> 6371., OS -> 384000, OE -> 384000}


earth = 

moons = {
 {Disk[{-1.5,1}, 0.03], AxesOrigin->{0,0}},
 {Disk[{0,1.8}, 0.03]},
 {Circle[{0,0}, 1.8]}
};

labels = {
 Text[Style["O", Medium], {0.05,-0.05}],
 Text[Style["U", Medium], {0.05,1-0.05}],
 Text[Style["E", Medium], {0.05,1.8-0.05}],
 Text[Style["S", Medium], {-1.5+0.05,1-0.08}],
}

you = {RGBColor[1,0,0], Disk[{0,1}, 0.03]}

arrows = {
 Line[{{0,0}, {-1.5,1}}],
 Arrow[{{0,1}, {-1.5,1}}],
 Line[{{0,0}, {0,1}}],
 Arrow[{{0,1}, {0,1.8}}]
};

Graphics[{earth,moons,arrows,you,labels}]
showit

