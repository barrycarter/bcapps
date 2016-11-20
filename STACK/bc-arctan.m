(*

http://math.stackexchange.com/questions/2022782/is-there-an-identity-for-arctanxy

*)

theta = 23*Degree

psi = 54*Degree

b = b /. Solve[ -1/Sin[theta]*Cos[psi+theta] + b == Sin[psi+theta], b]


m = -1/Sin[theta]

g = Graphics[{
 Circle[{0,0},1, {0,Pi/2}],
 Line[{{0,0}, {Cos[theta], Sin[theta]}}],
 Line[{{0,0}, {Cos[psi+theta], Sin[psi+theta]}}],
 Line[{{0,0}, {1,0}}],
 Line[{ {Cos[theta], Sin[theta]}, {Cos[theta],0}}],
 Line[{ {Cos[psi+theta], Sin[psi+theta]}, {Cos[psi+theta],0}}],
 Point[{ m*Cos[psi+theta], m*Sin[psi+theta]}]
}];



Solve[ -1/Sin[theta]*Cos[psi+theta] + b == Sin[psi+theta], b]

(* TODO: finish silly part above *)

greal = Graphics[{
 Circle[{0,0},1, {0,Pi/2}],
 Line[{{0,0}, {Cos[theta], Sin[theta]}}],
 Line[{{0,0}, {Cos[psi+theta], Sin[psi+theta]}}],
 Line[{ {Cos[theta], Sin[theta]}, {Cos[psi+theta], Sin[psi+theta]}}],
 Line[{ {Cos[theta], Sin[theta]}, {1, 0}}],
 Line[{ {0,0}, {Cos[theta+psi/2], Sin[theta+psi/2]}}],
 Line[{ {0,0}, {Cos[theta/2], Sin[theta/2]}}],
 Line[{{0,0}, {1,0}}],
}];

Show[greal, Axes -> True]
showit


If ArcTan[x+y] == c, then

x+y = Tan[c]

which we can split up as

Tan[d+f]

TrigExpand[Tan[d+f]] 

TrigExpand[Tan[d+f]] /. {Sin[x_] -> Tan[x]*Cos[x]}

Normal[Series[ArcTan[x+y],{x,0,4},{y,0,4}]]

In[88]:= Expand[Normal[Series[ArcTan[x+y]-ArcTan[x]-ArcTan[y],{x,0,3},{y,0,3}]]]

Expand[Normal[Series[
 ArcTan[x+y]-ArcTan[x]-ArcTan[y]-x*y*(x + y)*(-1 + x y) - x^2*y^2*(x+y),
{x,0,3},{y,0,3}]]]


Expand[Normal[Series[
 ArcTan[x+y]-ArcTan[x]-ArcTan[y]-x*y*(x + y)*(-1 + x y) - x^2*y^2*(x+y),
{x,0,5},{y,0,5}]]]

Normal[Series[ArcTan[x+y], {x,0,4}, {y,0,4}]]

Sum[-1^(2*n)*x^(2*n+1)/(2n+1), {n,0,Infinity}]


Sum[x^(2*n+1)/(2*n+1)*(-1)^n,{n,0,Infinity}]

nthterm[x_,n_] = x^(2*n+1)/(2*n+1)*(-1)^n

FullSimplify[
 nthterm[x+y,n] - nthterm[x,n] - nthterm[y,n],
{Element[n,Integers], n>0, Element[{x,y}, Reals]}
]






