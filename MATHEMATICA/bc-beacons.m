(*

TODO: consider publishing, but currently just a playground

we assume addition formula, dilation formula and all speeds as
fraction of light

we assume increase of dv every one time unit, but don't specify time
unit for now

*)

addVelocity[u_, v_] = (u+v)/(1+u*v)

dilationFactor[v_] = Sqrt[1-v^2]

addVelocity[dv,dv]

conds = {dv>0, n>0, dv<1, Element[n, Integers]}

(* velocity of nth beacon as measured from beacon 0 *)

velocity[n_] = 
FullSimplify[v[n] /. 
RSolve[{v[0] == 0, v[n] == (dv+v[n-1])/(1+dv*v[n-1])}, v[n], n][[1]],
conds]

(* time between nth and n+1st beacon drop based on time dilation, from
beacon 0 *)

timeBetween[n_] = FullSimplify[1/Sqrt[1-velocity[n]^2], conds]

(* distance ship travels between beacons n and n+1 *)

distanceTraveled[n_] = FullSimplify[timeBetween[n]*velocity[n],conds]

(* distance of nth beacon as measured from beacon 0; could not get this!!!

distance[n_] = FullSimplify[Sum[distanceTraveled[i],{i,0,n-1}], conds]

*)

(* time OF the nth drop *)

timeOf[n_] = FullSimplify[Sum[timeBetween[i],{i,0,n-1}],conds]

Solve[timeOf[n] == t, n, Reals]



