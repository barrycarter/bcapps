(* work around "new and improved" graphics handling in Mathematica 7+ *)

showit := Module[{},
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* this is a 'clean' library w/ no experiments that can be loaded using << *)

(* obliquity of ecliptic and formula converting horizons-based XYZ from barycenter to RA/DEC *)

(* from http://hpiers.obspm.fr/eop-pc/models/constants.html *)
ecliptic = ArcSin[0.397776995]
mecliptic = {{1,0,0}, {0, Cos[ecliptic], -Sin[ecliptic]},
 {0, Sin[ecliptic], Cos[ecliptic]}}

(* From http://reference.wolfram.com/mathematica/ref/Fourier.html
under Applications/Frequency Identification, modified for
non-zero-mean data *)

superfourier[data_] := Module[{n,m,pdata,f,pos,frpos,freq,phase,b,d},
 n = Length[data];
 m = Mean[data];
 pdata = data-m;
 f = Abs[Fourier[pdata]];
 pos = Ordering[-f, 1][[1]];
 fr = Abs[Fourier[pdata*Exp[2*Pi*I*(pos-2)*N[Range[0, n - 1]]/n],
 FourierParameters -> {0, 2/n}]];
 frpos = Ordering[-fr, 1][[1]];
 freq = N[(pos - 2 + 2*(frpos - 1)/n)];
 phase = Sum[Exp[freq*2*Pi*I*x/n]*data[[x]], {x,1,n}];
 b = N[2*Abs[phase]/n];
 d = N[Arg[phase]];
 Function[x, Evaluate[m + b*Cos[freq*2*Pi/n*x-d]]]
]

(* given data and a function that approximates that data, find an even
better approximation, using superfourier *)

refine[data_, f_] := Module[{t},
 t = Table[data[[x]]- f[x], {x,1,Length[data]}];
 Function[x,Evaluate[f[x] + superfourier[t][x]]]
]

(* multi-level approximations using superfourier and refine *)

superfour[data_, 0] = 0 &
superfour[data_, n_] := superfour[data, n] = refine[data,superfour[data,n-1]]
superleft[data_, n_] := 
 Table[superfour[data,n][x] - data[[x]], {x,1,Length[data]}]
