(* formulas start here *)

conds = {n>0, k>0, i>0, Element[{n,k,i},Integers], Abs[a] < 1, Abs[v0] < 1,
 Element[{a,v0}, Reals]};

dilation[v_] = 1/Sqrt[1-v^2];

add[u_,v_] = (u+v)/(1+u*v);

v[n_] = FullSimplify[
RSolve[{v[0] == v0, v[n+1] == add[v[n],a]}, v[n], n][[1,1,2]] , conds];

dt[n_] = FullSimplify[dilation[v[n+1]], conds];

ds[n_] = FullSimplify[dt[n]*v[n+1], conds];

(* formulas end here *)

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

TODO: maybe improve graphic (and add x axes markings?)

(*

Subject: Constant acceleration in special relativity: a discrete approach

Q: Say Barry, could you abuse the answer-your-own-question feature of
this site and explain constant acceleration in relativity?

A:

At t=0, Bob is $s(0)$ light seconds away from Carol and moving a
velocity of $v(0)$ (given as a fraction of the speed of light).

Bob then drops Beacon #0, accelerates at $a$ (light seconds per second
per second) for 1 second (in his own reference frame), and drops Beacon #1.

Bob repeats this procedure indefinitely: accelerating at $a$ for 1
second and dropping a beacon.

TODO: establish formulas we take as given

<h4>Velocity</h4>

How fast is the nth beacon traveling from Carol's reference frame?

We know Beacon #0 is traveling at $v(0)$ from the given initial conditions.

Beacon #1 is traveling at $a$ with respect to Beacon #0, so we use the
relativistic velocity addition formula:

$v(1)=\text{add}\left(v(0),a\right)=\frac{a+v(0)}{a v(0)+1}$

Beacon #2 is traveling at $a$ with respect to Beacon #1, so we have:

$
   v(2)=\text{add}(v(1),a)=\text{add}\left(\frac{a+v(0)}{1+a
    v(0)},a\right)=\frac{a (a v(0)+2)+v(0)}{a^2+2 a v(0)+1}
$

In general, we have:

$v(n)=\text{add}(v(n-1),a)=\frac{a+v(n-1)}{a v(n-1)+1}$

Solving the recursion, we have:

$
   v(n)=\frac{(\text{v(0)}+1) \left(\frac{a}{a-1}\right)^n+(\text{v(0)}-1)
    \left(\frac{1}{a+1}-1\right)^n}{(\text{v(0)}+1)
   \left(\frac{a}{a-1}\right)^n-(\text{v(0)}-1) \left(\frac{1}{a+1}-1\right)^n}
$

tacc = .002;
tn = 1/tacc;
t1 = Table[{n,v[n] /. {a -> tacc, v0 -> .10}}, {n,0,tn}]
t2 = Table[{n,.10+tacc*n}, {n,0,tn}]
ListPlot[{t1,t2}, PlotLegends -> {"Relativistic", "Newtonian"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Speed (fraction of c)", None}, {"Beacon #", None}},
 PlotLabel -> 
"Newtonian vs Relativistic Constant Acceleration\n(v(0) = 0.1, a = 0.002)"]
showit


TODO: make sure all v0 in TeX is v(0)

TODO: simpler formula based on eyeballing it?

TODO: Graphics, not fully happy with my discrete -> cont jump

TODO: explain what cont actually means

<h4>Time</h4>

Bob is dropping a beacon every second in his reference frame. How
often does Carol see a beacon dropped?

By our initial conditions, Beacon #0 is dropped at $t=0$.

Between dropping Beacon #0 and Beacon #1, Bob travels at:

$v(1)=\frac{a+\text{v(0)}}{a \text{v(0)}+1}$

By time dilation, Bob's one second becomes

$
   \frac{a \text{v(0)}+1}{\sqrt{\left(a^2-1\right)
    \left(\text{v(0)}^2-1\right)}}
$

seconds in Carol's frame.

In general, the time in Carol's frame between dropping Beacon #n and
Beacon #n+1 (during which time Bob is traveling at $v(n+1)$ is:

$
   \frac{1}{\sqrt{1-\left(\frac{2}{\frac{(\text{v0}+1)
    \left(\frac{a+1}{1-a}\right)^{n+1}}{\text{v0}-1}-1}+1\right)^2}}
$

t3 = Table[{i,dt[i] /. {a -> tacc, v0 -> .10}}, {i, 0, tn}]

<h4>Distance</h4>

How far apart are the beacons dropped in Carol's frame?

We know that Beacon #0 is dropped at distance $s(0)$ from Carol.

Bob then moves at $v(1)$ for $dt(0)$ seconds (in Carol's
frame). Multiplying these, we see that Bob moves a distance of:

$\frac{a+\text{v0}}{\sqrt{\left(a^2-1\right) \left(\text{v0}^2-1\right)}}$

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
   \frac{\frac{2}{\frac{(\text{v0}+1)
   \left(\frac{a+1}{1-a}\right)^{n+1}}{\text{v0}-1}-1}+1}{\sqrt{1-\left(\frac{2
    }{\frac{(\text{v0}+1)
    \left(\frac{a+1}{1-a}\right)^{n+1}}{\text{v0}-1}-1}+1\right)^2}}
$





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

