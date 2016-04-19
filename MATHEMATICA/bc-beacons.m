(* NOTE: previous versions of this file in git contain significantly
more information and calculations which may be useful in and of
themselves *)

(* formulas start here *)

conds = {n>0, k>0, i>0, Element[{n,k,i},Integers], Abs[a] < 1, Abs[a] > 0,
Abs[v0] < 1, Element[{a,v0}, Reals]};

dilation[v_] = 1/Sqrt[1-v^2];

add[u_,v_] = (u+v)/(1+u*v);

(*

The formulas below were derived as follows, but closed form given for
speed/convenience:

vhelp[n_] =  FullSimplify[
RSolve[{u[0] == v0, u[n+1] == add[u[n],a/k]}, u[n], n][[1,1,2]]
, conds]

v[n_] = FullSimplify[Limit[vhelp[k*n], k -> Infinity], conds]

t[n_] = FullSimplify[Integrate[dilation[v[t]],{t,0,n}],conds]

s[n_] = FullSimplify[Integrate[v[t]*dilation[v[t]], {t,0,n}], conds]

*)

v[n_] = (v0*Cosh[a*n] + Sinh[a*n])/(Cosh[a*n] + v0*Sinh[a*n])
t[n_] = t0 + (v0*(-1 + Cosh[a*n]) + Sinh[a*n])/(a*Sqrt[1 - v0^2])
s[n_] = s0 + (-1 + Abs[Cosh[a*n] + v0*Sinh[a*n]])/(a*Sqrt[1 - v0^2])

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

<h4>Setup</h4>

Let's use the following setup for the start of our thought experiment:

  - Carol's clock $t$ reads $t=t_0$

  - Bob's clock $u$ reads $u=u_0$

  - Bob starts at a velocity of $v_0$ (with respect to Carol), given
  as a fraction of the speed of light. Note that velocity is one thing
  both observers can agree on, so Bob's initial velocity is $v_0$ in
  both Bob's and Carol's frames (albeit in opposite directions).

  - Bob accelerates uniformly at $a$ (light seconds per second per
  second) in his own (constantly changing) frame. Note that 1 light
  second per second per second is $299792.458 \frac{\text{km}}{s^2}$
  so $a$ will normally be fractional.

  - In Carol's frame, Bob starts at a distance of $s_0$ light seconds.

  - Carol's frame is inertial. Bob's frame is not, since Bob is accelerating.

  - Bob flashes a numbered beacon every second in his
  timeframe. Beacon #0 is flashed at the start of the experiment,
  Beacon #1 is flashed after 1 second passes for Bob, and so on.

  - Note that we place no restrictions on $s_0$, $v_0$, or $a$: any of
  these can be positive or negative. So, for example Bob may be
  speeding up with respect to Carol, or slowing down with respect to
  Carol. Similarly, Bob may be moving farther away from Carol or may
  be moving closer to Carol.

TODO: bob to carol distance if we need it

<h4>Carol's Frame</h4>  

First let's ask: how fast is Bob traveling in Carol's reference frame
when he flashes the nth beacon?

To find this, we can break up Bob's $a$ acceleration per second into
$k$ smaller accelerations of $\frac{a}{k}$ each, and take the limit as
$k\to \infty$.

Taking the relativistic velocity addition formula as granted (though
it can be derived), we note that Bob accelerates for $n$ seconds
before flashing beacon $n$.

Thus, in our limiting setup, Bob accelerates $\frac{a}{k}$ a total of
$k n$ times. Referring to Bob's velocity after $i$ accelerations as
$\beta_i$ (just to avoid conflict with our existing variables), we
have the following recurrence relation:

$\beta_0=v_0$

$
\beta _{i+1}=\text{add}\left(\beta _i,\frac{a}{k}\right)=
\frac{\frac{a}{k}+\beta _i}{\frac{a \beta _i}{k}+1}
$

Solving this recurrence and simplifying (ugly details omitted) gives us:

$\beta _i=\frac{2}{\frac{(\text{v0}+1) (k-a)^{-i} (a+k)^i}{\text{v0}-1}-1}+1$

Allowing $i\to k n$ and taking the limit as above:

$\lim_{k\to \infty } \, \beta _{k n}=
   \lim_{k\to \infty } \, \left(1+\frac{2}{-1+\frac{(a+k)^{k n}
    (1+\text{v0})}{(-a+k)^{k n} (-1+\text{v0})}}\right)=
   \frac{\text{v0} \cosh (a n)+\sinh (a n)}{\text{v0} \sinh (a n)+\cosh (a n)}
$

Thus, Bob is traveling at 

$v(n) = \frac{\text{v0} \cosh (a
n)+\sinh (a n)}{\text{v0} \sinh (a n)+\cosh (a n)}$

when he flashes the nth beacon.

Since we solved for the continuous case, we can also say the formula
above applies even when $n$ is not an integer. For example, plugging
in $n=4.2$ refers to Bob's velocity 4.2 seconds after the start of the
experiment.

TODO: nth vs Beacon #n

Next, we know Bob is flashing a beacon every second in his reference
frame, but how often does Carol, in her reference frame, see a beacon
flash?

Taking the time dilation formula as granted (though it can also be
derived), we know that Bob is traveling at $\frac{\text{v0} \cosh (a
n)+\sinh (a n)}{\text{v0} \sinh (a n)+\cosh (a n)}$ when he flashes the
nth beacon. Roughly speaking, this means 1 second in Bob's frame
translates to:

$
  \text{dilation}(v(n))=\text{dilation}\left(\frac{\text{v0} \cosh (a n)+\sinh
    (a n)}{\text{v0} \sinh (a n)+\cosh (a n)}\right)=\frac{\left| \cosh (a
    n)+\text{v0} \sinh (a n) \right|}{\sqrt{1-\text{v0}^2}}
$

seconds in Carol's frame. Of course, that's only an approximation,
since Bob's velocity is constantly changing.

More accurately, we can say that $dn$ seconds in Bob's frame translates to:

$ \frac{\left| \cosh (a 
 n)+\text{v0} \sinh (a n) \right|}{\sqrt{1-\text{v0}^2}} dn
$ 

seconds in Carol's frame (where $n$ can be a decimal number).

To find the total time from Beacon #0's flash to Beacon #n's flash, we
integrate:

$
   \int_0^n \frac{\left| \cosh (a t)+\text{v0} \sinh (a t)
    \right|}{\sqrt{1-\text{v0}^2}} \, dt = 
   \frac{\text{v0} (\cosh (a n)-1)+\sinh (a n)}{a \sqrt{1-\text{v0}^2}}
$

Since Beacon #0 flashed at $t_0$ in Carol's frame, Carol sees the nth
beacon flash at:

$
\tau (n) =  \frac{\text{v0} (\cosh (a n)-1)+\sinh (a n)}{a
    \sqrt{1-\text{v0}^2}}+\text{t0}
$

in her reference frame.

Finally, how far does Bob travel in Carol's reference frame between
flashing Beacon #n-1 and Beacon #n?

We know that Bob is traveling at

$v(n-1) = 
   \frac{\text{v0} \cosh (a (n-1))+\sinh (a (n-1))}{\text{v0} \sinh (a
    (n-1))+\cosh (a (n-1))}
$

when flashing the (n-1)st beacon, and that, in Carol's frame, he travels for:

$\tau(n)-\tau(n-1) = 
   \frac{\text{v0} (\cosh (a n)-1)+\sinh (a n)}{a
   \sqrt{1-\text{v0}^2}}-\frac{\text{v0} (\cosh (a (n-1))-1)+\sinh (a (n-1))}{a
    \sqrt{1-\text{v0}^2}}=
  \frac{-\text{v0} \cosh (a (n-1))+\text{v0} \cosh (a n)+\sinh (a n)+\sinh (a-a
    n)}{a \sqrt{1-\text{v0}^2}}
$

between flashing the (n-1)st and nth beacons, so our rough
approximation would be that Bob travels $v(n-1) (t(n)-t(n-1))$ between
dropping Beacon #n-1 and Beacon #n.

Of course, that's only an approximation since Bob's velocity is
changing constantly. For an exact answer, we integrate:

$
ds(n-1,n) = \int_{\tau (n-1)}^{\tau (n)} v(t) \, dt=

   \int_{\frac{\text{v0} (\cosh (a (n-1))-1)+\sinh (a (n-1))}{a
    \sqrt{1-\text{v0}^2}}+\text{t0}}^{\frac{\text{v0} (\cosh (a n)-1)+\sinh (a
    n)}{a \sqrt{1-\text{v0}^2}}+\text{t0}} 
   \frac{\text{v0} \cosh (a t)+\sinh (a t)}{\text{v0} \sinh (a t)+\cosh (a t)}
 \, dt =
   \frac{\log \left(\cosh \left(\frac{\text{v0} (\cosh (a n)-1)+\sinh (a
    n)}{\sqrt{1-\text{v0}^2}}\right)+\text{v0} \sinh \left(\frac{\text{v0}
    (\cosh (a n)-1)+\sinh (a n)}{\sqrt{1-\text{v0}^2}}\right)\right)-\log
    \left(\cosh \left(\frac{\text{v0} (\cosh (a (n-1))-1)+\sinh (a
    (n-1))}{\sqrt{1-\text{v0}^2}}\right)+\text{v0} \sinh \left(\frac{\text{v0}
   (\cosh (a (n-1))-1)+\sinh (a (n-1))}{\sqrt{1-\text{v0}^2}}\right)\right)}{a}

$

To find the total distance from Beacon #0 to Beacon #n, we add:

$
\sum _{i=1}^n \text{ds}(i-1,i) =
\sum _{i=1}^n 
   \frac{\log \left(\cosh \left(\frac{\text{v0} (\cosh (a i)-1)+\sinh (a
    i)}{\sqrt{1-\text{v0}^2}}\right)+\text{v0} \sinh \left(\frac{\text{v0}
    (\cosh (a i)-1)+\sinh (a i)}{\sqrt{1-\text{v0}^2}}\right)\right)-\log
    \left(\cosh \left(\frac{\text{v0} (\cosh (a (i-1))-1)+\sinh (a
    (i-1))}{\sqrt{1-\text{v0}^2}}\right)+\text{v0} \sinh \left(\frac{\text{v0}    (\cosh (a (i-1))-1)+\sinh (a (i-1))}{\sqrt{1-\text{v0}^2}}\right)\right)}{a}
=
   \frac{\log \left(\cosh \left(\frac{\text{v0} (\cosh (a n)-1)+\sinh (a
    n)}{\sqrt{1-\text{v0}^2}}\right)+\text{v0} \sinh \left(\frac{\text{v0}
    (\cosh (a n)-1)+\sinh (a n)}{\sqrt{1-\text{v0}^2}}\right)\right)}{a}
$

and since Beacon #0 was at distance $s_0$, the distance from Carol to
Beacon #n in Carol's frame is:

$
s(n) = 
   \frac{\log \left(\cosh \left(\frac{\text{v0} (\cosh (a n)-1)+\sinh (a
    n)}{\sqrt{1-\text{v0}^2}}\right)+\text{v0} \sinh \left(\frac{\text{v0}
    (\cosh (a n)-1)+\sinh (a
    n)}{\sqrt{1-\text{v0}^2}}\right)\right)}{a}+\text{s0}
$



Integrate[v[u],{u,t[n-1],t[n]}]

ds[n_] = (-Log[Cosh[(v0*(-1 + Cosh[a*(-1 + n)]) + Sinh[a*(-1 + n)])/
          Sqrt[1 - v0^2]] + v0*Sinh[(v0*(-1 + Cosh[a*(-1 + n)]) + 
            Sinh[a*(-1 + n)])/Sqrt[1 - v0^2]]] + 
     Log[Cosh[(v0*(-1 + Cosh[a*n]) + Sinh[a*n])/Sqrt[1 - v0^2]] + 
       v0*Sinh[(v0*(-1 + Cosh[a*n]) + Sinh[a*n])/Sqrt[1 - v0^2]]])/a

above is n-1 to n

s[n_] = s0 + Log[Cosh[(v0*(-1 + Cosh[a*n]) + Sinh[a*n])/Sqrt[1 - v0^2]] + 
      v0*Sinh[(v0*(-1 + Cosh[a*n]) + Sinh[a*n])/Sqrt[1 - v0^2]]]/a





By continuity, we will again assume the beacon numbers can be
non-integers. Between flashing Beacon #k and Beacon #k+dk (where $dk$
is small), Bob travels at a velocity of:

$v(k) = 
\frac{\text{v0} \cosh (a k)+\sinh (a k)}{\text{v0} \sinh (a k)+\cosh (a k)}$

The time between dropping Beacon #k and Beacon #k+dk (in Carol's
reference frame is):

$\tau (k+\text{dk})-\tau (k) = 
   \frac{\text{v0} (\cosh (a (\text{dk}+k))-1)+\sinh (a (\text{dk}+k))}{a
    \sqrt{1-\text{v0}^2}}-\frac{\text{v0} (\cosh (a k)-1)+\sinh (a k)}{a
    \sqrt{1-\text{v0}^2}} =
   \frac{\text{v0} \cosh (a (\text{dk}+k))+\sinh (a (\text{dk}+k))-\text{v0}
    \cosh (a k)-\sinh (a k)}{a \sqrt{1-\text{v0}^2}}
$

The distance traveled is velocity multiplied by time or:

$
v(k) (t(k+\text{dk})-t(k)) =
  -\frac{(\text{v0} \cosh (a k)+\sinh (a k)) (-\text{v0} \cosh (a
   (\text{dk}+k))-\sinh (a (\text{dk}+k))+\text{v0} \cosh (a k)+\sinh (a k))}{a
    \sqrt{1-\text{v0}^2} (\text{v0} \sinh (a k)+\cosh (a k))}
$






does the nth beacon flash in Carol's reference
frame?





HoldForm[Integrate[Abs[Cosh[a*t] + v0*Sinh[a*t]]/Sqrt[1 - v0^2], {t,0,n
}] ]                                                                            



TODO: change drop to flash


TODO: this is not accurate obviousl



This means Carol see Bob's velocity as $\frac{\text{v0} \cosh (a
n)+\sinh (a n)}{\text{v0} \sinh (a n)+\cosh (a n)}$ after $n$ seconds
have passed **on Bob's clock** (in other words, when the nth beacon
has dropped). This does not tell us what Bob's velocity is (with
respect to Carol) when it reads $n$ seconds on Carol's clock.






beta[i_] = FullSimplify[ RSolve[{b[0] == v0, b[i+1] == add[b[i],a/k]}
, b[i], i][[1,1,2]], conds]


HoldForm[Limit[1 + 2/(-1 + ((a + k)^(k*n)*(1 + v0))/((-a + k)^(k*n)*(-
1 + v0))), k -> Infinity]]                                                      

FullSimplify[
RSolve[{b[0] == v0, b[i+1] == add[b[i],a/k]}, b[i], i][[1,1,2]],
 conds]










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

When does Carol see Beacon #n drop in her time frame?

We know from our initial conditions that Beacon #0 drops at $t=t_0$.

Between Beacon #0 and Beacon #n, Bob's velocity increases from $v_0$
at time $t=t_0$ to $\frac{\text{v0} \cosh (a n)+\sinh (a n)}{\text{v0}
\sinh (a n)+\cosh (a n)}$ by the time he drops the Beacon #n.

To find the total time elapsed in Carol's frame, we integrate the time
dilation resulting from these velocities:

$
 \int_0^n \text{dilation}(v(t)) \, dt=\int_0^n
    \frac{1}{\sqrt{-\frac{-1+\text{v0}^2}{(\cosh (a t)+\text{v0} \sinh (a
    t))^2}}} \, dt=\frac{\text{v0} (\cosh (a n)-1)+\sinh (a n)}{a
    \sqrt{1-\text{v0}^2}}
$

Thus, Carol sees Beacon #n dropped at $t_0 + \frac{\text{v0}
(\cosh (a n)-1)+\sinh (a n)}{a \sqrt{1-\text{v0}^2}}$

How far away is Beacon #n dropped in Carol's reference frame?

We know from out initial conditions that Beacon #0 is dropped at a
distance of $s_0$. To find the total distance between where Beacon #0
is dropped and where Beacon #n is dropped, we simply integrate the
velocity:

!!! THIS IS WRONG !!!

$
   \int_0^n v(t) \, dt=\int_0^n \frac{\text{v0} \cosh (a t)+\sinh (a t)}{\cosh
    (a t)+\text{v0} \sinh (a t)} \, dt=\frac{\log (\text{v0} \sinh (a n)+\cosh
    (a n))}{a}
$

Thus, Carol sees Beacon #n dropped at distance $\frac{\log (\text{v0}
\sinh (a n)+\cosh (a n))}{a}+\text{s0}$.

Summarizing what we know:

$
   \begin{array}{cccc}
    \text{Beacon $\#$} & \text{Drop time} & \text{Drop distance} &
      \text{Velocity} \\
    0 & t_0 & s_0 & v_0 \\
    1 & \frac{\text{v0} (\cosh (a)-1)+\sinh (a)}{a
      \sqrt{1-\text{v0}^2}}+\text{t0} & \frac{\log (\text{v0} \sinh (a)+\cosh
      (a))}{a}+\text{s0} & \frac{\text{v0} \cosh (a)+\sinh (a)}{\text{v0} \sinh
      (a)+\cosh (a)} \\
    n & \frac{\text{v0} (\cosh (a n)-1)+\sinh (a n)}{a
      \sqrt{1-\text{v0}^2}}+\text{t0} & \frac{\log (\text{v0} \sinh (a n)+\cosh
      (a n))}{a}+\text{s0} & \frac{\text{v0} \cosh (a n)+\sinh (a n)}{\text{v0}
      \sinh (a n)+\cosh (a n)} \\
   \end{array}
$

repl = {t0 -> 0, s0 -> 0, v0 -> .5, a -> .01}

TODO: formula for s is probably incorrect, assumes odd things about dt

vfake[n_] = v0 + a*n
sfake[n_] = s0 + v0*n + a*n^2/2
tfake[n_] = t0 + n

ListPlot[{Table[v[n] /. repl, {n,0,100}], 
          Table[vfake[n] /. repl, {n,0,100}]}
]

ListPlot[{Table[s[n] /. repl, {n,0,100}], 
          Table[sfake[n] /. repl, {n,0,100}]}
]

ListPlot[{Table[t[n] /. repl, {n,0,100}], 
          Table[tfake[n] /. repl, {n,0,100}]}
]

ListPlot[Table[{t[n], v[n]} /. repl, {n,0,100}]]
ListPlot[Table[{t[n], s[n]} /. repl, {n,0,500}]]
showit


TODO: make sure all TeX tables have vertical and horizontal lines

t1 = Grid[{
 {"Beacon #", "Drop time", "Drop distance", "Velocity"},

 {0, Subscript[t,0], Subscript[s,0], Subscript[v,0]},
 {1, t0 + (v0*(-1 + Cosh[a]) + Sinh[a])/(a*Sqrt[1 - v0^2]),
     s0 + Log[Cosh[a] + v0*Sinh[a]]/a, 
     (v0*Cosh[a] + Sinh[a])/(Cosh[a] + v0*Sinh[a])},
 {n, t0 + (v0*(-1 + Cosh[a*n]) + Sinh[a*n])/(a*Sqrt[1 - v0^2]),
     s0 + Log[Cosh[a*n] + v0*Sinh[a*n]]/a,
     (v0*Cosh[a*n] + Sinh[a*n])/(Cosh[a*n] + v0*Sinh[a*n])}
}];

temp1915 = Solve[t[n]==x, n] /. C[1] -> 0

temp1915[[1,1,2]]/temp1915[[2,1,2]]

temp1917 = temp1915[[1,1,2]]
temp1918 = temp1915[[2,1,2]]

strue[x_] = FullSimplify[s[temp1917], conds]

(* another attempt to simplify the velocity at least *)

temp1938[v_] = add[v,a*dt]




HoldForm[Integrate[v[t],{t,0,n}]] == HoldForm[Integrate[(v0*Cosh[a*t] +
 Sinh[a*t])/(Cosh[a*t] + v0*Sinh[a*t]),{t,0,n}] ]

TODO: avoid nth beacon, say Beacon #n


HoldForm[Integrate[dilation[v[t]],{t,0,n}]] == 
 HoldForm[Integrate[1/Sqrt[-((-1 + v0^2)/(Cosh[a*t] + v0*Sinh[a*t])^2)], 
 {t,0,n}]] == 
FullSimplify[Integrate[dilation[v[t]],{t,0,n}],conds]

time[n_] = FullSimplify[Integrate[dilation[v[t]],{t,0,n}],conds] 

1/Sqrt[-((-1 + v0^2)/(Cosh[a*t] + v0*Sinh[a*t])^2)]

<h4>Time</h4>



Returning briefly to our original setup (non-uniform acceleration), we
note that Bob travels at (the discrete version of) $v(n)$ for one
second after he drops Beacon #n, and then immediately accelerates to
$v(n+1)$ before dropping Beacon #n+1.

Since Bob is traveling at $v(n)$ between dropping Beacon #n and Beacon
#n+1 (the instant acceleration at the end of one second takes zero
time), the time dilation between these two drops is:

TODO: discrete checks of formulas I get

$
\text{dilation}(v(n))=
   \frac{1}{\sqrt{1-\left(\frac{2}{\frac{(\text{v0}+1) (1-a)^{-n}
    (a+1)^n}{\text{v0}-1}-1}+1\right)^2}}
$

Thus, while 1 second passes for Bob between the drops,

$
   \frac{1}{\sqrt{1-\left(\frac{2}{\frac{(\text{v0}+1) (1-a)^{-n}
    (a+1)^n}{\text{v0}-1}-1}+1\right)^2}}
$

seconds pass for Carol.

For the continuous case, we once again assume $k$ accelerations of
$\frac{a}{k}$ per second and take the limit as $k\to \infty$.

Omitting the ugly math, this yields:

$dt(n,n+1) = \frac{\text{v0} \sinh (a n)+\cosh (a n)}{\sqrt{1-\text{v0}^2}}$

TODO: graphics for both cases




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

(*

Subject: Error in deriving constant acceleration relativistic distance

Bob accelerates away from Carol at proper acceleration $a$ (in light
seconds per second), and Carol wants to know how far Bob has traveled
when $t$ seconds pass **in Bob's frame**.

Using math.ucr.edu/home/baez/physics/Relativity/SR/Rocket/rocket.html
and noting that $c=1$ because of the units we're using, Carol knows
that:

  - $t$ seconds in Bob's frame equals $\frac{\sinh (a t)}{a}$ in her frame

  - Bob's velocity in her frame is $\tanh (a t)$

so she integrates velocity over time to get distance:

$\int_0^{\frac{\sinh (a t)}{a}} \tanh (a u) \, du = 
\frac{\log (\cosh (\sinh (a t)))}{a}$

which is the wrong answer. What has Carol done wrong?

For reference, the correct answer is $\frac{\cosh (a t)-1}{a}$.

A power series expansion at $t=0$ shows these two answers are
surprisingly close to each other, but not identical:

$ 
   \frac{\log (\cosh (\sinh (a t)))}{a}=\frac{a t^2}{2}+\frac{a^3 
    t^4}{12}-\frac{a^5 t^6}{90}+\frac{a^7 t^8}{2520}+\frac{a^9 
    t^{10}}{1575}+ ... 
$
$ 
   \frac{-1+\cosh (a t)}{a}=\frac{a t^2}{2}+\frac{a^3 t^4}{24}+\frac{a^5 
    t^6}{720}+\frac{a^7 t^8}{40320}+\frac{a^9 
    t^{10}}{3628800}+ ... 
$ 

(*

more on discrete approach:

Bob starts at v0, jumps to plus cur speed + a*dt every dt in his
frame; stays at v0 for first dt

beacons each dt ( = bad idea?) 1/dt beacons per second

TODO: per math chat suggestion, change of var for adt+1 and adt-1

conds = {Element[{a,dt,v0}, Reals], Element[n, Integers], dt>0, dt<1,
Abs[a] > 0, Abs[a] < 1, n > 0, Abs[v0] < 1, alpha > 0, alpha < 2, beta > 0,
beta < 2};

dilation[v_] = 1/Sqrt[1-v^2];

add[u_,v_] = (u+v)/(1+u*v);

vhelp[n_]=
 RSolve[{u[0] == v0, u[n+1] == add[u[n],a*dt]}, u[n], n][[1,1,2]];

a*dt+1 = alpha so dt -> (alpha-1)/a
v0+1 = beta, so v0 -> (beta-1)

v[n_] = FullSimplify[vhelp[n] /. {dt -> (alpha-1)/a, v0 -> beta-1},conds]


below is in number of epsilon boosts:

(* v[n_] = FullSimplify[vhelp[n],conds] *)

dt[n_] = FullSimplify[dilation[v[n]]*dt,conds]

dt[n_] = FullSimplify[dilation[v[n]]*(alpha-1)/alpha,conds]

ds[n_] = FullSimplify[v[n]*dt[n],conds]

TODO: check limits below

t[n_] = Sum[dt[i], {i,0,n-1}]

s[n_] = Sum[ds[i], {i,0,n-1}]

t[n/dt] .. t[m].. m = n/dt ... n -> m*dt

t[m*dt]

I'm trying to compute
$\lim_{n\to \infty } \, \left(\sum _{i=1}^n f(i)\right)$

Sum[f[i,dt], {i,1,n}]

Limit[Sum[f[i,dt], {i,1,m*dt}], dt -> 0]





TODO: graph w stair steps as indicator?

