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

a = 10/300/10^6
conds = {t>0, a>0, v>0, v<1}
factor[v_] = (1-v^2)^(-1/2)
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

