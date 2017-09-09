(*

https://math.stackexchange.com/questions/2420506/existence-of-n-1-sigman-1-n-2-sigman-2-cdots-n-r-sigman-r-for






t = Table[{n, n*DivisorSigma[1,n]},{n,1,100000000}];

Commonest[Transpose[t][[2]]]

Select[t, #[[2]] == 5418319872 &]

Out[23]= {1584858562560, 105657237504000, 209201330257920}

Select[t, #[[2]] == 1584858562560 &]

Out[24]= {{624960, 1584858562560}, {640080, 1584858562560}, 
 
>    {696384, 1584858562560}, {708660, 1584858562560}, {713232, 1584858562560}}


