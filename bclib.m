<< FunctionApproximations`

(* not sure this is a good idea *)

$UnitSystem = "Metric";

(* per http://mathematica.stackexchange.com/questions/109010/texform-of-absan-is-not-valid-tex-known-error/109016#109016 *)

(* <<JavaGraphics` *)

(* work around "new and improved" graphics handling in Mathematica 7+ *)

(* keep files around just in case I need them again *)

showit := Module[{file},
 file = "/tmp/math"<>ToString[RunThrough["date +%Y%m%d%H%M%S", ""]]<>".gif";
 Export[file ,%];
 Run["display -update 1 "<>file<>"&"];
 Return[file];
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

(* findroot using binary method, which Mathematica cant do??? *)
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
sample[f_,a_,b_,n_] := Table[{x,f[x]},{x,a,b,(b-a)/(n-1)}];

(* Given data, return a 'meta-Fourier' function matching it *)

hyperfourier[data_] := Module[
 {f0, period, t1, t2, sampsize, phases, freqs, convert, mean, amp, freq, phase},

 (* TODO: let sampsize be a parameter *)
 sampsize = 1024;

 (* interpolate the function *)
 f0 = Interpolation[data];

 (* find the datas primary period *)
 period = Abs[2*Pi/superfourier[data,1][[3]]];

 (* resample the data to apply Fourier *)
 t1 = Table[Transpose[sample[f0,period*(n-1)+1, period*n+1, sampsize]][[2]], 
 {n,1,Floor[Length[data]/period]}];

 (* obtain the fourier parameters for each chunk *)
 t2 = Transpose[Table[superfourier[i,1],{i,t1}]];

 (* determine frequencies + phases by applying corrections *)
 freqs = t2[[3]]*(sampsize-1)/period;

 (* TODO: improve phase calculations here; subtract off line? *)
 phases = Table[t2[[4,i]]+t2[[3,i]]/period*
 (1 + (-1 + period) sampsize + i (period - period sampsize)),
 {i,1,Floor[Length[data]/period]}];

 (* convert t1 coefficients to actual x coordinates *)
 convert[x_] = (-2+period+2*x)/2/period;

 (* now, Fourier estimate mean, amplitude, frequencies and phases *)
 mean[x_] = superfour[t2[[1]],1][convert[x]];
 amp[x_] = superfour[t2[[2]],1][convert[x]];
 freq[x_] = superfour[freqs,1][convert[x]];
 phase[x_] = superfour[phases,1][convert[x]];

 (* and return the function *)
 Function[x, mean[x] + amp[x]*Cos[x*freq[x] + phase[x]]]
]

(* similar to hyperfourier, but keeps frequence constant *)

calmfourier[data_] := Module[
 {f0, period, t1, t2, sampsize, phases, freqs, convert, mean, amp, freq, phase},

 (* TODO: let sampsize be a parameter *)
 sampsize = 1024;

 (* interpolate the function *)
 f0 = Interpolation[data];

 (* find the datas primary period *)
 period = Abs[2*Pi/superfourier[data,1][[3]]];

 (* resample the data to apply Fourier *)
 t1 = Table[Transpose[sample[f0,period*(n-1)+1, period*n+1, sampsize]][[2]], 
 {n,1,Floor[Length[data]/period]}];

 (* obtain the best fit parameters for each chunk *)
 t2 = Transpose[Table[{a,b,2*Pi/(sampsize-1),c} /. 
 FindFit[t, a+b*Cos[2*Pi*(x-1)/(sampsize-1)+c], {a,b,c}, x],
 {t,t1}
]];

 (* determine frequencies + phases by applying corrections *)
 freqs = t2[[3]]*(sampsize-1)/period;

 (* TODO: improve phase calculations here; subtract off line? *)
 phases = Mod[Table[t2[[4,i]]+t2[[3,i]]/period*
 (1 + (-1 + period) sampsize + i (period - period sampsize)),
 {i,1,Floor[Length[data]/period]}],2*Pi];

 (* convert t1 coefficients to actual x coordinates *)
 convert[x_] = (-2+period+2*x)/2/period;

 (* now, Fourier estimate mean, amplitude, frequencies and phases *)
 mean[x_] = superfour[t2[[1]],1][convert[x]];
 amp[x_] = superfour[t2[[2]],1][convert[x]];
 freq[x_] = superfour[freqs,1][convert[x]];
 phase[x_] = superfour[phases,1][convert[x]];

 (* and return the function *)
 Function[x, mean[x] + amp[x]*Cos[x*freq[x] + phase[x]]]
]

(* generalized inverse discrete fourier transform, per
http://reference.wolfram.com/mathematica/tutorial/FourierTransforms.html; unlike InverseFourier, this works symbolically too
*)

gidft[list_, r_, a_:0, b_:1] := 
Sum[list[[s]]*Exp[-2*Pi*I*b*(r-1)*(s-1)/Length[list]], {s,1,Length[list]}]/
Length[list]^((1+a)/2)

(* Generalized discrete Fourier transform, per
http://reference.wolfram.com/mathematica/tutorial/FourierTransforms.html
*)

gdft[list_, s_, a_:0, b_:1] :=
Sum[list[[r]]*Exp[2*Pi*I*b*(r-1)*(s-1)/Length[list]], {r,1,Length[list]}]/
Length[list]^((1-a)/2)

(* convert a list of Chebyshev coefficients to a list of Taylor
coefficients; this version might be less efficient than the earlier
one, but works fast enough for me *)

cheb2tay[x_] := CoefficientList[Sum[
 x[[i]]*ChebyshevT[i-1,t], {i,1,Length[x]}],t];

(* Taylor of a list at a variable *)

(* putting list[[1]] separately avoids 0^0 error *)
taylor[list_,t_] := list[[1]]+Sum[list[[i]]*t^(i-1),{i,2,Length[list]}]

(* Chebyshev of a list at a variable *)

chebyshev[list_,t_] := Sum[list[[i]]*ChebyshevT[i-1,t],{i,1,Length[list]}]

(* Given a list of Taylor coefficients and n, create n sets of Taylor
coefficients, each good for 1/n of the interval [-1,1] (ie, tailor a
Taylor series to behave the way we want) *)

tailortaylor[list_,n_] := Table[CoefficientList[
 taylor[list,(t+2*i-1)/n-1],t],{i,1,n}]

(* Yet another Fourier approximation to a list, this one using
FindMinimum and usually finds a better fit *)

(* number of periods in a list, roughly *)

numperiods[data_] := Ordering[Abs[Take[Fourier[data], 
 {2,Round[Length[data]/2+1]}]],-1][[1]];

(* see comments for superfourier, same thing below; options passed
directly to FindMinimum *)

(* TODO: do not default to method Newton, find a better way to do this *)

fourtwo[data_] := 
 Function[x, Evaluate[a+b*Cos[c*x-d] /.
 FindMinimum[Sum[((a+b*Cos[c*n-d]) - data[[n]])^2, {n,1,Length[data]}],
 {{a,Mean[data]},{b,(Max[data]-Min[data])/2},
 {c,numperiods[data]*2*Pi/Length[data]},d}, Method -> Newton][[2]]
]];

refinefourtwo[data_, f_] := Module[{t},
 t = Table[data[[x]]- f[x], {x,1,Length[data]}];
 Function[x,Evaluate[f[x] + fourtwo[t][x]]]
]

superfourtwo[data_, 0] = 0 &
superfourtwo[data_, n_] := 
 superfourtwo[data, n] = refinefourtwo[data,superfourtwo[data,n-1]];

superfourtwoleft[data_, n_] := 
 Table[superfourtwo[data,n][x] - data[[x]], {x,1,Length[data]}];

(* matrix of rigid rotation around xyz axis *)

rotationMatrix[x,theta_] = {
 {1,0,0}, {0,Cos[theta],Sin[theta]}, {0,-Sin[theta],Cos[theta]}
};

rotationMatrix[y,theta_] = {
 {Cos[theta],0,-Sin[theta]}, {0,1,0}, {Sin[theta],0,Cos[theta]}
};

rotationMatrix[z,theta_] = {
 {Cos[theta],-Sin[theta],0}, {Sin[theta],Cos[theta],0}, {0,0,1}
};

(* TODO: check the formulas below, they might be wrong *)

(* ellipse, A/B = semimajor/minor axes, E = eccentricity, MA = mean
anomaly, TA = true anomaly *)

ellipseAreaFromFocus[a_,b_,t_] = a*b*t/2 - Sqrt[a^2-b^2]*b*Sin[t]/2
ellipseAB2E[a_,b_] = Sqrt[1-b^2/a^2]
ellipseEA2B[a_,e_] = a*Sqrt[1-e^2]

ellipseMA2T[a_,b_,ma_] := Module[{t},
 FindRoot[ellipseAreaFromFocus[a,b,t]==a*b*ma/2,{t,0}, AccuracyGoal ->
 10, PrecisionGoal -> 10][[1,2]]]

ellipseMA2TA[a_,b_,ma_] := Module[{t},
 t = ellipseMA2T[a,b,ma];
 ArcTan[a*Cos[t]-Sqrt[a^2-b^2],b*Sin[t]]
]

ellipseMA2XY[a_,b_,ma_] := Module[{t},
 t = ellipseMA2T[a,b,ma];
 {a*Cos[t], b*Sin[t]}
];

(* given a list, find all zero crossings, interpolating between elements *)
zeroCrossings[l_] := Module[{zc},
 (* the last elt of 0 crossings *)
 zc = Select[Range[2,Length[l]], Sign[l[[#-1]]] != Sign[l[[#]]] &];
 Table[i+l[[i]]/(l[[i-1]]-l[[i]]),{i,zc}]
];

(* the radius of the earth at latitude l (given in radians) *)

rad[lat_] = Sqrt[8108893139432429 - 32876703150355522144690902360200/
    (8108893139432429 + 27233178721371*Cos[2*lat])]/10000

(* GMST and GAST time at Unix day d, given as an angle,
http://aa.usno.navy.mil/faq/docs/GAST.php *)

gmst[d_] = 
  ((-452506800334363673497 + 41299464944756238*d)*Pi)/20593349747540136;

(* Brent method of FindRoot improved *)

brent[f_,a_,b_] = If[Sign[f[a]]==Sign[f[b]], {}, FindRoot[f,{a,b},
Method -> Brent]];

(* ternary method to find mimima *)

(* TODO: this is recursive and thus non-ideal *)

ternary[a_,b_,f_,eps_] := Module[{t},
 If[Abs[a-b]<eps,Return[{(a+b)/2,f[(a+b)/2]}]];
 t = Table[{x,f[x]},{x,a,b,(b-a)/3}];
 If[t[[2,2]]<=t[[3,2]]<=t[[4,2]],Return[ternary[a,t[[3,1]],f,eps]]];
 If[t[[3,2]]<=t[[2,2]]<=t[[1,2]],Return[ternary[t[[2,1]],b,f,eps]]];
 If[t[[2,2]]<t[[1,2]] && t[[3,2]]<t[[4,2]],
  Return[ternary[t[[2,1]],t[[3,1]],f,eps]]];
 Return[{Null,Null}];
]

(* per http://mathematica.stackexchange.com/questions/5663/about-multi-root-search-in-mathematica-for-transcendental-equations *)

Options[FindAllCrossings] = 
  Sort[Join[Options[FindRoot], {MaxRecursion -> Automatic,
       PerformanceGoal :> $PerformanceGoal, PlotPoints -> Automatic}]];

FindAllCrossings[f_, {t_, a_, b_}, opts___] := Module[{r, s, s1, ya},
       {r, ya} = Transpose[First[Cases[Normal[
                 Plot[f, {t, a, b}, Method -> Automatic,
                 Evaluate[Sequence @@ 
                 FilterRules[Join[{opts}, Options[FindAllCrossings]], 
                             Options[Plot]]]]], Line[l_] :> l, Infinity]]];
       s1 = Sign[ya]; If[ ! MemberQ[Abs[s1], 1], Return[{}]];
       s = Times @@@ Partition[s1, 2, 1];
       If[MemberQ[s, -1] || MemberQ[Take[s, {2, -2}], 0], 
          Union[Join[Pick[r, s1, 0], 
                Select[t /. Map[FindRoot[f, {t, r[[#]], r[[# + 1]]}, 
                       Evaluate[Sequence @@ 
                       FilterRules[Join[{opts}, Options[FindAllCrossings]], 
                                   Options[FindRoot]]]] &,
                       Flatten[Position[s, -1]]], a <= # <= b &]]], {}]]

(* the planet functions below only work if pos[] is defined *)

(* A planets position *)

posxyz[jd_,planet_] := Module[{jd2,chunk,days,t},

   (* special case for Earth sigh, below is EMRAT1 *)
   If[planet==earth, Return[
    posxyz[jd,earthmoon]-50000000000000/4115028453709531*posxyz[jd,moongeo]]];

   (* normalize to boundary *)
   jd2 = jd-33/2;

   (* days in a given chunk *)
   days = 32/info[planet][chunks];

   (* which chunk *)
   chunk = Floor[Mod[jd2,32]/days]+1;

   (* where in chunk *)
   t = Mod[jd2,days]/days*2-1;

   (* and Chebyshev *)
   Table[chebyshev[pos[planet][Quotient[jd2,32]*32+33/2][[chunk]][[i]],t],
    {i,1,3}]
];

(* the vector between earth and a planet *)

earthvector[jd_,planet_] := posxyz[jd,planet]-posxyz[jd,earthmoon];

(* the fixed J2000 vector for a given ra/dec [eg, fixed stars] *)

earthvecstar[ra_,dec_] = {Cos[ra]*Cos[dec], Sin[ra]*Cos[dec], Sin[dec]};

(* angle between two planets, as viewed from earth *)

earthangle[jd_,p1_,p2_] :=  VectorAngle[earthvector[jd,p1],earthvector[jd,p2]];

xyz2sph[x_,y_,z_] = {ArcTan[x,y], ArcTan[Sqrt[x^2+y^2],z], Norm[{x,y,z}]};
sph2xyz[th_,ph_,r_] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]};

xyz2sph[l_] := Apply[xyz2sph,l]
sph2xyz[l_] := Apply[sph2xyz,l]

(* the order here is time then distance, which may have been a bad idea *)

relativityMatrix[v_]= 1/Sqrt[1-v^2]*{ {1,v}, {v,1}};

(* from STACK/bc-rst.m, after simplification, deciding on El for
elevation, instead of Alt for altitude; HA = hour angle *)

HADecLat2azEl[ha_, dec_, lat_] = 
   {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat], -(Cos[dec]*Sin[ha])],
    ArcTan[Sqrt[Cos[dec]^2*Sin[ha]^2 + (Cos[lat]*Sin[dec] - 
         Cos[dec]*Cos[ha]*Sin[lat])^2], Cos[dec]*Cos[ha]*Cos[lat] + 
      Sin[dec]*Sin[lat]]}
