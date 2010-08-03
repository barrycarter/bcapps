(* Risk (or conquerclub.com) w/ strategy one: assault until one of:
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

(* However, the above assumes you will always auto-assault. If you
don't, you can stop assaulting when the odds turn against you. In
other words, strategy two is assault until one of:
  1. You win 
  2. You have fewer than 4 troops
  3. p[n,m] < .5
*)

(* Note: .5 could be .75 [or whatever] if you want to be safe *)

(* pf says you give up if odds are less than 50% *)
(* intentionally using soft equals here *)

pf[p_] = If[p<.5,0,p]

(* now the probabilities for this new strategy p1 *)

(* same base conditions *)
p1[n_,m_] := 0 /; n<=3

(* if defense has no troops left, you've won *)
p1[n_,0] := 1

(* if only one defender... *)

p1[n_,1] := 855/1296 + 441/1296*pf[p[n-1,1]]

(* and the basic case *)
p1[n_,m_] := 2890/7776*pf[p[n,m-2]] +
             2611/7776*pf[p[n-1,m-1]] +
             2275/7776*pf[p[n-2,m]] /; m>=2

(* of course, we're now using strategy 0's odds for strategy 1. This
leads us to ... strategy 2 *)

(* now the probabilities for this new strategy p2 *)

(* same base conditions *)
p2[n_,m_] := 0 /; n<=3

(* if defense has no troops left, you've won *)
p2[n_,0] := 1

(* if only one defender... *)

p2[n_,1] := 855/1296 + 441/1296*pf[p1[n-1,1]]

(* and the basic case *)
p2[n_,m_] := 2890/7776*pf[p1[n,m-2]] +
             2611/7776*pf[p1[n-1,m-1]] +
             2275/7776*pf[p1[n-2,m]] /; m>=2

(* of course, this leads us to strategy 3... ad infinitum *)






