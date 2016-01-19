(* lookup nearest physical constants; highly inefficient, loops thru
entire list *)

(* /tmp/math.txt is the output of "bc-solve-mathematica-104178.pl nist-constants.txt" *)

<< /tmp/math.txt
nearestPhysicalConstant[x_] := Module[{},
 Return[
Sort[Table[{i, MantissaExponent[x][[1]] - MantissaExponent[i[[2]]][[1]]},
 {i, physicalConstants}],  Abs[#1[[2]]] < Abs[#2[[2]]] &]]];

DumpSave["/home/barrycarter/BCGIT/MATHEMATICA/nearestPhysicalConstant.mx",
{nearestPhysicalConstant, physicalConstants}];

