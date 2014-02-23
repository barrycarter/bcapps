(* parametric ellipse *)

a = 2; b = 1;

(* TODO: assuming a and b are global below, fix *)

(* x and y pos at time t, increases linearlly with angle *)

x[t_] = a*Cos[t]
y[t_] = b*Sin[t]

(* +-Sqrt[3] are really focii? yup! *)

Sqrt[(x[t]-Sqrt[3])^2 + y[t]^2] + Sqrt[(x[t]+Sqrt[3])^2 + y[t]^2]


(* try drawing the problem out a bit *)

g1 = ParametricPlot[{x[t],y[t]},{t,0,2*Pi}]

g2 = Labeled[Point[{{0,0}, {Sqrt[3],0}, {-Sqrt[3],0}}], "foo"]

g3 = Labeled[Point[{0,0}], Text["foo"]]

Show[g1,Graphics[g2]]

(* polar coordinates area from origin *)

parea[t_] = Integrate[(x[theta]^2+y[theta]^2)/2, {theta,0,t}]

(* area from focus is area from center minus triangle *)

area[t_] = parea[t] - y[t]*Sqrt[a^2-b^2]/2

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
