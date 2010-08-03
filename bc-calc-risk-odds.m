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

(* so we create q[x,n,m], the probability of winning with strategy x *)

(* base conditions from above *)

(* the foo := foo = something is a Mathematica efficiency thing *)

(* never attack with 3 troops or fewer *)
q[x_,n_,m_] := (q[x,n,m] = 0) /; n<=3

(* WAS: q[x_,n_,m_] := 0 /; n<=3 *)
(* FAIL: q[x_,n_,m_] := q[x,n,m] = 0 /; n<=3 *)
(* FAIL: (q[x_,n_,m_] := q[x,n,m] = 0) /; n<=3 *)

(* if defense has no troops left, you've won *)
q[x_,n_,0] := q[x,n,0] = 1

(* if only one defender ... *)
q[x_,n_,1] := q[x,n,1] = 855/1296 + 441/1296*pf[q[x-1,n-1,1]]

(* q0 is just the basic strategy *)
q[0,n_,m_] := q[0,n,m] = p[n,m]

(* general case *)

q[x_,n_,m_] := (q[x,n,m] = 2890/7776*pf[q[x-1,n,m-2]] +
             2611/7776*pf[q[x-1,n-1,m-1]] +
             2275/7776*pf[q[x-1,n-2,m]]) /; m>=2

(* My Mathematica has problems w/ graphics, so I must do this *)
showit := Module[{},
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(*** JFF GRAPHING (want to avoid loading this every time)

ListPlot[Table[q[x,11,6],{x,0,20}], AxesOrigin->{0,0}, PlotJoined->True, 
 PlotRange -> All]

Table[q[10,n,m],{n,3,13},{m,1,13}]

***)
