(* formulas start here *)

(*

Formulas are given in Mathematica input format, after significant
simplification, as shown later in this file.

Formulas that depend on t are given for a,s,d,t (in that order) even
when they don't involve all four variables.

Formulas that don't depend on t are given for a,s,d (in that order),
even when they don't involve all three variables.

*)

(* 

original form of below (conds applies to all functions):

conds = {t>0, a>0, v>0, v<1, s<1, s>0}

speedA2B[a_,s_,d_,t_] = a*t/Sqrt[(a*t)^2+1]
distA2B[a_,s_,d_,t_] = FullSimplify[Integrate[speedA2B[a,s,d,u],{u,0,t}],conds]
totalTimeA2B[a_,s_,d_] = Solve[speedA2B[a,s,d,t]==s,t][[2,1,2]]
totalDistA2B[a_,s_,d_] = FullSimplify[Integrate[speedA2B[a,s,d,u],{u,0,
 totalTimeA2B[a,s,d]}], conds]

*)

conds = {t>0, a>0, v>0, v<1, s<1, s>0} 

speedA2B[a_, s_, d_, t_] = (a*t)/Sqrt[1 + a^2*t^2]
distA2B[a_, s_, d_, t_] = (-1 + Sqrt[1 + a^2*t^2])/a
totalTimeA2B[a_, s_, d_] = s/Sqrt[a^2 - a^2*s^2]
totalDistA2B[a_, s_, d_] = (-1 + 1/Sqrt[1 - s^2])/a

(* raw form of below:

speedB2C[a_,s_,d_,t_] = s
distB2C[a_,s_,d_,t_] = s*t
totalTimeB2C[a_,s_,d_] = FullSimplify[(d-2*totalDistA2B[a,s,d])/s, conds]
totalDistB2C[a_,s_,d_] = FullSimplify[totalTimeB2C[a,s,d]*s, conds]

*)

speedB2C[a_, s_, d_, t_] = s
distB2C[a_, s_, d_, t_] = s*t
totalTimeB2C[a_, s_, d_] = (2 + a*d - 2/Sqrt[1 - s^2])/(a*s)
totalDistB2C[a_, s_, d_] = (2 + a*d - 2/Sqrt[1 - s^2])/a

(* raw form of below:

TODO: check these when using actual numbers

speedC2D[a_,s_,d_,t_] = FullSimplify[
 speedA2B[a,s,d,totalTimeA2B[a,s,d]-t],conds]

distC2D[a_,s_,d_,t_] = FullSimplify[totalDistA2B[a,s,d] - 
 distA2B[a,s,d,totalTimeA2B[a,s,d]-t], conds]

totalTimeC2D[a_,s_,d_] = totalTimeA2B[a,s,d];
totalDistC2D[a_,s_,d_] = totalDistA2B[a,s,d];

*)

speedC2D[a_, s_, d_, t_] = (s - a*Sqrt[1 - s^2]*t)/
    Sqrt[1 + a*t*(a*t - s*(2*Sqrt[1 - s^2] + a*s*t))]

distC2D[a_, s_, d_, t_] = 
   (1 - Sqrt[1 + a*t*(a*t - s*(2*Sqrt[1 - s^2] + a*s*t))])/(a*Sqrt[1 - s^2])

totalTimeC2D[a_, s_, d_] = s/Sqrt[a^2 - a^2*s^2]

totalDistC2D[a_, s_, d_] = (-1 + 1/Sqrt[1 - s^2])/a

(* raw form of below:

speedA2D[a_,s_,d_,t_] = 
 Which[t<0, 0, 
 t < totalTimeA2B[a,s,d], speedA2B[a,s,d,t],
 t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d], 
     speedB2C[a,s,d,t-totalTimeA2B[a,s,d]],
 t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d]+totalTimeC2D[a,s,d],
     speedC2D[a,s,d,t-totalTimeA2B[a,s,d]-totalTimeB2C[a,s,d]],
   True, 0];

distA2D[a_,s_,d_,t_] = 
 Which[t<0, 0, 
   t<  totalTimeA2B[a,s,d], 
       distA2B[a,s,d,t],
   t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d], 
       totalDistA2B[a,s,d] + distB2C[a,s,d,t-totalTimeA2B[a,s,d]],
   t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d]+totalTimeC2D[a,s,d],
       totalDistA2B[a,s,d]+totalDistB2C[a,s,d]+
        distC2D[a,s,d,t-totalTimeA2B[a,s,d]-totalTimeB2C[a,s,d]],
   True, d];

totalTimeA2D[a_,s_,d_] = FullSimplify[
 totalTimeA2B[a,s,d] + totalTimeB2C[a,s,d] + totalTimeC2D[a,s,d], conds];

totalDistA2D[a_,s_,d_] = FullSimplify[
 totalDistA2B[a,s,d] + totalDistB2C[a,s,d] + totalDistC2D[a,s,d], conds]

*)

speedA2D[a_, s_, d_, t_] =
 Which[t<0, 0, 
 t < totalTimeA2B[a,s,d], speedA2B[a,s,d,t],
 t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d], 
     speedB2C[a,s,d,t-totalTimeA2B[a,s,d]],
 t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d]+totalTimeC2D[a,s,d],
     speedC2D[a,s,d,t-totalTimeA2B[a,s,d]-totalTimeB2C[a,s,d]],
   True, 0];

distA2D[a_,s_,d_,t_] = 
 Which[t<0, 0, 
   t<  totalTimeA2B[a,s,d], 
       distA2B[a,s,d,t],
   t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d], 
       totalDistA2B[a,s,d] + distB2C[a,s,d,t-totalTimeA2B[a,s,d]],
   t < totalTimeA2B[a,s,d]+totalTimeB2C[a,s,d]+totalTimeC2D[a,s,d],
       totalDistA2B[a,s,d]+totalDistB2C[a,s,d]+
        distC2D[a,s,d,t-totalTimeA2B[a,s,d]-totalTimeB2C[a,s,d]],
   True, d];

totalTimeA2D[a_, s_, d_] = (2 + a*d - 2*Sqrt[1 - s^2])/(a*s)

totalDistA2D[a_, s_, d_] = d

(* from ship perspective *)

shipSpeedA2B[a_, s_, d_, t_] = Tanh[a*t]
shipDistA2B[a_, s_, d_, t_] = Log[Cosh[a*t]]/a
shipTotalTimeA2B[a_, s_, d_] = ArcTanh[s]/a
shipTotalDistA2B[a_, s_, d_] = -Log[1 - s^2]/(2*a)

shipSpeedB2C[a_, s_, d_, t_] = s
shipDistB2C[a_, s_, d_, t_] = s*t
shipTotalDistB2C[a_, s_, d_] = (-2 + 2*Sqrt[1 - s^2] + a*d*Sqrt[1 - s^2])/a
shipTotalTimeB2C[a_, s_, d_] = (-2 + 2*Sqrt[1 - s^2] + a*d*Sqrt[1 - s^2])/(a*s)


shipSpeedC2D[a_, s_, d_, t_] = -Tanh[a*t - ArcTanh[s]]

shipDistC2D[a_, s_, d_, t_] = -(Log[1 - s^2] + 2*Log[Cosh[a*t - ArcTanh[s]]])/
    (2*a)

shipTotalTimeC2D[a_, s_, d_] = ArcTanh[s]/a
shipTotalDistC2D[a_, s_, d_] = -Log[1 - s^2]/(2*a)

(* TODO: need shipDistA2D *)

shipSpeedA2D[a_, s_, d_, t_] =
 Which[t<0, 0, 
 t < shipTotalTimeA2B[a,s,d], shipSpeedA2B[a,s,d,t],
 t < shipTotalTimeA2B[a,s,d]+shipTotalTimeB2C[a,s,d], 
     shipSpeedB2C[a,s,d,t-shipTotalTimeA2B[a,s,d]],
 t < shipTotalTimeA2B[a,s,d]+shipTotalTimeB2C[a,s,d]+shipTotalTimeC2D[a,s,d],
     shipSpeedC2D[a,s,d,t-shipTotalTimeA2B[a,s,d]-shipTotalTimeB2C[a,s,d]],
   True, 0];

shipTotalTimeA2D[a_,s_,d_] = (-2 + 2*Sqrt[1 - s^2] + a*d*Sqrt[1 - s^2] + 
 2*s*ArcTanh[s])/(a*s)

shipTotalDistA2D[a_,s_,d_] = (-2 + 2*Sqrt[1 - s^2] + a*d*Sqrt[1 - s^2] - 
 Log[1 - s^2])/a

(* some special numbers *)

g = 98/10/299792458;

y2s = 31556952;

(* formulas end here *)

shipSpeedC2D[a_,s_,d_,t_] = FullSimplify[
 shipSpeedA2B[a,s,d,shipTotalTimeA2B[a,s,d]-t],conds]


shipDistC2D[a_,s_,d_,t_] = FullSimplify[shipTotalDistA2B[a,s,d] - 
 shipDistA2B[a,s,d,shipTotalTimeA2B[a,s,d]-t], conds]

(*

[[image1.jpg]]

$
   \begin{array}{lllll}
    \text{Distance} & \text{30 ly} & \text{40 ly} & \text{50 ly} & \text{x ly}
      \\
    \text{Ship Time} & \text{40.70 years} & \text{54.03 years} & \text{67.36 years} & \text{0.697602 + 4x/3 years} \\
    \text{Earth Time} & \text{50.65 years} & \text{67.31 years} & \text{83.98 years} & \text{0.646262 + 5x/3 years} \\
   \end{array}
$

(these formulas are approximate [I derive exact ones below], and don't
work for x < 0.485 light years, since you can't accelerate to 0.6c at
1g when traveling that short a distance)

The "Earth Time" above is also the time experienced by stars/stations
"A" and "D" (any anything else that's at rest with respect to the
Earth), since they're in the same inertial reference frame as Earth
(E).

Note that the time elapsed to a "stationary" observer doesn't matter
on what direction you're flying. In the example above, you're flying
straight to/from A and D, but at angle to Earth (E). However, because
E, A, and D are at rest with respect to each other, they must
experience the same amount of time.

Relativity only allows time dilation for different speeds. So, E, A,
and D *will* see time dilation when observing the moving ship, but it
must be the *exact same* time dilation. Otherwise, they'd experience
time dilation with respect to each other, which is impossible.

The only thing the direction affects is the Lorentz contraction, and
even that only applies while the ship is moving (with respect to E, A,
and D). Once the ship has returned to rest with respect to these three
points, there is no Lorentz contraction either.

Exact formulas and derivations follow.

Since the relativistic effects at $0.6 c$ are fairly mild (which may
be why you chose it), I will solve the problem in general for the
limiting speed $s$, and use $0.995 c$ (where the time dilation/space
contraction is 10) as another example case to better show the effects
of relativity.

All of the equations/formulas here come from
http://physics.stackexchange.com/questions/240342 with:

  - $a$ is your acceleration per second as a fraction of the speed of
  light. In your case, this will be $\frac{g}{c}$ or about
  $\frac{9.8}{299792458} = \text{3.27}*10^{-8}$

  - $s$ is your coasting speed as a fraction of the speed of light (in
  your case, this is $0.6$)

  - $d$ is the total distance you're traveling in light seconds. In
  your case this is 40 light years * 31556952 seconds/year or
  1262278080 light seconds.

Note that the use of "seconds" above is arbitrary and any time unit
would work.

For consistency, some of the formulas below will have input variables
that are not actually used. Now...

As you move from A to B, your speed (relative to A) and distance $t$
seconds after blastoff will be:

$\text{speedA2B}(a,s,d,t)=\frac{a t}{\sqrt{a^2 t^2+1}}$

$\text{distA2B}(a,s,d,t)=\frac{\sqrt{a^2 t^2+1}-1}{a}$

From A's reference frame, you'll reach B (the point where you need to
start coasting) at:

$\text{totalTimeA2B}(a,s,d)=\frac{s}{\sqrt{a^2-a^2 s^2}}$

at which point your distance from A will be:

$\text{totalDistA2B}(a,s,d)=\frac{\frac{1}{\sqrt{1-s^2}}-1}{a}$

You then coast from B to C, traveling at constant speed $s$:

$\text{speedB2C}(a,s,d,t)=s$

$\text{distB2C}(a,s,d,t)=s t$

and the total time/distance this takes is:

$\text{totalTimeB2C}(a,s,d)=\frac{a d-\frac{2}{\sqrt{1-s^2}}+2}{a s}$

$\text{totalDistB2C}(a,s,d)=\frac{a d-\frac{2}{\sqrt{1-s^2}}+2}{a}$

Note that if $s>\frac{\sqrt{a^2 d^2-4}}{a d}$, there is no solution to
the problem: by the time you reach coasting speed, you will already be
more than halfway to your destination and not be able to decelerate
enough to land at speed 0.

Fortunately, this does not happen in either of our test cases.

You then decelerate from C to D, mirroring (in reverse) the
acceleration from A to B. 

$\text{speedC2D}(a,s,d,t)=
\frac{s-a \sqrt{1-s^2} t}{\sqrt{a t \left(a t-s \left(a s t+2
\sqrt{1-s^2}\right)\right)+1}}$

$\text{distC2D}(a,s,d,t)=
\frac{\sqrt{\left(\frac{s}{\sqrt{1-s^2}}-a t\right)^2+1}-1}{a}$

The time and distance are the same from A to B:

$\text{totalTimeC2D}(a,s,d)=\frac{s}{\sqrt{a^2-a^2 s^2}}$
$\text{totalDistC2D}(a,s,d)=\frac{\frac{1}{\sqrt{1-s^2}}-1}{a}$

The total time you spend on the trip (from A's reference frame) is:

$\text{totalTimeA2D}(a,s,d)=\frac{a d-2 \sqrt{1-s^2}+2}{a s}$

The distance traveled is, of course, $d$.

$\text{totalDistA2D}(a,s,d)=d$

Let's summarize some of these results in general and in our example cases:

$
   \begin{array}{llll}
    \text{a} & \text{any a} & \text{1g} & \text{1g} \\
    \text{s} & \text{any s} & \text{0.6c} & \text{0.995c} \\
    \text{d} & \text{any d} & \text{40 ly} & \text{40 ly} \\
    \text{A2B time} & \frac{s}{\sqrt{a^2-a^2 s^2}} & \text{0.727 years} &
      \text{9.658 years} \\
   \text{A2B distance} & \frac{\frac{1}{\sqrt{1-s^2}}-1}{a} & \text{0.242 ly} &
      \text{8.74 ly} \\
    \text{B2C time} & \frac{a d-\frac{2}{\sqrt{1-s^2}}+2}{a s} & \text{65.859
      years} & \text{22.640 years} \\
    \text{B2C distance} & \frac{a d-\frac{2}{\sqrt{1-s^2}}+2}{a} & \text{39.515
      ly} & \text{22.527 ly} \\
    \text{C2D time} & \frac{s}{\sqrt{a^2-a^2 s^2}} & \text{0.727 years} &
      \text{9.658 years} \\
   \text{C2D distance} & \frac{\frac{1}{\sqrt{1-s^2}}-1}{a} & \text{0.242 ly} &
      \text{8.74 ly} \\
    \text{A2D time} & \frac{a d-2 \sqrt{1-s^2}+2}{a s} & \text{67.313 years} &
      \text{41.955 years} \\
    \text{A2D distance} & d & \text{40 ly} & \text{40 ly} \\
   \end{array}
$

TODO: 8.74 ly issue? (more sig figs)

Note that the caveat $s<\frac{\sqrt{a^2 d^2-4}}{a d}$ still applies

TODO: make sure TeX formats ok, it's a bit wonky [or use mathematica images]

print = {
 {"a", "s", "d", "A2B time", "A2B distance", "B2C time", "B2C distance",
  "C2D time", "C2D distance", "A2D time", "A2D distance"},

 {"any a", "any s", "any d", 
  totalTimeA2B[a,s,d], totalDistA2B[a,s,d],
  totalTimeB2C[a,s,d], totalDistB2C[a,s,d],
  totalTimeC2D[a,s,d], totalDistC2D[a,s,d],
  totalTimeA2D[a,s,d], totalDistA2D[a,s,d]},

 {"1g", "0.6c", "40 ly", 
  "0.727 years", "0.242 ly",
  "65.859 years", "39.515 ly",
  "0.727 years", "0.242 ly",
  "67.313 years", "40 ly"
 },

 {"1g", "0.995c", "40 ly",
  "9.658 years", "8.74 ly",
  "22.640 years", "22.527 ly",
  "9.658 years", "8.74 ly",
  "41.955 years", "40 ly"
}

}

Grid[Transpose[print], Alignment -> Left, Spacings -> {2, 1}, Frame -> All, 
 ItemStyle -> "Text"] // TeXForm

Let's plot the ship's speed (for both sample coasting speeds) with
respect to time for reference frame A:

Plot[{speedA2D[g, .6, 40*y2s, t*y2s], speedA2D[g, .995, 40*y2s, t*y2s]}, 
 {t,0,67.313}]

Plot[{distA2D[g, .6, 40*y2s, t*y2s]/y2s, distA2D[g, .995, 40*y2s, t*y2s]/y2s}, 
 {t,0,67.313}]

Of course, all of the above is in A's reference frame. How do things
look from the ship?

$t$ seconds after blastoff, your speed is:

$\text{shipSpeedA2B}(a,s,d,t)=\tanh (a t)$

We can integrate this to find the total distance traveled:

$\text{shipDistA2B}(a,s,d,t)=\frac{\log (\cosh (a t))}{a}$

We reach our coasting speed of $s$ at:

$\text{shipTotalTimeA2B}(a,s,d)=\frac{\tanh ^{-1}(s)}{a}$

at which point we've traveled:

$\text{shipTotalDistA2B}(a,s,d)=-\frac{\log \left(1-s^2\right)}{2 a}$

We now coast as speed s, so our speed and distance from B to C are
quite simple:

$\text{shipSpeedB2C}(a,s,d,t)=s$

$\text{shipDistB2C}(a,s,d,t)=s t$

How long does it take us to travel from B to C? We know the distance
from B to C in A's frame of reference is:

$\frac{a d-\frac{2}{\sqrt{1-s^2}}+2}{a}$

Since we are traveling at our coasting speed of s, we can use the
Lorentz contraction to find the distance from B to C in the ship's
reference frame:

$\text{shipTotalDistB2C}(a,s,d)=\frac{a d \sqrt{1-s^2}+2 \sqrt{1-s^2}-2}{a}$

And since we're traveling at constant speed, the time it takes is just
that divided by s:

$\text{shipTotalTimeB2C}(a,s,d)=\frac{a d \sqrt{1-s^2}+2 \sqrt{1-s^2}-2}{a s}$

The trip from C to D mirrors (in reverse) the trip from A to B:

$\text{shipSpeedC2D}(a,s,d,t)=-\tanh \left(a t-\tanh ^{-1}(s)\right)$

$
   \text{shipDistC2D}(a,s,d,t)=-\frac{2 \log \left(\cosh \left(a t-\tanh
    ^{-1}(s)\right)\right)+\log \left(1-s^2\right)}{2 a}
$

$\text{shipTotalDistC2D}(a,s,d)=-\frac{\log \left(1-s^2\right)}{2 a}$

$\text{shipTotalTimeC2D}(a,s,d)=\frac{\tanh ^{-1}(s)}{a}$

Adding these up, we find our total time and distance:

$
   \text{shipTotalDistA2D}(a,s,d)=\frac{a d \sqrt{1-s^2}+2 \sqrt{1-s^2}-\log
    \left(1-s^2\right)-2}{a}
$

$
   \text{shipTotalTimeA2D}(a,s,d)=\frac{a d \sqrt{1-s^2}+2 \sqrt{1-s^2}+2 s
    \tanh ^{-1}(s)-2}{a s}
$

Now, let's look at actual numbers for our test cases, and, for
comparison, include the numbers from fixed reference frame A (as
computed above).

print = {
 {"Reference Frame",
"a", "s", "d", "A2B time", "A2B distance", "B2C time", "B2C distance",
  "C2D time", "C2D distance", "A2D time", "A2D distance"},

 {"A", "any a", "any s", "any d", 
  totalTimeA2B[a,s,d], totalDistA2B[a,s,d],
  totalTimeB2C[a,s,d], totalDistB2C[a,s,d],
  totalTimeC2D[a,s,d], totalDistC2D[a,s,d],
  totalTimeA2D[a,s,d], totalDistA2D[a,s,d]},

 {"ship", "any a", "any s", "any d", 
  shipTotalTimeA2B[a,s,d], shipTotalDistA2B[a,s,d],
  shipTotalTimeB2C[a,s,d], shipTotalDistB2C[a,s,d],
  shipTotalTimeC2D[a,s,d], shipTotalDistC2D[a,s,d],
  shipTotalTimeA2D[a,s,d], shipTotalDistA2D[a,s,d]},

 {"A", "1g", "0.6c", "40 ly", 
  "0.727 years", "0.242 ly",
  "65.859 years", "39.515 ly",
  "0.727 years", "0.242 ly",
  "67.313 years", "40 ly"
 },

 {"ship", "1g", "0.6c", "40 ly", 
  "0.672 years", "0.216 ly",
  "52.687 years", "31.612 ly",
  "0.672 years", "0.216 ly",
  "54.031 years", "32.045 ly"
 },

 {"A", "1g", "0.995c", "40 ly",
  "9.658 years", "8.74 ly",
  "22.640 years", "22.527 ly",
  "9.658 years", "8.74 ly",
  "41.955 years", "40 ly"
},

 {"ship", "1g", "0.995c", "40ly", 
  "2.903 years", "2.233 ly",
  "2.261 years", "2.250 ly",
  "2.903 years", "2.233 ly",
  "8.067 years", "6.716 ly"
}
}

Grid[Transpose[print], Alignment -> Left, Spacings -> {2, 1}, Frame -> All, 
 ItemStyle -> "Text"]
showit








TODO: note that trip times add, 30+40 ly vs 70ly (if you stop for first)


TODO: disclaim tables are cleaned up

TODO: check against reliable sources at least for coasting
 
TODO: graph

TODO: need to get this print cleaned up a bit (shade first row?)

TODO: TeX can't seem to display as fancy tables as Mathematica, use image

Grid[print, Alignment -> Left, Spacings -> {2, 1}, Frame -> All, 
 ItemStyle -> "Text", Background -> {{Gray, None}, {LightGray, None}}]
showit

Grid[print, Alignment -> Left, Spacings -> {2, 1}, Frame -> All, 
 ItemStyle -> "Text", Background -> { {LightGray, None}}
]
showit


TODO: label a/s/d above

TODO: note clean versions of formulas in body of text

TODO: mention this file

TODO: digression and end of digression marker

TODO: disclaim blind equations/simplifications

TODO: note that you don't gain much in `A`'s reference frame, but do in your own for .6 -> .995

MATHEMATICA NOTES:

conds = {t>0, a>0, v>0, v<1}

speed[a_,t_] = a*t/Sqrt[(a*t)^2+1]
dist[a_,t_] = Integrate[speed[a,t],t]

(******* TODO: critical, name variables distinctly *****)

speedA2B[a_,t_] = a*t/Sqrt[(a*t)^2+1]
distA2B[a_,t_] = FullSimplify[Integrate[speedA2B[a,u],{u,0,t}],conds]
totalTimeA2B[a_,s_] = Solve[speedA2B[a,t]==s,t][[2,1,2]]
totalDistA2B[a_,s_] = FullSimplify[dist[a,totalTimeA2B[a,s]],conds]

speedB2C[a_,s_,t_] = s
distB2C[a_,s_,t_] = s*t
totalTimeB2C[a_,s_,d_] = FullSimplify[(d-2*distA2B[a,s])/s, conds]
totalDistB2C[a_,s_,d_] = FullSimplify[totalTimeB2C[a,s,d]*s, conds]
speedC2D[a_,t_,s_] = FullSimplify[speedA2B[a,totalTimeA2B[a,s]-t],conds]
distC2D[a_,t_,s_] = FullSimplify[distA2B[a,totalTimeA2B[a,s]-t],conds]
totalTimeC2D[a_,s_] = totalTimeA2B[a,s];
totalDistC2D[a_,s_] = totalDistA2B[a,s];

speedA2D[a_,t_,s_,d_] = 
 Which[t<0, 0, 
 t < totalTimeA2B[a,s], speedA2B[a,t],
 t < totalTimeA2B[a,s]+totalTimeB2C[a,s,d], speedB2C[a,s,t],
 t < totalTimeA2B[a,s]+totalTimeB2C[a,s,d]+totalTimeC2D[a,s], speedC2D[a,t,s],
   True, 0];

distA2D[a_,t_,s_,d_] = 
 Which[t<0, 0, 
   t<  totalTimeA2B[a,s], 
       distA2B[a,t],
   t < totalTimeA2B[a,s]+totalTimeB2C[a,s,d], 
       totalDistA2B[a,s,d] + distB2C[a,s,d],
   t < totalTimeA2B[a,s]+totalTimeB2C[a,s,d]+totalTimeC2D[a,s],
       totalDistA2B[a,s]+totalDistB2C[a,s,d]+distC2D[a,t,s],
   True, d];

totalTimeA2D[a_,s_,d_] = FullSimplify[totalTimeA2B[a,s] + totalTimeB2C[a,s,d] +
totalTimeC2D[a,s], conds];

totalDistA2D[a_,s_,d_] = totalDistA2B[a,s] + totalDistB2C[a,s,d] + 
 totalDistC2D[a,s];

Solve[timeB2C[a,s,d]==0,s][[2]]

(* example of how to print *)

HoldForm[dist[a,t]] == dist[a,t]

secinyear = 86400*365.2425
g = 98/10;
c = 299792458;
conds = {a>0,t>0,s>0,d>0}
coasttime[a_,s_] = Solve[speed[a,t]==s,t][[2,1,2]]
coastdist[a_,s_] =  FullSimplify[dist[a,coasttime[a,s]],conds]

coastfor[a_,s_,d_] = FullSimplify[(d-2*coastdist[a,s])/s, conds]

distaftersecondcoast[a_,s_,d_] = 
 FullSimplify[coastdist[a,s] + s*coastfor[a,s,d], conds]




journeyTime[a_,s_,d_] = FullSimplify[2*coasttime[a,s] + coastfor[a,s,d],conds]

speedAtTime[a_,t_,s_,d_] = 
 If[t < coasttime[a,s], speed[a,t],
  If[t < coasttime[a,s] + coastfor[a,s,d], s,
   If[t < journeyTime[a,s,d], speed[a,journeyTime[a,s,d]-t],
    0]]]

Plot[speedAtTime[g/c, t*secinyear, .6, 40*secinyear],{t,0,
 journeyTime[g/c, .6, 40*secinyear]/secinyear}]

Plot[speedAtTime[g/c, t*secinyear, .995, 40*secinyear],{t,0,
 journeyTime[g/c, .6, 40*secinyear]/secinyear}]

Plot[{
 speedAtTime[g/c, t*secinyear, .6, 40*secinyear],
 speedAtTime[g/c, t*secinyear, .995, 40*secinyear]
}, {t,0,journeyTime[g/c, .6, 40*secinyear]/secinyear}]

Plot[{
 speedAtTime[g/c, t*secinyear, .6, 40*secinyear]-
 speedAtTime[g/c, t*secinyear, .995, 40*secinyear]
}, {t,0,journeyTime[g/c, .6, 40*secinyear]/secinyear}]







*)

Graphics[{
 PointSize[0.02],

(* showing P makes diagram worse?

 RGBColor[1/2,0,1/2],
 Point[{30,3}],
 Text[Style["P", FontSize -> 20], {31,3}],
 Arrow[{{30,3},{30,8}}],

*)

 RGBColor[1/2,0,1/2],
 Point[{30,15}],
 Text[Style["B", FontSize -> 20], {31,15}],
 Point[{30,25}],
 Text[Style["C", FontSize -> 20], {31,25}],
 RGBColor[0,0,0],
 Text[Style["30 ly", FontSize -> 20], {15,1}],

 (* using double arrow here is cheating *)
 Arrow[{{33,0},{33,40}}],
 Arrow[{{33,40},{33,0}}],
 Rotate[Text[Style["40 ly", FontSize -> 20], {34,20}], Pi/2],
 Rotate[Text[Style["50 ly", FontSize -> 20], {14,21}], ArcTan[3,4]],
 Line[{{0,0},{30,0}}],
 Line[{{30,0},{30,40}}],
 Line[{{0,0},{30,40}}],
 RGBColor[0,0,1],
 Point[{0,0}],
 Text[Style["E", FontSize -> 20], {-1,0}],
 RGBColor[0,1,0],
 Point[{30,0}],
 Text[Style["A", FontSize -> 20], {31,0}],
 RGBColor[0,1,0],
 Point[{30,40}],
 Text[Style["D", FontSize -> 20], {31,40}],
 RGBColor[1,0,0],
 Arrow[{{30,0},{30,15}}],
 Arrow[{{30,40},{30,25}}],
 Rotate[Text[Style["accel", FontSize -> 20], {31,7.5}], Pi/2],
 Rotate[Text[Style["decel", FontSize -> 20], {31,65/2}], Pi/2],
 RGBColor[0,0,1],
 Line[{{30,15},{30,25}}],
 Rotate[Text[Style["coast", FontSize -> 20], {31,20}], Pi/2],
}]
showit


 







a = 10/300/10^6
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

TODO: note Earth revolution/rotation ignored

(*

BELOW IS in ship's reference frame

TODO: find 0.6c/1g limit and note above in table

Now, let's look at the same trip from the ship's point of view.

Your speed and distance from A to B is:

TODO: put below in TeX too

shipSpeedA2B[a_,s_,t_,d_] = Tanh[a*t]

shipDistA2B[a_,s_,t_,d_] = Integrate[Tanh[a*t],t]

You thus reach your coasting velocity at:

shipTotalTimeA2B[a_,s_,d_] = Solve[shipSpeedA2B[a,s,t,d] == s,t][[1,1,2]]

having traveled:

shipTotalDistA2B[a_,s_,d_] = FullSimplify[
 shipDistA2B[a,s,shipTotalTimeA2B[a,s,d],d],conds]

in the ship's (constantly accelerating) reference frame.

shipTotalDistB2C[a_,s_,d_] = 
 FullSimplify[totalDistB2C[a,s,d]*Sqrt[1-s^2],conds]

shipTotalTimeB2C[a_,s_,d_] = FullSimplify[shipTotalDistB2C[a,s,d]/s, conds]






*)

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

TODO: mention

http://math.ucr.edu/home/baez/physics/Relativity/SR/Rocket/rocket.html
http://math.ucr.edu/home/baez/physics/Relativity/SR/acceleration.html

and note c = 1 for me

eyeball dist for constant accel may be: 


(a*u^2)/(2 + 2*a*u)

where u is time
