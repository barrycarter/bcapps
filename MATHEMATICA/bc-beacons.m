(*

Q: Say Barry, could you abuse the answer-your-own-question feature of
this site and explain constant acceleration in relativity?

A:

(* bob's velocity at time t *)

vbob[t_] = Floor[t+1]
sbob[t_] = Integrate[vbob[u],{u,0,t}]
beacon[n_,t_] = If[t>=n, Text[ToString[n], 
 {sbob[n-1]+vbob[n-1]*(t-n+1),0}], Null];

beacons[t_] = Table[beacon[n,t], {n,0,10}]

g2[t_] := Graphics[{

 Point[{sbob[t],0}],
 beacons[t]



}]

g3[t_] := Show[g2[t], PlotRange->{{0,45},{-1,1}}]

ani = Table[g3[t],{t,0,20,.05}]
Export["/tmp/test.gif", ani, ImageSize -> {1024, 50}]

TODO: maybe improve graphic

Bob drops a beacon and then accelerates at $a$ for one second,
repeating this process indefinitely. The 0th beacon is what we'll call
Bob's "starting point".

We take as given the formulas for relativistic velocity addition, time
dilation, and Lorentz contraction (all velocities given as a
percentage of the speed of light):

$\text{add}(u,v)=\frac{u+v}{u v+1}$

$\text{dilation}(\text{v$\_$})=\frac{1}{\sqrt{1-v^2}}$

TODO: add Carol

TODO: add contraction

TODO: Above is derivable

How fast is the nth beacon traveling, according to Carol?

The first beacon is traveling at $a$ since Bob started at rest with
respect to Carol.

The second beacon is traveling at $a$ with respect to the first
beacon, so we use the relativistic addition formula:

$\text{add}(a,a)\to \frac{2 a}{a^2+1}$

So we now know the second beacon is traveling at $\frac{2 a}{a^2+1}$
with respect to Carol.

The third beacon is traveling at $a$ with respect to the second
beacon, so we again apply the relativistic addition formula:

$   
    \text{add}\left(\frac{2 a}{1+a^2},a\right)\to \frac{a \left(a^2+3\right)}{3
    a^2+1}
$

In general, we find the velocity of the nth beacon as follows:

$v_{n+1}=\text{add}\left(v_n,a\right) \to \frac{a+v_n}{a v_n+1}$

The closed form for this recursion is:

$v_n=1-\frac{2 (1-a)^n}{(1-a)^n+(a+1)^n}$

If $a=0.01$ (which means Bob is accelerating at 1% the speed of light
every second or about 2997.92458 kilometers per second per second),
let's see what the speed of the nth beacon would look like.

Table[{{n, v[n] /. a -> .01}, {n, .01*n}},{n,0,100}]


c = 299792458

v[n_] = 
 FullSimplify[RSolve[{v[0] == 0, v[n+1] == add[v[n],a]}, v[n], n][[1,1,2]],
 {Element[n,Integers], n>0, a>0}]




It turns out the nth beacon (computations omitted) 

add[u_,v_] = (u+v)/(1+u*v)





TODO: how far, what time, and add light travel

TODO: mention git file



TODO: mention http://physics.stackexchange.com/questions/240342/clock-on-constantly-accelerating-object-approaches-gudermannian-limit

TODO: note to edit this question if I ever get around to showing linear transform


TODO: consider publishing, but currently just a playground

we assume addition formula, dilation formula and all speeds as
fraction of light

ship is accelerating at "a", and 1 beacon every 1/n seconds that's a/n
faster than the previous one for t seconds

*)

m[v_]={{1/Sqrt[1 - v^2], v/Sqrt[1 - v^2]}, {v/Sqrt[1 - v^2], 1/Sqrt[1 - v^2]}};

RSolve[{
 trans[0] == m[0],
 trans[n+1] == m[v].trans[n]
}, trans[i], i]

rs = RSolve[{
 mat00[0] == 1, mat10[0] == 0, mat01[0] == 0, mat11[0] == 1,
 mat00[i+1] == (mat00[i] + mat01[i]*v)/Sqrt[1-v^2],
 mat10[i+1] == (mat10[i] + mat11[i]*v)/Sqrt[1-v^2],
 mat01[i+1] == (mat01[i] + mat00[i]*v)/Sqrt[1-v^2],
 mat11[i+1] == (mat11[i] + mat10[i]*v)/Sqrt[1-v^2]
}, {mat00[i], mat01[i], mat10[i], mat11[i]}, i]

rs2 = FullSimplify[rs, {v>0, i>0, Element[i,Integers]}]

mat[i_]=FullSimplify[{{mat00[i], mat10[i]}, {mat01[i], mat11[i]}} /. rs2[[1]],
 v>0]

orig = FullSimplify[mat[i].{t,0}]

origvel = FullSimplify[orig[[2]]/orig[[1]]]

nth = {(1 + (-1 + 2/(1 + v))^i)/(2*(-1 + 2/(1 + v))^(i/2)), 
 -(-1 + (-1 + 2/(1 + v))^i)/(2*(-1 + 2/(1 + v))^(i/2))}

sol = Solve[nth[[1]]==u,i][[1,1,2]]

simp1 = FullSimplify[nth /. i -> sol]

sol2 = Solve[nth[[1]]==u,v][[1,1,2]]

simp2 = FullSimplify[nth /. v -> sol2]

Sqrt[simp2[[1]]^2-1] - simp2[[2]]

dist[u_] = Sqrt[u^2-1]






addVelocity[u_, v_] = (u+v)/(1+u*v)

dilationFactor[v_] = Sqrt[1-v^2]

conds = {a>0, n>0, m>0, Element[{m,n}, Integers]}

(* velocity of mth beacon as measured from beacon 0 *)

velocity[m_,a_,n_] =  FullSimplify[v[m] /. 
RSolve[{v[0] == 0, v[m] == (a/n+v[m-1])/(1+a/n*v[m-1])}, v[m], m], conds][[1]]

(* time between mth and m+1st beacon drop based on time dilation, from
beacon 0 *)

timeBetween[m_,a_,n_] = FullSimplify[1/n/Sqrt[1-velocity[m,a,n]^2], conds]

(* distance ship travels between beacons m and m+1 *)

distanceTraveled[m_,a_,n_] = 
 FullSimplify[timeBetween[m,a,n]*velocity[m,a,n],conds]

(* time OF the mth drop *)

timeOf[m_,a_,n_] = FullSimplify[Sum[timeBetween[i,a,n],{i,0,m-1}],conds]

(* distance of mth beacon as measured from beacon 0; could not get this!!!

distance[m_,a_,n_] = FullSimplify[Sum[distanceTraveled[i,a,n],{i,0,n-1}], 
 conds]

*)

Solve[timeOf[n] == t, n, Reals]



