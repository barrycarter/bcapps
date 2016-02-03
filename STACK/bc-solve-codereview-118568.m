(*

equations for RISK so I can rewrite C code 

base from: http://www.strategygamenetwork.com/statistics.html#q9

*)

p[n_,m_] := 2890/7776*p[n,m-2] + 2611/7776*p[n-1,m-1] + 2275/7776*p[n-2,m] /;
 m>=2

p[n_,0] := 1

p[n_,1] := 855/1296 + 441/1296*p[n-1,1]

p[2,2] := 295/1296 + 581/1296*p[1,1]





