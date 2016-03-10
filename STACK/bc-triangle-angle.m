(*
http://math.stackexchange.com/questions/1688586/finding-an-angle-in-a-triangle-when-the-length-of-one-side-is-unknown-and-the-d
*)

(*

Here's a purely analytical approach.

TODO: verbiage

N -> origin

A -> {an,0}

B -> {bx,by} (unknown, but norm is known)

S -> {sx,sy} (unknown, but three norms known)

lens: {ns, as, bs} and {an, bn} (note diagram gives sn, sa, sb)

conds = {an > 0, bn > 0, ns > 0, as > 0, bs > 0, sy > 0, 
 Element[{sx,bx,by}, Reals]}

TODO: disclaim sy>0

sol = FullSimplify[Solve[{sx^2 + sy^2 == ns^2, (sx-an)^2 + sy^2 == as^2}, 
 {sx,sy}, Reals], conds]

sxsol = sol[[1,1,2,1]]

sysol = Sqrt[ns^2 - (an^2 - as^2 + ns^2)^2/(4*an^2)]

(* NOTE: below is actually plusminus)

sy = Sqrt[ns^2 - (an^2 - as^2 + ns^2)^2/(4*an^2)] 

sol2 = FullSimplify[
Solve[{bx^2 + by^2 == bn^2, (bx-sx)^2 + (by-sy)^2 == bs^2}, {bx,by}],
conds]

(* using negative sy *)

sol3 = FullSimplify[
Solve[{bx^2 + by^2 == bn^2, (bx-sx)^2 + (by+sy)^2 == bs^2}, {bx,by}],
conds]


















Solve[{
 sx^2 + sy^2 == ns^2,
 (sx-an)^2 + sy^2 == as^2,
 (sx-bx)^2 + (sy-by)^2 == bs^2,
 bx^2 + by^2 == bn^2
}, {sx,sy,bx,by}, Reals]



Solve[{
 Norm[{sx,sy}]^2 == ns^2,
 Norm[{sx,sy} - {an,0}]^2 == as^2,
 Norm[{sx,sy} - {bx,by}]^2 == bs^2,
 Norm[{bx,by}]^2 == bn^2
}, {sx,sy,bx,by}, Reals]







*)
