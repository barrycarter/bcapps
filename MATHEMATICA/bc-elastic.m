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

(* Our case: mass m1 and velocity v1 collides elastically with one
object of mass m2 at v2 and then another with mass m3 and velocity
v3; final velocities for all three objects *)

colspeed[m1,m2,v1,v2]

colspeed[m1, m3, colspeed[m1,m2,v1,v2][[1]], v3]

bouncespeed[m1_, m2_, m3_, v1_, v2_, v3_] = {

((m1 - m3)*(m1*v1 - m2*v1 + 2*m2*v2) + 2*(m1 + m2)*m3*v3)/((m1 + m2)*(m1 + m3))
,

(2*m1*v1 - m1*v2 + m2*v2)/(m1 + m2),

((2*m1*(m1*v1 - m2*v1 + 2*m2*v2))/(m1 + m2) - m1*v3 + m3*v3)/(m1 + m3)

};

(* sanity checking *)

bouncespeed[1, 1000, 1000, -10, 50, 50]

(* iteration *)

bs[m1_, m2_, m3_, v1_, v2_, v3_] = 
 Flatten[{m1, m2, m3, bouncespeed[m1, m2, m3, v1, v2, v3]}];

bs2[{m1_, m2_, m3_, v1_, v2_, v3_}] = 
 Flatten[{m1, m2, m3, bouncespeed[m1, m2, m3, v1, v2, v3]}];

iter[0] = bs[m1,m2,m3,v1,v2,v3];

iter[n_] := Apply[bs,iter[n-1]];

RSolve[{f[0] == bs[m1,m2,m3,v1,v2,v3],
       f[n] == Apply[bs,f[n-1]]}, f[n], n]


RSolve[{f[0] == {m1,m2,m3,v1,v2,v3},
       f[n] == bs2[f[n-1]]}, f[n], n]


(* example Rsolve "error" *)









