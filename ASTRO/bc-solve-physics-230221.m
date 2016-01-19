(*

Without loss of generality, we can create a coordinate system so that
the target is at the origin (0,0), and the point mass' initial
position is (1,0).

*)

trajectory[v0_,a0_] := NDSolve[{s[0] == {1,0}, s'[0] == v0, s''[t] == a0}, 
 s, {t,0,10}][[1,1,2]]

trajcenter[v0_,a_] := NDSolve[{s[0] == {1,0}, s'[0] == v0, 
 s''[t] == -s[t]*(a/Norm[s[t]])}, 
 s, {t,0,10}][[1,1,2]]

trajcenter[{0,1}, 1]
ParametricPlot[trajcenter[{0,1},1][x],{x,0,10}]
showit

ParametricPlot[trajectory[{0,1},{-1,-1}][x],{x,0,10}]
showit

ParametricPlot[trajectory[{0,1},{-Sqrt[2]/2,-Sqrt[2]/2}][x],{x,0,10}]
showit







 
