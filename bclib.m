(* work around "new and improved" graphics handling in Mathematica 7+ *)

(* keep files around just in case I need them again *)

showit := Module[{file},
 file = "/tmp/math"<>ToString[RunThrough["date +%Y%m%d%H%M%S", ""]]<>".jpg";
 Export[file ,%, ImageSize->{800,600}];
 Run["display "<>file<>"&"];
];

(* another mathematica "fix" that breaks things *)
Unprotect[PlotJoined]
PlotJoined := Joined

(* this is a 'clean' library w/ no experiments that can be loaded using << *)

(* obliquity of ecliptic and formula converting horizons-based XYZ from barycenter to RA/DEC *)

(* from http://hpiers.obspm.fr/eop-pc/models/constants.html *)
ecliptic = ArcSin[0.397776995]
mecliptic = {{1,0,0}, {0, Cos[ecliptic], -Sin[ecliptic]},
 {0, Sin[ecliptic], Cos[ecliptic]}}

(*

From http://reference.wolfram.com/mathematica/ref/Fourier.html under
Applications/Frequency Identification, modified for non-zero-mean data.

If mode=1, return coefficients as a list, not a function

*)

superfourier[data_,mode_:0] :=
Module[{n,m,pdata,f,fr,pos,frpos,freq,phase,b,d},
 n = Length[data];
 m = Mean[data];
 pdata = data-m;
 f = Abs[Fourier[pdata]];
 pos = Ordering[-f, 1][[1]];
 fr = Abs[Fourier[pdata*Exp[2*Pi*I*(pos-2)*N[Range[0, n - 1]]/n],
 FourierParameters -> {0, 2/n}]];
 frpos = Ordering[-fr, 1][[1]];
 freq = N[(pos - 2 + 2*(frpos - 1)/n)];
 phase = Sum[Exp[freq*2*Pi*I*x/n]*pdata[[x]], {x,1,n}];
 b = N[2*Abs[phase]/n];
 d = N[Arg[phase]];
 If[mode==1,Return[{m,b,-freq*2*Pi/n,d}]];
 Function[x, Evaluate[m + b*Cos[freq*2*Pi/n*x-d]]]
]

(* 

Given data and a function that approximates that data, find an even
better approximation, using superfourier

*)

refine[data_, f_] := Module[{t},
 t = Table[data[[x]]- f[x], {x,1,Length[data]}];
 Function[x,Evaluate[f[x] + superfourier[t][x]]]
]

(* multi-level approximations using superfourier and refine *)

superfour[data_, 0] = 0 &
superfour[data_, n_] := superfour[data, n] = refine[data,superfour[data,n-1]];
superleft[data_, n_] := 
 Table[superfour[data,n][x] - data[[x]], {x,1,Length[data]}];

(* approximate derivative using definition *)

fakederv[f_,x_,delta_] = (f[x+delta/2]-f[x-delta/2])/delta;

(* list difference *)

difference[l_] := Table[l[[i]] - l[[i-1]], {i,2,Length[l]}]

(* continuous Fourier transform with memory *)

cft[l_,s_] := cft[l,s] = 
Sum[l[[x]]*Exp[2*Pi*I*(x-1)*(s-1)/Length[l]],{x,1,Length[l]}]/Sqrt[Length[l]];

(* findroot using binary method, which Mathematica can't do??? *)
(* using N throughout for speed *)
findroot2[f_, a_, b_, delta_] := Module[{mid,fa,fb,fmid},
 mid = N[(a+b)/2];
 If[Abs[a-b]<delta,Return[mid]];
 (* solely to avoid recomputation *)
 fa = N[f[a]];
 fb = N[f[b]];
 fmid = N[f[mid]];
 (* corner case *)
 If[Sign[fmid]==0,Return[mid]];
 If[Sign[fa]==Sign[fb],Return["error"]];
 If[Sign[fmid]==Sign[fa], Return[findroot2[f,mid,b,delta]]];
 If[Sign[fmid]==Sign[fb], Return[findroot2[f,a,mid,delta]]];
 Return["error"];
]

(* return a table that samples f at n different points between a and b *)
sample[f_,a_,b_,n_] := Table[{x,f[x]},{x,a,b,(b-a)/(n-1)}]

