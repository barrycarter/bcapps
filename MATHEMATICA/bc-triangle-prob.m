(*

Using bc-triangle-man.m to maybe solve:

http://math.stackexchange.com/questions/2104594/for-all-triangle-prove-that-sum-limits-cycm-a-cos-frac-alpha2-geq-frac3

*)

(* TODO: add theses to bc-triangle-man.m *)

area[z_] = Im[z]/2
cosa[z_] = Re[z]/lenb[z]
cosb[z_] = (1-Re[z])/lena[z]

(* NOTE: could probably also get this from (s-a)*(s-b)... formula *)

(* see where the altitude dropped from A intersects BC and measure
distance from C... then divide by b, the hypotenuse of the triangle *)

(* TODO: for symmetry, should I drop the altitude from B? *)

cosc[z_] = len[alta[z][1]-z]/lenb[z]



f[z_] = FullSimplify[
medalen[z]*Re[z]/lenb[z] + 
 medblen[z]*(1-Re[z])/lena[z] + 
 medclen[z]*Abs[z-alta[z][1]]/lenb[z] -
 3/4*(lena[z]+lenb[z]+lenc[z]),
 Element{z,Complexes}
]






Re[z]/b + 


FullSimplify[alta[z][1]]
