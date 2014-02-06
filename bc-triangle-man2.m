(* Revision of bc-triangle-man.m for arbitrary triangle with vertexs a b c *)

(* reference/sample triangle *)

test1 = {6.8466 + 0.337819*I, 8.06793 + 5.60294*I, 5.18765 + 0.631612*I}

(* form for plotting; yes, there are better ways to do this; note that a is repeated to get complete triangle *)

plotform[{a_,b_,c_}]={{Re[a],Im[a]},{Re[b],Im[b]},{Re[c],Im[c]},{Re[a],Im[a]}}

plot[t_] := ListPlot[plotform[t],
 PlotRange->All,PlotJoined->True,AspectRatio->Automatic]

(* transform triangle by translation t *)
transformt[{a_,b_,c_}, t_] = {a + t, b + t, c + t};

(* rotate a complex number about origin by r radians *)
transformr[z_, r_] = Exp[I*(Arg[z]+r)]*Abs[z]

(* transform triangle by rotation r radians around origin *)
transformr[{a_,b_,c_}, r_] = {transformr[a,r],transformr[b,r],transformr[c,r]}

(* scale a triangle compared to origin *)

transforms[{a_,b_,c_}, s_] = {a*s,b*s,c*s}

(* transformation converting a,b,c to 0,1,[point], when applied to arb point *)

standardize[p_, {a_,b_,c_}] = transformr[p-a, -Arg[b-a]]/Abs[b-a]

(* reverse transformation *)

revert[p_, {a_,b_,c_}] = transformr[p*Abs[b-a], Arg[b-a]] + a

(* angles don't change under standardize *)

angles[{a_,b_,c_}] = {Arg[standardize[c,{a,b,c}]], 
 -Arg[1-standardize[c,{a,b,c}]],  
 Pi + Arg[1-standardize[c,{a,b,c}]] - Arg[standardize[c,{a,b,c}]]}








(* transform triangle to "standard form" (two points transform to 0
and 1, other dets triangle) *)

t1 = transformt[test1, -test1[[1]]]
t2 = transformr[t1, -Arg[t1[[2]]]]
t3 = transforms[t2, 1/Abs[t2[[2]]]]

transformt[{a,b,c}, -a]
transformr[%, -Arg[%[[2]]]]
transforms[%, 1/Abs[%[[2]]]]

plot[transformt[test1,-test1[[1]]]]

transformr[test1,-Arg[test1[[1]]]]

(* vectors representing the sides *)

vectors[{a_,b_,c_}] = {b-c, c-a, a-b}

(* side lengths, in order *)

lengths[tri_] = Abs[vectors[tri]]

(* dot product when imaginary numbers are vectors *)

dot[x_,y_] = Re[x]*Re[y] + Im[x]*Im[y]

(* and angle *)

angle[x_,y_] = ArcCos[dot[x,y]/Abs[x]/Abs[y]]

(* the angles [in order A B C] *)

angles[tri_] = angle[vectors[tri]]

test1p = plot[test1]

