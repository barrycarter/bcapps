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

