(*
http://math.stackexchange.com/questions/1688586/finding-an-angle-in-a-triangle-when-the-length-of-one-side-is-unknown-and-the-d
*)

(*

[[image]]

As stated, the problem does not necessarily have a single solution. Example:

`AN = 1.0, BN = 0.65, NS = 0.92, AS = 0.81, BS = 0.35`

B's coordinates can be either {0.45509,0.354363} or
{0.733145,0.592696}, and the values of angle ANB is different for
these two sets of coordinates.

Note that I am using approximate numbers here, but the roundoff errors
are small enough to be ignored.

I hope to expand on my answer by providing a closed formula for the
two possible values of ANB (when they exist).

Create a Cartesian grid such that $N$ is at the origin, $A$ lies on
the positive x axis and $S$ lies in the upper half plane. You can
always do this using translation, rotation, and reflecting without
affecting any lengths:

[[image2.gif]]

(note that $A$ and $N$ above are flipped from my counterexample
earlier, as it turns out the calculations are easier with $N$ at the
origin; I've also replaced the side lengths with lowercase letters
since I'm using Mathematica to help solve this problem)

Although I've draw B and S in quadrant I, B can be in any quadrant,
and S can be in quadrants I or II (since we explicitly chose our axis
system so that sy > 0).

We can now find sx and sy by solving the simultaneous equations:

$\text{sx}^2+\text{sy}^2=d^2$

$(\text{sx}-c)^2+\text{sy}^2=e^2$

The are two solutions, but only one with sy > 0:

$
   \left\{\text{sx}\to \frac{c^2+d^2-e^2}{2 c},\text{sy}\to
    \sqrt{d^2-\frac{\left(c^2+d^2-e^2\right)^2}{4 c^2}}\right\}
$

We can now solve for bx and by using:

$(\text{bx}-\text{sx})^2+(\text{by}-\text{sy})^2=f^2$

$\text{bx}^2+\text{by}^2=g^2$

and plugging in the values of sx and sy we found earlier, yielding two
solutions, both valid:

$
   \left\{\text{bx}\to \frac{\left(c^2+d^2-e^2\right)
    \left(d^2-f^2+g^2\right)+\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}}{4 c d^2},\text{by}\to -\frac{c^4
    \left(d^2-f^2+g^2\right)+c^2 \left(\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e)
    (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-2 \left(d^2+e^2\right)
    \left(d^2-f^2+g^2\right)\right)+(d-e) (d+e) \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}+(d-e) (d+e)
    \left(d^2-f^2+g^2\right)\right)}{4 c d^2 \sqrt{-(c-d-e) (c+d-e) (c-d+e)
    (c+d+e)}}\right\}
$

$
   \left\{\text{bx}\to \frac{\left(c^2+d^2-e^2\right)
    \left(d^2-f^2+g^2\right)-\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}}{4 c d^2},\text{by}\to \frac{c^4
    \left(-\left(d^2-f^2+g^2\right)\right)+c^2 \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}+2 \left(d^2+e^2\right)
    \left(d^2-f^2+g^2\right)\right)+(d-e) (d+e) \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-(d-e) (d+e)
    \left(d^2-f^2+g^2\right)\right)}{4 c d^2 \sqrt{-(c-d-e) (c+d-e) (c-d+e)
    (c+d+e)}}\right\}
$

To find ABN, we simply take the arctangent of
$\frac{\text{by}}{\text{bx}}$. Since the angle will always be between
0 and 180 degrees (if it's larger than 180 degrees, we measure the
angle clockwise), we can use the single argument form of arctangent
(I'd stated incorrectly earlier than we needed the two argument
form. This yields:

$
   -\tan ^{-1}\left(\frac{c^4 \left(d^2-f^2+g^2\right)+c^2 \left(\sqrt{(c-d-e)
    (c+d-e) (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-2
    \left(d^2+e^2\right) \left(d^2-f^2+g^2\right)\right)+(d-e) (d+e)
    \left(\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g)
   (d+f+g)}+(d-e) (d+e) \left(d^2-f^2+g^2\right)\right)}{\sqrt{-(c-d-e) (c+d-e)
    (c-d+e) (c+d+e)} \left(\left(c^2+d^2-e^2\right)
    \left(d^2-f^2+g^2\right)+\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}\right)}\right)
$

$
   \tan ^{-1}\left(\frac{c^4 \left(-\left(d^2-f^2+g^2\right)\right)+c^2
    \left(\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g)
    (d+f+g)}+2 \left(d^2+e^2\right) \left(d^2-f^2+g^2\right)\right)+(d-e) (d+e)
    \left(\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g)
   (d+f+g)}-(d-e) (d+e) \left(d^2-f^2+g^2\right)\right)}{\sqrt{-(c-d-e) (c+d-e)
    (c-d+e) (c+d+e)} \left(\left(c^2+d^2-e^2\right)
    \left(d^2-f^2+g^2\right)-\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}\right)}\right)
$

Mathematica can't find a simpler form for the answer, and I'm not sure
how useful the above is, but there you have it.

Note that I assume the triangle inequality throughout. When the
triangle inequality doesn't hold, some of the square roots above are
of negative values, and thus have no real number solutions.

*)

conds = {c > 0, d > 0, e > 0, f > 0, g >0, sy> 0, 
 Element[{sx,bx,by}, Reals]}

sol = FullSimplify[Solve[{sx^2 + sy^2 == d^2, (sx-c)^2 + sy^2 == e^2},
 {sx,sy}, Reals], conds]

sxsol = sol[[1,1,2,1]];
sysol = sol[[2,2,2,1]];

sol2 = FullSimplify[
Solve[{bx^2 + by^2 == g^2, (bx-sxsol)^2 + (by-sysol)^2 == f^2}, {bx,by}],
conds]

bxsol1 = FullSimplify[sol2[[1,1,2]],conds]
bxsol2 = FullSimplify[sol2[[2,1,2]],conds]

bysol1 = FullSimplify[sol2[[1,2,2]],conds]
bysol2 = FullSimplify[sol2[[2,2,2]],conds]

ans1 = FullSimplify[ArcTan[bysol1/bxsol1],conds]
ans2 = FullSimplify[ArcTan[bysol2/bxsol2],conds]

bxsol1 /. {c -> 3, d -> 4, e -> 9/2, f -> 2, g -> 3}

g0 = Graphics[{
 Arrow[{{0,0},{1.1,0}}],
 Text[Style["A (0,0)", FontSize->25], {0,-.05}],
 Text[Style["N (c,0)", FontSize->25], {1,-.05}],
 Text[Style["S (sx,sy)", FontSize->25], {0.4,0.75}],
 Text[Style["c", FontSize->25], {0.5,-.02}],
 Text[Style["d", FontSize->25], {0.17,0.75/2}],
 Text[Style["e", FontSize->25], {.73,.75/2}],
 Arrow[{{0,0},{0,1}}],
 PointSize[0.02],
 Point[{0,0}],
 Point[{1,0}],
 Point[{.4, .7}],
 Line[{{0,0},{1,0}}],
 Line[{{0,0},{0.4,0.7}}],
 Line[{{1,0},{.4,.7}}],
}]
Show[g0]
showit

g1 = Graphics[{
 Arrow[{{0,0},{1.1,0}}],
 Text[Style["A (0,0)", FontSize->25], {0,-.05}],
 Text[Style["1", FontSize->25], {0.5,-.02}],
 Text[Style["0.81", FontSize->25], {0.17,0.75/2}],
 Text[Style["0.92", FontSize->25], {.73,.75/2}],
 Arrow[{{0,0},{0,1}}],
 PointSize[0.02],
 Point[{0,0}],
 Line[{{0,0},{1,0}}],
 Line[{{0,0},{0.4,0.7}}],
 Line[{{1,0},{.4,.7}}],
 RGBColor[{1,0,0}],
 Text[Style["N (1,0)", FontSize->25], {1,-.05}],
 Text[Style["r = 0.65", FontSize->25], {1,.60}],
 Point[{1,0}],
 Circle[{1,0}, .65, {90*Degree, 180*Degree}],
 RGBColor[{0,0,1}],
 Circle[{.4,.7}, .35],
 Point[{.4, .7}],
 Text[Style["S (0.4,0.7)", FontSize->25], {0.4,0.75}],
 Text[Style["r = 0.35", FontSize->25], {0.4,0.8}],
 RGBColor[{0,1,0}],
 Text[Style["B?", FontSize->25], {0.48,0.32}],
 Text[Style["B?", FontSize->25], {0.76,0.56}],
 Point[{0.45509,0.354363}],
 Point[{0.733145,0.592696}]
}]
Show[g1, Axes -> True]
showit

g2 = Graphics[{
 Arrow[{{0,0},{1.1,0}}],
 Text[Style["N (0,0)", FontSize->25], {0,-.05}],
 Text[Style["c", FontSize->25], {0.5,-.02}],
 Text[Style["d", FontSize->25], {0.17,0.75/2}],
 Text[Style["e", FontSize->25], {.7,.75/2+.03}],
 Text[Style["f", FontSize->25], {.45,.55}],
 Text[Style["g", FontSize->25], {.28,.23}],
 Arrow[{{0,0},{0,1}}],
 PointSize[0.02],
 Point[{0,0}],
 Line[{{0,0},{1,0}}],
 Line[{{0,0},{0.4,0.7}}],
 Line[{{1,0},{.4,.7}}],
 Line[{{0,0},{0.433145,0.392696}}],
 Line[{{.4,.7},{0.433145,0.392696}}],

 RGBColor[{1,0,0}],
 Text[Style["A (c,0)", FontSize->25], {1,-.05}],
 Point[{1,0}],

 RGBColor[{0,0,1}],
 Point[{.4, .7}],
 Text[Style["S (sx,sy)", FontSize->25], {0.4,0.75}],

 RGBColor[{1,0,1}],
 Text[Style["B (bx,by)", FontSize->25], {0.51,0.35}],
 Point[{0.433145,0.392696}]

}]
Show[g2]
showit
