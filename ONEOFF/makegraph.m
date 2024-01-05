
g0 = Table[{i -> j}, {i, 1, 10}, {j, 1, 10}]

p = 0.98

size = 160

g1 = Graph[Flatten[Table[If[Random[] < p, {i <-> j}, {}], 
 {i, 2, size}, {j, 1, i-1}]]]

FindClique[g1]

Normal[AdjacencyMatrix[g1]] >> /tmp/graph.txt

g2 = Normal[AdjacencyMatrix[g1]]

g3 = AdjacencyGraph[1-g2]


(* below loads an existing graph *)

x = << graph1.txt

x2 = AdjacencyGraph[x]


FindClique[x2, {17}, 1]

FindClique[{x2, 1}, 10]

(* below 1 works *)

FindClique[x2, {80}, 1]

FindClique[x2, {86}, 1] (* works *)

x3 = FindClique[x2, {86}, 1][[1]]

x4 = Table[x[[i]][[j]], {i, x3}, {j, x3}]

(* new start below just to clean it up a bit *)

g = Graph[Flatten[Table[If[Random[] < 0.98, {i <-> j}, {}], 
 {i, 2, 160}, {j, 1, i-1}]]];

g1 = Normal[AdjacencyMatrix[g]];

Export["/tmp/out.csv", g1]




















