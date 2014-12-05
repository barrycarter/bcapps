(* acceleration and velocity in terms of finding a gravitation object *)

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



