(* unary *)

unary[x_] := DeleteDuplicates[{x!, Sqrt[x], x/100, x/1000}];

binary[x_,y_] := DeleteDuplicates[{x*y, x/y, x+y, x-y, x^y, x^(1/y)}]

unalist[list_] := DeleteDuplicates[Flatten[Table[unary[i],{i,list}]]]

binlist[list_]:=DeleteDuplicates[Flatten[Table[binary[i,j],{i,list},{j,list}]]]



a0 = unary[1]

a1 = DeleteDuplicates[Chop[N[Flatten[Table[binary[i,j],{i,a0},{j,a0}]]]]]

a2 = DeleteDuplicates[Chop[Flatten[Table[unary[i], {i,a1}]]]]
