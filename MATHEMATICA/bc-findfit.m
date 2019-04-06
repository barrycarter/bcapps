(* fun w/ find fit *)

tab = Table[{RandomReal[1, 4], RandomReal[1]}, 20]

FindFit[tab, 1 + a*x[[1]], {a,b,c,d}, x]


