(* Revision of bc-triangle-man.m for arbitrary triangle with vertexs a b c *)

(* reference/sample triangle [changed to be acute later] *)

test1 = {3.49053 + 8.4664 I, 1.23971 + 1.47722 I, 8.58063 + 4.85151 I}

(* TODO: area, incenter, circumcenter; circles like incircle; add
labels; side alignment/order *)

(************ PLOTTING SECTION **********)

(* for plotting, convert complex number to pair *)

topair[z_] = {Re[z],Im[z]}
SetAttributes[topair, Listable]

(* plot "anything" *)

superplot[obj_,type_,extra_:{}]:=Graphics[Join[extra,{type[topair[obj]]}]]

(************* HELPER FUNCTIONS ***********)

(* slope of a complex line *)
line2slope[{a_,b_}] = (Im[b]-Im[a])/(Re[b]-Re[a])

(* given slope and point, construct line of arb length *)
slope2line[m_, p_] = {p, p+I*m+1}

(* point where two lines intersect [TODO: UGLY!] *)
intersection[{z1_,z2_},{z3_,z4_}] = z1 + (z2-z1)*
(t /. Flatten[Solve[{
 Re[z1] + t*(Re[z2] - Re[z1]) ==  Re[z3] + u*(Re[z4] - Re[z3]),
 Im[z1] + t*(Im[z2] - Im[z1]) ==  Im[z3] + u*(Im[z4] - Im[z3])},
{t,u}]])

(* function sending z1 to 0, z2 to 1, when applied to arb p + inverse *)
tonorm[z1_, z2_, p_] = (p-z1)/(z2-z1)
fromnorm[z1_, z2_, p_] = z1 + p*(z2-z1)

(* to find line perpendicular to line thru z1 z2, and thru p, we go to
and then from "normal" form above; line = two points *)
perpin[{z1_, z2_}, p_] = {fromnorm[z1, z2, Re[tonorm[z1,z2,p]]], p}

(* perpendicular to a,b through p even if p is on a,b *)
perpin2[{a_,b_}, p_] = slope2line[-1/line2slope[{a,b}], p]

(* given a list of lines, return their lengths (norms) *)
norms[list_] := Table[Norm[i[[2]]-i[[1]]], {i,list}]

(* given a list of lines, return mutual intersections [in hope of
finding simplest form for various triangle centers] *)

intersects[list_] := Flatten[FullSimplify[Table[intersection[
 list[[i]],list[[j]]], {i,1,Length[list]},{j,i+1,Length[list]}]]]

(* psuedo dot product of two complex numbers *)
dot[z1_, z2_] = Re[z1]*Re[z2] + Im[z1]*Im[z2]

(* cosine, as dot product over product of lengths *)
cos[z1_, z2_] = dot[z1,z2]/Norm[z1]/Norm[z2]

(* given a formula to generate a point in the 0,1,z space, generate
the lines that connect the equivalent points to B and then C *)

translates[f_] := FullSimplify[{
 {0,f[z]}, {1,fromnorm[1,z,f[tonorm[1,z,0]]]}, 
 {z,fromnorm[z,0,f[tonorm[z, 0, 1]]]}}]

(******** FUNCTIONS ON BASE TRIANGLE AND VARIANTS ********)

(* the translation of test1 *)

test2 = {0,1,tonorm[test1[[1]], test1[[2]], test1[[3]]]}

(* medians, in order *)

base1midpoint[z_] = (1+z)/2
base1medians[z_] = {{0,(1+z)/2}, {1,z/2}, {z, 1/2}}
base1centroid[z_] = (1+z)/3

(* perpendicular bisectors, in order, arb length; third case is
special since perpendicular bisector has inifinite slope *)

base1fakeperps[z_] = {perpin2[{1,z},(1+z)/2], perpin2[{0,z}, z/2],
 {1/2, 1/2+I}}
base1circumcenter[z_] = intersection[perpin2[{1,z},(1+z)/2],{1/2, 1/2+I}]

(* altitudes and orthocenter, in order *)
base1altitude[z_] = perpin[{1,z}, 0][[1]]
base1altitudes[z_] = {perpin[{1,z},0], perpin[{0,z}, 1], perpin[{0,1},z]}
base1orthocenter[z_] = intersection[perpin[{1,z},0], perpin[{0,z}, 1]]

(* angle bisectors and incenter *)

cos[z,1]


(* angle bisector/trisector/etc at origin of 0,1,z *)

intersection[{0, 1+I*Tan[Arg[z]/2]}, {1,z}]
intersection[{0, 1+I*Tan[Arg[z]/3]}, {1,z}]
intersection[{0, 1+I*Tan[Arg[z]/4]}, {1,z}]




(* intersection of the perpendicular bisector with opposite sides *)

intersection[{1/2, 1/2+I}, {0,c}]
intersection[{1/2, 1/2+I}, {1,c}]



fromnorm[a,b,1/2]

(*********** ACTUAL FUNCTIONS **********)

(* line segments that make up this triangle *)
segments[{a_,b_,c_}] = {{a,b},{b,c},{c,a}}

(* altitudes *)
alts[{a_,b_,c_}] = {perpin[{b,c},a], perpin[{a,c},b], perpin[{a,b},c]}

(* orthocenter *)
orthocenter[{a_,b_,c_}] = intersection[alts[{a,b,c}][[1]], alts[{a,b,c}][[2]]]

(* medians *)
medians[{a_,b_,c_}] = {{a,(b+c)/2}, {b,(a+c)/2}, {c,(a+b)/2}}

(* centroid *)
centroid[{a_,b_,c_}] = Mean[{a,b,c}]

(* if we map AB to 0,1 Arg[c] gives us the angle *)
angles[{a_,b_,c_}] = Arg[{tonorm[a,b,c], tonorm[b,c,a], tonorm[c,a,b]}]

(* the perpendicular bisectors, sort of, TODO: how long to draw these? *)
perbis[{a_,b_,c_}] = {perpin2[{a,b},(a+b)/2], perpin2[{b,c}, (b+c)/2],
perpin2[{a,c}, (a+c)/2]}

(* the circumcenter *)
circumcenter[{a_,b_,c_}] = intersection[
 perbis[{a,b,c}][[1]],  perbis[{a,b,c}][[2]]
]

(* angle bisector of 0,1,c [end point, other pt is 0], not scaled! *)

f3[{a_,b_,c_}] = {a,fromnorm[a,b,1 + I*Tan[Arg[tonorm[a,b,c]]/2]]}

bisectors[{a_,b_,c_}] = {f3[{a,b,c}], f3[{b,a,c}], f3[{c,a,b}]}

incenter[{a_,b_,c_}] = intersection[bisectors[{a,b,c}][[1]], 
 bisectors[{a,b,c}][[2]]]



(********* PLAYGROUND ********)

fromnorm[a,b,1/2]

Show[{
superplot[segments[test1], Line],
superplot[perbis[test1], Line, {Hue[.6]}],
superplot[medians[test1], Line, {Hue[.3]}],
superplot[bisectors[test1], Line]
}]

Show[{
superplot[segments[test1], Line],
superplot[alts[test1], Line, {Dashing[.008],Hue[1]}],
superplot[medians[test1], Line, {Hue[.3]}],
superplot[perbis[test1], Line, {Hue[.6]}],
superplot[circumcenter[test1], Point, {Hue[.4]}]
}]



perbis[{a_,b_,c_}] = 

f1[{a_,b_,c_}] = intersection[perpin2[{a,b},(a+b)/2], {a,c}]

f2[{a_,b_,c_}] = {(a+b)/2, f1[{a,b,c}]}

Show[{
superplot[segments[test1], Line],
superplot[f2[test1], Line]
}]




(* angles don't change under standardize *)

angles[{a_,b_,c_}] = {Arg[(a-c)/(a-b)], -Arg[(c-b)/(a-b)],
Pi+Arg[(c-b)/(a-b)]-Arg[(a-c)/(a-b)]}

(* side lengths, in order *)

lengths[{a_,b_,c_}] = Map[Norm,{b-c,c-a,a-b}]

(* TODO: for formulas below, provide derivation not just results *)

(********* DERIVATIONS (entire section intentionally commented out)

How some of the formulas above were derived

centroid[{a_,b_,c_}] = intersection[
 medians[{a,b,c}][[1]], medians[{a,b,c}][[2]]]












*********)
