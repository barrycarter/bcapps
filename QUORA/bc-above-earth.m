(* 



TODO: how to paste TeX into Quora? $tex$ fails

*)

epr = 6356.75231424518*1000
g = 9.8
ti = 17220

sol[t_] = NDSolve[{x[0] == 40000*1000+epr, x'[0] == 0, 
 x''[t] == -g*(epr/x[t])^2
},  x[t], {t,0,ti}][[1,1,2]]

Plot[(sol[t]-epr)/1000,{t,0,ti}]
showit

https://en.wikipedia.org/wiki/Free_fall#Inverse-square_law_gravitational_field

TODO: traj question on SE

TODO: popa correct

