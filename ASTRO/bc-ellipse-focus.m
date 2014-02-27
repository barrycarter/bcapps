(* THIS STARTS OUT AS AN EXACT COPY OF bc-ellipse-center.m AND
DOES NOT CURRENTLY CALCULATE AREA FROM FOCUS; I WILL REMOVE THIS NOTE
WHEN IT DOES *)

(* Derives the formula for area of ellipse matching focal angle *)

(* a > b required for focal angle *)
x[t_] = a*Cos[t]
y[t_] = b*Sin[t]

(* focus is on x axis for a>b at this position *)
focus[a_,b_] = Sqrt[a^2-b^2]

(* setting a,b to concrete values to draw ellipse *)
a = 1.1; b = 1;

(* this draws a digram of the top right part*)

g1 = ParametricPlot[{x[t],y[t]},{t,0,Pi/2}]

(* "randomly" chosen value of t to show it doesn't match focal angle*)
(* t is NOT measured in degrees; degrees below is for convenience only *)

samp = 55*Degree

(* the lines from ellipse center and x/y axes to point, and angle arc *)
g2 = {
 Line[{{focus[a,b],0},{x[samp],y[samp]}}],
 Circle[{focus[a,b],0}, 1/20, {0, ArcTan[x[samp]-focus[a,b],y[samp]]}],
 Text[Style["\[Theta]", FontSize->25], {focus[a,b],0}, {-1.5,-0.75}],
 Line[{{0,0.05}, {focus[a,b],0.05}}],
 Line[{{focus[a,b],0}, {focus[a,b],0.10}}],
 Line[{{0,0}, {0,0.10}}],
 RGBColor[1,0,0],
 Line[{{focus[a,b],0.05}, {x[samp],0.05}}],
 Line[{{x[samp],0}, {x[samp],0.1}}],
 Line[{{focus[a,b],0}, {focus[a,b],0.1}}],
 Text[Style[d, FontSize->25], {(x[samp]+focus[a,b])/2,0.05}, {0,-1}],
 RGBColor[0,0,0],
 Dashing[0.01],
 Line[{{x[samp],y[samp]}, {x[samp],0}}],
 Line[{{x[samp],y[samp]}, {0,y[samp]}}],
 Text[Style[HoldForm[b*Sin[t]], FontSize->25], {x[samp],y[samp]/2}, {-1.1,0}],
 Text[Style[HoldForm[a*Cos[t]], FontSize->25], {x[samp]/2,y[samp]}, {0,-1.1}],
 Text[Style[HoldForm[Sqrt[a^2-b^2]], FontSize->25], {focus[a,b]/2,0.05}, {0,-1}]
} 

(* results in bc-ellipse-from-center.png in this directory *)
dia = Show[g1,Graphics[g2]]

(* unsetting a and b to resume general case *)
Unset[a]; Unset[b];

(* conditions under which the below work *)
conds = {a>b,b>0,x>0,x<Pi/2,Element[a,Reals],Element[b,Reals],Element[x,Reals],
theta>0, Element[theta,Reals], theta < Pi/2}

(* below only works for theta <= Pi/2; case theta > Pi/2 is NOT symmetric *)
theta[t_] = ArcTan[y[t]/(x[t]-focus[a,b])]
t[x_] = InverseFunction[theta][x]
t[x_] = FullSimplify[t[x], conds]

(* reparametrizing using theta *)

x[theta_] = FullSimplify[a*Cos[t[theta]],conds]
y[theta_] = FullSimplify[b*Sin[t[theta]],conds]

(* the radius squared at theta *)
r2[theta_] = FullSimplify[x[theta]^2 + y[theta]^2, conds]


(* and the area *)
parea[theta_] = FullSimplify[Integrate[r2[x]/2,{x,0,theta}], conds]




Abort[]


(* below aren't true in general, but are here and useful for simplication *)

(* some of these are very specific to this file/problem *)

rewrite = {Sqrt[a_^2] -> a, Sqrt[Sec[a_]^2] -> Sec[a], Sqrt[a_^4] -> a^2}

(* assumptions valid for what we are doing *)

assums = {a>b, Member[x,Reals], Member[theta,Reals]}

(* the assumptions below are hand-coded and not general case *)

t[x_] = InverseFunction[theta][x] /.
 {Sqrt[b_^4 + b_^4*Tan[x_]^2] -> b^2*Sec[x], (a_-b_)*(a_+b_) -> a^2-b^2}

parea[theta_] = Integrate[r2[x]/2,{x,0,theta}]

parea[theta_] = Simplify[parea[theta], {Member[theta,Reals]}]





(* contradictory answers? 

ArcTan[(b*Sin[t])/(-Sqrt[a^2 - b^2] + a*Cos[t])]


*)



(* Solve[theta[t]==x && a > 0 && b > 0 && x > 0,t,Reals] *)


(******** IGNORING BELOW FOR NOW


(* from the diagram, we see Tan[theta] = (b*Sin[t])/(a*Cos[t])
   Mathematica solves this for t poorly (extraneous junk), so
   I just give the cleaned up result below *)

t[theta_] = ArcTan[a*Tan[theta]/b]


x[theta_] = a*Cos[t[theta]]
y[theta_] = b*Sin[t[theta]]


(* and integrating r^2/2 from 0 to theta *)

(* Mathematica takes a long time to get an ugly answer, so I'm
hardcoding the results of the following below:

parea[theta_] = Integrate[FullSimplify[r2[x]/2],{x,0,theta}] *)

parea[theta_] = a*b*ArcTan[a*Tan[theta]/b]/2

Graphics[Text[Style["Sqrt[a^2-b^2]", FontSize->25], {0,0}]]



**********)
