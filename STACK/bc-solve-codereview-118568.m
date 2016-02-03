(*

equations for RISK so I can rewrite C code 

base from: http://www.strategygamenetwork.com/statistics.html#q9

*)

p[n_,m_] := 2890/7776*p[n,m-2] + 2611/7776*p[n-1,m-1] + 2275/7776*p[n-2,m] /;
 m>=2

p[n_,0] := 1

p[n_,1] := 855/1296 + 441/1296*p[n-1,1]

p[2,2] := 295/1296 + 581/1296*p[1,1]

(* but not quite what I want... *)

(*

working backwards

if 5 vs 0, what was prev:

 5 vs 2 and def lost 2 2890/7776

 6 vs 1 and each lost 1 2611/7776

 7 vs 0 [not possible]

if 5 vs 2, what prev:

 5 vs 4 def lost 2

 6 vs 3 both lost 1

 7 vs 2 attack lost 2


q[5,2] = q[5,4]*xxx + q[6,3]*yyy + q[7,2]*zzz

and we are counting down, so if we know q[n,m] == 1, then...

q[i,j] = q[i,j+2]*xxx + q[i+1,j+1]*yyy + q[i+2,j]*zzz

if 0 attackers left, previous could have been 1 vs d+1 or 2 vs d or ...

3v2 -> 3v0, 2v1, 1v2

3v1 -> 3v0, 2v0, 1v1

2v2 -> 2v0, 1v1, 0v2

2v1 -> 2v0, 1v0, 0v1

1v1 -> 1v0, 0v0 [not really], 0v1

*)



