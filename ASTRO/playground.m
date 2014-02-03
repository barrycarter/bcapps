(* based on the output of bc-read-cheb.pl for mercury x values 2014 *)

(* this is the file with the output of bc-read-cheb.pl *)
<</tmp/math.m

(* TODO: make this a pure function *)

tab = Table[
Sum[mercury[x][i][[n]]*ChebyshevT[n+1,t], {n,1,Length[mercury[x][i]]}],
{i,1,48}]

tab2 = Table[Function[t,Evaluate[tab[[i]]]],{i,1,Length[tab]}]

Plot[{tab2[[1]][t*2-1],tab2[[2]][t*2+1]},{t,-1,1}]
showit
