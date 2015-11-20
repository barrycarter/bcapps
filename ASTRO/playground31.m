(* oversimplified xy plane orbit to test some stuff *)

p[t_] := {x[t],y[t]}

DSolve[{p[0] == {1,0}, p'[t] == {1,0}}, {x,y}, t]
