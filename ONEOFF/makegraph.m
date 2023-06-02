
g0 = Table[{i -> j}, {i, 1, 10}, {j, 1, 10}]

p = 0.98

size = 160

g1 = Graph[Flatten[Table[If[Random[] < p, {i <-> j}, {}], 
 {i, 2, size}, {j, 1, i-1}]]]

FindClique[g1]

Normal[AdjacencyMatrix[g1]] >> /tmp/graph.txt







