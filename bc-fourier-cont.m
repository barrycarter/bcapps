(* Continuous Fourier transforms to approximate data such as
solar/lunar positions *)

(* given a collection of data, return the cosine-ish function that
approximates it. From
http://stackoverflow.com/questions/4463481/continuous-fourier-transform-on-discrete-data-using-mathematica
*)

(* TODO: dislike returning f[x] instead of a pure function f, but
can't find fix for now *)

superfourier[data_] :=Module[{pdata, n, f, pos, fr, frpos, freq, phase, coeff},
 pdata = data - Mean[data];
 n = Length[data];
 f = Abs[Fourier[pdata]];
 pos = Ordering[-f, 1][[1]];
 fr = Abs[Fourier[pdata*Exp[2*Pi*I*(pos-2)*Range[0,n-1]/n], 
      FourierParameters -> {0, 2/n}]];
 frpos = Ordering[-fr, 1][[1]];
 freq = (pos-2 + 2*(frpos - 1)/n);
 phase = Sum[Exp[freq*2*Pi*I*x/n]*pdata[[x]], {x,1,n}];
 coeff =  {Mean[data], 2*Abs[phase]/n, freq*2*Pi/n, Arg[phase]};
 Return[coeff[[1]] + coeff[[2]]*Cos[coeff[[3]]*x - coeff[[4]]]]
]

(* some tests *)
rand = {Random[Real,100],Random[Real,100],Random[Real,100],Random[Real,2*Pi]}
f[x_] = rand[[1]] + rand[[2]]*Cos[rand[[3]]*x/10000 - rand[[4]]]
data = Table[f[x],{x,1,10000}]
g[x_] = superfourier[data]
gxt = Table[g[x],{x,1,10000}]
ListPlot[{data,gxt}]
ListPlot[{data-gxt}]



