(*

https://math.stackexchange.com/questions/2420506/existence-of-n-1-sigman-1-n-2-sigman-2-cdots-n-r-sigman-r-for


(* done later for 10^8 *)

alertme := Run["xmessage -geometry 1024 mathematica done &"];

t = Table[{n, n*DivisorSigma[1,n]},{n,1,100000000}]; alertme

t = Table[{n, n*DivisorSigma[1,n]},{n,1,10^9}]; alertme

temp1530 = Commonest[Transpose[t][[2]]]; alertme

temp1534 = Select[t, #[[2]] == temp1530[[1]] &]; alertme

Select[t, #[[2]] == 5418319872 &]

Out[23]= {1584858562560, 105657237504000, 209201330257920}

Select[t, #[[2]] == 1584858562560 &]

Out[24]= {{624960, 1584858562560}, {640080, 1584858562560}, 
 
>    {696384, 1584858562560}, {708660, 1584858562560}, {713232, 1584858562560}}


