(* 

Attempts to solve
http://math.stackexchange.com/questions/1615072/eccentricity-is-invariant-for-ellipse-defined-by-intersection-between-plane-and

(x/a)^2 + (y/b)^2 + *(1-fx-gy)/ch)^2 == 1

"randomly" choosing values below 

*)

a = 2;
b = 1;
f = 3;
g = 12;
h = 8;
c = 12;

s = Solve[(x/a)^2 + (y/b)^2 + ((1-f*x-g*y)/c/h)^2 == 1,y]

Plot[{s[[1,1,2]], s[[2,1,2]]}, {x,-a,a}, AspectRatio -> Automatic]

ParametricPlot[{2*Cos[t],Sin[t]},{t,0,2*Pi}]

ParametricPlot[{2*Cos[t],Sin[t+45*Degree]},{t,0,2*Pi}]

foci = Sqrt[3]*{{1,1},{-1,1}}

Norm[{2*Cos[t],Sin[t+45*Degree]}-foci[[1]]] +
Norm[{2*Cos[t],Sin[t+45*Degree]}-foci[[2]]]

semimajor axis is Sqrt[5], 

p[t_] = 2*Sqrt[2]/3*{2*Cos[t],Sin[t+45*Degree]};

ParametricPlot[p[t],{t,0,2*Pi}]

ParametricPlot[p[t],{t,0,Pi/2}, AxesOrigin->{0,0}]

q[t_] = {2*Cos[t],Sin[t]}

ParametricPlot[q[t],{t,0,2*Pi}]


(2*Cos[t])^2/2 + (Sin[t+45*Degree])^2/(1/2)


(2*Cos[t])^2/a^2 + (Sin[t+45*Degree])^2/b^2

Sin[ArcCos[x/2]+45*Degree]
