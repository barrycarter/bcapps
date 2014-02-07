(* Revision of bc-triangle-man.m for arbitrary triangle with vertexs a b c *)

(* reference/sample triangle [changed to be acute later] *)

test1 = {3.49053 + 8.4664 I, 1.23971 + 1.47722 I, 8.58063 + 4.85151 I}

(* TODO: area, incenter, circumcenter; circles like incircle; add
labels; side alignment/order *)

(* plotting *)

(* solely for plotting, convert complex number to pair *)

topair[z_] = {Re[z],Im[z]}
SetAttributes[topair, Listable]

plotpoint[z_,extra_:{}]:=Graphics[Join[extra, {Point[topair[z]]}]]

(* plot "anything", failed *)

superplot[obj_, type_, extra_:{}] := Module[{xy},
(* xy = Map[topair, {obj}, 2]; *)
 Graphics[type[topair[obj]]]
(* Graphics[Flatten[{extra, type[xy]},1]] *)
]

(* line segments that make up this triangle *)

segments[{a_,b_,c_}] = {{a,b},{b,c},{c,a}}

superplot[segments[test1], Polygon]

superplot[segments[test1], Line]

superplot[test1,Polygon, {Hue[1], Hue[.5]}]

superplot[test1,Point]

superplot[test1,Line]




(* plot a single point *)

plotpoint[z_, style_:{}] := Graphics[Flatten[{style, Point[topair[z]]}, 1]]

(* plotting a line (segment) between two points in the complex plane *)

plotline[{z1_,z2_},style_:{}] := ParametricPlot[topair[z1+t*(z2-z1)], {t,0,1},
AspectRatio->Automatic, AxesOrigin->{0,0}, PlotRange->All, PlotStyle->style]

(* plotting multiple lines *)

plotlines[list_,style_:{}] := Show[Table[Apply[plotline,{i,style}],{i,list}]]

(* plotting a triangle *)

plottri[{a_,b_,c_},style_:{}] := plotlines[{{a,b},{b,c},{c,a}}, style]

(* slope of a complex line *)

line2slope[{a_,b_}] = (Im[b]-Im[a])/(Re[b]-Re[a])

(* given slope and point, construct line of arb length *)

slope2line[m_, p_] = {p, p+I*m+1}

(* perpendicular to a,b through p even if p is on a,b *)

perpin2[{a_,b_}, p_] = slope2line[-1/line2slope[{a,b}], p]

(* point where two lines intersect [TODO: UGLY!] *)

intersection[{z1_,z2_},{z3_,z4_}] = z1 + (z2-z1)*
(t /. Flatten[Solve[{
 Re[z1] + t*(Re[z2] - Re[z1]) ==  Re[z3] + u*(Re[z4] - Re[z3]),
 Im[z1] + t*(Im[z2] - Im[z1]) ==  Im[z3] + u*(Im[z4] - Im[z3])},
{t,u}]])



perbis[{a_,b_,c_}] = {perpin2[{a,b},(a+b)/2], perpin2[{b,c}, (b+c)/2],
 perpin2[{a,c}, (a+c)/2]}

Show[{
plottri[test1],
plotlines[perbis[test1], {Black}]
}]

Reduce[Re[p0+m1*t] == Re[p1+m2*u], {u,t}]


(* altitudes (TODO: move this to main section later) *)

alts[{a_,b_,c_}] = {perpin[{a,c},b], perpin[{b,c},a], perpin[{a,b},c]}

(* medians (TODO: move to main section later) *)

medians[{a_,b_,c_}] = {{a,(b+c)/2}, {b,(a+c)/2}, {c,(a+b)/2}}

(* below fails because its a single point *)



Show[{
plottri[test1],
plotlines[alts[test1], {Black}],
plotlines[medians[test1], {Red}]
}]

{plotline[perpin[Take[test1,2], test1[[3]]]],
plotline[Take[test1,2]]}



ParametricPlot[topair[test1[[1]]+t*(test1[[2]]-test1[[1]])], {t,0,1}]



(* generic formulas for lines in complex space *)

(* function sending z1 to 0, z2 to 1, when applied to arb p + inverse *)
tonorm[z1_, z2_, p_] = (p-z1)/(z2-z1)
fromnorm[z1_, z2_, p_] = z1 + p*(z2-z1)

(* to find line perpendicular to line thru z1 z2, and thru p, we go to
and then from "normal" form above; line = two points *)

perpin[{z1_, z2_}, p_] = {fromnorm[z1, z2, Re[tonorm[z1,z2,p]]], p}

perpin[test1[[1]], test1[[2]], test1[[3]]]





(* parametric equation of line in complex plane given two points *)
line[z1_,z2_] = Function[z1 + #1*(z2-z1)]

(* intersection of two lines defined by four points *)

d1[t_,u_] = Norm[line[z1,z2][t] - line[z3,z4][u]]

Solve[line[z1,z2][t] == line[z3,z4][u], {}, 
 {Member[u,Reals],Member[t,Reals]}]

Solve[line[z1,z2][t] == line[z3,z4][u], {u,t}, Reals]

(* form for plotting; yes, there are better ways to do this; note that a is repeated to get complete triangle *)

plotform[{a_,b_,c_}]={{Re[a],Im[a]},{Re[b],Im[b]},{Re[c],Im[c]},{Re[a],Im[a]}}

plot[t_] := ListPlot[plotform[t],
 PlotRange->All,PlotJoined->True,AspectRatio->Automatic,AxesOrigin->{0,0}]

(* transformation converting a,b,c to 0,1,something , when applied to arb p *)

standardize[p_, {a_,b_,c_}] = (a-p)/(a-b)

(* reverse transformation *)

revert[p_, {a_,b_,c_}] = a-p*(a-b)

(* angles don't change under standardize *)

angles[{a_,b_,c_}] = {Arg[(a-c)/(a-b)], -Arg[(c-b)/(a-b)],
Pi+Arg[(c-b)/(a-b)]-Arg[(a-c)/(a-b)]}

(* side lengths, in order *)

lengths[{a_,b_,c_}] = Map[Norm,{b-c,c-a,a-b}]

(* TODO: for formulas below, provide derivation not just results *)

(* TODO: this is ugly, find better form? *)

intersectlines[z1_, z2_, z3_, z4_] =
  (z2*(-z3 + z4)*Conjugate[z1] + z1*(z3 - z4)*Conjugate[z2] + 
  (z1 - z2)*(z4*Conjugate[z3] - z3*Conjugate[z4]))/
  (-((z3 - z4)*(Conjugate[z1] - Conjugate[z2])) + 
  (z1 - z2)*(Conjugate[z3] - Conjugate[z4]))

(* Given two points forming a line, form the perpendicular line through p *)

perpin[z1_, z2_, p_] = Function[t, p + t - I t Cot[Arg[z1 - z2]]]

(* the altitudes *)

d1 = perpin[test1[[3]], test1[[1]], test1[[2]]]

Show[{plot[test1], ParametricPlot[{Re[d1[t]],Im[d1[t]]}, {t,-1,0}]}]


