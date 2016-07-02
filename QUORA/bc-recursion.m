(* https://www.quora.com/How-would-you-solve-this-series-problem *)




Clear[a]
a[2] = 2;
a[n_] := a[n] = a[n-1]^n - 4


4^(1/2)

(4 + 4^(1/3))^(1/2)

(4+(4+4^(1/4))^1/3)^1/2

(4+4^(1/n))^(1/(n-1))


a[n_] := Module[{v,i},
 v = 4^(1/n);
 For[i=n-1, i>=2, i--,
  v = (4+v)^(1/i)];
 Return[v];
];


tab0929 = Table[Log[a[n+1]/a[n]], {n,2,100}];


b[n_] := Module[{v,i},
 v = 2^(1/n);
 For[i=n-1, i>=2, i--,
  v = (2+v)^(1/i)];
 Return[v];
];


