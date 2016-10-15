(*

https://www.quora.com/What-route-from-Maine-to-California-by-land-would-cross-through-the-least-US-states-whilst-staying-in-the-US-throughout-the-journey draw boundary graph

TODO: note Four Corners issue an ddefn of border

state_latlon.csv from https://dev.maxmind.com/geoip/legacy/codes/state_latlon/

"math -initfile ~/BCGIT/QUORA/stateborders.m" or equivalent to use


*)

usa = Import["/home/barrycarter/BCGIT/QUORA/state_latlon.csv", "Data"];
temp1102 = Flatten[Table[{i[[1]] <-> i[[2]]}, {i, borders}],1]

(* assign lat lon *)

Table[latlon[i[[1]]] = {i[[2]],i[[3]]}, {i, usa}]

(* NOTE: below NOT expected to work *)

coords = Drop[Table[{i[[2]],i[[3]]}, {i,usa}],1]


coords = Table[{latlon[i][[2]],latlon[i][[1]]}, 
 {i,VertexList[Graph[temp1102]]}]

Graph[temp1102]

g = Graph[temp1102, VertexLabels -> "Name", VertexCoordinates -> coords]

