extractVariables[exp_] := 
Select[DeleteDuplicates@Cases[exp, _Symbol, Infinity],
Attributes[#] == {} &];

variableSolutions[exp_] := Table[Solve[exp, i], {i, extractVariables[exp]}];

symbol2Variable[sym_] := ToExpression[ToString[sym]<>"_"];

symbolList2Variable[symlist_] := Map[symbol2Variable[#] &, symlist];

(* TODO: can we make convert non-global? *)

oneExpression2Function[exp_] := Map[solution2Function[#] &,
variableSolutions[exp]];

solution2Function[sol_] := Module[{outvar, invar1, invar2},
 If[Head[sol] == Solve, Return[]];
 outvar = sol[[1, 1, 1]];
 invar1 = extractVariables[sol[[1,1,2]]];
 invar2 = symbolList2Variable[invar1];
 Return[{invar1, outvar, invar2, outvar /. sol}];
]

expressions2Function[exps_] := Flatten[Map[oneExpression2Function[#]
&, exps], 1]

(* converts expressions to a metafunction, and sets provided f to that
metafunction *)

expressions2MetaFunction[exps_, f_] := 
Table[f[i[[1]], i[[2]]][i[[3]]] = i[[4]], {i, expressions2Function[exps]}];

expressions2Edges[exps_] := 
 Table[i[[1]] -> {i[[2]]}, {i, expressions2Function[exps]}]
