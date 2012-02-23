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

(* tests on sample triangle *)

test = 1/6+3/5*I

N[anglea[test]/Degree]
N[angleb[test]/Degree]
N[anglec[test]/Degree]

N[lena[test]]
N[lenb[test]]
N[lenc[test]]

(* useful graphics *)

plotline[line_] := ParametricPlot[{Re[line[t]],Im[line[t]]}, {t,0,1}]


(* The 'Show' below forces all lines onto the same graph *)

Show[{plotline[meda[test]], plotline[medb[test]], plotline[medc[test]]}]
Show[{plotline[sidea[test]], plotline[sideb[test]], plotline[sidec[test]]}, 
 PlotRange->All, AxesOrigin->{0,0}]




