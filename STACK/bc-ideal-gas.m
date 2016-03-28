(*

g = Graphics3D[{
 Arrow[{{0,0,0}, {1,0,0}}],
 Arrow[{{1,0,0}, {1,0,3}}], 
 Arrow[{{0,0,3}, {0,0,2.1}}],
 Text[Style["r", FontSize->25], {0.4,0.2,0}],
 Text[Style["h", FontSize->25], {1,-0.2,1.5}],
 Text[Style["x", FontSize->25], {0,-0.2,2.55}],
 RGBColor[{1,0,0}],
 Cylinder[{{0,0,2},{0,0,2.1}}, 1],
 RGBColor[{0,0,1}],
 Opacity[.2],
 Cylinder[{{0,0,0},{0,0,3}}, 1]
}]


Show[g, Boxed -> False]
showit

TODO: improve or explain diagram above

[[image]]

The answer to your question is "no, there is insufficient information
provided to find the change in temperature". However, if you know the
cylinder's "shape" (ie, the $h:r$ ratio above), the answer is yes.






Since the gas is ideal and the quantity doesn't change, we have:

P1V1/T1 = P0V0/T0

Let x be the distance the piston is lowered, and r and h be the radius
and original height of the cylinder respectively.

conds = {P0 > 0, P1 > 0, V0 > 0, V1 > 0, T0 > 0, T1 > 0, r > 0, x > 0, g > 0,
 n > 0, R > 0};

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
