(*** CANON FORMULAS START HERE ***)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]

conds = {Element[{x, z, r}, Reals], -Pi/2 < {phi,theta} < Pi/2, r>0};

lineBetweenPoints[p_, x0_, y0_, z0_, x1_, y1_, z1_] =
 {x0 + p*(x1-x0),  y0 + p*(y1-y0),  z0 + p*(z1-z0)}

lineHitsXY[x0_, y0_, z0_, x1_, y1_, z1_] = 
Simplify[Take[lineBetweenPoints[z0/(z0-z1), x0, y0, z0, x1, y1, z1],2]]

(* front half is theta from -Pi/2 to Pi/2, Phi from -Pi to Pi *)

point[x_, z_, r_, theta_,phi_] = 
 {x + r*Cos[theta]*Cos[phi], r*Sin[theta]*Cos[phi], z + Sin[phi]}

sunHitsXY[x_, z_, r_, phi_, theta_] = 
 Apply[lineHitsXY, Flatten[{point[x,z,r,theta,phi],0,0,1}]]

(*** CANON FORMULAS END HERE ***)



(*

What is the shape of the shadow cast by the sun on a single point; not necessarily a circle of even an ellipse

TODO: consider refraction

sun = sphere centered at (-x, 0, z) with radius r (we choose axes so
y=0), consider only front "shell" of sphere, point is (0,0,1)

(* positive solution only, rest is "back of" Sun *)

s0824 = Solve[(px+x)^2 + py^2 + (pz-z)^2 == r^2, x][[2]]

conds = {Element[{px,py,pz}, Reals], r>0}

f[z_] = Solve[(px+x)^2 + py^2 + (pz-z)^2 == r^2, x][[2,1,2]]

valid for z in [-r,r]

above doesnt work, too many degrees of freedom

note, I define phi from xy plane so below is correct

{r*Cos[theta]*Cos[phi], r*Sin[theta]*Cos[phi], Sin[phi]}

parametrizing a line between that and (0,0,1) is

line[theta_,phi_,p_] = 
{ p*(-x + r*Cos[theta]*Cos[phi]), p*r*Sin[theta]*Cos[phi],
  p*(z + Sin[phi])+ (1-p)}

where does this line hit xy plane?

p[z_,phi_] = Solve[p*(z + Sin[phi])+ (1-p) == 0, p][[1,1,2]]

line[theta,phi,p[z,phi]]

Table[Take[Out[91] /. {x -> -2, z -> 2, r -> 0.1},2], {theta,-Pi/2,Pi/
2,.01}, {phi,-Pi,Pi,.01}]                                                       

TODO: above is wrong, need to simplify and build this up

(* value of p where line hits XY plane and then the xy coords of it *)

p0906 = Solve[z0 + p*(z1-z0) == 0, p]

(* it's z0/(z0-z1) which I prob could've figured out... *)

Apply[lineHitsXY, Flatten[{point[x,z,theta,phi],0,0,1}]]

sunHitsXY[-2, 2, 1, 0, 0]

NOT WORKING!

lineBetweenPoints[p, -2+1, 0, 2, 0, 0, 1]

lineHitsXY[-2+1, 0, 2, 0, 0, 1]

point[-2, 2, 0, 0]

ZWhereLineHitsXYPlane[x0_,y0_,z0_,x1_,y1_,z1_] = 

(* tests *)

t0931 = Flatten[Table[sunHitsXY[-2,2,1,phi,theta], 
 {phi,-Pi/2, Pi/2, 0.1}, {theta, -Pi/2, Pi/2, 0.1}],1]

ListPlot[t0931, PlotRange -> All]
showit

t0934 = Flatten[Table[sunHitsXY[-2,100,1,phi,theta], 
 {phi,-Pi/2, Pi/2, 0.1}, {theta, -Pi/2, Pi/2, 0.1}],1]

t0934 = Flatten[Table[sunHitsXY[-2,100,1,phi,theta], 
 {phi,-Pi/2, Pi/2, 0.01}, {theta, -Pi/2, Pi/2, 0.01}],1];

ListPlot[t0934, PlotRange -> All]

ParametricPlot[sunHitsXY[-2,100,1,0,theta], {theta, -Pi/2, Pi/2},
 PlotRange -> All, AxesOrigin -> {0,0}]


ParametricPlot[sunHitsXY[-2,100,1,Pi/4,theta], {theta, -Pi/2, Pi/2},
 PlotRange -> All, AxesOrigin -> {0,0}]


ParametricPlot[sunHitsXY[-2,100,1,85*Degree,theta], {theta, -Pi/2, Pi/2},
 PlotRange -> All, AxesOrigin -> {0,0}]


plot[i_] := ParametricPlot[sunHitsXY[-2,100,1,i,theta], {theta,
-Pi/2, Pi/2}, PlotRange -> All, AxesOrigin -> {0,0}]


plot2[i_] := ParametricPlot[sunHitsXY[-150,100,1,i,theta], {theta,
-Pi/2, Pi/2}, PlotRange -> All, AxesOrigin -> {0,0}]


plot2[i_] := ParametricPlot[sunHitsXY[-150,100,1,i,theta], {theta,
-Pi/2, Pi/2}, PlotRange -> All, AxesOrigin -> {0,0}]


plot2[i_] := ParametricPlot[sunHitsXY[-150,100,1,i,theta], {theta,
-Pi/2, Pi/2}]

t2043 = Table[plot2[i],{i,-90*Degree,90*Degree,10*Degree}]

Show[t2043, ImageSize -> {1024,768}, AspectRatio -> 1, 
 PlotRange -> {{1.4,1.6}, {-0.1,0.1}}]


showit

p2104 = ParametricPlot[sunHitsXY[-150,100,1,phi,Pi/2], {phi,-Pi/2,Pi/2}]
p2105 = ParametricPlot[sunHitsXY[-150,100,1,phi,-Pi/2], {phi,-Pi/2,Pi/2}]

Show[{p2104,p2105}, PlotRange -> All, AspectRatio -> 1]
showit

sunHitsXY[x,z,r,phi,-Pi/2] + sunHitsXY[x,z,r,phi,Pi/2]

the y components do cancel out so there is symmetry about x axis

p2114 = ParametricPlot[sunHitsXY[-150,10,1,phi,Pi/2], {phi,-Pi/2,Pi/2}]
p2115 = ParametricPlot[sunHitsXY[-150,10,1,phi,-Pi/2], {phi,-Pi/2,Pi/2}]

Show[{p2114,p2115}, PlotRange -> All, AspectRatio -> 1]
showit

p2116 = ParametricPlot[sunHitsXY[-150,1000,1,phi,Pi/2], {phi,-Pi/2,Pi/2}]
p2117 = ParametricPlot[sunHitsXY[-150,1000,1,phi,-Pi/2], {phi,-Pi/2,Pi/2}]

Show[{p2116,p2117}, PlotRange -> All, AspectRatio -> 1]
showit

p2118 = ParametricPlot[sunHitsXY[-150,2.1,1,phi,Pi/2], {phi,-Pi/2,Pi/2}]
p2119 = ParametricPlot[sunHitsXY[-150,2.1,1,phi,-Pi/2], {phi,-Pi/2,Pi/2}]
Show[{p2118,p2119}, PlotRange -> All, AspectRatio -> 1]
showit

p2122 = ParametricPlot[sunHitsXY[-2,3,1,phi,Pi/2], {phi,-Pi/2,Pi/2}]
p2123 = ParametricPlot[sunHitsXY[-2,3,1,phi,-Pi/2], {phi,-Pi/2,Pi/2}]
Show[{p2122,p2123}, PlotRange -> All, AspectRatio -> Automatic,
 ImageSize -> {1024,768}, AxesOrigin -> {0,0}]
showit








Table[plot[i],{i,-90*Degree,90*Degree,10*Degree}]

In[58]:= sunHitsXY[-x,z,r,0,0]                                                  
above is center... for fixed phi is it a circle?


center of sun hits:

{(-r + x)/(-1 + z), 0}

top edge:

{x/z, 0}

bottom edge:

{x/(-2 + z), 0}

right edge (center):

{x/(-1 + z), -(r/(-1 + z))}

left edge (center):

{x/(-1 + z), r/(-1 + z)}

FullSimplify[Norm[sunHitsXY[-x,z,r,0,0] - sunHitsXY[-x,z,r,Pi/2,0]],conds]

(* dist from center to top *)

Abs[x - r*z]/Abs[(-1 + z)*z]

(* dist from center to bottom *)

Abs[(-2*r + x + r*z)/(2 - 3*z + z^2)]




