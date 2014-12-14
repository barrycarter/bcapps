(* https://astronomy.stackexchange.com/questions/8237/could-a-theoretical-cube-shaped-planet-have-a-moon *)

(* force at point xyz *)

f[x_,y_,z_] = Simplify[({x,y,z} - {x0,y0,z0})/Norm[{x,y,z} - {x0,y0,z0}]^3, 
Element[{x,y,z,x0,y0,z0}, Reals]]

Integrate[f[x,y,z],{x,-1/2,1/2},{y,-1/2,1/2},{z,-1/2,1/2}]

Integrate[f[x,y,z][[1]],{x,-1/2,1/2}]






