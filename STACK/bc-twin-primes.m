tab[i_] := Table[{3*Prime[i]*n-2, 3*Prime[i]*n-4}, {n,1,Prime[i],2}]

num[i_] := num[i] = Length[Select[tab[i], PrimeQ[#] == {True,True} &]]

test = Table[num[i],{i,1,7250}]
