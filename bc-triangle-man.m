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

(* Re and Im here is ugly! *)

Solve[{
 Re[line[z1,z2][t]] == Re[line[z3,z4][u]], 
 Im[line[z1,z2][t]] == Im[line[z3,z4][u]]
}, {u,t}, Reals]

(* generic *)

Solve[z1 + t*z2 == z3 + u*z4, {t,u}]

Solve[

Solve[{
Re[z1 + t*z2] == Re[z3 + u*z4],
Im[z1 + t*z2] == Im[z3 + u*z4]},
{t,u}, Reals]

Solve[{
Re[z1] + t*Re[z2] == Re[z3] + u*Re[z4],
Im[z1] + t*Im[z2] == Im[z3] + u*Im[z4]},
{t,u}]

Solve[{
z1r + t*z2r == z3r + u*z4r,
z1i + t*z2i == z3i + u*z4i},
{t,u}, Reals]

Solve[{line[z1,z2][t] == line[z3,z4][u], Im[t]==0, Im[u]==0},
 {t,u}]

Solve[line[z1,z2][t] == line[z3,z4][u], t]

Eliminate[line[z1,z2][t] == line[z3,z4][u], t]








I + 3t and -t-tI

I + 3*(t /. Flatten[Solve[I + 3t == -u-u*I,{t,u},Reals]])

Solve[I + 3t == -u-u*I,{t},Reals]

intersect[line1_,line2_] = Solve[line1[z][t] == line2[z][u]]

line[0,(z+1)/2]
line[1,z/2]

Solve[line[0,(z+1)/2][t] == line[1,z/2][u]]

Solve[sidea[test][t] == sideb[test][u]]

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




