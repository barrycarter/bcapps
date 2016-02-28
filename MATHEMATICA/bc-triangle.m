(*

Yet another attempt to find triangle formulas, this time using psuedo
objects (all work is in complex plane):

triangle[{z1,z2,z3}]: the triangle with vertices z1, z2, z3
line[{z1,z2}]: the line (segment) from z1 to z2

*)

angle[line[{z1_,z2_}],line[{z3_,z4_}]] = Arg[z2-z1]-Arg[z4-z3]

lines[triangle[{z1_,z2_,z3_}]] = {line[{z2,z3}], line[{z1,z3}], line[{z1,z2}]};



{Arg[z2-z1]-Arg[z3-z1], 
Arg[z1-z2]-Arg[z3-z2],  Arg[z1-z3]-Arg[z2-z3]};






