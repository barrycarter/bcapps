(*

Subject: Clock on constantly accelerating object approaches Gudermannian limit?

If an object is moving away from X with a constant acceleration of
`a`, its velocity at time t (relative to X and accounting for
relativity) is given by:

$v(t)=\tanh (a t)$

If an object is traveling at velocity `v` (measured as a fraction of
the speed of light) relative to X, the time dilation factor is:

$\sqrt{1-v^2}$

For example, if an object is traveling at .99c relative to X, the time
dilation factor is approximately 0.14, meaning that for every second X
measures on its own clock, it sees 0.14 seconds ticked off on the
moving object's clock.

Combining these two equations, I find the time dilation factor for an
object with constant acceleration `a` is:

$\sqrt{1-v(t)^2}=\sqrt{1-\tanh ^2(a t)}=\text{sech}(a t)$

In other words, at time t for X, the object's clock is ticking at
$\text{sech}(a t)$ seconds for every second on X's clock.

To find the total elapsed time, I should be able to just integrate:

$
\int \text{sech}(a t) \, dt = \frac{2 \tan ^{-1}\left(\tanh
\left(\frac{a t}{2}\right)\right)}{a} = \frac{\text{gd}(a t)}{a}
$

where `gd` is the Gudermannian function.

The problem: as t approaches infinity...

$\lim_{t\to \infty } \, \frac{\text{gd}(a t)}{a} = \frac{\pi }{2 a}$

If true, this means X will never see the object's clock pass
$\frac{\pi }{2 a}$.

This seems incorrect. What am I doing wrong?

Note: I came across this while attempting to answer
http://astronomy.stackexchange.com/questions/13817/

EDIT (to answer @Timaeus):

Here's the discrete analog of what I (the moving object) am
doing. Every second:

  - I drop a beacon that has zero relative velocity to me.

  - I accelerate until I'm traveling at 10m/s (or whatever `a` I
  choose) with respect to the beacon.

I believe:

  - When smoothed out to be continuous, I will feel a constant acceleration.

  - As viewed from X (the stationery observer), my velocity is tanh(a*t)

You mention in your answer "for every unit of your time the object
accelerates to the speed of an object that it currently thinks is
moving at a certain speed. But this means it has to accelerate at a
faster rate according to its own clock", but I'm not sure I understand
this.

As I see it, the moving object can be seen as accelerating with
respect to a beacon it just dropped, and the small 10m/s velocity
increase shouldn't have significant time dilation. In the continuous
case, there should be no time dilation at all.

I believe your answer is correct, but think I'm still missing something.

EDIT (this is the discrete case, just for fun, but with my
misunderstanding corrected):

NOTE: for the below "my" refers to the accelerating frame of reference
and "fixed" refers to non-accelerating frame of reference.

The formula for adding relativistic velocities (when both are given as
a fraction of light speed) is:

$\text{add}(u,v)=\frac{u+v}{u v+1}$

If I start at zero velocity (with respect to some fixed X), and follow
the process above (drop beacons and accelerate by `a` where `a` is
much smaller than `c`) every second of **my** time, my speed as viewed
by the fixed observer is given by:

$\text{speed}(a,0)=0$
$\text{speed}(a,n+1)=\frac{a+\text{speed}(a,n)}{a * \text{speed}(a,n)+1}$

The closed-form solution (simplest form Mathematica could find):

$\text{speed}(a,n)=\frac{2}{\left(\frac{2}{a+1}-1\right)^n+1}-1$

**Although I'm dropping beacons every 1 second in my own time frame, I
am dropping them slower and slower to the fixed observer
X. This was the crux of my misunderstanding**

For the fixed observer, how much time passes between my dropping
beacon $n$ and beacon $n+1$?

When 1 second passes on my clock, time dilation tells me
$\frac{1}{\sqrt{1-\text{speed}(a,n)^2}}$ passes on the fixed
observer's clock. Plugging in $\text{speed}(a,n)$ and simplifying:

$\text{dilation}(a,n) = 
\frac{1}{2} \left(1-a^2\right)^{-n/2} \left((1-a)^n+(a+1)^n\right)$

For the continuous case, we accelerate $\frac{a}{k}$ (k times slower)
$k n$ (k times as often) and take the limit as $k\to \infty$. This yields:

$\text{contspeed}(n)=\lim_{k\to \infty } \, \text{speed}\left(\frac{a}{k},
nk\right) = \tanh (a n)
$

Note this is the same value I had earlier, but that it refers to
seconds elapsed in **my** frame of reference.

How many seconds have elapsed in the fixed frame of reference in the
continuous case? The instantaneous time dilation is:

$
\text{contdilation}(a,n) = 
lim_{k\to \infty } \text{dilation}\left(\frac{a}{k}, nk\right) =
lim_{k\to \infty }
\frac{1}{2} \left(k^2-a^2\right)^{-\frac{k n}{2}} \left((k-a)^{k n}+(a+k)^{k
n}\right) = \cosh (a n)
$

Thus, when the nth infinitesimal time unit ticks off in my reference
frame, $\cosh (a n)$ infinitesimal time units tick off in the fixed
frame. The total elapsed time for the fixed frame is simply the
integral of this or $\frac{\sinh (a n)}{a}$

So, when $\frac{\sinh (a n)}{a}$ seconds have elapsed in the fixed
reference frame, my speed (relative to the fixed reference frame) is
$\tanh (a n)$:

$\text{fixedspeed}\left(\frac{\sinh (a n)}{a}\right)=\tanh (a n)$

To solve, we apply this change of variable to both sides:

$n\to \frac{\sinh ^{-1}(a x)}{a}$

to yield:

$\text{fixedspeed}(n)=\frac{a n}{\sqrt{a^2 n^2+1}}$

which is equivalent to @timeaus' answer for v(t).

The total distance is just the integral of this, or:

$\text{fixeddist}(a,n)=\int \text{fixedspeed}(a,n) \, dn = 
\frac{\sqrt{a^2 n^2+1}}{a}$

which, as expected, is equivalent to timeaus' answer for x(t).

MATHEMATICA NOTES:

timeaus[a_,n_] = FullSimplify[c^2*t/(Sqrt[c^4/a^2 + c^2*t^2]),
 {t>0,a>0,c==1}] /. t -> n

fixedspeed[a_,n_] = a*n/Sqrt[(a*n)^2+1]

conds = {a>0,a<1,n>0,Element[n,Integers],k>0}

add[u_,v_] = (u+v)/(1+u*v)

speed[a_, n_] = 
FullSimplify[RSolve[{v[0] == 0, v[n] == add[v[n-1],a]}, v[n], n][[1,1,2]],
 {a>0,a<1,n>0,Element[n,Integers]}]

dv[a_,n_] = FullSimplify[speed[a,n+1]-speed[a,n], 
 {a>0,a<1,n>0,Element[n, Integers]}]

factor[v_] = (1-v^2)^(-1/2)

dilation[a_,n_] = FullSimplify[factor[speed[a,n]],conds]

elapsed[a_,n_] = FullSimplify[Sum[dilation[a,i],{i,0,n}],conds]

accel[a_,n_] = FullSimplify[dv[a,n]/dilation[a,n],conds]

Solve[lspeed[elapsed[a,n]] == speed[a,n], lspeed[n]]

TODO: spell check

*)

(*

Answer to main question starts here.









a = 10/300/10^6
conds = {t>0, a>0, v>0, v<1}
speed[t_] = Tanh[a*t]
distance[t_] = Integrate[speed[t],t]
rate[t_] = FullSimplify[1/factor[speed[t]], conds]
elapsed[t_] = FullSimplify[Integrate[rate[t],t],conds]
distrat[t_] = FullSimplify[1/factor[speed[t]],conds]
totdist[t_] = 

FullSimplify[Integrate[speed[t]*distrat[t],t],conds]

TODO: it would be more fun to derive these from first principles

This doesn't fully answer your question.

As you accelerate away from star 1 at 10m/s^2, Newtonian mechanics
would give your velocity at time t as 10*t.

travels distance u in 1 second

your distance u = u/factor[v], factor[v], or u + v - uv^2

accel = 10/300/10^6

Solve[Tanh[accel*t] == .6, t]

I say: .5 light seconds in 1 second

converted: 0.433013 light seconds in 1.1547s or 


factor[v_] = (1-v^2)^(-1/2)

Plot[1-v^2,{v,0,1}]

DSolve[{v'[t] == u*(1-v[t]^2),v[0]==0},v[t],t]

u = 10/300000000

Plot[Tanh[t*u]*300000000,{t,0,30000000},PlotRange->All]

f[u_] = u + u*(1-u^2)

RSolve[{
 a[n+1] == a[n] + a[n]*(1-a[n]^2),
 a[0] == 2
},
a[n],n]

(* integrating the addition equation; uv in fractional light speed *)

(* putting in c^2 just to make things happy *)

add2[u_,v_] = (u+v)/(1+u*v/c^2)
Simplify[(add[v,dv]-v)/dv]




test[0] = 0;

test[n_] := test[n] = add[test[n-1],.01]

tab = Table[test[n],{n,0,1000}];
dtab = difference[tab];

v2[t_] = FullSimplify[c^2*t/Sqrt[c^4/a^2+c^2*t^2], Element[{a,c,t},Reals]]

v2[t_] = v2[t] /. {c -> 1, a -> .01}

Maximize[Tanh[.01*t]-v2[t],t]                                          
0.0736882, {t -> 162.195}

v[0] = 0;

v[n_] := v[n] = (a + v[n-1])/(1 + a*v[n-1])

Solve[(a + x)/(1+a*x) == x, x]

g[n_] = FullSimplify[
v[n] /. RSolve[{v[0] == 0, v[n] == (a+v[n-1])/(1+a*v[n-1])}, v[n], n],
Element[a, Reals]][[1]]

f[n_] = FullSimplify[
RSolve[{speed[0] == 0, speed[n] == (a+speed[n-1])/(1+a*speed[n-1]/c^2)},
 speed[n], n][[1,1,2]], {a>0, c>0, n>=0, Element[n, Integers]}]




RSolve[{v[0] == 0, v[n] == (a+speed[n-1])/(1+a*speed[n-1])}, v[n], n]



