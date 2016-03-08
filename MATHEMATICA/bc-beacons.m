(*

TODO: consider publishing, but currently just a playground

we assume addition formula and all speeds as fraction of light

*)

addVelocity[u_, v_] = (u+v)/(1+u*v)

dilationFactor[v_] = Sqrt[1-v^2]

addVelocity[dv,dv]

conds = {dv>0, dt>0, n>0, dv<1, Element[n, Integers]}

(* velocity of nth beacon as measured from beacon 0 *)

velocity[n_] = 
FullSimplify[v[n] /. 
RSolve[{v[0] == 0, v[n] == (dv+v[n-1])/(1+dv*v[n-1])}, v[n], n][[1]],
conds]

(* distance of nth beacon as measured from beacon 0 *)

distance[n_] = FullSimplify[Sum[velocity[i]*dt,{i,0,n}], conds]

(* time between nth and n+1st beacon drop based on time dilation, from
beacon 0 *)

timeBetween[n_] = FullSimplify[dt/Sqrt[1-velocity[n]^2], conds]




