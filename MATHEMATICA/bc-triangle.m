(*

Yet another attempt to find triangle formulas, this time using psuedo
objects (all work is in complex plane):

triangle[{z1,z2,z3}]: the triangle with vertices z1, z2, z3
line[{z1,z2}]: the line (segment) from z1 to z2

*)

(* Mathematica yields errors on definitions like these, but allows them *)

arg[line[pts_]] = Arg[pts[[2]]-pts[[1]]]

angle[line1_,line2_] = arg[line1] - arg[line2]

(* TODO: these lines/angles aren't in "order"? *)

lines[triangle[pts_]] = 
 Flatten[Table[line[{pts[[i]],pts[[j]]}],{i,2},{j,i+1,3}]]

angles[triangle[pts_]] = Flatten[Table[angle[lines[triangle[pts]][[i]], 
 lines[triangle[pts]][[j]]], {i,2}, {j,i+1,3}]]







