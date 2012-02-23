(* Math for my 'sphere of humanity' blog post *)

(* below only accurate to nearest year, inaccurately assumes 3%
constant growth; if we really had 3% constant growth, the population
in 1244 would be a single person *)

pop[y_] = 7*10^9*1.03^(y-2011)

(* giving everyone 8 cubic feet would take a cube with a side of ... *)
(* sphere would be more efficient, but harder to balance? *)

side[pop_] = (8*pop)^(1/3)

(* velocity and acceleration *)

vside[y_] = D[side[pop[y]],y]

aside[y_] = D[side[pop[y]],y,y]

(* uncomfy acceleration == 5g; converting m/s^2 to ft/y^2 per wolframalpha:
http://www.wolframalpha.com/input/?i=5g+in+feet+per+year+per+year&a=*C.g-_*Unit.dflt-&a=UnitClash_*g.*GravityAccelerations--
 *)

Solve[aside[y] == 1.6*10^17,y]

(* excluding relativity, speed of light; conversion courtesy wolfram:
http://www.wolframalpha.com/input/?i=speed+of+light+in+feet+per+year
*)

Solve[vside[y] == 3.102*10^16, y]

(* now, for square, 1 sq ft per person *)

sside[pop_] = Sqrt[pop]

vsside[y_] = D[sside[pop[y]],y]

asside[y_] = D[sside[pop[y]],y,y]

(* uncomfy 5g... and psuedo-speed-of-light *)

Solve[asside[y] == 1.6*10^17,y]

Solve[vsside[y] == 3.102*10^16, y]

