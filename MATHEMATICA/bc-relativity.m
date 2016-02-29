(*

TODO: animations are in ~/20160229

Q: For the community wiki, derive the special theory of relativity
without using matrices, mirrors, or Greek letters.

A:

First, let's consider a simple example:

  - Observer B is moving at 0.9c with respect to Observer A.

  - One second after Observer B passes Observer A, Observer A shoots a
  light beam towards Observer B. Of course, this is 1 second in
  Observer A's reference frame.

  - In Observer A (blue)'s frame, Observer B (green) and the light
  beam look something like this:

[[image1.gif]]

Note that the light beam hits Observer B 10 seconds after Observer A
and Observer B are at the same position, and that Observer B is 9
light seconds away from the crossing point when this occurs.

Since we're assuming Observer B's time/distance system is different
(though we don't know *how* it's different), the view from Observer
B's perspective is less enlightening:

[[image2.gif]]

We know that t=0 when the two observers cross, but we don't know `t`
at any other time.

We also know that Observer A shoots a light beam at some unknown
distance `x` from Observer B and that the light beam eventually
reaches Observer B.

Because the speed of light is constant, we know that the light beam
traveled distance `x` to reach us in time `x/c`. It turns out this
fact will be relevant in the following derivation.

The example above is when Observer B is moving at 0.9c with respect to
Observer A. To generalize, let `v` be Observer B's velocity as a
fraction of the speed of light. In Observer A's frame, B's position is thus:

$\text{pos}(b)=t v$

Since Observer A shoots a light beam at time t=1, and the light beam
travels at the speed of light, it's position at time t>=1 is:

$\text{pos}(\text{light})=t-1$

If we set these equal, we see the light beam hits Observer B at time

$\left\{t\to \frac{1}{1-v}\right\}$

We can find the position of the hit using either `pos` formula above to get:

$\text{pos}(\text{hit})=\frac{v}{1-v}$

Again, this applies only to Observer A. For Observer B, all we know is
that the light beam traveled at the speed of light, `c`.

Before we move on, let's consider a point sometimes missed when
discussing relativity.

According to our calculations and the animation above, here's what
Observer A sees at t=4 seconds:

[[image4.gif]] (TODO: trim me!)

The light beam that we launched at t=1 has moved 3 light seconds to
t=4, and Observer B, traveling at 0.9*c has moved 3.6 light seconds
since crossing our position.

However, there's a problem: if Observer B is 3.6 light seconds away,
it will take 3.6 seconds for us to see him at that position, since the
light from Observer B takes that long to reach us.

In other words, we actually see Observer B 3.6 light seconds away at
t=7.6 seconds (3.6 seconds after t=4) and retroactively construct the
scene at t=4 seconds.

In other words, though the animation above is correct, it's not
real-time, and would be reconstructed from future observations.

What does Observer A see in real time?

[[image3.gif]]

In other words, even though the light beam hits Observer B at t=10
seconds, that event occurs 9 light seconds away, so we're not aware of
it until t=19 seconds.

Moving on to the derivation, we make two observations:

  - Einstein's observation: the time and distance an event takes in
  one reference frame depends on the time and distance an event takes
  in another reference frame, and the relative velocity between the
  two reference frames.

As stated above, this could even apply to Newtonian mechanics. The
important distinction:

    - The time an event takes in one reference frame depends on **both
    the time and distance** it takes in another reference frame.

    - The distance an event takes in one reference frame depends on
    **both the time and distance** it takes in another reference
    frame.

Einstein's genius was in realizing time can affect distance, and
distance can affect time.

  - Linearity: the change in time and distance between reference
  frames is linear. In other words, if 5 seconds my time translates to
  1 second your time, 10 seconds will translate to 2 seconds, 15
  seconds will translate to 3 seconds, and so on. Similiarly with
  distance. If 5 meters translates to 1 meter, 10 meters will
  translate to 2 meters, and so on.

According to
https://en.wikipedia.org/wiki/Derivations_of_the_Lorentz_transformations:

<blockquote>
Since space is assumed to be homogeneous, the transformation must be linear.
</blockquote>

I have to admit that I, Barry Carter, the person writing this answer,
do not understand why this implication holds. Searching the Internet
(or even just stackexchange.com, especially physics.stackexchange.com)
show several explanations (and at least one result that disagrees with
this hypothesis), but these explanations seem extremely complicated
for such a simple hypothesis. For now, let's accept linearity to
proceed with the derivation.




TODO: note specific to v






Simple relativity:

A shoots light at B, 0.9 light second away moving at .9c after 1s

A sees light reach B at 9s, 9ls away

beam origin for A: (0,1)

beam target for A: (9, 9)

beam travel for A: (9,8); general case: ((1-v)^-1, ((1-v)*c)^-1)

B sees light t seconds later at distance 0

beam origin for B: (-0.9*t, t)

beam target for B: (0, t + 0.9*t/c)

beam travel for B: (0.9*t, 0.9*t/c), general case: (v*t, v*t/c)

Thus, A to B transform is:

{9, 9} -> {0, t}

*)

(* g2 = actually seen based on light speed delay *)

(* actual pos is 0.9*t, but seen at  *)

(* position seen:

1  .9  1.9
2 1.8  3.8
3 2.7  5.7
t t*.9 1.9*t

light:

1 0 0
2 1 2
3 2 5
4 3 7

*)

pos[t_] = (.9/1.9)*t

light[t_] = (t-1)/2

g2[t_] := Graphics[{
 PointSize[0.01],
 Text[Style[StringJoin["t=",ToString[
 PaddedForm[Round[t,.1], {3,1}]
]],FontSize -> 20],
 {0,0.2}],
 Hue[2/3],
 Point[{0,0}],
 Thickness[0.004],
 Hue[1],
 If[t>1, Line[{{0,0},{(t-1)/2,0}}]],
 If[Abs[t-1]<.25, Text[Style["FIRE!", FontSize -> 20],{0,.5}]],
 If[Abs[t-19]<.25, Text[Style["I'M HIT!", FontSize -> 20],{9,.5}]],
 Hue[1/3],
 Point[{0.9/1.9*t,0}],
}];

show3[t_] := Show[g2[t], PlotRange -> {{-1.1,10},{-1,1}}, Axes -> {True,False},
 ImageSize-> {800,200}]

t3 = Table[show3[t],{t,-0.5,22,.1}];
Export["/tmp/animate.gif",t3]

g0[t_] := Graphics[{
 PointSize[0.01],
 Text[Style[StringJoin["t=",ToString[
 PaddedForm[Round[t,.1], {2,1}]
]],FontSize -> 20],
 {0,0.2}],
 Hue[2/3],
 Point[{0,0}],
 Thickness[0.004],
 Hue[1],
 If[t>1, Line[{{0,0},{t-1,0}}]],
 If[Abs[t-1]<.25, Text[Style["FIRE!", FontSize -> 20],{0,.5}]],
 If[Abs[t-10]<.25, Text[Style["I'M HIT!", FontSize -> 20],{9,.5}]],
 Hue[1/3],
 Point[{0.9*t,0}],
}];

show[t_] := Show[g0[t], PlotRange -> {{-1.1,10},{-1,1}}, Axes -> {True,False},
 ImageSize-> {800,200}]

t1 = Table[show[t],{t,-0.5,11,.1}];
Export["/tmp/animate.gif",t1]

g1[t_] := Graphics[{
 Arrowheads[{-0.02,0.02}],
 Arrow[{{-2.7,-0.2},{0,-0.2}}],
 Text[Style["x", FontSize -> 20], {-1.35,-.4}],
 PointSize[0.01],
 If[Abs[t]<0.11, Text[Style[StringJoin["t=",ToString[
 PaddedForm[Round[0,.1], {2,1}]
]],FontSize -> 20],
 {0,0.2}],
 Text[Style["t=???",FontSize -> 20], {0,0.2}]],
 Hue[2/3],
 Point[{-0.9*t,0}],
 Thickness[0.004],
 Hue[1],
 If[t>3, Line[{{-2.7,0},{-2.7+(t-2.7),0}}]],
 Hue[1/3],
 Point[{0,0}],
}];

show2[t_] := Show[g1[t], PlotRange -> {{-10, 1.1},{-1,1}}, 
 Axes -> {True,False}, ImageSize-> {800,200}, Ticks -> None]
show2[5]
showit

t2 = Table[show2[t],{t,-0.5,11,.1}];
Export["/tmp/animate.gif",t2]


Export["/tmp/test.gif",show[-.5], ImageSize -> {800,200}]
Run["display /tmp/test.gif&"]




Show[g0[5], PlotRange -> {{-0.1,10},{-0.4,0.4}}]
showit



(* the Loretnz contraction, v as fraction of light speed *)

Sqrt[1-v^2]

(* time dilation *)

1/Sqrt[1-v^2]

(* using pqrs to avoid conflicting vars *)

d2[d1_,t1_] = r*t1+s*d1
t2[d1_,t1_] = p*t1+q*d1

sol6 = Solve[t2[v*t,v*t/c] == 1,t][[1]]

sol3 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1]/t2[(1-v)^-1,((1-v)*c)^-1] == c
},p][[1]]

eq1 = (d2[d2[d1,t1],t2[d1,t1]] == d1 /. sol3)
eq2 = (t2[d2[d1,t1],t2[d1,t1]] == t1 /. sol3)

sol4 = Solve[{eq1,eq2},{q,r}][[1]]

eq5 = (d2[(1-v)^-1,((1-v)*c)^-1] == v*t)





sol0 = Solve[{
 d2[d2[d1,t1],t2[d1,t1]] == d1,
 t2[d2[d1,t1],t2[d1,t1]] == t1
}, {p,q,r,s}][[1]]

eq5 = (d2[(1-v)^-1,((1-v)*c)^-1] == v*t) /. sol3

Solve[eq5]

sol4 = Solve[


sol1 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1] == v*t,
 t2[(1-v)^-1,((1-v)*c)^-1] == v*t/c
}][[1]]

sol1 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1] == v*t,
 t2[(1-v)^-1,((1-v)*c)^-1] == v*t/c
}, {p,q,r,s}]

eq1 = (d2[d2[d1,t1],t2[d1,t1]] == d1 /. sol1)
eq2 = (t2[d2[d1,t1],t2[d1,t1]] == t1 /. sol1)

sol2 = Solve[{eq1,eq2},{q,s}]




sol0 = Solve[{
 d2[d2[d1,t1],t2[d1,t1]] == d1,
 t2[d2[d1,t1],t2[d1,t1]] == t1
}, {p,q,r,s}][[1]]

eq0 = (d2[9,8]/t2[9,8] == c /. sol0)

Solve[eq0,r]

sol1 = Solve[{
 d2[(1-v)^-1,((1-v)*c)^-1] == v*t,
 t2[(1-v)^-1,((1-v)*c)^-1] == v*t/c
} /. sol0, {q,r}]




eq1 = (d2[9,8] == v*t /. sol0)
eq2 = (t2[9,8] == v*t/c /. sol0)

Solve[{eq1,eq2},{q,r}]






t2[t2[t1,d1],d2[t1,d1]]
d2[t2[t1,d1],d2[t1,d1]]

Solve[{
 t2[t2[t1,d1],d2[t1,d1]] == t1,
 d2[t2[t1,d1],d2[t1,d1]] == -d1
}, {p,q,r,s,t}]
