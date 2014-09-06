(* TODO: this may be useful for general library *)

(* Taylor of a list at a variable *)

taylor[list_,t_] := Sum[list[[i]]*t^(i-1),{i,1,Length[list]}]

(* Chebyshev of a list at a variable *)

chebyshev[list_,t_] := Sum[list[[i]]*ChebyshevT[i-1,t],{t,1,Length[list]}]

(* Given a list of Taylor coefficients and n, create n sets of Taylor
coefficients, each good for 1/n of the interval [-1,1] (ie, tailor a
Taylor series to behave the way we want) *)

tailortaylor[list_,n_] := Table[CoefficientList[
 taylor[list,(t+2*i-1)/n-1],t],{i,1,n}]






(* below is wrong:

tailortaylor[list_, n_] := Table[
CoefficientList[Sum[list[[i]]*((t+2*j-1)/n-1)^(j-1), {i,1,Length[list]}],t],
{j,1,n}]

*)

list = Table[1/i,{i,1,5}]

tay = Table[t^i,{i,0,4}]

Total[list*tay]

Plot[%,{t,-1,1}]

tailortaylor[list,4]

Total[%[[3]]*tay]




(* Chebyshev or Taylor packing *)

mdec = Table[{AstronomicalData["Moon", {"Declination", DateList[t]}]},
 {t, AbsoluteTime[{2014,1,1}], AbsoluteTime[{2015,1,1}], 300}];

mdec2 = Table[AstronomicalData["Moon", {"Declination", DateList[t]}],
 {t, AbsoluteTime[{2014,1,1}], AbsoluteTime[{2015,1,1}], 3600}];

t[n_] := Sum[((i-4381)/4380)^n*mdec2[[i]],{i,1,Length[mdec2]}];

Table[t[i],{i,1,125}]*Table[t^i,{i,1,125}]

(* data packing *)

(* coeffs = Partition[coeffs,14]; *)

cheb2truetay = CoefficientList[Sum[a[i+1]*ChebyshevT[i,x],{i,0,ncoeff-1}],x]

(* with Mercury data loaded *)

(* mercury = Partition[coeffs,14]; *)

(* below for moon compared to earth *)

planet = Partition[coeffs,ncoeff];

newcoff = Table[cheb2truetay /. a[n_] -> planet[[i,n]],{i,1,Length[planet]}];

(* decimeter-level precision *)
newcoff2 = Round[1000000*newcoff];

new2 = Partition[Flatten[newcoff2],ncoeff*3];

new2 = Transpose[new2];

test3 = Table[{i,1+2*Max[Abs[new2[[i]]]]}, {i,1,Length[new2]}]

Table[Ceiling[Log[test3[[i,2]]]/Log[256]], {i,1,Length[test3]}]

(* bytes required given precision level:

km: 78 bytes
m: 129 bytes
dm: 147 bytes
cm: 164 bytes
mm: 179 bytes
um: 233 bytes

*)

(* Earth pos *)

(* moongeo.m and earthmoon.m loaded *)

earthmoon = Partition[Partition[earthmoon,13],3];
moongeo = Partition[Partition[moongeo,13],3];

earthmoon[[23394]][[1]]
moongeo[[23394]][[1]]


(* Chebyshev to Taylor *)

cheb[x_] = Sum[c[i+1]*ChebyshevT[i,x],{i,0,13}]
taylor = Table[t^i,{i,0,13}]

temp1[a_,b_] = CoefficientList[cheb[a+frac*(b-a)],frac]

random = Table[Random[],{i,1,14}]

rand1[x_] = cheb[x] /. c[i_] -> random[[i]]

Plot[rand1[x],{x,-1,1}]

(* The Taylor series for the right hand side *)

rand2[t_] = Total[(temp1[0.4,0.6] /. c[i_] -> random[[i]])*taylor]

Plot[rand2[t],{t,0,1}]

(* TODO: assuming a and b are global below, fix *)

(* parametric ellipse *)

a = 2; b = 1;

(* below parametrizes an ellipse but NOT by angle, as we shall see *)

x[t_] = a*Cos[t]
y[t_] = b*Sin[t]
focus[a_,b_] = Sqrt[a^2-b^2]


(* the ellipse, top right part *)
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


Graphics[TeXForm[Text[Style["b*Sin[t]", FontSize->25]], {0,0}, {-1.1,0}]]
 
(* area from focus, less eccentric ellipse here *)
g3 = {
 Line[{{focus[a,b],0},{x[samp],y[samp]}}],
 Circle[{focus[a,b],0}, 1/20, {0, ArcTan[x[samp]-focus[a,b],y[samp]]}],
 Dashing[0.01], 
 Line[{{x[samp],0},{x[samp],y[samp]}}], 
 Line[{{0,y[samp]},{x[samp],y[samp]}}],
 Text[Style["b*Sin[t]", FontSize->25], {x[samp], y[samp]/2}, {-1.1,0}],
 Text[Style["a*Cos[t]", FontSize->25], {x[samp]/2, y[samp]}, {0,-1.1}],
 Text[Style["\[Theta]", FontSize->25], {focus[a,b],0.05}, {-1,-1}]
} 
 
Show[g1,Graphics[g3]]
showit

(* we see than tan(theta) = (b*Sin[t])/(a*Cos[t]), solving for t *)

(* Mathematica solves below poorly, so doing my own formula *)

(* Solve[Tan[theta] == (b*Sin[t])/(a*Cos[t]), t] *)

t[theta_] = ArcTan[a*Tan[theta]/b]

(* We can now reparametrize *)
x[theta_] = a*Cos[t[theta]]
y[theta_] = b*Sin[t[theta]]

(* We now have y[theta]/x[theta] == Tan[theta], as desired *)

(* the radius squared at theta *)
r2[theta_] = x[theta]^2 + y[theta]^2

(* this takes forever to compute, so hardcoding it after getting result *)

(* parea[theta_] = Integrate[r2[x]/2,{x,0,theta}] *)

parea[theta_] = a*b*ArcTan[a*Tan[theta]/b]/2

a = 2; b = 1;
ParametricPlot[{x[t],y[t]} /. {a->2,b->1},{t,0,Pi/2}]



Solve[Tan[theta] == (b*Sin[t])/(a*Cos[t]), theta]
Solve[Tan[theta] == (b*Sin[t])/(a*Cos[t]), theta, Reals]


(* +-Sqrt[3] are really focii? yup! *)

Sqrt[(x[t]-Sqrt[3])^2 + y[t]^2] + Sqrt[(x[t]+Sqrt[3])^2 + y[t]^2]


(* try drawing the problem out a bit *)


g2 = Labeled[Point[{{0,0}, {Sqrt[3],0}, {-Sqrt[3],0}}], "foo"]

g3 = Labeled[Point[{0,0}], Text["foo"]]

Show[g1,Graphics[g2]]

(* polar coordinates area from origin *)

parea[t_] = Integrate[(x[theta]^2+y[theta]^2)/2, {theta,0,t}]

(* area from focus is area from center minus triangle *)

area[t_] = parea[t] - y[t]*Sqrt[a^2-b^2]/2

Normal[InverseSeries[Series[parea[t], {t,0,15}]]]

(* below is unrelated *)

r*Sin[theta] == Exp[(-r*Cos[theta])^2]

Log[r] + Log[Sin[theta]] == (-r*Cos[theta])^2



(* t, given x or y [top half of ellipse only] *)

tx[x_] = ArcCos[x/a]
ty[y_] = ArcSin[y/b]

(* y given x *)

yofx[x_] = y[tx[x]]

(* area swept out from center *)

(* triangle part *)

triarea[t_] = x[t]*y[t]/2

(* rest *)

(* need general intgrl here, Mathematica is bad about definite integral here *)

f[x_] = Integrate[yofx[x],x]

restarea[t_] = FullSimplify[f[a] - f[x[t]], Member[{a,b,t}, Reals]]

(* below is just abt/2, wow! *)

totalarea[t_] = FullSimplify[triarea[t] + restarea[t], Member[{a,b,t},Reals]]

(* these simplifications only apply sometimes, but ... *)

totalarea[t] /. {Sqrt[Sin[t]^2] -> Sin[t]}

(* area from focus is area from center minus triangle *)

areafromfocus[t_] = a*b*t/2 - y[t]*Sqrt[a^2-b^2]/2

areafromfocus'[t]
areafromfocus''[t]
areafromfocus'''[t]
areafromfocus''''[t]
areafromfocus'[t]/areafromfocus'''[t]

Plot[areafromfocus[t]/t /. {a->1.1, b->1}, {t, 0, Pi}]

Solve[Normal[Series[areafromfocus[t]/t, {t, 0, 3}]]==c, t]

Solve[Normal[Series[areafromfocus[t]/t, {t, 0, 5}]]==c, t]

Solve[Normal[Series[areafromfocus[t]/t, {t, 0, 7}]]==c, t]

Solve[areafromfocus[t] == c, t]



(* confirms area of ellipse, top half *)
Integrate[yofx[x],{x,-a,a}]



(* the x value of the rightmost focus *)
(* this can only work when a >= b? *)

focus[a_,b_] = Sqrt[a^2-b^2]

(* angle theta from rightmost focus *)

Solve[ theta == ArcTan[a*Cos[t]/b*Sin[t]], t, Reals]

(* area of triangle connecting rightmost focus to ellipse *)

area[t_] = (x[t]-focus[a,b])*y[t]

(* quadrant specific below *)

yofx[x_] = b*Sin[ArcCos[x/a]]

curvearea[t_] := Integrate[yofx[x],{x, x[t], x[0]}]

totalarea[t_] := curvearea[t] + area[t]



f[t_]=Sqrt[(x[t]-focus[a,b])^2 + y[t]^2] + Sqrt[(x[t]+focus[a,b])^2 + y[t]^2]-4

FullSimplify[f[t], {Element[t,Reals]}]


ParametricPlot[{x[t],y[t]},{t,0,2*Pi}]

d[t_] = Sqrt[(x[t]+x0)^2 + y[t]^2] + Sqrt[(x[t]-x0)^2 + y[t]^2]

d[t] /. {x1 -> -x0, y0 -> 0, y1 -> 0}






ParametricPlot[{x[t],y[t]},{t,0,2*Pi},AspectRatio->Automatic]


(* based on the output of bc-read-cheb.pl for mercury x values 2014 *)

(* this is the file with the output of bc-read-cheb.pl *)
<</tmp/math.m

jds = mercury[x][1][[1]]
jde = mercury[x][48][[2]]

(* the first 2 list elts are start/end Julian date *)

tab = Table[Function[t,Evaluate[
Sum[mercury[x][i][[n]]*ChebyshevT[n-3,t], {n,3,Length[mercury[x][i]]}]]],
{i,1,48}]

(* continous Fourier? *)

f3[k_] = Integrate[tab[[1]][t]*Exp[2*Pi*I*k*t],{t,-1,1}]
maxk = k /. Maximize[Abs[f3[k]],k][[2]]



Plot[tab[[1]][t]/Cos[


(* trivial function that converts a number from [s,e] to [-1,1] *)
f1[t_,s_,e_] = 2*(t-s)/(e-s)-1
(* its inverse: [-1,1] to [s,e] *)
f2[t_,s_,e_] = s + (t+1)*(e-s)/2

g[t_] = Piecewise[
Table[{tab[[i]][f1[t,mercury[x][i][[1]],mercury[x][i][[2]]]], 
 mercury[x][i][[1]] <= t <= mercury[x][i][[2]]}, {i,1,Length[tab]}]
]

Plot[g[t],{t,jds,jde}]

<</home/barrycarter/BCGIT/MATHEMATICA/cheb1.m

(* coeffs stretched to length 15 (my fault when writing cheb1) *)

chebcoff[n_] := PadRight[Take[mercury[x][n], {3,16}],15]

(* combining in pairs *)

t3 = Table[Take[cheb1[chebcoff[i],chebcoff[i+1]],14],{i,1,47,2}]

t4 = Table[{list2cheb[t3[[i]]][
 f1[t, mercury[x][i*2-1][[1]], mercury[x][i*2][[2]]]
],
 mercury[x][i*2-1][[1]] <= t <= mercury[x][i*2][[2]]}, {i,1,Length[t3]}]

k[t_] = Piecewise[t4]

Plot[k[t]-g[t],{t,jds,jde},PlotRange->All]

(* intentionally chopping at 14, though cheb1 gives 30 *)

test1[x_] = list2cheb[Take[cheb1[chebcoff[1],chebcoff[2]],14]]

test2[x_] = test1[f1[x,jds,jds+16]]

Plot[{test2[x]-g[x]},{x,jds,jds+16}]

PadRight[mercury[x][1],15]
PadRight[mercury[x][2],15]

Plot[{tab[[1]][t*2-1],tab[[2]][t*2+1]},{t,-1,1}]
showit

f[t_] = Piecewise[{{tab[[1]][t], t <= 1}, {tab[[2]][t-2], t > 1}}]
Plot[f[x],{x,-1,3}]
showit

g[t_] = Piecewise[Table[{tab[[i]][t+2-2*i], t < -1 + 2*i},{i,1,Length[tab]}]]

Plot[g[t],{t,-1,95}]
