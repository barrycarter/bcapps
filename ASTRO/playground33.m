(* http://astronomy.stackexchange.com/questions/12981/delta-v-from-mercury-surface-to-venus-surface *)

(* units: mercury distance + mercury orbit + mercury mass*g, 2D, sun
is 6M times more massive *)


merc[t_] = {Cos[t],Sin[t]};

(* affect of gravity on payload *)

NDSolve[{
pay[0] == {1,0},
pay'[0] == {0,1},
pay''[t] == merc[t]-pay[t] - pay[t]*10^6
}, pay[t], {t,0,1000}]

