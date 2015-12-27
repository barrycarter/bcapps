(* http://astronomy.stackexchange.com/questions/12981/delta-v-from-mercury-surface-to-venus-surface *)

(* single dimension escape from sun? *)

conds = {g>0, m2>0, d>0}
DSolve[{f[0] == d, f'[0] == v0, f''[t] == -g*m2/f[t]^2}, f, t]


nds = NDSolve[{f[0] == 1, f'[0] ==Sqrt[2], f''[t] == -1/f[t]^2}, f, {t,0,1000}]

Plot[nds[[1,1,2]][t],{t,0,1000}]



(* acceleration of an object at v1 with mass m1 due to an object at v2
with mass m2 [note that m1 is actually irrelevant], and with
gravitational constant g *)

accel[v1_,v2_,m1_,m2_,g_] = (v2-v1)*g*m2/Norm[v1-v2]^3

(* only works for 2d below *)

accel[{x1_,y1_},{x2_,y2_},m1_,m2_,g_]=g*m2/Norm[{x2-x1,y2-y1}]^3*{x2-x1,y2-y1}

(*

exact approach, units are planets orbital radius and period; 
initial pos of planet = {1,0} by definition
pr = planets radius (currently assuming launch from right side of planet);
v0 = initial payload velocity (assuming launch "straight up")

*)

planet[t_] = {Cos[t],Sin[t]};

DSolve[{
 f[0] == {1+pr,0},
 f'[0] == {v0,1},
 f''[t] == accel[f[t],{0,0},1,sm,g] + accel[f[t],planet[t],1,1,g]
},f,t]

(* Mathematica wont solve above, so lets give it SOME exact numbers *)

mercsma = 57909050000;
mercper = Rationalize[87.9691,0];
merc[t_] = {Cos[t*2*Pi/mercper/86400],Sin[t*2*Pi/mercper/86400]}*mercsma
mercrad = 2439700
mercmass = Rationalize[3.3011*10^23,0]
g = Rationalize[6.6740*10^-11,0]
sun[t_] = {0,0}
sunmass = Rationalize[1.98855*10^30,0]

v0=500

DSolve[{
 f[0] == {mercsma+mercrad,0},
 f'[0] == merc'[0] + {v0,0},
 f''[t] == accel[f[t],{0,0},sunmass,g] + 
 accel[f[t],merc[t],1,mercmass,g]
},f,t]




(* units here are kg-m-s *)

vensma = 108208000000;

mercsma = 57909050000;
mercper = 87.9691
merc[t_] = {Cos[t*2*Pi/mercper/86400],Sin[t*2*Pi/mercper/86400]}*mercsma
mercrad = 2439700
mercmass = 3.3011*10^23

g = 6.6740*10^-11

sun[t_] = {0,0}
sunmass = 1.98855*10^30

vensma = 108208000000;
venper = 224.701;
angle = 65;
ven[t_] = vensma*{Cos[t*2*Pi/venper/86400+angle*Degree],
	Sin[t*2*Pi/venper/86400+angle*Degree]}
venmass = 4.8675*10^24

timelimit = 30*86400

nds = NDSolve[{

f[0] == {mercsma+mercrad,0},
f'[0] == merc'[0]+{0,4250*4},
f''[t] == accel[f[t],sun[t],1,sunmass,g] + 
          accel[f[t],merc[t],1,mercmass,g] +
	  accel[f[t],ven[t],1,venmass,g]
},f,{t,0,timelimit}]

ParametricPlot[{nds[[1,1,2]][t],merc[t],ven[t]},{t,0,timelimit},
AxesOrigin->{0,0}]

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

