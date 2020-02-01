TODO: preserve lexicographic order of variables

TODO: if requested output is already input

TODO: chain joining

TODO: can compute from subset special case

TODO: single answer inside set or no?


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


