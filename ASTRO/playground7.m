(* https://astronomy.stackexchange.com/questions/8237/could-a-theoretical-cube-shaped-planet-have-a-moon *)

(* force at point xyz *)

conds = {Element[{x,y,z,x0,y0,z0}, Reals], x0>0, y0>0, z0>0,
 x0>1/2 || y0>1/2 || z0>1/2};

(* trying this without simplifications to see if that helps *)

f[x_,y_,z_] = ({x,y,z} - {x0,y0,z0})/Norm[{x,y,z}-{x0,y0,z0}]^3;

f[x_,y_,z_] = FullSimplify[f[x,y,z],conds];

i1130 = Integrate[f[x,y,z][[1]],{x,-1/2,1/2}, Assumptions -> conds]

i1144 = Integrate[i1130[[1]],{y,-1/2,1/2}, Assumptions -> conds]



i1127 = Integrate[f[x,y,z],{x,-1/2,1/2},{y,-1/2,1/2},{z,-1/2,1/2},conds];









