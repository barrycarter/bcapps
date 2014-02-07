(* Revision of bc-triangle-man.m for arbitrary triangle with vertexs a b c *)

(* reference/sample triangle *)

test1 = {6.8466 + 0.337819*I, 8.06793 + 5.60294*I, 5.18765 + 0.631612*I}

(* generic formulas for lines in complex space *)

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


