(*



we have {f, x, a, y}

{f, x, a} -> y
{f, a, y} -> x
{f, x, y} -> a
{x, a, y} -> f

{f, x, a} -> f
{f, x, a} -> x
{f, x, a} -> a

Graph[{
{f, x, a} -> y,
{f, a, y} -> x,
{f, x, y} -> a,
{x, a, y} -> f,
{f, x, a} -> f,
{f, x, a} -> x,
{f, x, a} -> a
}]

*)

Subsets[{a, b,c, d}];
implies[s_] := Flatten[Table[t -> i, {t, Subsets[s]}, {i, Subsets[t]}]]

Length[implies[{a,b, c, d, e}]];
Graph[implies[{a,b,c}], VertexLabels -> Automatic]

Subsets[{a, b,c, d}];
implies[s_] := Flatten[Table[t -> i, {t, Subsets[s]}, {i, Subsets[t, {Max[0,Length[t]-1]}]}]]

Length[implies[{a,b, c, d, e}]]
Graph[implies[{a,b,c, d, e}], VertexLabels -> Automatic]

s = {a, b, c, d};

restDetermineOne[s_] :=
 Table[Sort[i] -> Complement[s, i], 
 {i, Subsets[s, {Length[s]-1}]}];
 
Graph[restDetermineOne[{a, b, c, d, e}], VertexLabels -> Automatic]

TODO: why can't I use 't' inside direct[s] and in set s

<formulas>

direct[s_] := Flatten[Table[Sort[u] -> Sort[i], {u, Subsets[s]}, {i, Subsets[u,
{Max[0,Length[u]-1]}]}]]

restDetermineOne[s_] :=
 Table[Sort[i] -> Sort[Complement[s, i]], 
 {i, Subsets[s, {Length[s]-1}]}];
 
</formulas>

s[0] = direct[{f, x, a, y, b, angPOC, areaPOC, areaPink,
areaFromCenter, ecc, t, areaFOP, areaPurple, angOFP, angAFP}];

s[1] = restDetermineOne[{f, x, a, y}];

r[1] = direct[{f, x, a, y}];

s[2] = restDetermineOne[{a, b, f}];

r[2] = direct[{a, b, f}];

s[3] = restDetermineOne[{angPOC, y, x}];

r[3] = direct[{angPOC, y, x}];

s[4] = restDetermineOne[{areaPOC, x, y}];

r[4] = direct[{areaPOC, y, x}];

s[5] = {Sort[{a, x, areaPink}] -> b, Sort[{a, b, x}] -> areaPink};

s[6] = restDetermineOne[{areaFromCenter, areaPOC, areaPink}];

s[7] = restDetermineOne[{a, b, ecc}];

s[8] = restDetermineOne[{a, x, t}];

s[9] = restDetermineOne[{areaFOP, y, f}];

s[10] = restDetermineOne[{areaPurple, areaFOP, areaPink}];

s[11] = restDetermineOne[{angOFP, y, f, x}];

s[12] = restDetermineOne[{angAFP, angOFP}];
 
set = Flatten[Table[s[i], {i, 0, 12}]];
set2 = Flatten[Table[r[i], {i, 1, 4}]];

final = Flatten[{set, set2}]; 

g0 = TransitiveReductionGraph[Graph[final], VertexLabels -> Automatic]




