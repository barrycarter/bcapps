(*

An eyeball approach to relativity.

Experiment: ship flies from Earth to Star 10 light years away at 0.8c
+ returns (accel + decel instant), gamma is 0.6, angular diameter for
distance.

view from earth: 0,0 to 22.5, 7.5
return view from earth: 22.5, 7.5 to 25,15

(* unadjusted view of ship clock from Earth *)
view[e,s,t,0][t_] = t/3

(* unadjusted view of ship clock from planet *)
view[p,s,t,0][t_] = 7*t/5-10

(* unadjusted view of earth clock from ship *)
view[s,e,t,0][t_] = t/3

(* unadjusted view of planet clock from ship *)
view[s,p,t,0][t_] = 3*t-10

(* unadjusted view of ship distance from Earth, angular *)
view[e,s,d,0][t_] = 4*t/9

(* unadjusted view of ship distance from planet *)
view[p,s,d,0][t_] = 10-4*t/5




(* TODO: consider e,s,d instead of long form *)

Plot[view[ship,planet,time,0][t],{t,0,7.5}]

Plot[view[earth,ship,time,0][t],{t,0,22.5}]
Plot[view[ship,earth,time,0][t],{t,0,7.5}]
Plot[view[planet,ship,time,0][t],{t,0,12.5}]



I feel bad about having to write this function

f[x1_,y1_,x2_,y2_] = Function[x, (x-x1)/(x2-x1)*(y2-y1)+y1]

view from planet: 0,-10 to 10,7.5



journey takes:

v=0.8

gamma[v_] = Sqrt[1-v^2]

length[v_] = gamma[v]/v

rapidity[v_] = v/gamma[v]

ship view of earth clock:

view[v_][ship][earth][clock][t_] = ((1 + v)*t)/Sqrt[1 - v^2]

and of planet clock:

view[v_][ship][planet][clock][t_] = -1 + ((1 + v)*t)/Sqrt[1 - v^2]

adjusting for earth distance with rapidity

view2[v_][ship][earth][clock][t_] = ((1 + v)*t)/Sqrt[1 - v^2] - rapidity[v]*t

so clocks run 1/gamma[v] faster



ship viewing earth clock:



rapidity[v_] = v/gamma[v]

v = 8/10

view from ship: earth time

and planet

Plot[{3*x, 10+x/3}, {x,0,7.5}]

allowing for distance, from earth is rapidity[v]*x

Plot[{3*x-x*1.33333}, {x,0,7.5}]

Plot[{10+x/3 - (10-1.33333*x)}, {x,0,7.5}]

Plot[{3*x-x*1.33333, (7.5-1.33333*x)+10+x/3}, {x,0,7.5}]

Plot[{3*x-x*.8, 10+x/3}, {x,0,7.5}]




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




