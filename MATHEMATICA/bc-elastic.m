(*

Elastic collisions and trains

*)

(* If an object with mass m1 and velocity v1 collides elastically with
an object of mass m2 and velocity v2, what are the velocities of the
two objects (u1 and u2) after the collision *)

colspeed[m1_,m2_,v1_,v2_] = {u1,u2} /. Solve[{
 m1*v1 + m2*v2 == m1*u1 + m2*u2,
 m1*v1^2/2 + m2*v2^2/2 == m1*u1^2/2 + m2*u2^2/2,
 u1 != v1, u2 != v2
}, {u1,u2}][[1]]

colspeed[mb, mt, -vb, vt]

vb2 = colspeed[mb, mt, vb, vt][[1]]

colspeed[mb, mt, vb2, -vt]






