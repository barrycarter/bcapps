(*

This is a rewrite of bc-solve-astronomy-13817.m which was getting
hideously nasty. This only includes formulas and my brief notes, and
attempts to make derivations easier (and also computes light travel
time issues).

TODO: all todos from bc-solve-astronomy-13817.m still apply

only really need velocity here, rest by integration etc

have to calc this "out of band" to use it

g = 98/10/299792458;

y2s = 31556952;

stationVelocity[a_, s_, d_, t_] = Piecewise[{
 {0, t<0},
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
