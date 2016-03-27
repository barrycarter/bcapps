(*

http://physics.stackexchange.com/questions/14362

I just got a fantastic answer to this in chat, and wanted to share it.

Consider the Newtonian analog: a stick of unknown length is moving at
velocity $v$ away from you:

  - You see the left end at time $t$ and it's $x$ meters away. You
  can't see the right end.

  - At time $t+dt$, you see the right end and it's $x+dx$ away. You
  can't see the left end.

How long is the stick?

You obviously wouldn't measure the stick's length as $dx$ (the
distance between your two observations), since the stick moved between
those two observations.

How much did it move? Well, the time between the observations was $dt$
and the stick is moving at velocity $v$, so it moved $v \text{dt}$.

Subtracting off this movement, we see that the stick's length is
$\text{dx}-\text{dt} v$

Now, let's do the problem using special relativity.

An observer is traveling at velocity $v$ with respect to you and, at
the instant he passes you, he observes two simultaneous events: one at
his origin (the point where he passes you) and the other 1m away.

You see the first event at $\{0,0\}$ in your frame, but how about the
other one. Applying the relativity transform matrix:

$
   \left(
   \begin{array}{cc}
    \frac{1}{\sqrt{1-v^2}} & \frac{v}{\sqrt{1-v^2}} \\
    \frac{v}{\sqrt{1-v^2}} & \frac{1}{\sqrt{1-v^2}} \\
   \end{array}
   \right).\{0,1\}=\left\{\frac{v}{\sqrt{1-v^2}},\frac{1}{\sqrt{1-v^2}}\right\}
$

As you note, the resulting distance, $\frac{1}{\sqrt{1-v^2}}$ is
longer than 1m.

However, applying the correction we discovered in the Newtonian analog:

$
\frac{1}{\sqrt{1-v^2}}-v \text{dt}\to \frac{1}{\sqrt{1-v^2}}-v
\frac{v}{\sqrt{1-v^2}}\to \sqrt{1-v^2}
$

I found it remarkable that the $\text{dx}-\text{dt} v$ exactly flipped
the fraction so that an expansion of $\sqrt{1-v^2}$ turned into a
contraction of $\sqrt{1-v^2}$

In some sense, the Lorentz contraction is a "hoax" that occurs only
because objects exist (persist) over a period of time.

In our "flashing meter stick" example above, we never see the entire
meter stick at once, so we realize there's a time delay between the
two ends.

However, if the meter stick existed continuously (as most true objects
do), we would never realize that we're seeing one end of the meter
stick at a different time than we're seeing the other end, and the
length we assign is due to this delay.





Apply[Divide,Reverse[relativityMatrix[v].{t,0}]] == v

(so it converts your frame to my frame)

test0818 = relativityMatrix[v].{dt,dv}

speed[vec_] := vec[[2]]/vec[[1]]

test0819 = Simplify[speed[test0818]]

(* new velocity is beta *)

test0820 = relativityMatrix[v].{dt,dt*beta}

Simplify[speed[test0820]]

in the frame of the accelerated item this is? 

relativityMatrix[v].relativityMatrix[dt*beta].{t,0}

conds = {t>0, t1>t0, t0>0, v>0, Element[{s0,v0,a,d0,d1}, Reals]}

v0*(t+dt) + a*(t+dt)^2 - (v0*t + a*t^2)

test2127 = {dt, dt*(a*(dt + 2*t) + v0)}

Simplify[relativityMatrix[v].test2127, conds]

(*

event occurs in my frame: t0 to t1 and d0 to d1

*)

len = FullSimplify[relativityMatrix[v].{t1-t0,d1-d0},conds]

(* time/dist from crossing to start of event *)

start = FullSimplify[relativityMatrix[v].{t0,d0},conds]

Simplify[len+start, conds]

start2 = FullSimplify[start + {start[[2]], 0},conds]

FullSimplify[relativityMatrix[v].{dt,a*dt^2/2},conds]











TODO: include eyeball time formulas

m[v].{t,0}
m[v].{0,d}

simple case: object is moving at 'v' in my frame and ejects an object
that moves at 'dv' after 'dt' (in the object's time frame)

(this is wrong I'm using an unnecess ref frame)
(m[v].{dt,a*dt} - m[v].{t,v*t})/dt

m[v].{t,u*t}

temp0924= FullSimplify[m[v].{dt, a*dt^2/2}]

temp0925 = FullSimplify[temp0924[[2]]/temp0924[[1]]]-v

temp0926 = FullSimplify[temp0925/temp0924[[1]]]

temp0938 = (a*(1 - v^2)^(3/2))/2

problem: this assumes accels come from orig frame?

temp0947 = FullSimplify[temp0924[[2]]/temp0924[[1]]]

temp0949 = FullSimplify[m[temp0947].{dt, a*dt^2/2}]

temp0952 = FullSimplify[temp0949[[2]] - temp0924[[2]]]

temp0953 = FullSimplify[temp0949[[1]] - temp0924[[1]]]

temp0954 = FullSimplify[temp0952/temp0953]

derv[t_] = (s[t+dt]-s[t])/dt

(derv[t+dt]-derv[t])/dt

m[v+a*dt].{dt,a*dt^2/2}

m[v].{t,0}

m[-v].{t,s0+v*t}

from the v frame, object accelerates over dt to go a*dt^2/2

m[v].{dt, a*dt^2/2}

m[v].{v*t,t}

m[v].{v*(t+1),t}

m[0.5].{2,4}

m[0.5].{1,2}

m[0.5].{1,t}


Experimenting w/ answer to my question below:

B: distance between 2 points is 60m

C: I'm at 0.866c (gamma=2), so the distance is 30m

D: I'm at 0.942c (gamma=3) with respect to C, so I assume the distance
is 10m for me.

Since the factor between B and D is 6, we conclude D's velocity is 0.986c.

Relativistic addition, however, gives: 0.996 however (gamma = 10.8)

m[.995].{100,.995}

Solve[m[.995].{t,x} == {10,9.95},{t,x}]

m[.995].{100,.995}

m[.995].{t, .995*t}

m[.995].{100,99.5}

m[-.995].{10,0}
m[-.995].{10,9.95}

m[.99].{10,0}

m[.99].{10,10}

c(len) = 

m[-.995].{10,0}

m[-.995].{10,9.95}

m[-.995].{t,9.95}

m[-.995].{0,9.95}

Subject: Error in deriving relativity velocity addition formula

$D$ is traveling at .995c with respect to $C$ who is traveling at
.995c with respect to $B$ all in the same direction. We want to
compute $D$'s velocity as observed from $B$. Note that the Lorentz
contraction/time dilation factor for .995c is $\sqrt{1-0.995^2}$ which
I will approximate as 1/10. Now:

  - $C$ announces "my clock reads 10 seconds, and $D$ is .995*10 or
  9.95 light seconds ahead of me".

  - $B$ converts this reading to his own frame of reference:

    - 10 seconds of $C$ time is 100 seconds of my time.

    - 9.95 light seconds of $C$ distance is 0.995 light seconds of my distance.

    - Thus, the distance between $C$ and $D$ is 0.995 light seconds
    when my clock reads 100 seconds.

    - Since I know $C$ is 99.5 light seconds away at 100 seconds, and
    I know (from above) that $D$ is .995 light seconds further out.

    - Thus $D$ is 99.5+.995 = 100.495 light seconds away from me at
    100 seconds.

    - However, this would mean $D$ is traveling faster than light in
    my reference frame (100.495 light seconds in 100 seconds =
    1.00495c), which is impossible.

What have I done wrong?

I know the correct formula for relativistic velocity addition (which
would give $D$ a speed of 0.999987c), but just want to know why I
didn't get that answer.

I also realize there are several similar questions, but I don't think
there's one that exactly addresses this (mis)-derivation.

END OF Q HERE

I am observing something at v0*t and its observing something at u0*t,
what is my observed position for it?

thing: at time t, I observer position u0*t

me: at time t/Sqrt[1-v0^2], I observe u0*t*Sqrt[1-v0^2]

t*u0*(1-v0^2) = where I see it?

example:

Obs: at 5 seconds, it's at 5*3 = 15 units away

Me: at 5/Sqrt[1-v0^2] seconds, its 15*Sqrt[1-v0^2] away

so 3*(1-v0^2) is the velo for me (assuming I was in obs frame)

at time = 10 seconds, I report object is 9 light seconds away

me: 22.9416 seconds, distance of object from you is 3.92 light seconds and obs is 20.6474 light seconds, so

22.9416 seconds -> 24.5674 light seconds -> 

other way:

10 seconds of my time: B is 9 light seconds away and 4.3589 have
elapsed on his clock; he thus sees C 3.923 light seconds away

for me thats 1.71 light seconds










*)



(* formulas start here *)

BELOW THIS IS WRONG; MUST ACCOUNT FOR TIME DIFF TOO

stationReladist[a_,s0_,v0_,t_]= 
 s0+t*v0+((-1 + Sqrt[1 + a^2*t^2])*Sqrt[1 - v0^2])/a
stationNewtdist[a_,s0_,v0_,t_] = s0 + v0*t + a*t^2/2

g = 98/10/299792458;
y2s = 31556952;

conds = {Element[{a,s0,v0,t},Reals]}

stationRelavel[a_,s0_,v0_,t_] = v0 + (a*t*Sqrt[1 - v0^2])/Sqrt[1 + a^2*t^2]
stationNewtvel[a_,s0_,v0_,t_] = a*t + v0

stationRelaacc[a_,s0_,v0_,t_] = (a*Sqrt[1 - v0^2])/(1 + a^2*t^2)^(3/2)
stationNewtacc[a_,s0_,v0_,t_] = a

shipReladist[a_,s0_,v0_,t_] = Log[Cosh[a*t]]/a + t*v0*Sech[a*t]
shipRelavel[a_,s0_,v0_,t_] = Tanh[a*t] + Sech[a*t]*(v0 - a*t*v0*Tanh[a*t])

(* formulas end here *)

Plot[stationRelavel[g,0,.9,t*y2s],{t,0,10}]

(*

This is a rewrite of bc-solve-astronomy-13817.m which was getting
hideously nasty. This only includes formulas and my brief notes, and
attempts to make derivations easier (and also computes light travel
time issues).

TODO: all todos from bc-solve-astronomy-13817.m still apply

*)


Solve[stationRelavel[a,0,0,t] == s, t]


FullSimplify[shipReladist[a,s0,v0,t],conds] 

FullSimplify[Solve[relavel[a,s0,v0,t] == s,t,Reals], {s>0}]

Plot[reladist[g,0,0,t*y2s]/y2s,{t,0,5}]

Plot[relavel[g,0,0,t*y2s],{t,0,5}]



