conds = {x[t] > 0, t > 0, a < 0, Element[{C[1], C[2]}, Reals]}
sol = DSolve[x''[t] == a/x[t]^2, x, t]
tsols = Solve[sol[[1]] /. x[t] -> x, t]
t1[x_] = FullSimplify[tsols[[1,1,2]], conds]

FullSimplify[a*(t1''[x])^2, conds]

is

a^3/(x*(-2*a + x*C[1])^3)

DSolve[{
 x''[t] == a1/(y[t]-x[t])^2,
 y''[t] == a2/(y[t]-x[t])^2,
 x[0] - y[0] == d,
 x'[0] == 0, y'[0] == 0
}, x, t]






(* 

[i]"Eight miles high and falling fast, it landed foul on the grass"[/i] - American Pie, Don McLean

The mass would fall 1204.57 km and have a velocity of 0.675 km/s
(about 1500 mph).

[[image]]

Frank Popa is essentially correct.

Because of the way the meter was to be originally defined, 40,000 km is almost exactly the circumference of the Earth, or [math]2 \pi  r[/math] where r is the Earth's radius.

Thus, the starting acceleration is [math]\frac{g}{(2 \pi )^2}[/math], where g is gravitational acceleration at the Earth's surface.

Although this acceleration increases as the mass approached Earth, it doesn't increase that much. If we assume the acceleration is constant, the distance is:

[math]

a \frac{t^2}{2} = (\frac{g}{(2 \pi)^2}) \frac{t^2}{2}  \approx 

(\frac{\frac{9.8}{1000}}{(2 \pi)^2}) \frac{3600^2}{2}

\approx 1608.58

[/math]

and the velocity is:

[math]

a t = (\frac{g}{(2 \pi)^2})t \approx 

(\frac{\frac{9.8}{1000}}{(2 \pi)^2}) 3600

\approx  0.894

[/math]

both of which are semi-reasonable estimates.

To solve the problem more exactly, we must solve this differential equation:

[math]x''(t)=\frac{a}{x(t)^2}[/math]

for specific initial conditions. Note that, at the Earth's surface, the acceleration is g and the distance from the Earth's center is r, so we have:

[math]
g=\frac{a}{r^2} \to a=g r^2 \to a \approx \frac{9.8}{1000} 6353^2 \to  
a \approx 395534 
[/math]

There's no closed formula for the differential equation above in terms
of x(t), but there is for t(x), it's inverse function. Mathematica
gives:

[math]
   \frac{\left(\sqrt{c_1} x(t) \sqrt{c_1-\frac{2 a}{x(t)}}+a \log \left(x(t)
    \left(\sqrt{c_1} \sqrt{c_1-\frac{2
    a}{x(t)}}+c_1\right)-a\right)\right){}^2}{c_1^3}=\left(c_2+t\right){}^2
[/math]

where [math]c_1[/math] and [math]c_2[/math] are constants that depend on the initial conditions (position and velocity).

Solving this quadratic equation for t yields:

[math]
t(x) = 
c_2  \pm\frac{\sqrt{c_1^4 x(t) \left(c_1 x(t)-2 a\right)+a c_1^3 \log
    \left(\sqrt{c_1} x(t) \sqrt{c_1-\frac{2 a}{x(t)}}-a+c_1 x(t)\right) \left(2
    \sqrt{c_1} x(t) \sqrt{c_1-\frac{2 a}{x(t)}}+a \log \left(\sqrt{c_1} x(t)
    \sqrt{c_1-\frac{2 a}{x(t)}}-a+c_1 x(t)\right)\right)}}{c_1^3}
[/math]

Taking the derivative with respect to x (not t) and simplifying, we have:

[math]
   \frac{x \left(\sqrt{c_1} \left(2 a-c_1 x\right)+a \sqrt{c_1-\frac{2 a}{x}}
    \log \left(\sqrt{c_1} x \sqrt{c_1-\frac{2 a}{x}}-a+c_1 x\right)\right)
    \sqrt{c_1^4 x \left(c_1 x-2 a\right)+a c_1^3 \log \left(\sqrt{c_1} x
    \sqrt{c_1-\frac{2 a}{x}}-a+c_1 x\right) \left(2 \sqrt{c_1} x
    \sqrt{c_1-\frac{2 a}{x}}+a \log \left(\sqrt{c_1} x \sqrt{c_1-\frac{2
    a}{x}}-a+c_1 x\right)\right)}}{c_1^{3/2} \left(c_1 x-2 a\right) \left(c_1 x
    \left(c_1 x-2 a\right)-a^2 \log ^2\left(\sqrt{c_1} x \sqrt{c_1-\frac{2
    a}{x}}-a+c_1 x\right)\right)}
[/math]

Since [math]\frac{\text{dx}}{\text{dt}}=\frac{1}{\frac{\text{dt}}{\text{dx}}}[/math], we can take the reciprocal to find the velocity:

[math]
x'(t) = \pm
   \frac{\left(\sqrt{c_1} \left(2 a-c_1 x(t)\right)+a \sqrt{c_1-\frac{2
    a}{x(t)}} \log \left(\sqrt{c_1} x(t) \sqrt{c_1-\frac{2 a}{x(t)}}-a+c_1
    x(t)\right)\right) \sqrt{c_1^4 x(t) \left(c_1 x(t)-2 a\right)+a c_1^3 \log
    \left(\sqrt{c_1} x(t) \sqrt{c_1-\frac{2 a}{x(t)}}-a+c_1 x(t)\right) \left(2
    \sqrt{c_1} x(t) \sqrt{c_1-\frac{2 a}{x(t)}}+a \log \left(\sqrt{c_1} x(t)
    \sqrt{c_1-\frac{2 a}{x(t)}}-a+c_1 x(t)\right)\right)}}{c_1^{3/2} \left(c_1
    x(t) \left(c_1 x(t)-2 a\right)-a^2 \log ^2\left(\sqrt{c_1} x(t)
    \sqrt{c_1-\frac{2 a}{x(t)}}-a+c_1 x(t)\right)\right)}
[/math]








This is technically still a quadratic equation (not a solution for t); instead of solving it, however, I'll note that this is a fairly well known problem and its answer(s) can be found here: https://en.wikipedia.org/wiki/Free_fall#Inverse-square_law_gravitational_field (direct link to correct section).

Solve[Out[40][[1]] /. {x[t] -> blob}, t][[1]]

FullSimplify[Solve[Out[40][[1]] /. {x[t] -> blob}, t],
 {t>0, blob>0, Element[{C[1], C[2]}, Reals]}]




x''[t] == a/x[t]^2

38795.4 high and falling 675.123 m/s 

TODO: how to paste TeX into Quora? $tex$ fails [math /]

0.184277 = accel



(graph ignores air friction) (issue near end)

*)

epr = 6356.75231424518
g = 9.8/1000
ti = 17220

sol[t_] = NDSolve[{x[0] == 40000+epr, x'[0] == 0, 
 x''[t] == -g*(epr/x[t])^2
},  x[t], {t,0,ti}][[1,1,2]]

Plot[sol[t]-epr,{t,0,ti}]
showit

https://en.wikipedia.org/wiki/Free_fall#Inverse-square_law_gravitational_field

TODO: link to other answer re general formula

TODO: general solution with constant filled in

TODO: treating as physics problem

TODO: traj question on SE

TODO: popa correct

TODO: note this file

TODO: improve graph

TODO: ignores asteroids

TODO: old def meter

FullSimplify[DSolve[{x''[t] == a/x[t]^2}, x, t], {x[t]>0, t>0}]

FullSimplify[DSolve[{x''[t] == a/x[t]^n}, x, t], {x[t]>0, t>0}]

FullSimplify[DSolve[{x'''[t] == a/x[t]^3}, x, t], {x[t]>0, t>0}]

sol = DSolve[{x''[t] == a/x[t]^2}, x, t]

tsols = Solve[sol[[1]] /. x[t] -> blob, t] /. blob -> x[t]

tsols = Solve[sol[[1]] /. x[t] -> x, t]

TODO: if dumping x(t) notation, indicate x still func of t

conds = {x[t] > 0, t > 0, a > 0, Element[{C[1], C[2]}, Reals]}

t1[x_] = FullSimplify[tsols[[1,1,2]], conds]
t2[x_] = FullSimplify[tsols[[2,1,2]], conds]

(* number below is -1 as desired *)
FullSimplify[tsols[[1,1,2]]+C[2], conds]/
FullSimplify[tsols[[2,1,2]]+C[2], conds]




(tsols[[1]] /. {C[1] -> C[2], C[2] -> C[1]})[[1,2]] - tsols[[2]]

 - tsols[[2]]

Solve[sol1[[1]], t]


TODO: mention numerical

TODO: wp free fall

TODO: if using inline, apolog + point to git
