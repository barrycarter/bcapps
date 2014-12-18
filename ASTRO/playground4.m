(* 12/07/14: attempting to generalize what Ive found below for a
single orbit *)

(* dtheta using dot products *)

derv[t_, delta_] = 
 ArcCos[s[t-delta].s[t+delta]/Norm[s[t-delta]]/Norm[s[t+delta]]]/2/delta;

Plot[derv[5,dx],{dx,0,1}]

Plot[derv[t,.01],{t,0,365}]
Plot[Norm[s[t]],{t,0,365}]

(* number below is very nearly constant *)

Plot[Norm[s[t]]^2*derv[t,.01],{t,0,365}]

(* experiment below to find better focus *)

(* below does weird but unhelpful things *)

Plot[Norm[s[t]+{-712222., -288357., -79737.9}]^2*derv[t,.01],{t,0,365}]


(* using memoization as these are slow to compute *)

s[t_] := s[t] = {eval[x,1,0,t],eval[y,1,0,t],eval[z,1,0,t]};

v[t_] := v[t] = {D[poly[x,1,0,t][w],w], D[poly[y,1,0,t][w],w], 
 D[poly[z,1,0,t][w],w]} /. w -> t

a[t_] := a[t] = {D[poly[x,1,0,t][w],w,w], D[poly[y,1,0,t][w],w,w], 
 D[poly[z,1,0,t][w],w,w]} /. w -> t

Plot[Norm[s[t]]^2*Norm[a[t]],{t,0,365}]

(* this is a quasi orbit, not necessarily real; starting values below
= cheating *)

t0 = t /. NMinimize[Norm[s[t]]^2*Norm[a[t]],{t,20,40}][[2]]
t1 = t /. NMinimize[Norm[s[t]]^2*Norm[a[t]],{t,100,150}][[2]]

(* t1-t0 = 89.8108 which is quite different from orbital period, hmmm *)

(* find average of quantity *)

gm = NIntegrate[Norm[s[t]]^2*Norm[a[t]],{t,t0,t1}]/(t1-t0);

(* formula for radius *)

r[t_] := r[t] = Sqrt[gm/Norm[a[t]]];

(* and center *)

c[t_] := c[t] = s[t] + r[t]*(a[t]/Norm[a[t]]);

ParametricPlot3D[c[t],{t,t0,t1}]

(* equal area sweeping from barycenter or new center? *)

(* I'm doing this fundamentally wrong somehow *)

area[x_] := NIntegrate[r[t],{t,t0+x,t0+x+1}];

(* this is NOT very even *)

Plot[area[t],{t,0,t1-t0-1}]

area2[x_] := NIntegrate[Norm[s[t]-c[t]],{t,t0+x,t0+x+1}];

(* and, sadly, neither is this *)

Plot[area2[t],{t,0,t1-t0-1}]

(* acceleration and velocity in terms of finding a gravitation object *)

(* this is using eval[] from bc-xsp2math.pl *)

s[t_] := {eval[x,1,0,t],eval[y,1,0,t],eval[z,1,0,t]};

ParametricPlot3D[s[t],{t,0,365}]

(* this is km/day *)

v[t_] := {D[poly[x,1,0,t][w],w], D[poly[y,1,0,t][w],w], 
 D[poly[z,1,0,t][w],w]} /. w -> t

ParametricPlot3D[v[t],{t,0,365}]

(* this is km/day/day *)

a[t_] := {D[poly[x,1,0,t][w],w,w], D[poly[y,1,0,t][w],w,w], 
 D[poly[z,1,0,t][w],w,w]} /. w -> t

ParametricPlot3D[a[t],{t,0,365}]

(* find distance from "true" center, assuming orbit is NOT around barycenter *)

(* v^2/r == a, so v^2/a == r *)

r[t_] := Norm[v[t]]^2/Norm[a[t]];

Plot[{r[t],Norm[s[t]]},{t,0,365}]

(* this should be constant IF orbit were around barycenter *)

(* variation is only about 5% around 10^21, which is nearly solar system mass times gravitation constant *)

Plot[Norm[s[t]]^2*Norm[a[t]],{t,0,365}]

(* this should be 1 if orbit were around barycenter, but is really .8 to 1.2 *)

Plot[Norm[v[t]]^2/Norm[s[t]]/Norm[a[t]],{t,0,365}]

(* hypothetical orbit center *)

c[t_] := s[t] + r[t]*(a[t]/Norm[a[t]]);

ParametricPlot3D[c[t],{t,0,365}]

ParametricPlot3D[s[t]-c[t],{t,0,365}]

(* checking against that center... this fit is MUCH WORSE, about 2:1 *)

Plot[Norm[s[t]-c[t]]^2*Norm[a[t]],{t,0,365}]

(* should be 1 if I've found correct orbit; this is constant 1 because
I chose it that way *)

Plot[Norm[v[t]]^2/Norm[s[t]-c[t]]/Norm[a[t]],{t,0,365}]

(* another method to compute r using a = G*m2/r^2, so Sqrt[G*m2/a] *)

(* below in m^3 1/kg 1/s^2 *)

grav = 6.67384*10^-11

(* converting to km^3, 1/kg, 1/day^2 *)

grav2 = grav/1000^3*86400^2;

sm = 1.9891*10^30;

(* mass of solar system *)

ssm = 1.0014*sm

(* test mass *)

tmass = sm*1.03

r2[t_] := Sqrt[grav2*tmass/Norm[a[t]]];

(* r2[t] seems much more reasonable *)

c2[t_] := s[t] + r2[t]*(a[t]/Norm[a[t]]);

ParametricPlot3D[c2[t],{t,0,365}]

Plot[r2[t],{t,0,365}]

Plot[{r[t],r2[t]},{t,0,365}]

(* this is for the first array, ie, first 8 days of mercury's orbit *)

n = 17;

s[t_]={parray[x,1,0][[n]], parray[y,1,0][[n]], parray[z,1,0][[n]]} /. w -> t;

v[t_] = D[s[t],t];

a[t_] = D[v[t],t];

(* Norm[a] is proportional to 1/r^2 but barycenter is not true orbital pt? *)

Plot[Norm[a[t]]*Norm[s[t]]^2,{t,-1,1}]

(* a = v^2/r or a*r/v^2=1? but barycenter not true orbital point *)

Plot[Norm[a[t]]*Norm[s[t]]/Norm[v[t]]^2,{t,-1,1}]

(* one estimate for radius from true center is v^2/a *)

r1[t_] = Norm[v[t]]^2/Norm[a[t]];

(* another is Sqrt[1/Norm[a]], at least proportionally *)

r2[t_] = Norm[a[t]]^(-1/2);

Plot[r1[t],{t,-1,1}]

(* true center of orbit *)

c1[t_] = s[t] + r1[t]/Norm[a[t]]*a[t];

ParametricPlot3D[c[t],{t,-1,1}, AspectRatio->1]



