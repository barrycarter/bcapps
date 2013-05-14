(* Computations to find point p% of way from p1 to p2 on great circle; see also http://math.stackexchange.com/questions/383711/parametric-equation-for-great-circle *)

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* Below is an easyish working solution *)

p1={Cos[lon1]*Cos[lat1], Sin[lon1]*Cos[lat1], Sin[lat1]}
p2={Cos[lon2]*Cos[lat2], Sin[lon2]*Cos[lat2], Sin[lat2]}

(* Let v[t] be the parametrized vector that starts as p1 and ends at p2 *)

v[t_] := Simplify[(1-t)*p1+t*p2]

(* at some point v[t] is perpendicular to p1, that occurs when... *)

perp[t_] = t /. Solve[Simplify[v[t].p1]==0,t][[1]]



(* Let p1 and p2 be the (unit) vectors representing lat1,lon1 and
lat2,lon2 on the unit sphere: *)

(* p3 is our desired solution *)

p1={Cos[lon1]*Cos[lat1], Sin[lon1]*Cos[lat1], Sin[lat1]}
p2={Cos[lon2]*Cos[lat2], Sin[lon2]*Cos[lat2], Sin[lat2]}
p3={Cos[lon3]*Cos[lat3], Sin[lon3]*Cos[lat3], Sin[lat3]}

p1={x1,y1,z1}
p2={x2,y2,z2}
p3={x3,y3,z3}

(* the cross product p1 x p2 is the vector perpendicular to the p1/p2/origin plane *)

cp = Cross[p1,p2]

(* find vector whose dot product with p1 is given quantity AND vector
must also be in plane *)

Solve[{p3.p1==r,p3.Cross[p1,p2]==0,Norm[p3]==1},{lon3,lat3}]

norm[v_] := Sqrt[Sum[v[[i]]^2,{i,1,Length[v]}]]

(* Let v[t] be the parametrized vector that starts as p1 and ends at p2 *)

v[t_] := Simplify[(1-t)*p1+t*p2]

dotpn[t_] := Simplify[(v[t]/norm[v[t]]).v[0]]

Simplify[%,{x1^2+y1^2+z1^2==1,x2^2+y2^2+z2^2==1}]

Solve[dotpn[t]==dp,t]

(* distance travelled on straight line *)
dist[t_] = Total[t*(Sqrt[(p2-p1)^2])]

theta[t_] = ArcSin[t*d]

Solve[theta[t]==r,t]

(* Let v2[t] be this parametrized vector extended to length 1 *)

(*Mathematica doesnt simplify norms of real vectors well *)
norm[v_] := Sqrt[Simplify[Sum[v[[i]]^2,{i,1,Length[v]}]]]
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

(* below is just numerical playing *)

(* journey 35N -120W to 35N +120E *)

lat1 = 35. Degree;
lat2 = 49. Degree;
lon1 = -106. Degree;
lon2 = +30. Degree;
p1={Cos[lon1]*Cos[lat1], Sin[lon1]*Cos[lat1], Sin[lat1]}
p2={Cos[lon2]*Cos[lat2], Sin[lon2]*Cos[lat2], Sin[lat2]}

(* parametric as line *)
p[t_] = Simplify[p1*(1-t)+p2*t]
(* as extruded line *)
pe[t_] = Simplify[p[t]/Norm[p[t]]]

Table[p[t],{t,0,1,.01}]
Table[pe[t],{t,0,1,.01}]

Table[ArcTan[pe[t][[1]],pe[t][[2]]],{t,0,1,.01}]

Table[pe[t].p1,{t,0,1,.01}]

ListPointPlot3D[%]

pint[an_] := ({x,y,z} /. Solve[{
 p1.{x,y,z}==Cos[an],
 {x,y,z}.Cross[p1,p2]==0,
 Norm[{x,y,z}]==1
},{x,y,z}][[2]]) [[3]]

Plot[pint[an],{an,0,360 Degree}]

cp = Cross[p1,p2]

p3={Cos[lon3]*Cos[lat3], Sin[lon3]*Cos[lat3], Sin[lat3]}

p3 /. 
Solve[{p3.p1==Cos[10 Degree],p3.Cross[p1,p2]==0,Norm[p3]==1},{lon3,lat3}][[1]]

ListPointPlot3D[{{p1,p2,%}},PlotRange->{x,-1,1}]

{x3,y3,z3}.{x1,y1,z1}
{x3,y3,z3}.{x2,y2,z2}

{sx,sy,sz} /.
Solve[{
 {sx,sy,sz}.{x1,y1,z1}==0,
 {sx,sy,sz}.{x2,y2,z2}==r
}, {sx,sy,sz}][[1]]

Simplify[%, {x1^2+y1^2+z1^2==1}]

Solve[{{x,y,z}.{x1,y1,z1}==r, x^2+y^2+z^2==1, {x,y,z}.{x2,y2,z2}==0}, {x,y,z}]

{x,y,z} = {x,y,z} /.
 Solve[{x,y,z}.{x2,y2,z2}==0,{x,y,z}][[1]]

rlon = RotationTransform[-lon Degree, {0, 0, 1}]
rlat = RotationTransform[-lat Degree, {1, 0, 0}]

{u, v} = rz @ rx @ {{1, 0, 0}, {0, 1, 0}};

p1={x1,y1,z1}
p2={x2,y2,z2}

mat = { {a11, a12, a13}, {a21, a22, a23}, {a31, a32, a33}}

Solve[{mat.p1=={1,0,0},mat.p2=={0,1,0}},Flatten[mat]]

rx = RotationTransform[angx, {1, 0, 0}]
ry = RotationTransform[angy, {0, 1, 0}]
rz = RotationTransform[angz, {0, 0, 1}]

(* arbitrary matrix of length preservation *)
mat = Transpose[{
 {Cos[th1]*Cos[ph1], Sin[th1]*Cos[ph1], Sin[ph1]},
 {Cos[th2]*Cos[ph2], Sin[th2]*Cos[ph2], Sin[ph2]},
 {Cos[th3]*Cos[ph3], Sin[th3]*Cos[ph3], Sin[ph3]}
}]

Reduce[(mat.{1,0,0}).(mat.{0,1,0})==0, {th1,ph1,th2,ph2,th3,ph3}]

(* rotation about cross vector? *)

Cross[p1,p2]

RotationTransform[ang, Cross[p1,p2]] @ p1

Simplify[%, Member[{x1,y1,z1,x2,y2,z2,ang},Reals]]

Cross[Cross[p1,p2],p1]

lat1 = (Random[]*180-90)*Degree;
lat2 = (Random[]*180-90)*Degree;
lon1 = (Random[]*360-180)*Degree;
lon2 = (Random[]*360-180)*Degree;

p1:={Cos[lon1]*Cos[lat1], Sin[lon1]*Cos[lat1], Sin[lat1]}
p2:={Cos[lon2]*Cos[lat2], Sin[lon2]*Cos[lat2], Sin[lat2]}

(* an oblique representation *)
v1[t_] := p1*Cos[t*Pi/2]+p2*Sin[t*Pi/2]
v[t_] := v1[t]/Norm[v1[t]]


