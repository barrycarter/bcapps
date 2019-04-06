(* fun w/ find fit *)

tab = Table[RandomReal[1, 5], 20]

FindFit[tab, 1 + a*x, {a,b,c,d}, x]
