(* fun w/ constellations *)

Interpreter["Constellation"]["The Big Dipper"]["BoundaryLine"]
Interpreter["Constellation"]["The Big Dipper"]["Properties"]

Interpreter["Constellation"]

(* find boundaries of constellations to get formula *)

t0924 = EntityList["Constellation"]

t0925 = Table[i["BoundaryLine"], {i, t0924}]

ListPlot[t0925[[1,1]][[1]]]                                            


(* but should probably use my own list, B1850.0, "straighter" lines *)




