(*

https://www.quora.com/What-route-from-Maine-to-California-by-land-would-cross-through-the-least-US-states-whilst-staying-in-the-US-throughout-the-journey draw boundary graph

TODO: note Four Corners issue an ddefn of border

state_latlon.csv from https://dev.maxmind.com/geoip/legacy/codes/state_latlon/

"math -initfile ~/BCGIT/QUORA/stateborders.m" or equivalent to use


*)

usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];

(* helper functions *)
state[n_] := usa[[1,2,2,n]]
name[n_] := usa[[1,6,2,n]]
centroid[n_] := Flatten[Apply[List,state[n][[1]]]]
ewpoints[n_] := Transpose[Partition[Flatten[Apply[List,state[n],1]],2]]
width[n_] := Max[ewpoints[n][[1]]]-Min[ewpoints[n][[1]]]

states = Table[f[n] = name[n], {n,1,50}]

g = Table[{
 EdgeForm[Thin],
 Text[Style[f[i], FontSize-> 60*width[i]/StringLength[f[i]]], centroid[i]],
 Opacity[0.1],
 state[i]
}, {i,states}];




temp1102 = Flatten[Table[{i[[1]] <-> i[[2]]}, {i, borders}],1]



(* assign lat lon *)

Table[latlon[i[[1]]] = {i[[2]],i[[3]]}, {i, usa}]

(* NOTE: below NOT expected to work *)

coords = Drop[Table[{i[[2]],i[[3]]}, {i,usa}],1]


coords = Table[{latlon[i][[2]],latlon[i][[1]]}, 
 {i,VertexList[Graph[temp1102]]}]

Graph[temp1102]

g = Graph[temp1102, VertexLabels -> "Name", VertexCoordinates -> coords]

