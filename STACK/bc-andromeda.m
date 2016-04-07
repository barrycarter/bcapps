(* TODO: note conversion is in x,t order *)

translate[v_,x_,t_] = {x-v*t, t-v*x}/Sqrt[1-v^2]

(* suppose andromeda galaxy is at rest wrt nonwalking guy; dist 2.5 M ly *)

translate[v, x, 0]

Solve[translate[v,x,t][[2]] == 0,t]



