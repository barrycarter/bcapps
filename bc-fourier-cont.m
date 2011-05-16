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

(* given data and a function that approximates that data, find an even
better approximation, using superfourier *)

refine[data_, f_] := Module[{t},
 t = Table[data[[x]]- f[x], {x,1,Length[data]}];
 f[x] + superfourier[t]
]

(* tmp isn't mirrored so this data [obtained from
http://ssd.jpl.nasa.gov/?horizons] isn't available in this repo [but
will be if I find it more useful] *)

data = ReadList["/home/barrycarter/BCGIT/tmp/moondec.txt"]

(* defining h1 to be 0 is silly, but useful; h2 is effectively
superfourier on the data *)

(* could loopify below, but not doing so for now *)

h1[x_] = 0
h2[x_] = refine[data,h1]
h3[x_] = refine[data,h2]
h4[x_] = refine[data,h3]
h5[x_] = refine[data,h4]
h6[x_] = refine[data,h5]
h7[x_] = refine[data,h6]
h8[x_] = refine[data,h7]
h9[x_] = refine[data,h8]
h10[x_] = refine[data,h9]
h11[x_] = refine[data,h10]
h12[x_] = refine[data,h11]
h13[x_] = refine[data,h12]
h14[x_] = refine[data,h13]


tab = Table[h14[x],{x,1,Length[data]}]

ListPlot[{data-tab}]


