(*

TODO: consider publishing, but currently just a playground

we assume addition formula and all speeds as fraction of light

*)

addVelocity[u_, v_] = (u+v)/(1+u*v)

addVelocity[dv,dv]

conds = {a>0, dt>0, n>0, Element[n, Integers]}

(* velocity of nth beacon as measured from beacon 0 *)

velocity[n_] = 
FullSimplify[
v[n] /. 
RSolve[{v[0] == 0, v[n] == (a*dt+v[n-1])/(1+a*dt*v[n-1])}, v[n], n][[1]],
{a>0,dt>0,n>0}]

FullSimplify[Sum[velocity[i]*dt,{i,0,n}], {a>0,dt>0,n>0}]
