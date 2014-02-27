(* THIS STARTS OUT AS AN EXACT COPY OF bc-ellipse-center.m AND
DOES NOT CURRENTLY CALCULATE AREA FROM FOCUS; I WILL REMOVE THIS NOTE
WHEN IT DOES *)

(* default values when we don't supply a and b *)
a0 = 11/10; b0 = 1;

(* Derives the formula for area of ellipse matching focal angle *)

(* a > b required for focal angle *)
x[t_,a_:a0,b_:b0] = a*Cos[t]
y[t_,a_:a0,b_:b0] = b*Sin[t]

(* focus is on x axis for a>b at this position *)
focus[a_,b_] = Sqrt[a^2-b^2]

(* this draws a digram of the top right part*)

g1 = ParametricPlot[{x[t],y[t]},{t,0,Pi/2}]

(* "randomly" chosen value of t to show it doesn't match focal angle*)
(* t is NOT measured in degrees; degrees below is for convenience only *)

samp = 55*Degree

(* the lines from ellipse center and x/y axes to point, and angle arc *)
g2 = {
 Line[{{focus[a0,b0],0},{x[samp],y[samp]}}],
 Circle[{focus[a0,b0],0}, 1/20, {0, ArcTan[x[samp]-focus[a0,b0],y[samp]]}],
 Text[Style["\[Theta]", FontSize->25], {focus[a0,b0],0}, {-1.5,-0.75}],
 Line[{{0,0.05}, {focus[a0,b0],0.05}}],
 Line[{{focus[a0,b0],0}, {focus[a0,b0],0.10}}],
 Line[{{0,0}, {0,0.10}}],
 RGBColor[1,0,0],
 Line[{{focus[a0,b0],0.05}, {x[samp],0.05}}],
 Line[{{x[samp],0}, {x[samp],0.1}}],
 Line[{{focus[a0,b0],0}, {focus[a0,b0],0.1}}],
 Text[Style[d, FontSize->25], {(x[samp]+focus[a0,b0])/2,0.05}, {0,-1}],
 RGBColor[0,0,0],
 Dashing[0.01],
 Line[{{x[samp],y[samp]}, {x[samp],0}}],
 Line[{{x[samp],y[samp]}, {0,y[samp]}}],
 Text[Style[HoldForm[b*Sin[t]], FontSize->25], {x[samp],y[samp]/2}, {-1.1,0}],
 Text[Style[HoldForm[a*Cos[t]], FontSize->25], {x[samp]/2,y[samp]}, {0,-1.1}],
 Text[Style[HoldForm[Sqrt[a^2-b^2]], FontSize->25], {focus[a0,b0]/2,0.05}, {0,-1}]
} 

(* results in bc-ellipse-from-center.png in this directory *)
dia = Show[g1,Graphics[g2]]

(* conditions under which the below work *)
conds = {a>b,b>0,x>0,x<Pi/2,Element[a,Reals],Element[b,Reals],Element[x,Reals],
theta>0, Element[theta,Reals], theta < Pi/2}

(* below only works for theta <= Pi/2; case theta > Pi/2 is NOT symmetric *)
theta[t_,a_:a0,b_:b0] = ArcTan[y[t,a,b]/(x[t,a,b]-focus[a,b])]

(* and the inverse *)
t[theta_,a_:a0,b_:b0] = t /. Solve[theta[t,a,b] == theta, t][[4]]
t[theta_,a_:a0,b_:b0] = FullSimplify[t[theta,a,b], conds]

Abort[]

Plot[theta[t],{t,0,Pi/2}]
Plot[t[theta],{theta,0,Pi/2}]
Plot[theta[t[x]]-x, {x,0,Pi/2}]
Plot[t[theta[x]]-x, {x,0,Pi/2}]

(* reparametrizing using theta *)

x[theta_,a_:a0,b_:b0] = FullSimplify[a*Cos[t[theta,a,b]],conds]
y[theta_,a_:a0,b_:b0] = FullSimplify[b*Sin[t[theta,a,b]],conds]

(* the radius squared at theta *)
r2[theta_,a_:a0,b_:b0] = FullSimplify[x[theta,a,b]^2 + y[theta,a,b]^2, conds]


(* and the area *)
parea[theta_,a_:a0,b_:b0] = 
 FullSimplify[Integrate[r2[x,a,b]/2,{x,0,theta}], conds]

