(* Computations to find point p% of way from p1 to p2 on great circle; see also http://math.stackexchange.com/questions/383711/parametric-equation-for-great-circle *)

(* Let p1 and p2 be the (unit) vectors representing lat1,lon1 and
lat2,lon2 on the unit sphere: *)

p1={Cos[lon1]*Cos[lat1], Sin[lon1]*Cos[lat1], Sin[lat1]}
p2={Cos[lon2]*Cos[lat2], Sin[lon2]*Cos[lat2], Sin[lat2]}

p1={x1,y1,z1}
p2={x2,y2,z2}

norm[v_] := Simplify[Sum[v[[i]]^2,{i,1,Length[v]}]]

(* Let v[t] be the parametrized vector that starts as p1 and ends at p2 *)

v[t_] := Simplify[(1-t)*p1+t*p2]

(* distance travelled on straight line *)
dist[t_] = Total[t*(Sqrt[(p2-p1)^2])]

theta[t_] = ArcSin[t*d]

Solve[theta[t]==r,t]

(* Let v2[t] be this parametrized vector extended to length 1 *)

(* Mathematica doesnt simplify norms of real vectors well *)
norm[v_] := Simplify[Sum[v[[i]]^2,{i,1,Length[v]}]]
v2[t_] := Simplify[v[t]/norm[v[t]], {x1^2+y1^2+z1^2==1,x2^2+y2^2+z2^2==1}]

Simplify[p1.v2[t],{x1^2+y1^2+z1^2==1,x2^2+y2^2+z2^2==1}]

Simplify[Solve[ArcCos[p1.v2[t]]==ang,t],{x1^2+y1^2+z1^2==1,x2^2+y2^2+z2^2==1}]


(* Although v2[t] uniformly parametrizes the line between p1 and p2, v2[t]
does NOT uniformly parametrize the great circle from p1 to p2. *)

ang[t_] := Simplify[ArcCos[p1.v2[t]],{x1^2+y1^2+z1^2==1,x2^2+y2^2+z2^2==1}]

(* For any given angle, we can solve for t *)

t[ang_] = Simplify[t /. Solve[ang[t] == ang, t][[1]]]

(* point on sphere corresponding to angle *)

xyz[ang_] = Simplify[v2[t[ang]]]

