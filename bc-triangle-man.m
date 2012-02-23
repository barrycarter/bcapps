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

(* tests on sample triangle *)

test = 1/6+3/5*I

N[anglea[test]/Degree]
N[angleb[test]/Degree]
N[anglec[test]/Degree]

N[lena[test]]
N[lenb[test]]
N[lenc[test]]






