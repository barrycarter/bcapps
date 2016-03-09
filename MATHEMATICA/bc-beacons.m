(*

TODO: consider publishing, but currently just a playground

we assume addition formula, dilation formula and all speeds as
fraction of light

ship is accelerating at "a", and 1 beacon every 1/n seconds that's a/n
faster than the previous one for t seconds

*)

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



