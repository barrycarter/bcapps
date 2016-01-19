(*

Without loss of generality, we can create a coordinate system so that
the target is at the origin (0,0), and the point mass' initial
position is (1,0).

*)

NDSolve[{
 s[0] == {1,0},
 s'[0] == {0,1},
 s''[t] == {-2,0}
}, s, {t,0,5}]



 
