(* geodesics using planes *)


(*

Claim: any great circle plane is z = ax + by because 0,0,0 must be in plane.

*)

(* theta is longitude here *)

xyz1 = sph2xyz[{theta1, phi1, 1}]
xyz2 = sph2xyz[{theta2, phi2, 1}]

Solve[{
 a*xyz1[[1]] + b*xyz1[[2]] == xyz1[[3]],
 a*xyz2[[1]] + b*xyz2[[2]] == xyz2[[3]]
}, {a,b}, Reals]

conds = {-Pi <= theta1 <= Pi, -Pi <= theta2 <= Pi, -Pi/2 <= phi1 <= Pi/2,
 -Pi/2 <= phi2 <= Pi/2};



