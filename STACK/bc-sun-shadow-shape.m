(*

What is the shape of the shadow cast by the sun on a single point; not necessarily a circle of even an ellipse

TODO: consider refraction

sun = sphere centered at (-x, 0, z) with radius r (we choose axes so
y=0), consider only front "shell" of sphere, point is (0,0,1)

(* positive solution only, rest is "back of" Sun *)

s0824 = Solve[(px+x)^2 + py^2 + (pz-z)^2 == r^2, x][[2]]

conds = {Element[{px,py,pz}, Reals], r>0}

f[z_] = Solve[(px+x)^2 + py^2 + (pz-z)^2 == r^2, x][[2,1,2]]

valid for z in [-r,r]

above doesnt work, too many degrees of freedom

note, I define phi from xy plane so below is correct

{r*Cos[theta]*Cos[phi], r*Sin[theta]*Cos[phi], Sin[phi]}

front half is theta from -Pi/2 to Pi/2, Phi from -Pi to Pi

point[theta_,phi_] = {-x + r*Cos[theta]*Cos[phi], r*Sin[theta]*Cos[phi],
 z + Sin[phi]}

parametrizing a line between that and (0,0,1) is

line[theta_,phi_,p_] = 
{ p*(-x + r*Cos[theta]*Cos[phi]), p*r*Sin[theta]*Cos[phi],
  p*(z + Sin[phi])+ (1-p)}

where does this line hit xy plane?

p[z_,phi_] = Solve[p*(z + Sin[phi])+ (1-p) == 0, p][[1,1,2]]

line[theta,phi,p[z,phi]]

Table[Take[Out[91] /. {x -> -2, z -> 2, r -> 0.1},2], {theta,-Pi/2,Pi/
2,.01}, {phi,-Pi,Pi,.01}]                                                       

TODO: above is wrong, need to simplify and build this up



 






