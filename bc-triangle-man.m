showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* An attempt to find all quantities for a given unscaled triangle in
free space *)

(* Given any unscaled triangle in free space, you can resize it,
reflect it and place it on the complex plane such that two vertices
are 0 and 1, and the other point is z (where Re(z) and Im(z) are both
nonnegative. We therefore let z 'define' the triangle in question * )

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

(* intersection of two lines *)

intersect[line1_,line2_] = 

line[0,(z+1)/2]
line[1,z/2]

Solve[line[0,(z+1)/2][t] == line[1,z/2][u]]


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

test1[line_] = Table[{Re[line[t]],Im[line[t]]}, {t,0,1,.1}]

ParametricPlot[{Re[line[t]],Im[line[t]]}, {t,0,1}] /. line -> meda[test]

plotline[meda[test]]

Table[{Re[meda[test][t]], Im[meda[test][t]]}, {t,0,1,0.1}]


