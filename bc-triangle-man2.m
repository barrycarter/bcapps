showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* Revision of bc-triangle-man.m for arbitrary triangle with vertexs a b c *)

(* reference/sample triangle *)

test1 = {6.8466 + 0.337819*I, 8.06793 + 5.60294*I, 5.18765 + 0.631612*I}

(* form for plotting; yes, there are better ways to do this; note that a is repeated to get complete triangle *)

plotform[{a_,b_,c_}] = {{Re[a],Im[a]},{Re[b],Im[b]},{Re[c],Im[c]},{Re[a],Im[a]}}
plot[t_] := ListPlot[plotform[t], PlotRange->All,PlotJoined->True]

test1p = plot[test1]

(* transform triangle by translation t *)
transformt[{a_,b_,c_}, t_] = {a + t, b + t, c + t};

(* rotate a complex number about origin by r radians *)
transformr[z_, r_] = Exp[I*(Arg[z]+r)]*Abs[z]

(* transform triangle by rotation r radians around origin *)
transformr[{a_,b_,c_}, r_] = {transformr[a,r],transformr[b,r],transformr[c,r]}

(* scale a triangle compared to origin *)

transforms[{a_,b_,c_}, s_] = {a*s,b*s,c*s}

(* transform triangle to "standard form" (two points transform to 0
and 1, other dets triangle) *)

t1 = transformt[test1, -test1[[1]]]
t2 = transformr[t1, -Arg[t1[[2]]]]
t3 = transforms[t2, 1/Abs[t2[[2]]]]


plot[transformt[test1,-test1[[1]]]]

transformr[test1,-Arg[test1[[1]]]]

