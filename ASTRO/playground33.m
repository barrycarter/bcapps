(* http://astronomy.stackexchange.com/questions/12981/delta-v-from-mercury-surface-to-venus-surface *)


(* acceleration of an object at v1 with mass m1 due to an object at v2
with mass m2 [note that m2 is actually irrelevant], and with
gravitational constant g *)

accel[v1_,v2_,m1_,m2_,g_] = (v2-v1)*g*m2/Norm[v1-v2]^3

(* only works for 2d below *)

accel[{x1_,y1_},{x2_,y2_},m1_,m2_,g_]=g*m2/Norm[{x2-x1,y2-y1}]^3*{x2-x1,y2-y1}

nds = NDSolve[{

f[0] == {1.1,0}, f'[0] == {3,0}, 
f''[t] == accel[f[t],{0,0},1,1,1] + accel[f[t],{Cos[t],Sin[t]},1,1,1]

},f,{t,0,2*Pi}]

ParametricPlot[nds[[1,1,2]][t],{t,0,2*Pi}]

(* just a test for simple cases first *)

planet[t_] = {Cos[t],Sin[t]};

obj[t_] = f[t] /.

$Assumptions = Element[f[t], Vectors[2,Real]]

Assuming[Element[f[t], Vectors[2,Real]],

NDSolve[{
f[0] == {1.1,0.2}, f'[0] == {0,1},
f''[t] == -f[t]/Norm[f[t]]^3 + {f[t][[1]],f[t][[2]]}-{Cos[t],Sin[t]}
}, f, {t,0,1000}]




[[1,1]]



 obj''[t] == accel[obj[t],planet[t],1,1,1] + accel[obj[t],sun[t],1,1,1]



(* units: mercury distance + mercury orbit + mercury mass*g, 2D, sun
is 6M times more massive; merc radius = 4.213*10^-5 its orbit *)

merc[t_] = {Cos[t],Sin[t]};

(* affect of gravity on payload *)

NDSolve[{
pay[0] == {1,0},
pay'[0] == {0,1},
pay''[t] == merc[t]-pay[t] - pay[t]*10^6
}, pay[t], {t,0,1000}]

