(* attempts to solve http://earthscience.stackexchange.com/questions/7281/what-is-the-moons-distance-from-viewer-at-horizon *)

(*

TODO: summarize answer, ignoring refraction, not to scale

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




*)

(* loophole graphics *)

moon = {-5,5};

lh = {

 (* the Earth *)
 {RGBColor[0,0,1], Circle[{0,0}, 1]},

 (* the viewer *)
 {RGBColor[1,0,0], Disk[{0,1}, 0.03]},

 (* viewer horizon *)
 {RGBColor[1,0,0], Line[{{moon[[1]],1},{1,1}}]},

 (* the moon *)
 {Disk[moon, 0.03]},

 (* geocenter to you *)
 {Line[{{0,0},{0,1}}]},

 (* geocenter to moon *)
 {Line[{{0,0},moon}]},

 (* moon to axes *)
 {Dashed, Line[{moon, {0, moon[[2]]}}]},

 (* you to moon *)
 {Line[{{0,1},moon}]},

 (* angle label *)
 Text[Style["\[Theta]", Large], {-0.20,1.20}],



  (* the null at the end is so I can end every line above w a comma *)

{}};

Graphics[lh, Axes->True, TicksStyle -> Directive[FontOpacity -> 0,
FontSize -> 0]]
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

