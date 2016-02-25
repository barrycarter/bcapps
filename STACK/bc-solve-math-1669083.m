
f[x_] := Module[{},
 For[n=0, n<9999, n++,
 If[!MemberQ[IntegerDigits[x*2^n],4],Return[{n,x*2^n}]]]]

