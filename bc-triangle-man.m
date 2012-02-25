showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* An attempt to find all quantities for a given unscaled triangle in
free space *)

(* Given any unscaled triangle in free space, you can resize it,
reflect it and place it on the complex plane such that two vertices
are 0 and 1, and the other point is z (where Re(z) and Im(z) are both
nonnegative. We therefore let z 'define' the triangle in question *)

(* Reference triangle: triangle-in-complex-plane.png *)

(* Sample triangle: 1/6 + 3/5*i, sort of like reference triangle *)

(* the angles *)

anglea[z_] = Arg[z]
angleb[z_] = -Arg[1-z]
anglec[z_] = Pi + Arg[1-z] - Arg[z]

(* the side lengths *)

lenc[z_] = 1
lenb[z_] = Abs[z]
lena[z_] = Abs[1-z]

(* general helpful formulas *)

(* parametric equation of line in complex plane given two points *)

line[z1_,z2_] = Function[z1 + #1*(z2-z1)]

(* intersection of two lines, by 4 points *)
(* Re and Im here is ugly! *)

intersectionbypts[z1_,z2_,z3_,z4_] = z1 + (z2-z1)*
(t /. Flatten[Solve[{
 Re[z1] + t*(Re[z2] - Re[z1]) ==  Re[z3] + u*(Re[z4] - Re[z3]),
 Im[z1] + t*(Im[z2] - Im[z1]) ==  Im[z3] + u*(Im[z4] - Im[z3])},
{t,u}]])

(* intersection of lines by formula *)

intersect[line1_, line2_] =
intersectionbypts[line1[0],line1[1],line2[0],line2[1]]

test1[line1_, line2_] = {line1[0],line1[1],line2[0],line2[1]}

intersectionbypts[sidea[test][0],sidea[test][1],sideb[test][0],sideb[test][1]]
intersect[sidea[test],sideb[test]]

(* line perpindicular to given line, going through given point *)

perpin[line_, p_] = Function[t, p + (1 + I*Tan[Arg[line[0] - line[1]]+Pi/2])*t]

(* nonworking code alpha starts here 

(* icky special case for vertical lines, not working *)

perpin[line_, p_] = Function[t, p + (line[1]-line[0])*t] /; 
 Member[(line[1]-line[0])/I, Reals]

nonworking code alpha ends here *)

(* the side formulas *)

sidea[z_] = line[1,z]
sideb[z_] = line[0,z]
sidec[z_] = line[0,1]

(* medians, formulas *)

meda[z_] = line[0,(z+1)/2]
medb[z_] = line[1,z/2]
medc[z_] = line[z,1/2]

(* medians, length *)

medalen[z_] = Abs[(1+z)/2]
medblen[z_] = Abs[1-z/2]
medclen[z_] = Abs[z-1/2]

(* centroid, calculated 3 different ways, agree; final one is super-simple form *)

centroid1[z_] = intersect[meda[z],medb[z]]
centroid2[z_] = intersect[meda[z],medc[z]]
centroid3[z_] = intersect[medb[z],medc[z]]
centroid[z_] = Simplify[centroid3[z]]

(* point where perpindicular hits opposite side *)
intersect[perpin[sidea[z],0],sidea[z]]

(* altitudes scaled so t=1 hits opposite edge *)

alta[z_] = line[0, intersect[perpin[sidea[z],0],sidea[z]]]
altb[z_] = line[1, intersect[perpin[sideb[z],1],sideb[z]]]

(* TODO: dislike having below as special case! *)
altc[z_] = line[z, Re[z]]

(* orthocenter *)

orthocenter1[z_] = Simplify[intersect[alta[z],altb[z]]]
orthocenter2[z_] = Simplify[intersect[alta[z],altc[z]]]
orthocenter3[z_] = Simplify[intersect[altb[z],altc[z]]]

orthocenter[z_] = Simplify[ComplexExpand[orthocenter3[z], {z}]]

Simplify[orthocenter[z], {Im[z]>0,Re[z]>0}]

Simplify[Cot[Arg[z]], {Im[z]>0, Re[z]>0}]

(* below is testing only, Cot + Tan aren't always inverse functions *)

orthocenter[z] //. {Arg[z_] -> Tan[Im[z]/Re[z]], Cot[Tan[z_]] -> z}

(* tests on sample triangle *)

test = 1/6+3/5*I

(* useful graphics *)

plotline[line_, style_:{}] :=
 ParametricPlot[{Re[line[t]],Im[line[t]]}, {t,0,1}, PlotStyle -> style]

(* test code below is commented out

centroid1[test]
centroid2[test]
centroid3[test]

N[anglea[test]/Degree]
N[angleb[test]/Degree]
N[anglec[test]/Degree]

N[lena[test]]
N[lenb[test]]
N[lenc[test]]

perpin[sidea[test], 0]

plotline[perpin[sidea[test],0], Red]

(* everything w color scheme; red medians; blue alts *)

Show[{
 plotline[sidea[test],{Black,Thick}],
 plotline[sideb[test],{Black,Thick}],
 plotline[sidec[test],{Black,Thick}], 
 plotline[meda[test],{Red,Thick}],
 plotline[medb[test],{Red,Thick}],
 plotline[medc[test],{Red,Thick}],
 plotline[alta[test],{Blue,Thick}],
 plotline[altb[test],{Blue,Thick}],
 plotline[altc[test],{Blue,Thick}]
}, PlotRange-> All, AxesOrigin -> {0,0}]


(* testing color changes *)

Show[{plotline[sidea[test]], Graphics[Red], plotline[sideb[test]]}]

(* The 'Show' below forces all lines onto the same graph *)

Show[{plotline[alta[test]], plotline[altb[test]], plotline[altc[test]],
      plotline[sidea[test]], plotline[sideb[test]], plotline[sidec[test]]},
 PlotRange->All, AxesOrigin->{0,0}]

Show[{plotline[meda[test]], plotline[medb[test]], plotline[medc[test]]},
 {plotline[sidea[test]],plotline[sideb[test]],plotline[sidec[test]]},
 PlotRange->All, AxesOrigin->{0,0}]

Show[{plotline[sidea[test]], plotline[sideb[test]], plotline[sidec[test]]}, 
 PlotRange->All, AxesOrigin->{0,0}]

Show[{plotline[sidea[test]], plotline[sideb[test]], plotline[sidec[test]], 
 plotline[perpin[sidea[test],0]], 
 plotline[perpin[sideb[test],0]], 
 plotline[perpin[sidec[test],0]]}, 
 PlotRange->All, AxesOrigin->{0,0}]

test code above is commented out *)
