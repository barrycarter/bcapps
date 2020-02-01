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
 Table[i -> Complement[s, i], 
 {i, Subsets[s, {Length[s]-1}]}];
 
 Graph[restDetermineOne[{a, b, c, d, e}], VertexLabels -> Automatic]

<formulas>

direct[s_] := Flatten[Table[t -> i, {t, Subsets[s]}, {i, Subsets[t,
{Max[0,Length[t]-1]}]}]]

restDetermineOne[s_] :=
 Table[i -> Complement[s, i], 
 {i, Subsets[s, {Length[s]-1}]}];
 
</formulas>
