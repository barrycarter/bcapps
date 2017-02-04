(*

 http://politics.stackexchange.com/questions/15180/number-of-winning-coalitions-of-state-in-the-electoral-college?noredirect=1#comment54198_15180

*)

Clear[num];
num[{}, 0] := 1
num[{}, n_] := 0
num[s_, n_] := num[s,n] = If[n<0, 0, Sum[
 num[Delete[s,i],n] + 
 If[n<s[[i]],0,num[Delete[s,i], n-s[[i]]]],{i,1,Length[s]}]/Length[s]]

num[{1,2,3},6]


(* above works, below tests *)

t1024 = Table[i,{i,1,20}]

num[t1024, 2]




num[{1,2,3},6]

num[{1,2},3]

num[{2}, 3] + num[{2}, 2] + num[{1}, 3] + num[{1}, 1]

num[{1,2,4,7}, 7]
?num



(* wrong approach above? *)

num[{1,2,4,7}, 7] = ...

{2,4,7} to 6 + {1,4,7} to 5 + {1,2,7} to 7 + {1,2,4} to 7









(* new method above here *)

a[1] = 1;
a[2] = 1;
a[3] = 1;
a[4] = 2;

a[n_] := a[n] = Sum[a[i]*a[n-i],{i,1,n/2}]

this approach wont work, counts states twice





