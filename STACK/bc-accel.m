(*

This is a rewrite of bc-solve-astronomy-13817.m which was getting
hideously nasty. This only includes formulas and my brief notes, and
attempts to make derivations easier (and also computes light travel
time issues).

TODO: all todos from bc-solve-astronomy-13817.m still apply

this is correct:

reladist[a_,s0_,v0_,t_] = 
s0 + t*v0 + ((-1 + Sqrt[1 + a^2*t^2])*Sqrt[1 - v0^2])/a

newtdist[a_,s0_,v0_,t_] = s0 + v0*t + a*t^2/2



start at s0, v0, constant acceleration (which includes 0 and negative)

(a*t)/Sqrt[1 + a^2*t^2]

dist[t_] = FullSimplify[Sqrt[1 + a^2*t^2]/a-1/a,conds]

dist[t_] =  (-1 + Sqrt[1 + a^2*t^2])/a

from me to observer:

s0 + v0*t

lorentz:

s0 + v0*t + Sqrt[1-v0^2]*dist[t]

dist[t_] = FullSimplify[s0 + v0*t + Sqrt[1-v0^2]*dist[t],
 {Element[{s0,v0,a,t}, Reals]}]

(* special case for 0 acceleration, sigh *)

reladist[0,s0_,v0_,t_] = s0 + v0*t

reladist[a_,s0_,v0_,t_] = 
(s0 + t*v0)*(2 - v0^2 + Sqrt[1 - v0^2]) + 
 (1 - v0^2)^(3/2)*InputForm[(-1 + Sqrt[1 + a^2*t^2])/a]

Plot[{newtdist[g,5,1,t],reladist[g,5,1,t]}, {t,0,10}]



above is if starting velo is 0, so consider observer at v0 at 0

(v0+speedA2B[a,s,d,t])/(1+v0*speedA2B[a,s,d,t])

speed[a_,s0_,v0_,t] = 


only really need velocity here, rest by integration etc

have to calc this "out of band" to use it

g = 98/10/299792458;

y2s = 31556952;

(*

raw form:

Take[Partition[Apply[List,speedA2D[a,s,d,t]],2],{2,4}]

stationVelocity[a_, s_, d_, t_] = FullSimplify[Apply[Piecewise,
 {Map[Reverse[#]&,Take[Partition[Apply[List,speedA2D[a,s,d,t]],2],{2,4}]]}],
conds]


*)

(* below is compact, but conditions not in terms of t *)

stationVelocity[a_, s_, d_, t_] = 
   Piecewise[{{(a*t)/Sqrt[1 + a^2*t^2], a*Sqrt[1 - s^2]*t < s}, 
     {s, s^2 + (2 + a*d)*Sqrt[1 - s^2] > 2 + a*s*Sqrt[1 - s^2]*t}, 
     {(2 - 2*Sqrt[1 - s^2] + a*(d - s*t))/Sqrt[8 - 3*s^2 - 8*Sqrt[1 - s^2] + 
         a*(d - s*t)*(4 - 4*Sqrt[1 - s^2] + a*(d - s*t))], 
      2*Sqrt[1 - s^2] + a*s*t < 2 + a*d}}, 0]

Plot[stationVelocity[g, .6, 40*y2s, t*y2s], {t,0,100}]



stationVelocity[a_, s_, d_, t_] = 
   Piecewise[{{(a*t)/Sqrt[1 + a^2*t^2], t < s/Sqrt[a^2 - a^2*s^2]}, 
     {s, t < s/Sqrt[a^2 - a^2*s^2] + (2 + a*d - 2/Sqrt[1 - s^2])/(a*s)}, 
     {(s - a*Sqrt[1 - s^2]*(-(s/Sqrt[a^2 - a^2*s^2]) - 
          (2 + a*d - 2/Sqrt[1 - s^2])/(a*s) + t))/
       Sqrt[1 + a*(-(s/Sqrt[a^2 - a^2*s^2]) - (2 + a*d - 2/Sqrt[1 - s^2])/
            (a*s) + t)*(a*(-(s/Sqrt[a^2 - a^2*s^2]) - 
             (2 + a*d - 2/Sqrt[1 - s^2])/(a*s) + t) - 
           s*(2*Sqrt[1 - s^2] + a*s*(-(s/Sqrt[a^2 - a^2*s^2]) - (2 + a*d - 
                 2/Sqrt[1 - s^2])/(a*s) + t)))], 
      t < (2*s)/Sqrt[a^2 - a^2*s^2] + (2 + a*d - 2/Sqrt[1 - s^2])/(a*s)}}, 0]

Assuming[conds, Integrate[stationVelocity[a,s,d,u],{u,0,t}]]


Plot[stationVelocity[g, .6, 40*y2s, t*y2s], {t,0,100}]


stationVelocity[a_, s_, d_, t_] = Piecewise[{

 {(a*t)/Sqrt[1 + a^2*t^2], t<s/Sqrt[a^2 - a^2*s^2]},

 {s, t<(2 + a*d - 2/Sqrt[1 - s^2])/(a*s)},

 {(2 - 2*Sqrt[1 - s^2] + a*(d - s*t))/
 Sqrt[8 - 3*s^2 - 8*Sqrt[1 - s^2] + a*(d - s*t)*(4 - 4*Sqrt[1 - s^2] +
 a*(d - s*t))],
 t<(2 + a*d - 2*Sqrt[1 - s^2])/(a*s)}
}, 0]


Plot[stationVelocity[g, .6, 40*y2s, t*y2s], {t,0,100}]


 

 {a*t/Sqrt[(a*t)^2+1], t >= 0 && t < s/Sqrt[a^2 - a^2*s^2]},
 {s, t >= s/Sqrt[a^2 - a^2*s^2]
   && t < (2 + a*d - 2/Sqrt[1 - s^2])/(a*s) + s/Sqrt[a^2 - a^2*s^2]},
 {(s - a*Sqrt[1 - s^2]*t)/Sqrt[1 + a*t*(a*t - s*(2*Sqrt[1 - s^2] + a*s*t))],
  t >= (2 + a*d - 2/Sqrt[1 - s^2])/(a*s) + s/Sqrt[a^2 - a^2*s^2] &&
  t < (2 + a*d - 2*Sqrt[1 - s^2])/(a*s)},
 {0, t >= (2 + a*d - 2*Sqrt[1 - s^2])/(a*s)}
}];

Plot[stationVelocity[g, .6, 40*y2s, t*y2s], {t,0,100}]


TODO: check formulas above, using from other script because I "know they work"

Plot[Piecewise[{
 {t^2, t< 0},
 {t+2, t< 5},
 {17, True}
}],{t,-1,6}];
