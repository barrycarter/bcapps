(*

 http://politics.stackexchange.com/questions/15180/number-of-winning-coalitions-of-state-in-the-electoral-college?noredirect=1#comment54198_15180

*)

num[{}, 0] := 1
num[s_, 0 ] := 0
num[s_, n_] := Sum[num[Delete[s,i], n-s[[i]]],{i,1,Length[s]}]





(* new method above here *)

a[1] = 1;
a[2] = 1;
a[3] = 1;
a[4] = 2;

a[n_] := a[n] = Sum[a[i]*a[n-i],{i,1,n/2}]

this approach wont work, counts states twice





