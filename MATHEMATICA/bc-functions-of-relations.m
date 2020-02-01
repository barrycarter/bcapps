<formulas>

extractVariables[exp_] := DeleteDuplicates@Cases[exp, _Symbol, Infinity];

variableSolutions[exp_] := Table[Solve[exp, i], {i, extractVariables[exp]}];

symbol2Variable[sym_] := ToExpression[ToString[sym]<>"_"];

symbolList2Variable[symlist_] := Map[symbol2Variable[#] &, symlist];

(* TODO: can we make convert non-global? *)

defineConvert[exp_] := Module[{}, Return[{}]];

solution2Function[sol_] := Module[{},






</formulas>


TODO: preserve lexicographic order of variables

TODO: if requested output is already input

TODO: chain joining

TODO: can compute from subset special case

TODO: single answer inside set or no?

TODO: solve can't solve it?


convert[{f,x,y}, a][f_, x_, y_] = (Sqrt[Abs[-f + x]^2 + Abs[y]^2] +
Sqrt[Abs[f + x]^2 + Abs[y]^2])/2;

convert[{a,f,y}, x][a_, f_, y_] = (a*Sqrt[a^2 - f^2 - Abs[y]^2])/Sqrt[a^2 - f^2]

convert[{a,f,y}, f][a_, f_, y_] = f

eq1 = (Norm[{x,y}-{f,0}] + Norm[{x,y}-{-f,0}] == 2*a);

temp1205 = DeleteDuplicates@Cases[eq1, _Symbol, Infinity];

Table[Solve[eq1, i], {i, temp1205}]

extractVariables[exp_] := DeleteDuplicates@Cases[exp, _Symbol, Infinity];

variableSolutions[exp_] := Table[Solve[exp, i], {i, extractVariables[exp]}];

eq1 = (Norm[{x,y}-{f,0}] + Norm[{x,y}-{-f,0}] == 2*a);

variableSolutions[eq1]


extractVariables[exp_] := DeleteDuplicates@Cases[exp, _Symbol, Infinity];

variableSolutions[exp_] := Table[Solve[exp, i], {i, extractVariables[exp]}];

eq1 = (Norm[{x,y}-{f,0}] + Norm[{x,y}-{-f,0}] == 2*a);

v1212 = variableSolutions[eq1];

v1212[[3, 1, 1, 1]] /. v1212[[3]]

{a} -> a_


Clear[convert];
extractVariables[exp_] := DeleteDuplicates@Cases[exp, _Symbol, Infinity];

variableSolutions[exp_] := Table[Solve[exp, i], {i, extractVariables[exp]}];

eq1 = (Norm[{x,y}-{f,0}] + Norm[{x,y}-{-f,0}] == 2*a);

v1212 = variableSolutions[eq1];

v1213 = v1212[[3, 1, 1, 1]] /. v1212[[3]];

v1214 = extractVariables[v1212[[3, 1, 1, 1]] /. v1212[[3]]];

v1215 = v1212[[3, 1, 1, 1]];

convert[v1214, v1215][v1214] = v1212[[3]];

t1232 = ToExpression[ToString[v1214[[1]]]<>"_"];

t1235 = Table[ToExpression[ToString[i]<>"_"], {i, v1214}]

h[t1235] = a + f + x;

h[{1, 2, 3}]

convert[{a,f,x}, y][1, 2, 3];


Clear[convert]; Clear[f];
extractVariables[exp_] := DeleteDuplicates@Cases[exp, _Symbol, Infinity];
variableSolutions[exp_] := Table[Solve[exp, i], {i, extractVariables[exp]}];
symbol2Variable[sym_] := ToExpression[ToString[sym]<>"_"];
symbolList2Variable[symlist_] := Map[symbol2Variable[#] &, symlist];

eq1 = (Norm[{x,y}-{f,0}] + Norm[{x,y}-{-f,0}] == 2*a);
v1212 = variableSolutions[eq1];
s1243 = v1212[[1]]
outvar = s1243[[1, 1, 1]]
invar1 = extractVariables[s1243[[1,1,2]]];
invar2 = symbolList2Variable[invar1];
invar2
f[invar2] = outvar /. s1243
convert[invar1, outvar][invar2] = outvar /. s1243
convert[{a,x,y},f][{1,2,3}]
?f
?convert


