(*

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



