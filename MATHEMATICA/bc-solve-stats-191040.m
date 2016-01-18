(* attempts to solve http://stats.stackexchange.com/questions/191040/use-points-in-euclidean-space-to-find-probability-based-on-distributions *)

(* 

Solution:

  - If |y| is bigger than 3, the string is always longer than 3 units,
  regardless of the value of x. The chance that the standard normal
  distribution will be less than -3 or greater than +3 is:

$\text{erfc}\left(\frac{3}{\sqrt{2}}\right)$

which is about 0.0026998

  - For `-3 < y < 3`, the chance that `y = y0` (for any y0) is the PDF
  of the standard normal at y0 or:

$\frac{e^{-\frac{\text{y0}^2}{2}}}{\sqrt{2 \pi }}$

  - If y=y0, we want to compute the chance that `x^2 + y0^2 > 3^2`, or
  `x^2 > 3^2 - y0^2` or `|x| > Sqrt[3^2-y0^2]`.

  - The chance that `x < -Sqrt[3^2-y0^2]` is just the CDF of x's
  distribution to the value, which is:

$\frac{1}{2} \text{erfc}\left(\frac{\sqrt{9-\text{y0}^2}+2}{\sqrt{2}}\right)$

  - The chance that `x > Sqrt[3^2-y0^2]` is 1 minus the CDF of x's
  distribution to the value, which is:

$1-\frac{1}{2}\text{erfc}\left(-\frac{\sqrt{9-\text{y0}^2}-2}{\sqrt{2}}\right)$

  - Since the two events above don't overlap, the total chance that x
  will be large enough to make the total length bigger than 3 is the
  sum of the above or:

$
   \frac{1}{2}
    \left(-\text{erfc}\left(-\frac{\sqrt{9-\text{y0}^2}-2}{\sqrt{2}}\right)+\tex
    t{erfc}\left(\frac{\sqrt{9-\text{y0}^2}+2}{\sqrt{2}}\right)+2\right)
$

  - So, for any given value of y0, the above is the chance x will be
  big enough to make the total length greater than 3. Since we know
  the probability of y=y0 (as above), the probability of the combined
  events is the product of the two probabilities or:

$
   \frac{e^{-\frac{\text{y0}^2}{2}}
    \left(-\text{erfc}\left(-\frac{\sqrt{9-\text{y0}^2}-2}{\sqrt{2}}\right)+\tex
    t{erfc}\left(\frac{\sqrt{9-\text{y0}^2}+2}{\sqrt{2}}\right)+2\right)}{2
    \sqrt{2 \pi }}
$

  - To find the total probability over all y0, we integrate the above
  from -3 to +3 (since we made a special case for y < -3 and y > 3
  above) numerically to get 0.211662.

  - We now add this probability to the probability of |y| > 3 we
  computed earlier to get 0.214362

Here's a plot of your probability function and a circle of radius 3
(note that the circle looks elongated because it follows the surface
of your probability distribution)

[[IMAGE]]

Note: I wrote
https://github.com/barrycarter/bcapps/blob/master/MATHEMATICA/bc-solve-stats-191040.m
to help solve this.

*)

bigy = 2*CDF[NormalDistribution[0,1]][-3];

yeqy0 = PDF[NormalDistribution[0,1]][y0];

xsmall = CDF[NormalDistribution[2,1]][-Sqrt[3^2-y0^2]]

xbig = 1-CDF[NormalDistribution[2,1]][Sqrt[3^2-y0^2]]

Integrate[yeqy0*(xsmall+xbig),{y0,-3,3}]

f[x_,y_] = PDF[NormalDistribution[0,1]][y]*PDF[NormalDistribution[2,1]][x];

p1 = Plot3D[f[x,y],  {x,-5,5}, {y,-5,5}, ColorFunction -> Hue, 
 ViewVector -> {0,0,1}, PlotRange -> All]

p5 = ParametricPlot3D[{3*Cos[x],3*Sin[x],f[3*Cos[x],3*Sin[x]]}, {x,0,2*Pi},
 ViewVector -> {0,0,1}, PlotStyle -> {Thick}]

p5 = ParametricPlot3D[{3*Cos[x],3*Sin[x],0}, {x,0,2*Pi},
 ViewVector -> {0,0,1}, PlotStyle -> {Thick}]

p5 = ParametricPlot3D[{3*Cos[x],3*Sin[x],0}, {x,0,2*Pi}, PlotStyle -> {Thick}]

p5 = ParametricPlot3D[{3*Cos[x],3*Sin[x], 0.01+f[3*Cos[x], 3*Sin[x]]}, 
 {x,0,2*Pi}, PlotStyle -> {Thick}]

p5 = ParametricPlot3D[{3*Cos[x],3*Sin[x], 0.15}, 
 {x,0,2*Pi}, PlotStyle -> {Thick}]

Show[p1,p5]
showit


p3 = Plot3D[If[Abs[x^2+y^2-9] < 0.5, 1,0],{x,-5,5},{y,-5,5}]

p4 = Graphics3D[Cylinder[{{0, 0, 0}, {0, 0, 1}}, 3]]

p4 = Graphics3D[Cylinder[{{0, 0, 0}, {0, 0, 0.15}}, 3]]

p2 = ParametricPlot3D[{Cos[t],Sin[t],0},{t,0,2*Pi}]

p6 = ParametricPlot3D[{3*Cos[x],3*Sin[x],0}, {x,0,2*Pi}]


Graphics[{Thickness[2],p2,p1}]




