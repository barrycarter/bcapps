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

Create a Cartesian grid such that `A` is at the origin, `N` lies on
the positive x axis and `S` lies in the upper half plane. You can
always do this using translation, rotation, and reflecting without
affecting any lengths:

[[image2.jpg]]

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

$(\text{bx}-c)^2+\text{by}^2=g^2$

and plugging in the values of sx and sy we found earlier, yielding two
solutions, both valid:

$
   \left\{\text{bx}\to \frac{\left(c^2+d^2-e^2\right)
    \left(d^2+f^2-g^2\right)+\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}}{4 c d^2},\text{by}\to -\frac{c^4
    \left(d^2+f^2-g^2\right)+c^2 \left(\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e)
    (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-2 \left(d^2+e^2\right)
    \left(d^2+f^2-g^2\right)\right)+(d-e) (d+e) \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}+(d-e) (d+e)
    \left(d^2+f^2-g^2\right)\right)}{4 c d^2 \sqrt{-(c-d-e) (c+d-e) (c-d+e)
    (c+d+e)}}\right\}
$

$
   \left\{\text{bx}\to \frac{\left(c^2+d^2-e^2\right)
    \left(d^2+f^2-g^2\right)-\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}}{4 c d^2},\text{by}\to \frac{c^4
    \left(-\left(d^2+f^2-g^2\right)\right)+c^2 \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}+2 \left(d^2+e^2\right)
    \left(d^2+f^2-g^2\right)\right)+(d-e) (d+e) \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-(d-e) (d+e)
    \left(d^2+f^2-g^2\right)\right)}{4 c d^2 \sqrt{-(c-d-e) (c+d-e) (c-d+e)
    (c+d+e)}}\right\}
$

To find ABN, we simply take the arctangent:







TODO: triangle inequality

Note that sx can be negative or positive (I just drew it as positive),
but sy is definitely positive as above.

I also changed the names of the lengths to lower case letters for
Mathematica's sake.

Since we know c, d, and e, we can easily compute sx and sy:

$\text{sx}=\frac{c^2+d^2-e^2}{2 c}$

$\text{sy}=\sqrt{d^2-\frac{\left(c^2+d^2-e^2\right)^2}{4 c^2}}$

Since we also know lengths BN (call it f) and BS (call it g), we can
find the coordinates of B:

$
   \left\{\text{bx}\to \frac{\left(c^2+d^2-e^2\right)
    \left(d^2+f^2-g^2\right)+\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}}{4 c d^2},\text{by}\to -\frac{c^4
    \left(d^2+f^2-g^2\right)+c^2 \left(\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e)
    (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-2 \left(d^2+e^2\right)
    \left(d^2+f^2-g^2\right)\right)+(d-e) (d+e) \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}+(d-e) (d+e)
    \left(d^2+f^2-g^2\right)\right)}{4 c d^2 \sqrt{-(c-d-e) (c+d-e) (c-d+e)
    (c+d+e)}}\right\}
$

$
   \left\{\text{bx}\to \frac{\left(c^2+d^2-e^2\right)
    \left(d^2+f^2-g^2\right)-\sqrt{(c-d-e) (c+d-e) (c-d+e) (c+d+e) (d-f-g)
    (d+f-g) (d-f+g) (d+f+g)}}{4 c d^2},\text{by}\to \frac{c^4
    \left(-\left(d^2+f^2-g^2\right)\right)+c^2 \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}+2 \left(d^2+e^2\right)
    \left(d^2+f^2-g^2\right)\right)+(d-e) (d+e) \left(\sqrt{(c-d-e) (c+d-e)
    (c-d+e) (c+d+e) (d-f-g) (d+f-g) (d-f+g) (d+f+g)}-(d-e) (d+e)
    \left(d^2+f^2-g^2\right)\right)}{4 c d^2 \sqrt{-(c-d-e) (c+d-e) (c-d+e)
    (c+d+e)}}\right\}
$

You may've worked this out already, but, as stated, there is not
necessarily a unique solution.

TODO: give two solutions




TODO: put answer at top then derive

conds = {c > 0, d > 0, e > 0, f > 0, g >0, sy> 0, 
 Element[{sx,bx,by}, Reals]}

sol = FullSimplify[Solve[{sx^2 + sy^2 == d^2, (sx-c)^2 + sy^2 == e^2},
 {sx,sy}, Reals], conds]

sxsol = sol[[1,1,2,1]];
sysol = sol[[2,2,2,1]];

sol2 = FullSimplify[
Solve[{bx^2 + by^2 == f^2, (bx-sxsol)^2 + (by-sysol)^2 == g^2}, {bx,by}],
conds]

bxsol1 = FullSimplify[sol2[[1,1,2]],conds]
bxsol2 = FullSimplify[sol2[[2,1,2]],conds]

bysol1 = FullSimplify[sol2[[1,2,2]],conds]
bysol2 = FullSimplify[sol2[[2,2,2]],conds]

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
 Text[Style["A (0,0)", FontSize->25], {0,-.05}],
 Text[Style["c", FontSize->25], {0.5,-.02}],
 Text[Style["d", FontSize->25], {0.17,0.75/2}],
 Text[Style["e", FontSize->25], {.65,.75/2}],
 Text[Style["f", FontSize->25], {.57,.67}],
 Text[Style["g", FontSize->25], {.87,.36}],
 Arrow[{{0,0},{0,1}}],
 PointSize[0.02],
 Point[{0,0}],
 Line[{{0,0},{1,0}}],
 Line[{{0,0},{0.4,0.7}}],
 Line[{{1,0},{.4,.7}}],
 Line[{{1,0},{0.733145,0.592696}}],
 Line[{{.4,.7},{0.733145,0.592696}}],
 RGBColor[{1,0,0}],
 Text[Style["N (c,0)", FontSize->25], {1,-.05}],
 Point[{1,0}],
 RGBColor[{0,0,1}],
 Point[{.4, .7}],
 Text[Style["S (sx,sy)", FontSize->25], {0.4,0.75}],
 RGBColor[{1,0,1}],
 Text[Style["B (bx,by)", FontSize->25], {0.85,0.6}],
 Point[{0.733145,0.592696}]
}]
Show[g2]
showit




TODO: verbiage

N -> origin

A -> {an,0}

B -> {bx,by} (unknown, but norm is known)

S -> {sx,sy} (unknown, but three norms known)

lens: {ns, as, bs} and {an, bn} (note diagram gives sn, sa, sb)

TODO: disclaim sy>0

sol = FullSimplify[Solve[{sx^2 + sy^2 == ns^2, (sx-an)^2 + sy^2 == as^2}, 
 {sx,sy}, Reals], conds]

sxsol = sol[[1,1,2,1]]

sysol = Sqrt[ns^2 - (an^2 - as^2 + ns^2)^2/(4*an^2)]

FullSimplify[by/bx /. sol2[[1]],conds]

sol = Solve[{
 sx^2 + sy^2 == ns^2,
 (sx-an)^2 + sy^2 == as^2, 
 (bx-sx)^2 + (by-sy)^2 == bs^2,
 


{bx^2 + by^2 == bn^2, (bx-sxsol)^2 + (by-sysol)^2 == bs^2}, {bx,by}],


bxsol1 /. {c -> 1, d -> .81, e -> .92, f -> .46, g -> .46}

claim both

{0.431638,

{

Solve[{
 (bx-1)^2 + by^2 == .65^2,
 (bx-.4)^2 + (by-.7)^2 == .35^2
}, {bx,by}]











Solve[{
 sx^2 + sy^2 == ns^2,
 (sx-an)^2 + sy^2 == as^2,
 (sx-bx)^2 + (sy-by)^2 == bs^2,
 bx^2 + by^2 == bn^2
}, {sx,sy,bx,by}, Reals]



Solve[{
 Norm[{sx,sy}]^2 == ns^2,
 Norm[{sx,sy} - {an,0}]^2 == as^2,
 Norm[{sx,sy} - {bx,by}]^2 == bs^2,
 Norm[{bx,by}]^2 == bn^2
}, {sx,sy,bx,by}, Reals]







*)
