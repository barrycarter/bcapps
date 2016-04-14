(* formulas start here *)

conds = {n>0, k>0, i>0, Element[{n,k,i},Integers], Abs[a] < 1, Abs[v0] < 1,
 Element[{a,v0}, Reals]};

dilation[v_] = 1/Sqrt[1-v^2];

add[u_,v_] = (u+v)/(1+u*v);

(* TODO: rename vars below so calling this function twice doesn't
break things *)

v[n_] = FullSimplify[
RSolve[{v[0] == v0, v[n+1] == add[v[n],a]}, v[n], n][[1,1,2]] , conds];

vbeacon[n_] = (v0*Cosh[a*n] + Sinh[a*n])/(Cosh[a*n] + v0*Sinh[a*n])

dt[n_] = FullSimplify[dilation[v[n+1]], conds];

(*

temporarily commenting out next 3 as I may go a different direction here

t[n_] = FullSimplify[t0+ Sum[dt[i],{i,0,n}],conds];

ds[n_] = FullSimplify[dt[n]*v[n+1], conds];

s[n_] = FullSimplify[s0 + Sum[v[i+1]*dt[i], {i,0,n}], conds];

*)

(*

NOTE: commenting this out; doing this too early breaks things

t0 = Subscript[t,0]

s0 = Subscript[s,0]

v0 = Subscript[v,0]

u0 = Subscript[u,0]

*)

(* formulas end here *)

beacons[t_] = Table[beacon[n,t], {n,0,10}]

g2[t_] := Graphics[{

 Point[{sbob[t],0}],
 beacons[t]

}]

g3[t_] := Show[g2[t], PlotRange->{{0,45},{-1,1}}]

ani = Table[g3[t],{t,0,20,.05}]
Export["/tmp/test.gif", ani, ImageSize -> {1024, 50}]

TODO: maybe improve graphic (and add x axes markings?) (or maybe just a fixed graphic)

(*

Subject: Constant acceleration in special relativity: a discrete approach

Q: Say Barry, could you abuse the answer-your-own-question feature of
this site and explain constant acceleration in relativity?

A:

Let's use the following setup for the start of our thought experiment:

  - Carol's clock $t$ reads $t=t_0$

  - Bob's clock $u$ reads $u=u_0$

  - Bob is traveling at a constant velocity of $v_0$, given as a
  fraction of the speed of light.

  - Carol sees Bob at a distance of $s_0$ light seconds.

  - Bob drops beacon #0. In Carol's frame, beacon #0 is $s_0$ distance
  from her and traveling at a velocity of $v_0$.

Bob then repeats the following process every second: 

  - instantly increases his velocity (accelerates) by $a$ (light seconds
  per second per second)

  - coasts for one second at his new velocity

  - drops a new beacon

Note that 1 light second per second per second is $299792.458
\frac{\text{km}}{s^2}$ so $a$ will normally be fractional.

<h4>Velocity</h4>

How fast is the nth beacon traveling in Carol's reference frame?

We know that Beacon #0 is traveling at $v_0$ by the given initial conditions.

Beacon #1 is traveling at $a$ with respect to Beacon #0, so we use the
relativistic velocity addition formula:

$v(1)=\text{add}(v_0,a)=\frac{a+v_0}{a v_0+1}$

Beacon #2 is traveling at $a$ with respect to Beacon #1, so we have:

$
   v(2)=\text{add}(v(1),a)=\text{add}\left(\frac{a+v_0}{1+a
    v_0},a\right)=\frac{\left(a^2+1\right) v_0+2 a}{a^2+2 a v_0+1}
$

In general, we have:

$v(n)=\text{add}(v(n-1),a)=\frac{a+v(n-1)}{a v(n-1)+1}$

Solving the recursion, we have:

$
   v(n)=\frac{(v_0+1) \left(\frac{a}{a-1}\right)^n+(v_0-1)
    \left(\frac{1}{a+1}-1\right)^n}{(v_0+1)
   \left(\frac{a}{a-1}\right)^n-(v_0-1) \left(\frac{1}{a+1}-1\right)^n}
$

Of course, this only applies when Bob is instantly accelerating every
second, not accelerating uniformly.

To find out what happens when Bob accelerates uniformly, we assume $k
n$ accelerations of $\frac{a}{k}$ each, and take the limit as $k\to
\infty$

$
v(n) = 
\lim_{k\to \infty } \,
\frac{(v_0+1)
\left(\frac{{\frac{a}{k}}}{{\frac{a}{k}}-1}\right)^{k n}+(v_0-1)
\left(\frac{1}{{\frac{a}{k}}+1}-1\right)^{k n}}{(v_0+1)
\left(\frac{{\frac{a}{k}}}{{\frac{a}{k}}-1}\right)^{k n}-(v_0-1)
\left(\frac{1}{{\frac{a}{k}}+1}-1\right)^{k n}}
= \frac{v_0 \cosh (a n)+\sinh (a n)}{v_0 \sinh (a n)+\cosh (a n)}
$

Thus, if Bob accelerates at a uniform rate of $a$ light seconds per
second per second, the velocity of the nth beacon is $\frac{v_0 \cosh
(a n)+\sinh (a n)}{v_0 \sinh (a n)+\cosh (a n)}$

<h4>Time</h4>

Bob is dropping a beacon every second in his reference frame. How
often does Carol see a beacon dropped in her reference frame?

Returning briefly to our original setup (non-uniform acceleration), we
note that Bob travels at (the discrete version of) $v(n)$ when he
drops Beacon #n, and then immediately accelerates to $v(n+1)$ and
travels for 1 second at $v(n+1)$ before dropping Beacon #n+1.

Since Bob is traveling at $v(n+1)$ between dropping Beacon #n and
Beacon #n+1, the time dilation between these two drops is:

$
\text{dilation}(v(n+1))=
\frac{1}{\sqrt{1-\left(\frac{2}{\frac{\left(v_0+1\right)
\left(\frac{a+1}{1-a}\right)^{n+1}}{v_0-1}-1}+1\right){}^2}}
$

Thus, while 1 second passes for Bob between the drops,

$
\frac{1}{\sqrt{1-\left(\frac{2}{\frac{\left(v_0+1\right)
\left(\frac{a+1}{1-a}\right)^{n+1}}{v_0-1}-1}+1\right){}^2}}
$

seconds pass for Carol.



For the continuous case, we once again assume $k$ accelerations of
$\frac{a}{k}$ per second and take the limit as $k\to \infty$.

Omitting the ugly math, this yields:

$dt(n,n+1) = \frac{v_0 \sinh (a n)+\cosh (a n)}{\sqrt{1-v_0^2}}$





dtbeacon[n_] = FullSimplify[Limit[dt[n*k] /. a -> a/k, k -> Infinity],conds]



each, and take the limit as $k\to

dt[n_] = FullSimplify[dilation[v[n+1]], conds] 



By our initial conditions, Beacon #0 is dropped at $t=t_0$.



Between dropping Beacon #0 and Beacon #1, Bob uniformly accelerates
from $v_0$ to $v(1) = \frac{v_0 \cosh (a)+\sinh (a)}{v_0 \sinh
(a)+\cosh (a)}$.

In general, between dropping Beacon #n and Beacon #n+1, Bob's velocity changes uniformly from $v(n) = \frac{v_0 \cosh (a n)+\sinh (a n)}{v_0 \sinh (a n)+\cosh (a n)}

$v(1)=\frac{a+v_0}{a v_0+1}$

By time dilation, Bob's one second becomes

$\frac{a v_0+1}{\sqrt{\left(a^2-1\right)\left(v_0^2-1\right)}}$

seconds in Carol's frame.

In general, the time in Carol's frame between dropping Beacon #n and
Beacon #n+1 (during which time Bob is traveling at $v(n+1)$ is:

$
\text{dt}(n)=   \frac{1}{\sqrt{1-\left(\frac{2}{\frac{(v_0+1)
    \left(\frac{a+1}{1-a}\right)^{n+1}}{v_0-1}-1}+1\right)^2}}
$

To find when the nth beacon is dropped, we simply add:

$
t(n)=   \sum _{i=0}^n \frac{1}{\sqrt{1-\left(\frac{2}{\frac{\left(v_0+1\right)
    \left(\frac{a+1}{1-a}\right)^{i+1}}{v_0-1}-1}+1\right){}^2}}+t_0
$

(there does not appear to be an easily-found closed form for this sum).

TODO: maybe not why I chose the hyperbolic rotation form


\lim_{k\to \infty } \, 
\frac{(v_0+1) 
\left(\frac{{\frac{a}{k}}}{{\frac{a}{k}}-1}\right)^{k n}+(v_0-1) 
\left(\frac{1}{{\frac{a}{k}}+1}-1\right)^{k n}}{(v_0+1) 
\left(\frac{{\frac{a}{k}}}{{\frac{a}{k}}-1}\right)^{k n}-(v_0-1) 
\left(\frac{1}{{\frac{a}{k}}+1}-1\right)^{k n}} 
= \frac{v_0 \cosh (a n)+\sinh (a n)}{v_0 \sinh (a n)+\cosh (a n)} 
$ 


$\frac{v_0 \coth
(a n)+1}{\coth (a n)+v_0}$





NOTE: I have dt[-1] equal to dtbeacon[0] off by one?




FullSimplify[Limit[v[n*k] /. a -> a/k, k -> Infinity], conds]



$  
   \frac{(v_0+1) \left(\frac{a}{a-1}\right)^n+(v_0-1)
    \left(\frac{1}{a+1}-1\right)^n}{(v_0+1)
   \left(\frac{a}{a-1}\right)^n-(v_0-1) \left(\frac{1}{a+1}-1\right)^n}
$



$
\lim_{k\to \infty } \,
   \frac{(\text{v(0)}-1) \left(\frac{1}{\frac{a}{k}+1}-1\right)^{k
    n}+(\text{v(0)}+1) \left(\frac{a}{k \left(\frac{a}{k}-1\right)}\right)^{k
    n}}{(\text{v(0)}+1) \left(\frac{a}{k \left(\frac{a}{k}-1\right)}\right)^{k
    n}-(\text{v(0)}-1) \left(\frac{1}{\frac{a}{k}+1}-1\right)^{k n}}
$


TODO: consider killing h4 headings

v[n*k] /. a -> a/k

(* this is the form I like best *)

vtrue[n_] = (1 + Coth[a*n]*v0)/(Coth[a*n] + v0)

vtest[n_] = (Tanh[a*n] + v0)/(1+Tanh[a*n]*v0)

vtrue[n]-vtest[n]


tacc = .002;
(* can't use v0 here, would override *)
vnull = .10;
tn = 1/tacc;
t1 = Table[{n, v[n] /. {a -> tacc, v0 -> vnull}}, {n,0,tn}]
t2 = Table[{n, vnull+tacc*n}, {n,0,tn}]
t3 = Table[{n, vtrue[n] /. {a -> tacc, v0 -> vnull}}, {n,0,tn}]

ListPlot[{t1-t3}]
showit

ListPlot[{t1,t2,t3}, PlotLegends -> {"Relativistic", "Newtonian"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Speed (fraction of c)", None}, {"Beacon #", None}},
 PlotLabel -> 
"Newtonian vs Relativistic Constant Acceleration\n(v(0) = 0.1, a = 0.002)"]
showit





TODO: ABOVE THIS LINE = NEWEST TREATMENT

To find Bob's velocity in Carol's frame at a given time $t$, 

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



let's
break up his $a$ acceleration per second into $\frac{a}{k}$ discrete
accelerations every $\frac{1}{k}$ of a second (coasting at constant
speed in between the accelerations), and take the limit.

We know Bob is initially ($t=t_0$) traveling at $v_0$ from the given
initial conditions.

After $\frac{1}{k}$ of a second has passed on Bob's clock, he
increases his speed (accelerates) by $\frac{a}{k}$.



After $\frac{1}{k}$ seconds, Bob has added $\frac{a}{k}$ to his
velocity, so we use the relativistic velocity addition formula:

$
v\left(\text{t0}+\frac{1}{k}\right)=\text{add}\left(\text{v0},
\frac{a}{k}\right)=\frac{a+k v_0}{a v_0+k}
$

After another $\frac{1}{k}$ seconds (and thus at 


TODO: change all \text{v0} to v_0, same for t0 and s0

$
  v\left(\frac{1}{k}\right)=\text{add}\left(v_0,\frac{a}{k}\right)=\frac{
    a+k v_0}{a v_0+k}
$




$v(1)=\text{add}(v_0,a)=\frac{a+v_0}{a v_0+1}$

HoldForm[v[t0+ 1/k]] == HoldForm[add[v0, a/k]] == 
 FullSimplify[add[v0,a/k]]





TODO: note that assumption of continuity of derivative is assumed


Bob drops Beacon #0, and then instantly accelerates (increases his
velocity by) $\frac{a}{k}$ (light seconds per second per second). He
then coasts for $\frac{1}{k}$ of a second, repeats this process $k$
times (where $k$ is a positive integer throughout), and then drops
another beacon. 

In other words, Bob is accelerating $a$ light seconds per second per
second, but is breaking this acceleration up into $k$ smaller steps of
$\frac{a}{k}$ acceleration, which will help us when we reach the
continuous case.



$a$ (light seconds per second
per second) for 1 second (in his own reference frame), and drops Beacon #1.

Bob repeats this procedure indefinitely: accelerating at $a$ for 1
second and dropping a beacon.

TODO: establish formulas we take as given

<h4>Distance</h4>

How far apart are the beacons dropped in Carol's frame?

We know that Beacon #0 is dropped at distance $s_0$ from Carol.

Bob then moves at $v(1)$ for $dt(0)$ seconds (in Carol's
frame). Multiplying these, we see that Bob moves a distance of:

$\frac{a+v_0}{\sqrt{\left(a^2-1\right) \left(v_0^2-1\right)}}$

before dropping Beacon #1.

Of course, since Beacon #0 was dropped at distance $s(0)$ from Carol,
the total distance to Beacon #1 is $s(0)$ plus the above.

Note that the beacons are moving (in Carol's reference frame) the
moment they're dropped, so we're only looking at the distance where
the nth beacon is dropped: it's actual distance changes as time
passes.

In general, the distance $ds(n)$ between dropping Beacon #n and Beacon
#n+1 is $v(n+1) dt(n)$ or

$
\text{ds}(n) = \frac{\frac{2}{\frac{(v_0+1)
   \left(\frac{a+1}{1-a}\right)^{n+1}}{v_0-1}-1}+1}{\sqrt{1-\left(\frac{2
    }{\frac{(v_0+1)
    \left(\frac{a+1}{1-a}\right)^{n+1}}{v_0-1}-1}+1\right)^2}}
$

To find where Beacon #n is dropped (in Carol's frame), we add:

$
   s(n)=\sum _{i=0}^n \frac{\frac{2}{\frac{\left(v_0+1\right) (1-a)^{-i-1}
    (a+1)^{i+1}}{v_0-1}-1}+1}{\sqrt{1-\left(\frac{2}{\frac{\left(v_0+1\right)
    \left(\frac{a+1}{1-a}\right)^{i+1}}{v_0-1}-1}+1\right){}^2}}+s_0
$



TODO: avoid words "our" and "his/her/their", use names





tacc = .002;

Table[{i, v[i], 



t3 = Table[{i,dt[i] /. {a -> tacc, v0 -> .10}}, {i, 0, tn}]


HoldForm[v[1/k]] == HoldForm[add[v0, a/k]] == add[v0,a/k]              
HoldForm[v[1]] == HoldForm[add[v0, a]] == add[v0,a] // TeXForm         

HoldForm[v[2]] == HoldForm[add[v[1], a]] == HoldForm[
 add[(a + Subscript[v, 0])/(1 + a*Subscript[v, 0]), a]] == 
 FullSimplify[add[v[1],a], conds]

TODO: change all v_0 to v_0, etc



TODO: simpler formula based on eyeballing it?

TODO: Graphics, not fully happy with my discrete -> cont jump

TODO: explain what cont actually means



TODO: convert time frame -> reference frame thruout





v[n] /. {n -> k*n, a -> a/k, v0 -> "v(0)"}

Limit[v[n] /. {n -> k*n, a -> a/k}, k -> Infinity]



conds = {n>0, k>0, Element[{n,k},Integers], Abs[a] < 1, Abs[v0] < 1,
 Element[{a,v0}, Reals]}

v[n_] = FullSimplify[
RSolve[{v[0] == v0, v[n+1] == add[v[n],a]}, v[n], n][[1,1,2]]
, conds]

v[n] /. {v0 -> "v(0)", n -> "kn"}

FullSimplify[v[k*n] /. a -> a/k, conds]

StringReplace[ToString[TeXForm[v[n]]], "a" -> "\\frac{a}{k}"]         













We take as given the formulas for relativistic velocity addition, time
dilation, and Lorentz contraction (all velocities given as a
percentage of the speed of light):

$\text{add}(u,v)=\frac{u+v}{u v+1}$

$\text{dilation}(\text{v$\_$})=\frac{1}{\sqrt{1-v^2}}$

TODO: add Carol

TODO: add contraction

TODO: Above is derivable

If $a=0.01$ (which means Bob is accelerating at 1% the speed of light
every second or about 2997.92458 kilometers per second per second),
let's see what the speed of the nth beacon would look like.

plot1 = Table[{n, v[n] /. a -> .01}, {n,0,200}]
plot2 = Table[{n, .01*n}, {n,0,200}]

ListPlot[{plot1,plot2}, PlotRange -> { {0,100}, {0,1}}, 
 PlotLegends -> {"Actual", "Newtonian"}]
showit

plot3 = Table[{n, v[n] /. a -> .01}, {n,0,1000}]

ListPlot[plot3]
showit

TODO: summary table

Table[{{n, v[n] /. a -> .01}, {n, .01*n}},{n,0,100}]


c = 299792458

v[n_] = 
 FullSimplify[RSolve[{v[0] == 0, v[n+1] == add[v[n],a]}, v[n], n][[1,1,2]],
 {Element[n,Integers], n>0, a>0}]

(* time between n-1st and nth beacon drop *)

dt[n_] = FullSimplify[1/Sqrt[1-v[n]^2], {a>0, a<1, Element[n, Integers], n>0}]

(* TODO: graph *)

conds = {a>0, n>0, Element[n,Integers]}

t[n_] = FullSimplify[Sum[dt[i], {i,1,n}],conds]

(* distance between n-1st and nth beacon drop *)

ds[n_] = FullSimplify[dt[n]*v[n], conds]

s[n_] = FullSimplify[Sum[ds[i],{i,1,n}],conds]

visible[n_] = FullSimplify[s[n]+t[n],conds]


TODO: explicit workout of time and position for 1, 2, 3 just to
confirm formulas

It turns out the nth beacon (computations omitted) 

add[u_,v_] = (u+v)/(1+u*v)

TODO: bob -> carol frame

TODO: send msg to nth beacon takes how long

TODO: return msg takes how long

TODO: how far, what time, and add light travel

TODO: mention git file

TODO: consider log plots where appropriate

TODO: s0 and v0 case? (and decel?)


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

(*

Subject: Help Mathematica FullSimplify functions from basic relativity

<pre><code>
v[n_] = 1 + 2/(-1 + ((1 + a)^n*(1 + v0))/((1 - a)^n*(-1 + v0)))
dt[n_] = 
   1/Sqrt[1 - (1 + 2/(-1 + (((1 + a)/(1 - a))^(1 + n)*(1 + v0))/(-1 + v0)))^2]
conds = {n>0, k>0, i>0, Element[{n,k,i},Integers], Abs[a] < 1, Abs[v0] < 1,
 Element[{a,v0}, Reals]}
</code></pre>

I'm convinced that both $v(n)$ and $dt(n)$ have a much simpler form
under the given $conds$, but `FullSimplify` won't give me one. Any
thoughts on how I can help Mathematica simplify these?

Background:

  - Using the basic time dilation and relativistic velocity addition
  formulas for special relativity:

TODO: finish this?


<pre><code>
conds = {n>0, k>0, i>0, Element[{n,k,i},Integers], Abs[a] < 1, Abs[v0] < 1,
 Element[{a,v0}, Reals]}

dilation[v_] = 1/Sqrt[1-v^2]

add[u_,v_] = (u+v)/(1+u*v)

v[n_] = FullSimplify[
RSolve[{v[0] == v0, v[n+1] == add[v[n],a]}, v[n], n][[1,1,2]]
, conds]

dt[n_] = FullSimplify[dilation[v[n+1]], conds] 
</code></pre>

