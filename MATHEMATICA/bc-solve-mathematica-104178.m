(* lookup nearest physical constants; highly inefficient, loops thru
entire list *)

nearestPhysicalConstant[x_] := Module[{},
 Return[
Sort[Table[{i, MantissaExponent[x][[1]] - MantissaExponent[i[[2]]][[1]]},
 {i, physicalConstants}],  Abs[#1[[2]]] < Abs[#2[[2]]] &]]];


test[x_] := 
Sort[Table[{i, MantissaExponent[x][[1]] - MantissaExponent[i[[2]]][[1]]}, 
 {i, physicalConstants}]

