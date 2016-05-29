(* 

38795.4 high and falling 675.123 m/s 

TODO: how to paste TeX into Quora? $tex$ fails [math /]

0.184277 = accel



(graph ignores air friction) (issue near end)

*)

epr = 6356.75231424518
g = 9.8/1000
ti = 17220

sol[t_] = NDSolve[{x[0] == 40000+epr, x'[0] == 0, 
 x''[t] == -g*(epr/x[t])^2
},  x[t], {t,0,ti}][[1,1,2]]

Plot[sol[t]-epr,{t,0,ti}]
showit

https://en.wikipedia.org/wiki/Free_fall#Inverse-square_law_gravitational_field

TODO: traj question on SE

TODO: popa correct

TODO: note this file

TODO: improve graph

TODO: ignores asteroids

TODO: old def meter

FullSimplify[DSolve[{x''[t] == a/x[t]^2}, x, t], {x[t]>0, t>0}]

FullSimplify[DSolve[{x''[t] == a/x[t]^n}, x, t], {x[t]>0, t>0}]

FullSimplify[DSolve[{x'''[t] == a/x[t]^3}, x, t], {x[t]>0, t>0}]

