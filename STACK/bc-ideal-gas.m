(*

Let $x$ be the amount the piston moves down due to the mass $m$:

[[image15.gif]]

The answer to your question is "no, there is insufficient information
provided to find the change in temperature". However, if you know the
cylinder's "shape" (ie, the $h:r$ ratio above) and the gas' heat
capacity (https://en.wikipedia.org/wiki/Heat_capacity), the answer is
yes:

  - To support the extra mass $m$, the force on the piston must
  increase by $g m$. Since force is pressure times area, we have

$\Delta  P (\pi r^2) = m g\to \Delta P = \frac{g m}{\pi  r^2}$

Note that $\Delta P$ is independent of $x$.

  - The change in volume is simply:

$\Delta V=-\pi  r^2 x$

  - By Joule's Second Law, the total energy of an ideal gas depends
  only on its temperature:

$E_{\text{total}}=c n R T$

where $c$ is the gas' heat capacity.

Since the gas gains the $m g x$ of potential gravitational energy that
the mass loses (and $c$, $n$, and $R$ remain constant):

$\Delta E_{total} = c n R \Delta T = m g x \to \Delta T = \frac{m g x}{c n R}$

  - By the Ideal Gas Law, we know that $\frac{P V}{n R T}$ remains
  constant. Since $n$ and $R$ are already constant, this means
  $\frac{P V}{T}$ remains constant. Thus, using $P$, $V$, and $T$ as
  the original pressure, volume and temperature, we have:

$\frac{P V}{T}=\frac{(P+\Delta P) (v+\Delta V)}{T+\Delta T}$

Using the values of $\Delta P$, $\Delta V$, and $\Delta T$ above, we
can solve for $x$:

$x\to \frac{g m n R T V}{\pi  r^2 \left(n R T \left(g m+\pi  P r^2\right)+g m
    P V\right)}
$

Plugging this into our formula for $\Delta T$ yields:

$
\Delta T =    
\frac{g^2 m^2 T V}{\pi  r^2 \left(n R T \left(g m+\pi  P r^2\right)+g m P
    V\right)}
$

We can further simplify, since $n R T\to P V$:

$\Delta T = \frac{g^2 m^2 T}{2 \pi  g m P r^2+\pi ^2 P^2 r^4}$

(of course, we could've also made this simplification earlier when
computing $\Delta T$)

While this answer is technically correct, it appears to have an odd
dependency on $r$, the radius of the cylinder, and no dependency on
$V$, the initial volume.

However, if we define, $k=\frac{h}{r}$ (which measures the "shape" of
the cylinder in some sense), we have $h=k r$ and thus:

$V=\pi  r^2 h=\pi  r^2 (k r) = \pi r^3 k \to r = \sqrt[3]{\frac{V}{\pi  k}}$

Making this final substitution, we have:

$
\Delta T = 
   \frac{g^2 m^2 T}{2 \sqrt[3]{\pi } g m P \left(\frac{V}{k}\right)^{2/3}+\pi
    ^{2/3} P^2 \left(\frac{V}{k}\right)^{4/3}}
$

Disclaimer: This is a purely mathematical answer. You should check
that it makes sense in real life.

*)


dp = g*m/Pi/r^2
dv = -Pi*r^2*x
dt = m*g*x/c/n/R

conds = {P0 > 0, P1 > 0, V0 > 0, V1 > 0, T0 > 0, T1 > 0, r > 0, x > 0, g > 0,
 n > 0, R > 0};


sol = FullSimplify[Solve[P*V/T == (P+dp)*(V+dv)/(T+dt), x],conds]

dtf = FullSimplify[sol[[1,1,2]]*m*g/c/n/R, conds]

sol3 = FullSimplify[dtf /. n*R*T -> P*V,conds]




Since the gas is ideal and the quantity doesn't change, we have:

P1V1/T1 = P0V0/T0

Let x be the distance the piston is lowered, and r and h be the radius
and original height of the cylinder respectively.

P1 = P0 + Pi*r^2*m*g

V1 = V0 - Pi*r^2*x

T1 = (2*m*g*x/3/(P0*V0/T0) + T0) 

test0110 = x /. FullSimplify[Solve[P1*V1/T1 == P0*V0/T0, x],conds][[1,1]]

TODO: use height, not radius, easier



m*g - P0*Pi*r^2

P1*Pi*r^2 = mg, so P1 = mg/Pi/r^2

force on top is 

m*g - P(t)*Pi*r^2

extreme cases: mass doesn't move piston: no work done, no temp change

mass moves piston, no temp change: movement is as above, extra energy is mgh?

P1 = mg/Pi/r^2

3/2*n*r*T1 = 3/2*n*r*T0 + mgx so

T1 = 2mgx/3nR + T0

V1 = V0 - Pi*r^2*x

m*g*Pi/r^2*(V0-Pi*r^2*x)/(2*m*g*x/3/n/R + T0) == P0*V0/T0








T1 = T0

http://www.dummies.com/how-to/content/calculating-kinetic-energy-in-an-ideal-gas.html

g2 = Graphics3D[{
 Arrow[{{0,0,0}, {1,0,0}}],
 Arrow[{{1,0,0}, {1,0,3}}], 
 Arrow[{{0,0,3}, {0,0,2.1}}],
 Text[Style["r", FontSize->25], {0.4,0.2,0}],
 Text[Style["h", FontSize->25], {1,-0.2,1.5}],
 Text[Style["x", FontSize->25], {0,-0.2,2.6}],
 RGBColor[{1,0,0}],
 Cylinder[{{0,0,2},{0,0,2.1}}, 1],
 RGBColor[{0,0,1}],
 Opacity[.2],
 Cylinder[{{0,0,0},{0,0,3}}, 1]
}]


Show[g2, Boxed -> False]
showit

