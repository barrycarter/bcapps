(* https://www.quora.com/unanswered/How-long-would-an-object-fall-to-Earth-from-1-light-year-distance-if-other-bodies-didnt-perturb-the-trajectory *)

(* TODO: put answer at top

[b]Under several unrealistic assumptions, it would take 1.62 billion years, and land at a speed of 11,179 km/s, slightly below the Earth's escape velocity of 11,186 km/s[/b]

This is effectively the same problem as launching a rocket from Earth's surface at just below escape velocity, so that the rocket goes as far as 1 light year away before stopping, turning around, and returning.

The general formula for landing time is:

[math]\frac{d \left(2 \sqrt{r (d-r)}+d \left(i \log \left(2 i \sqrt{r (d-r)}+d-2r\right)-i \log (d)+\pi \right)\right)}{2 \sqrt{2} r \sqrt{d g}}[/math]

(note that the formula contains imaginary numbers, but these will all cancel out and the end result will be real; for more details on how this formula is derived and possible alternate forms: https://github.com/barrycarter/bcapps/blob/master/QUORA/bc-1ly.m and https://mathematica.stackexchange.com/questions/124477/how-to-fullsimplify-real-expression-so-intermediate-terms-are-also-real)

where:

  - [math]r[/math] is the radius of the planet where you land (6371km for Earth)

  - [math]g[/math] is the acceleration due to gravity at the surface of the planet, given as a positive number (9.807m/s^2 at the Earth's surface)

  - [math]d[/math] is the starting distance (1 light year = 9.461*10^12km)

with a final velocity of:

[math]-\sqrt{2} \sqrt{\frac{g r (d-r)}{d}}[/math]

Note that as [math]d\to \infty[/math], the final velocity becomes the escape velocity [math]-\sqrt{2 g r}[/math], as expected. Note that this form is slightly different from the normally-given form because we are measuring g at the surface of the planet, and not using the mass of the planet.

Near the surface of the Earth, we have [math]d=\frac{g t^2}{2} \to t=\sqrt{\frac{2 d}{g}}[/math] so we'd expect landing time to be about [math]\sqrt{\frac{2 d}{g}}[/math], which it is:





In general, 

FullSimplify[t0[r,g,d,r], {r>0, d>r, g>0}]

FullSimplify[1/t'[r]]

FullSimplify[t0[r,g,d,r], {Element[{r,d,g}, Reals], {r>0, d>r, g>0}}] /.
 Sign[r] -> 1

FullSimplify[t0[r,g,d,r], {Element[{r,d,g}, Reals], {r>0, d>r, g>0}}] /.
 {Log[x_]-Log[y_] -> Log[x/y]} /. {Sign[r] -> 1} /. 
 {Sqrt[x_]*Sqrt[y_] -> Sqrt[x*y]}

FullSimplify[t0[r,g,d,r], {Element[{r,d,g}, Reals], {r>0, d>r, g>0}}] /.
 {Log[x_]-Log[y_] -> Log[x/y]} /. {Sign[r] -> 1} /. 
 {Sqrt[x_]*Sqrt[y_] -> Sqrt[x*y]} /. {x_^(3/2) -> x*Sqrt[x]}

t0[r,g,d,r] /. {x_^(-3/2) -> 1/x/Sqrt[x]}

FullSimplify[t0[r,g,d,r] /. {-(g*r^2/d) -> a0}]







Simplify[t0[r,g,d,r], {Element[{r,d,g}, Reals], {r>0, d>0, g>0}}]

Simplify[
Simplify[t0[r,g,d,r], {Element[{r,d,g}, Reals], {r>0, d>0, g>0}}] /. 
 Abs[r] -> r
]







To solve this problem, we can use the formulas at https://en.wikipedia.org/wiki/Free_fall#Inverse-square_law_gravitational_field or derive similar ones ourselves.

TODO: no weight (ie, earth not pulled)

11283 = velocity when it hits

(*

(* note: r is the distance at which the acceleration is -g *)

sol = DSolve[{x''[t] == -g/(x[t]/r)^2}, x[t], t]

t1[x_] = -sol[[1,1,1]]-C[2] /. x[t] -> x

(* solving for constants *)

c1sol = Solve[Simplify[1/t1'[d]] == 0, C[1]][[1]]

(* above gives C[1] -> -2*g*r^2/d *)

t2[x_] = t1[x] /. c1sol

c2sol = Solve[t2[d] == 0, C[2]][[1]]

t[x_] = t2[x] /. c2sol

t[r]

t[x_] = FullSimplify[t2[x] /. c2sol, Element[{x,g,d}, Reals]]

t0[x_,g_,d_,r_] = FullSimplify[t2[x] /. c2sol, Element[{x,g,d}, Reals]]

(* above this line = solution *)

Plot[t0[er, g0, d, er], {d,er,ly}]

Plot[t0[er, g0, er+d, er], {d,0,1}]

Plot[t0[er, g0, er+d/1000, er], {d,0,100000}]

Plot[{t0[er, g0, er+d/1000, er], Sqrt[d/5]}, {d,0,1000000}]

Plot[{t0[er, g0, er+d/1000, er], Sqrt[d/5]}, {d,0,100000}]

Plot[{t0[er, g0, er+d/1000, er], Sqrt[d/5]}, {d,0,1000}]

Limit[t0[r,g,d,r]/d^(3/2), d -> Infinity]

TODO: answer north pole question, sun mass much higher ignored



(* below is in km and s *)

ly = 9.461*10^12
g0 = 9.807/1000
er = 6371.

t0[er, g0, er+ly, er]/365.2425/86400


Plot[t[x, er+1, g0], {x, er, er+1}]

t0[er, g0, er+1, er]

*)


conds = {g -> -9.812/1000, d -> er+1}

(* above makes C[1] approx 3*10^-6, and C[2] approx 8.38553*10^6 or its neg *)

cond2 = {C[1] -> 3*10^-6, C[2] -> 8.4*10^6, g -> -9.812/1000}

DSolve[{x[0] == d, x'[0] == 0, x''[0] == 0, x''[t] == -g/x[t]^2}, x[t], t]

(* cut point *)

(* sanity testing *)

t3[0.5] /. {d -> 1, g -> 1}

using positive sol value yields imaginary for t3[.5]
using negative sol value ALSO yields imaginary for t3[.5]

(* testing formula near Earth *)

Plot[t3[x] /. {d -> 40000/2/Pi + 1, g -> 9.812/1000}, {x,40000/2/Pi,
40000/2/Pi+1}]


Solve[q^2 == (t+C[2])^2, t]

TODO: mention coriolis and initial speed issues, link to my SE answer

