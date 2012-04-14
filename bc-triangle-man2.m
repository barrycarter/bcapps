showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* Revision of bc-triangle-man.m for arbitrary triangle with vertexs a b c *)

(* reference/sample triangle *)

test1 = {6.8466 + 0.337819*I, 8.06793 + 5.60294*I, 5.18765 + 0.631612*I}

(* form for plotting; yes, there are better ways to do this *)

plot[{a_,b_,c_}] = {{Re[a],Im[a]},{Re[b],Im[b]},{Re[c],Im[c]}}

test1p = ListPlot[plot[test1], PlotJoined->True, PlotRange->All, AxesOrigin -> {0,0}]

(* transform triangle by translation t *)
transformt[{a_,b_,c_}, t_] = {a + t, b + t, c + t};

(* rotate a complex number about origin by r radians *)
transformr[z_, r_] = Exp[Arg[z]+r]*Abs[z]

(* transform triangle by rotation r radians around origin *)
transformr[{a_,b_,c_}, r_] = {transformr[a], transformr[b], transformr[c]}

(* scale a triangle compared to origin *)

transforms[{a_,b_,c_}, s_] = {a*s,b*s,c*s}

