(*

TODO: consider publishing, but currently just a playground

we assume addition formula, dilation formula and all speeds as
fraction of light

ship is accelerating at "a", and 1 beacon every 1/n seconds that's a/n
faster than the previous one for t seconds

*)

m[v_]={{1/Sqrt[1 - v^2], v/Sqrt[1 - v^2]}, {v/Sqrt[1 - v^2], 1/Sqrt[1 - v^2]}};

RSolve[{
 trans[0] == m[0],
 trans[n+1] == m[v].trans[n]
}, trans[i], i]

rs = RSolve[{
 mat00[0] == 1, mat10[0] == 0, mat01[0] == 0, mat11[0] == 1,
 mat00[i+1] == (mat00[i] + mat01[i]*v)/Sqrt[1-v^2],
 mat10[i+1] == (mat10[i] + mat11[i]*v)/Sqrt[1-v^2],
 mat01[i+1] == (mat01[i] + mat00[i]*v)/Sqrt[1-v^2],
 mat11[i+1] == (mat11[i] + mat10[i]*v)/Sqrt[1-v^2]
}, {mat00[i], mat01[i], mat10[i], mat11[i]}, i]

rs2 = FullSimplify[rs, {v>0, i>0, Element[i,Integers]}]

mat[i_]=FullSimplify[{{mat00[i], mat10[i]}, {mat01[i], mat11[i]}} /. rs2[[1]],
 v>0]

orig = FullSimplify[mat[i].{t,0}]

origvel = FullSimplify[orig[[2]]/orig[[1]]]

nth = {(1 + (-1 + 2/(1 + v))^i)/(2*(-1 + 2/(1 + v))^(i/2)), 
 -(-1 + (-1 + 2/(1 + v))^i)/(2*(-1 + 2/(1 + v))^(i/2))}

sol = Solve[nth[[1]]==u,i][[1,1,2]]

simp1 = FullSimplify[nth /. i -> sol]

sol2 = Solve[nth[[1]]==u,v][[1,1,2]]

simp2 = FullSimplify[nth /. v -> sol2]

Sqrt[simp2[[1]]^2-1] - simp2[[2]]

dist[u_] = Sqrt[u^2-1]






addVelocity[u_, v_] = (u+v)/(1+u*v)

dilationFactor[v_] = Sqrt[1-v^2]

conds = {a>0, n>0, m>0, Element[{m,n}, Integers]}

(* velocity of mth beacon as measured from beacon 0 *)

velocity[m_,a_,n_] =  FullSimplify[v[m] /. 
RSolve[{v[0] == 0, v[m] == (a/n+v[m-1])/(1+a/n*v[m-1])}, v[m], m], conds][[1]]

(* time between mth and m+1st beacon drop based on time dilation, from
beacon 0 *)

timeBetween[m_,a_,n_] = FullSimplify[1/n/Sqrt[1-velocity[m,a,n]^2], conds]

(* distance ship travels between beacons m and m+1 *)

distanceTraveled[m_,a_,n_] = 
 FullSimplify[timeBetween[m,a,n]*velocity[m,a,n],conds]

(* time OF the mth drop *)

timeOf[m_,a_,n_] = FullSimplify[Sum[timeBetween[i,a,n],{i,0,m-1}],conds]

(* distance of mth beacon as measured from beacon 0; could not get this!!!

distance[m_,a_,n_] = FullSimplify[Sum[distanceTraveled[i,a,n],{i,0,n-1}], 
 conds]

*)

Solve[timeOf[n] == t, n, Reals]



