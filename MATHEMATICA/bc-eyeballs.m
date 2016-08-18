(*

An eyeball approach to relativity.

Experiment: ship flies from Earth to Star 10 light years away at 0.8c
(accel + decel instant), gamma is 0.6, angular diameter for distance

view from ship: shrinks to 6ly at 0.8c or 7.5y
view from planet: trip takes 12.5y

rapidity in ship: 1.333333

earth: t=0 -> t=0, t=7.5 -> t=2.5 because of light travel time (doppler)

planet: t=0 -> t=-10, t=7.5 -> t=12.5

Plot[x/3,{x,0,7.5}]

Plot[{x/3,x/7.5*22.5-10},{x,0,7.5}]

allowing for anuglar distance:

Plot[{x/3+x*4/3, x/7.5*22.5-10 + (10-x*4/3)},{x,0,7.5}]

view from earth: 0,0 to 10, 17.5
view from planet: 0,-10 to 10,7.5

1.75 time dilation [no that excludes light travel]

or 0.75 from ship view





