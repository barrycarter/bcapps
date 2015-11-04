(* How could the planettime possibly work? perhaps as below *)

(* two planets, 1AU and 5AU, dist = 3 AU *)

p1[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]};
p2[t_] = 3*{Cos[2*Pi*t/5],Sin[2*Pi*t/5]};

(* vector between them *)

v[t_] = p2[t]-p1[t];

(* vector angle *)

ang[t_] = ArcTan[v[t][[2]]/v[t][[1]]];

(* the psuedo-planet is at distance 2 *)

(* parametrized vector *)

Norm[u*p1[t] + (1-u)*p2[t]]

