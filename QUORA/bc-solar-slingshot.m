(*

Suppose I following a circular trajectory (not an orbit) with the following parameters:

  * I complete one orbit in time p (for period) seconds

  * I am at constant distance d meters from the Sun's center, such that d puts me in the Sun's corona

  * My ship is 1m^2, has and a thicnkess of 1mm, and the density of water, giving it a mass of 1kg (all these numbers chose just for convenience).

  * My ship can gather matter (with its 1m^2 surface area) and convert it to energy at E=mc^2 instantly.

Then we have:

  * The ship has a tangential speed of 2*d*Pi/p, and a centripetal acceleration of 4*d*Pi^2/p^2

  * Since the ship weighs 1kg, it takes 4*d*Pi^2/p^2 Newtons of force to maintain this acceleration. Note that the actual amount is slightly less, since the Sun's own gravity helps. However, once the ship is circling (not orbiting) the Sun fast, the additional assist from the Sun's gravity is negligible.

  * Since the ship travels 2*Pi*d per "orbit", we multiply force by distance to compute: the ship requires 8*d^2*Pi^3/p^2 of work to maintain the given acceleration for an entire orbit.

  * The ships 1m^2 surface traverses a volume of 2*Pi*d m^3 per "orbit".

  * If the Sun's coronal density is b (in kg/m^3), the ships 1m^2 surface passes through 2*Pi*d*b kg of mass per "orbit".

  * Using E=mc^2, that's 2*Pi*d*b*c kg*m^2/s^2 of energy.

so limit is b*c Newtonian, but even b>1 won't help

TODO: mathify?

If we assume a coronal density of p, and assume 


TODO: do not use p for density



TODO: ignore sun help gravity

TODO: mention Newtonian method, momentum loss due to particles, auto-refresh corona

say 1m^2 and weighs 1kg for simplicity

distance d from sun center

corona density p consistently + rejuvenates

2*pi*d = coronal matter picked up

revolution time p

s[t_] = {d*Cos[2*Pi*t/p], d*Sin[2*Pi*t/p]}

FullSimplify[Norm[s'[t]], {t>0,p>0,d>0}]

above is 2*d*Pi/p as expected

FullSimplify[Norm[s''[t]], {t>0,p>0,d>0}]

4*d*Pi^2/p^2 as expected



d/2/Pi = tangential velocity

d/4/Pi/Pi




*)
