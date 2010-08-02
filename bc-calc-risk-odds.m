(* Risk (or conquerclub.com) w/ strategy: assault until one of:
   1. You win
   2. You have fewer than 4 troops
 *)

(* never attack with 3 troops or fewer *)
p[n_,m_] := 0 /; n<=3

(* if defense has no troops left, you've won *)
p[n_,0] := 1

(* if only one defender ... *)
p[n_,1] := 855/1296 + 441/1296*p[n-1,1]

(* chance of winning when defense has at least 2 courtesy
   http://www.strategygamenetwork.com/statistics.html#q9 *)

p[n_,m_] := 2890/7776*p[n,m-2] + 2611/7776*p[n-1,m-1] + 2275/7776*p[n-2,m] /;
 m>=2



