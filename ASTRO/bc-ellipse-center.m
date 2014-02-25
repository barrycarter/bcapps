(* Derives the formula for area of ellipse matching central angle *)

x[t_] = a*Cos[t]
y[t_] = b*Sin[t]

(* setting a,b to concrete values to draw ellipse *)
a = 2; b = 1;

(* this draws a digram of the top right part*)

g1 = ParametricPlot[{x[t],y[t]},{t,0,Pi/2}]

(* "randomly" chosen value of t to show it doesn't match theta *)
(* t is NOT measured in degrees; degrees below is for convenience only *)
samp = 55*Degree

(* the lines from ellipse center and x/y axes to point, and angle arc *)
g2 = {
 Line[{{0,0},{x[samp],y[samp]}}],
 Circle[{0,0}, 2/10, {0, ArcTan[x[samp],y[samp]]}],
 Dashing[0.01],
 Line[{{0,0},{x[samp],y[samp]}}], 
 Dashing[0.01], 
 Line[{{x[samp],0},{x[samp],y[samp]}}], 
 Line[{{0,y[samp]},{x[samp],y[samp]}}],
 Text[Style["b*Sin[t]", FontSize->25], {x[samp], y[samp]/2}, {-1.1,0}],
 Text[Style["a*Cos[t]", FontSize->25], {x[samp]/2, y[samp]}, {0,-1.1}],
 Text[Style["\[Theta]", FontSize->25], {0.2,0.05}, {-1,-1}]
} 

(* results in bc-ellipse-from-center.png in this directory *)
dia = Show[g1,Graphics[g2]]

(* unsetting a and b to resume general case *)
Unset[a]; Unset[b];

(* from the diagram, we see Tan[theta] = (b*Sin[t])/(a*Cos[t])
   Mathematica solves this for t poorly (extraneous junk), so
   I just give the cleaned up result below *)

t[theta_] = ArcTan[a*Tan[theta]/b]

(* reparametrizing using theta *)

x[theta_] = a*Cos[t[theta]]
y[theta_] = b*Sin[t[theta]]

(* the radius squared at theta *)
r2[theta_] = x[theta]^2 + y[theta]^2

(* and integrating r^2/2 from 0 to theta *)

(* Mathematica takes a long time to get an ugly answer, so I'm
hardcoding the results of the following below:

parea[theta_] = Integrate[FullSimplify[r2[x]/2],{x,0,theta}] *)

parea[theta_] = a*b*ArcTan[a*Tan[theta]/b]/2





