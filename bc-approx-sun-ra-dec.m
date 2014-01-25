(* 

DO NOT "<<" this file; it's more of a cut-and-paste sort of thing

Mathematica script to approximate Suns RA/DEC for bc-sun-always-shines.pl
<h>that video is creepy</h>

TODO: ending formulas are simple enough for JavaScript, so someone
could write a Javascript that lets you watch "sunset sweep
majestically over Albuquerque" <h>(or some such bullshit anyway)</h>

NOTE: Mathematica whines a lot when using AstronomicalData as a pure
numerical function because it tries to simplify it symbolically
first. Example:

AstronomicalData::notprop: 
   {"Declination", ToDate[x]} is not a known property for AstronomicalDat
     a. Use AstronomicalData["Properties"] for a list of properties.

ToDate::tdn: First argument #1 should be an integer or a real number.

Despite this, it ultimately comes up w/ the right answers

"setenv TZ GMT" before starting Mathematica to force GMT

*)

(* planet xyz position data, every 10th line only for now *)

<<"/home/barrycarter/DATA/199-mini.txt"
p1 = planet199;
p2 = Table[{x[[2]],{x[[3]],x[[4]],x[[5]]}}, {x,p1}];
f0 = Interpolation[p2]
f3[t_] = 2*(t-p2[[1,1]])/(p2[[-1,1]]-p2[[1,1]])-1;

f4[t_] = f0[f3[t]]






f1[x_] = Table[superfour[Transpose[Transpose[p2][[2]]][[i]],2][x],{i,1,3}]

(* 1 -> p2[[1]], Length[p2] -> p2[[-1]] *)

ftemp[t_] = (t-p2[[1,1]])/(p2[[-1,1]]-p2[[1,1]])*(Length[p2]-1)+1

f2[x_] = f1[ftemp[x]]

ParametricPlot3D[f2[t]-f0[t],{t,p2[[1,1]],p2[[-1,1]]}]
ParametricPlot3D[f2[t]-f0[t],{t,p2[[1,1]],p2[[1,1]]+24}]



ParametricPlot3D[f1[x],{x,1,Length[p2]}]


px = Table[x[[3]],{x,p1}];
py = Table[x[[4]],{x,p1}];
pz = Table[x[[5]],{x,p1}];
pdist = Sqrt[px^2+py^2+pz^2];
pang = ArcSin[pz/pdist];

period = Abs[2*Pi/superfourier[pdist,1][[3]]]
f0 = Interpolation[pdist]
list = Transpose[sample[f0, period+1, 2*period+1,1024]][[2]];
a0 = FourierDCT[list,2];
a2 = Take[Table[{i,a0[[i]]}, {i, Reverse[Ordering[Abs[a0]]]}],4];
a3 = Table[0,{i,Length[list]}];
Table[a3[[i[[1]]]] = i[[2]], {i,a2}];
a4 = FourierDCT[a3,3];
ListPlot[{a4-list},PlotRange->All]
showit
Total[Abs[a4-list]]/Length[list]



f21[x_] = 7*Cos[3*x] + Cos[4*x]

f20[n_] = Integrate[Cos[n*x]*(f21[x]),{x,0,2*Pi}]

Plot[f20[n],{n,0,6}]

f0 = Interpolation[px]
f1[x_] = calmfourier[px][x]
Plot[{f1[x],f0[x]},{x,1,Length[px]}]
showit
Plot[{f1[x]-f0[x]},{x,1,Length[px]}]
showit
r1 = Table[f1[x]-px[[x]],{x,1,Length[px]}];

f2[x_] = calmfourier[r1][x]
Plot[{f1[x]-f0[x],f2[x]},{x,1,Length[px]}]
showit
Plot[{f1[x]-f0[x]-f2[x]},{x,1,Length[px]}]
showit
r2 = Table[f1[x]-px[[x]]-f2[x],{x,1,Length[px]}];

f3[x_] = calmfourier[r2][x]
Plot[{f1[x]-f0[x]-f2[x],f3[x]},{x,1,Length[px]}]
showit
Plot[{f1[x]-f0[x]-f2[x]-f3[x]},{x,1,Length[px]}]
showit
r3 = Table[f1[x]-px[[x]]-f2[x]-f3[x],{x,1,Length[px]}];

f4[x_] = calmfourier[r3][x]
Plot[{f1[x]-f0[x]-f2[x]-f3[x],f4[x]},{x,1,Length[px]}]
showit
Plot[{f1[x]-f0[x]-f2[x]-f3[x]-f4[x]},{x,1,Length[px]}]
showit
r4 = Table[f1[x]-px[[x]]-f2[x]-f3[x]-f4[x],{x,1,Length[px]}];

r5 = superleft[px,2];
ListPlot[r5]
showit
g1[x_] = calmfourier[r5][x]

r6 = Table[g1[x],{x,1,Length[pdist]}];
ListPlot[r5-r6]
showit

r7 = r5-r6;












fourcoff[a_,b_,c_,d_] = Function[x,a + b*Cos[c*x+d]];

f[x_] = FullSimplify[fourcoff[a1,a2,a3,a4][x] + fourcoff[b1,b2,b3,b4][x]*
Cos[fourcoff[c1,c2,c3,c4][x] + fourcoff[d1,d2,d3,d4][x]], Reals]

l = {a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4,d1,d2,d3,d4}

g[x_] = f[x] /. FindFit[pdist, f[x], l, x]

Plot[{g[x],f0[x]},{x,1,Length[pdist]}]

(* this time, only change mean + amp, not phase/etc *)

f0 = Interpolation[pdist]

coeff = superfourier[pdist,1];
period = Abs[2*Pi/coeff[[3]]];
phase = coeff[[4]];

means = Table[NIntegrate[f0[x],{x,period*(n-1)+1, period*n+1}],
{n,1,Floor[Length[pdist]/period]}]/period

amps = Sqrt[Table[NIntegrate[(f0[x]-means[[n]])^2,
 {x,period*(n-1)+1, period*n+1}],
{n,1,Floor[Length[pdist]/period]}]/(period/2)]

convert[x_] = (-2+period+2*x)/2/period;

mean[x_] = superfour[means,1][convert[x]];
amp[x_] = superfour[amps,1][convert[x]];

f[x_] = mean[x] + amp[x]*Cos[-2*Pi/period*x + phase];

r1 = Table[pdist[[i]]-f[i],{i,1,Length[pdist]}];



ListPlot[r1]

g[x_] = calmfourier[r1][x]

r2 = Table[pdist[[i]]-f[i]-g[i],{i,1,Length[pdist]}];

h[x_] = calmfourier[r2][x]

r3 = Table[pdist[[i]]-f[i]-g[i]-h[i],{i,1,Length[pdist]}];

j[x_] = calmfourier[r3][x]

r4 = Table[pdist[[i]]-f[i]-g[i]-h[i]-j[i],{i,1,Length[pdist]}];


(* interpolate the function *)

f0 = Interpolation[pdist];

(* find the period and phase *)
period = Abs[2*Pi/superfourier[pdist,1][[3]]];

(* sample size *)
sampsize = 1024;

(* list chunks *)

(* todo: do NOT omit the last "incomplete" chunk *)

t1 = Table[Transpose[sample[f0,period*(n-1)+1, period*n+1, sampsize]][[2]], 
{n,1,Floor[Length[pdist]/period]}];

t2 = Transpose[Table[{a,b,2*Pi/(sampsize-1),c} /. 
 FindFit[t, a+b*Cos[2*Pi*(x-1)/(sampsize-1)+c], {a,b,c}, x],
 {t,t1}
]]

f3[x_,n_] := t2[[1,n]] + t2[[2,n]]*Cos[t2[[3,n]]*x+ t2[[4,n]]]

f4[n_] = Function[x, ((x-1)*period/(sampsize-1) + 1) + (n-1)*period]

f5[n_] = InverseFunction[f4[n]]

f3[f5[1][x],1]

phases = Mod[Table[t2[[4,i]]+t2[[3,i]]/period*
 (1 + (-1 + period) sampsize + i (period - period sampsize)),
 {i,1,Floor[Length[pdist]/period]}],2*Pi];

convert[x_] = (-2+period+2*x)/2/period;

f[x_] = t2[[1,1]]+t2[[2,1]]*Cos[t2[[3,1]]*x+t2[[4,1]]]

mean[x_] = superfour[t2[[1]],1][convert[x]];
amp[x_] = superfour[t2[[2]],1][convert[x]];
phase[x_] = superfour[phases,1][convert[x]];

f10[x_] =  mean[x] + amp[x]*Cos[2*Pi/period*x + phase[x]]








ListPlot[t1]

Plot[{Interpolation[t1[[1]]][x],superfour[t1[[1]],1][x]},{x,1,1024}]

Plot[{superfour[pdist,1][f4[1][x]],superfour[t1[[1]],1][x]},{x,1,1024}]

t6 = Transpose[sample[f0,1,period+1,sampsize]][[2]]

t7 = superfour[Take[pdist,{1,Round[period]}],1]

a+b*Cos[2*Pi*(x-1)/(sampsize-1)+c] /. 
FindFit[t1[[1]], a+b*Cos[2*Pi*(x-1)/(sampsize-1)+c], {a,b,c}, x]

a+b*Cos[2*Pi*(x-1)/(sampsize-1)+c] /. 
FindFit[t1[[7]], a+b*Cos[2*Pi*(x-1)/(sampsize-1)+c], {a,b,c}, x]

(* obtain the Fourier coefficients for each period *)

t2 = Transpose[Table[superfourier[i,1],{i,t1}]]

(* fix frequencies and phase shifts *)

freqs = t2[[3]]*(sampsize-1)/period;

phases = Table[t2[[4,i]]+t2[[3,i]]/period*
(1 + (-1 + period) sampsize + i (period - period sampsize)),
{i,1,Floor[Length[pdist]/period]}]

(* converting fourier coefficients x value to true x value *)

f7[n_] = FullSimplify[((period*(n-1)+1) + (period*n+1))/2,Reals]

f8[x_] = FullSimplify[InverseFunction[f7][x],Reals]

mean[x_] = superfour[t2[[1]],1][f8[x]];
amp[x_] = superfour[t2[[2]],1][f8[x]];
freq[x_] = superfour[freqs,1][f8[x]];
phase[x_] = superfour[phases,1][f8[x]];

f10[x_] =  mean[x] + amp[x]*Cos[x*freq[x] + 2.14326]
f10[x_] =  mean[x] + amp[x]*Cos[-x*0.00297514 + 2.14326]
f10[x_] =  mean[x] + 1.15017*10^7*Cos[-x*0.00297514 + 2.14326]

f10[x_] =  5.9116018609681964*^7 + 1.1501735723131603*^7*
 Cos[-x*0.002975140780890627 + 2.1432646522503234]

f10[x_] =  mean[x] + 1.1501735723131603*^7*
 Cos[-x*0.002975140780890627 + 2.1432646522503234]

f10[x_] =  mean[x] + amp[x]*
 Cos[x*freq[x] + 2.1432646522503234]


f10[x_] =  mean[x] + amp[x]*Cos[x*freq[x] + phase[x]]



(* below is:

superfour[t1[[3]],1][x]
Simplify[superfour[t1[[3]],1][f5[3][x]]]                              

*)

(* formula for 3rd chunk of table above: *)

Cos[1.73404 - 0.00548878 x]

(* when converted to true x *)

Cos[12.9612 - 0.00265876 x]

(* change in period is correct *)

(period/c)* (1 + (-1 + period) sampsize + n (period - period sampsize))










(* fix the phases; MUST be done BEFORE fixing the freqs? *)

phases = Table[t2[[4,n]] + t2[[3,n]]/period*(1 - sampsize + period*(n
+ sampsize - n*sampsize)), {n,1,Floor[Length[pdist]/period]}];

(* fix the frequency *)

freqs = t2[[3]]*(sampsize-1)/period;

f4[n_] = Function[x, ((x-1)*period/(sampsize-1) + 1) + (n-1)*period]

f5[n_] = InverseFunction[f4[n]]

f6[x_] = a+b*Cos[c*x+d]

f7[x_] = f6[f5[n][x]][[2,2,1]]

FullSimplify[f7[x]-f7'[x]*x]

f3[x_,n_] := t2[[1,n]] + t2[[2,n]]*Cos[t2[[3,n]]*x+ t2[[4,n]]]

(* below shouldn't work, but does *)

f1[x_,n_] := t2[[1,n]] + t2[[2,n]]*Cos[freqs[[n]]*x+t2[[4,n]]]

f2[x_,n_] := superfour[Take[pdist, {Round[period*(n-1)+1],
Round[period*n+1]}], 1][f5[n][x]]

f11[x_,n_] := superfour[Take[pdist, {Round[period*(n-1)+1],
Round[period*n+1]}], 1][x-period+1]

Plot[{f1[x,7],f2[x,7]},{x,6*period+1,7*period+1}]

Plot[f3[x,2],{x,1,1024}]

Plot[{f2[x,19],f10[x]},{x, 18*period+1, 19*period+1}]

Plot[{f10[x],f0[x]},{x,1,Length[pdist]}]
Plot[{f10[x],superfour[pdist,1][x]},{x,1,Length[pdist]}]

mean[x_] = superfour[t2[[1]],1][f8[x]];
amp[x_] = superfour[t2[[2]],1][f8[x]];
freq[x_] = superfour[freqs,1][f8[x]];
phase[x_] = superfour[phases,1][f8[x]];

f10[x_] =  mean[x] + amp[x]*Cos[x*freq[x] + phase[x]]



f9[x_] = superfour[t2[[1]],1][f8[x]] + superfour[t2[[2]],1][f8[x]] *
 Cos[superfour[freqs,1][f8[x]]*x + superfour[t2[[4]],1][f8[x]]]













(* final function? *)

f2[x_] = superfour[t2[[1]],1][x/period] + superfour[t2[[2]],1][x/period] *
 Cos[superfour[freqs,1][x/period]*x + superfour[t2[[4]],1][x/period]]

Plot[{f2[x],f0[x]},{x,1,period+1}]

ftest[x_] = t2[[1,1]] + t2[[2,1]]*Cos[freqs[[1]]*x + t2[[4,1]]]

Plot[{ftest[x],f0[x]},{x,1,period+1}]

ftest2[x_] = t2[[1,1]]+t2[[2,1]]*Cos[superfour[freqs,1][x/period]*x+t2[[4,1]]]

Plot[{ftest2[x],f0[x]},{x,1,period+1}]

orig[x_] = 5.9116018609681964*^7 + 1.1501735723131603*^7*
Cos[2.1432646522503234 - 0.002975140780890627*x]

Plot[{f0[x]-orig[x]},{x,1,Length[pdist]}]
Plot[{f0[x]-orig[x]},{x,15*period+1,16*period+1}]

mod1[x_] = superfour[t2[[1]],1][x/period] + 1.1501735723131603*^7*
Cos[2.1432646522503234 - 0.002975140780890627*x]

Plot[{f0[x]-mod1[x]},{x,1,Length[pdist]}]
Plot[{f0[x]-mod1[x]},{x,15*period+1,16*period+1}]
Plot[{orig[x]-mod1[x]},{x,15*period+1,16*period+1}]
Plot[{orig[x]-mod1[x]},{x,1,period+1}]
Plot[{orig[x]-mod1[x]},{x,1,Length[pdist]}]

mod2[x_] = superfour[t2[[1]],1][x/period] + superfour[t2[[2]],1][x/period]*
Cos[2.1432646522503234 - 0.002975140780890627*x]

Plot[{f0[x]-mod2[x]},{x,1,Length[pdist]}]
Plot[{f0[x]-mod2[x]},{x,15*period+1,16*period+1}]
Plot[{f0[x]-mod2[x]},{x,1,period+1}]
Plot[{f0[x]-orig[x]},{x,1,period+1}]
Plot[{orig[x]-mod2[x]},{x,15*period+1,16*period+1}]
Plot[{orig[x]-mod2[x]},{x,1,period+1}]
Plot[{orig[x]-mod2[x]},{x,1,Length[pdist]}]

mod3[x_] = superfour[t2[[1]],1][x/period] + superfour[t2[[2]],1][x/period]*
Cos[2.1432646522503234 - 0.002975140780890627*x]

phase = Table[t2[[4,i]]/f1[t2[[4,i]]/t2[[3,i]]], {i,1,Length[t2[[4]]]}]

(* and the frequency *)

freqs = 

,{n,0,Floor[Length[pdist]/period]-1}]

Table[{period*n+1, period*(n+1)+1},

(* sample the function 1024 times on one period *)

Transpose[sample[f0,1,1+period,1024]][[2]]

(* and its inverse *)
f2[x_] = InverseFunction[f1][x]

superfour[pdist,1]

(* know the period, we define some functions *)

(* a5[10] and f1[10][x] sync *)

f1[n_] = Function[x,f0[x+1+2111.9*n]]

f7[x_] = (x-1)/1023*2111.9+1

Plot[f1[0][x],{x,0,2111.9}]

Table[f1[n][x],{n,0,Length[pdist]/2111.9-1}]

a5[n_] = Transpose[sample[f1[n],0,2111.9,1024]][[2]];


a1 = Table[Transpose[sample[f1[n],0,2111.9,1024]][[2]],
{n,0,Length[pdist]/2111.9-1}];

a2 = Transpose[Table[superfourier[n,1],{n,a1}]]

(* correction to frequency: multiply by 1024/2111.9 *)

a2[[3]] = a2[[3]]*1024/2111.9;

(* correction to phase??? *)

a2[[4]] = a2[[4]]*1024/2111.9;

a3 = Table[superfour[a,1][x],{a,a2}]

h[x_] = a3[[1]] + a3[[2]]*Cos[a3[[3]]*x + a3[[4]]]

f[x_] = a3[[1]] + a3[[2]]*Cos[a3[[3]]*((x-1)*2111.9 + 1) + a3[[4]]]

(* f looks fine, shape wise *)

g[x_] = f[(x-1)/2111.9+1]

Table[pdist[[i]]-g[i/2],{i,1,Length[pdist]}]


(* extracting terms from what superfour returns:

[[2,1]] is the constant term [aka mean]
[[2,2,1]] is the amplitude
[[2,2,2,1,1]] is the phase shift
[[2,2,2,1,2,1]] is the freq multiplier

TODO: this is almost definitely the wrong way to extract these

 *)

means = Table[a2[[n,2,1]],{n,1,Length[a2]}]
amps = Table[a2[[n,2,2,1]],{n,1,Length[a2]}]
phases = Table[a2[[n,2,2,2,1,1]],{n,1,Length[a2]}]
freqs = Table[a2[[n,2,2,2,1,2,1]],{n,1,Length[a2]}]

(* converts 1 to 33 to 1 to 67581.8, the part of the list we have estimate *)

f5[x_] = (x-1)*2111.9 + 1

f2[x_] = superfour[means,1][x] + 
 superfour[amps,1][x]*Cos[superfour[phases,1][x] +
 superfour[freqs,1][x]*(f5[x])]






f2[x_] = 5.9098661146211445*^7 + 157420.07418009013*
  Cos[1.0665587845114386 - 0.13847240346401293*x] + 
 (2.1093957681357905*^7 + 6.817254377756953*^6*
    Cos[2.6001789885745974 - 0.16155113737468174*x])*
  Cos[2.3320744633974773 - 0.005533443481300548*x + 
    0.8129172267000655*Cos[2.769057777981352 - 0.16155113737468174*x] + 
    0.0008618055381934119*x*Cos[2.775733748081489 + 0.20770860519601939*x]]


ParametricPlot[{Mod[x,2111.9],f0[x]},{x,1,Length[pdist]},AspectRatio->1]

superfour[Tranpose[sample[f0,1,2112.9,1024]][[2]],1]



(* partition into "best" period, 2112h *)

(* TODO: allow for fractional periods using resampling *)

a0 = Partition[pdist,2112];

Table[superfour[a0[[i]],1][x],{i,1,Length[a0]}]

(* this shows we made a good choice with 2112 *)
ListPlot[a0]

(* the mean of each cycle changes slightly *)
a2 = Map[Mean,a0]

(* we can compensate *)
f1[x_] = Mean[a2]+superfour[a2-Mean[a2],1][x/2112]

(* and the amplitude of each cycle changes slightly *)
a3 = (Map[Max,a0] - Map[Min,a0])/2

(* compensating *)
f2[x_] = Mean[a3]+superfour[a3-Mean[a3],1][x/2112]

Plot[f1[x],{x,1,Length[pdist]}]

Plot[{f1[x]-f2[x]},{x,1,Length[pdist]}]


(* now, we partition the residuals *)
a1 = Partition[superleft[pdist,1],2112];
ListPlot[a1]

(* the amplitude changes a lot! *)
Map[Mean,a1]-Mean[Map[Mean,a1]]





(* let's look at the coeffs themselves? *)

a0 = superfour[pdist,50]
a0 = superfour[px,1]

ListPlot[Take[Log[Abs[Fourier[pdist]]],100],PlotRange->All]

Sort[Table[a0[[2,n,1]],{n,2,51}]]

(* period of superleft[pdist,1] is 1055.94 samples/period or 66.4139
periods in sample, 2137ish for superleft[pdist,2] *)

a1 = Partition[superleft[px,2],2111]
a1 = Partition[superleft[px,2],704];
ListPlot[a1]
showit

Map[Mean,a1]

a2 = Partition[superleft[px,2], 2111];
ListPlot[a2]
showit

ListPlot[{Map[Max,a2],Map[Min,a2]}]

a4 = Map[Mean,a2]

a5 = Interpolation[a4]

a6 = Interpolation[superleft[px,2]]

Plot[{a6[x],a5[x/Length[px]*Length[a4]]}, {x,1,Length[px]}]
Plot[a6[x]-a5[x/Length[px]*Length[a4]], {x,1,Length[px]}]




Map[Mean,Abs[Partition[superleft[px,2],704]]]
Length[Mean[Partition[superleft[px,2],704]]]
Mean[Partition[superleft[px,2],704]]


a13 = Sqrt[Mean[Partition[superleft[pdist,1]^2,1056]]]
a13 = Sqrt[Mean[Partition[superleft[pdist,2]^2,2136]]]
a13 = Sqrt[Mean[Partition[superleft[pdist,2]^2,2137]]]
Fourier[a13]

f14 = Interpolation[a13]
f15 = Interpolation[superleft[pdist,1]]
f15 = Interpolation[superleft[pdist,2]]

Plot[f15[x]/f14[1056/70129*x],{x,1,Length[pdist]}]





a12 = Table[Cos[0.00010732*t]*Cos[0.00112922*t-1.625],{t,1,Length[pdist]}];

a0[t_] = superfour[superleft[pdist,1],1][t]
a1 = Table[a0[t],{t,1,Length[pdist]}];
ListPlot[{a1, superleft[pdist,1]}]

a2 = difference[superleft[pdist,1]];
a3 = difference[a2];
a4 = difference[a3];

a5 = Log[Abs[Take[a2,{2,Length[a2]-1}]/a4]];

a6[x_] = c1 + c2*Cos[c3*x-c4]

a7[x_] = c2*Cos[c3*x-c4] + c5*Cos[c6*x-c7]
a8[t_] = FourierTransform[a7[x],x,t]

p1 = a8[c3] /. {DiracDelta[0] -> 1, DiracDelta[_] -> 0}
p2 = a8[c6] /. {DiracDelta[0] -> 1, DiracDelta[_] -> 0}

f[x] /. DSolve[f''[x] == -c*f[x], f[x], x][[1]]

Plot[3*Cos[2*x] + 5*Cos[3*x],{x,0,2*Pi}]

a10[x_] = d1*Cos[d2*x+d3]*Cos[d4*x+d5];
a9[t_] = FourierTransform[a10[x],x,t];

q1 = a9[d2+d4] /. {DiracDelta[0] -> 1, DiracDelta[_] -> 0}
q2 = a9[d2-d4] /. {DiracDelta[0] -> 1, DiracDelta[_] -> 0}

q1 /. Solve[{d2+d4==c3, d2-d4==c6},{d2,d4}][[1]]

a10[x] /. 
 Solve[{p1==q1, p2==q2, d2+d4==c3, d2-d4==c6, d3==0}, {d1,d2,d3,d4,d5}][[1]]





temp = superleft[pdist,1]*Reverse[superleft[pdist,1]];

(* find the peak of the continous Fourier transform between 0 and 1 by
setting psuedo-derivative equal to 0 after subtracting off the biggest
Fourier term *)

order = 8;
var := pdist;
f[x_] := Abs[cft[superleft[var,order],x]];
g[x_] := fakederv[f,x,.001];
ListPlot[Table[g[x],{x,.1,.9,.05}]]
xroot = findroot2[g,0.01,0.99,.01]
yroot = cft[superleft[var,order],xroot]

mult = Abs[yroot]/Sqrt[Length[var]]*2
arg = Arg[yroot]
freq = 2*Pi*xroot/Length[var]

h[x_] = mult*Cos[freq*x-arg]

Plot[h[x],{x,1,Length[pdist]}]

residuals = superleft[pdist,4]-Table[h[x],{x,1,Length[pdist]}];



Abs[yroot]*Cos[2*Pi*x*xroot/Length[pdist]-Arg[yroot]],{x,1,Length[pdist]}]

temp = Fourier[Table[3*Cos[2*x-Pi/7],{x,0,2*Pi,.001}]]

(* Abs[temp[[3]]]/Sqrt[Length[temp]]*2==3, Arg[temp[[3]]]==Pi/7 *)

temp1 = superleft[pdist,1];
tempf[x_] := Abs[cft[temp1,x]]
tempg[x_] := fakederv[tempf, x, .01]

Plot[tempg[x],{x,.2,.3}]

FindRoot[tempg[x],{x,.2,.3}]
FindRoot[tempg[x],{x,.2,.3},StepMonitor->Print[x]]


Table[{x,tempg[x]},{x,.2,.3,.01}]
Table[{x,tempg[x]},{x,.26,.27,.001}]
Table[{x,tempg[x]},{x,.265,.266,.0001}]
Table[{x,tempg[x]},{x,.2654,.2655,.00001}]
Table[{x,tempg[x]},{x,.26542,.26543,.000001}]
Table[{x,tempg[x]},{x,.265421,.265422,.0000001}]




FindRoot[tempg[x],{x,.2,.3}]


fakederv[x_] := (Abs[cft[superleft[pdist,1],x+.05]] -
Abs[cft[superleft[pdist,1],x-.05]])*10

tempa = DiscreteWaveletTransform[pdist];
tempb = tempa[All,"Values"];

tempa = ContinuousWaveletTransform[pdist];
WaveletScalogram[tempa]

tempb = ContinuousWaveletTransform[superleft[pdist,1]];
WaveletScalogram[tempb]

NMaximize[Abs[cft[superleft[pdist, 1], x]], {x, 0.1, 0.3}]

Integrate[f[x]*Exp[2*Pi*I*x*f],x]

tempc[w_] := N[FourierTransform[pid[t],t,w]]

temp = Table[{x,Abs[cft[px,x]]},{x,0,0.1,.01}]
temp = Table[{x,Abs[cft[px,x]]},{x,0,50}]
temp = Table[{x,Abs[cft[px,x]]},{x,0,2,.1}]

temp = Table[{x,Abs[cft[superleft[px,3],x]]},{x,0,0.2,.01}]

ListPlot[ArcCos[px/Max[Abs[px]]]]


pxderv = Table[px[[i]]-px[[i-1]], {i,2,Length[px]}];
pxdervd = Table[pxderv[[i]]-pxderv[[i-1]], {i,2,Length[pxderv]}];


pfdist[t_] = superfour[pdist,2][t]
pid[t_] = Interpolation[pdist][t]

pix[t_] = Interpolation[px][t]
piy[t_] = Interpolation[py][t]
piz[t_] = Interpolation[pz][t]

pfx[t_] = superfour[px,2][t]
diffies = Table[pfx[t]-px[[t]],{t,1,Length[px]}];
ListPlot[Take[diffies,365*24*5]]
diffi[t_] = Interpolation[diffies][t]
Plot[diffi[t],{t,1,88*24}]

Plot[diffi'[t]/diffi'''[t], {t,0,Length[px]}, PlotRange->All]

pidx[t_] = D[pix[t],t]
piddx[t_] = D[pix[t],t,t]

Plot[pix[t]/piddx[t],{t,0,Length[px]}]


pfx[t_] = superfour[px,4][t]
pfy[t_] = superfour[py,4][t]
pfz[t_] = superfour[pz,4][t]
pfdist[t_] = superfour[pdist, 4][t]
pfang[t_] = superfour[pang,4][t]


dist[t_] = Sqrt[pfx[t]^2 + pfy[t]^2 + pfz[t]^2]

Plot[dist[t], {t,0,Length[px]}]

ParametricPlot[{pfx[t],pfy[t]},{t,0,88*24}]

diffs = Table[px[[i]]-pfx[i],{i,1,Length[px]}];
divs = Table[px[[i]]/pfx[i],{i,1,Length[px]}];

(* largest periods from above:

87.964d = orbit of mercury (5.6469*10^7)
43.983d = half orbit of mercury [ellipse?] (5.71583*10^6)
29.2204d = third orbit of mercury [ellipse?] (708012)
2922d = 8y (almost exact) = ??? (516427)

*)

x[t_] = Sum[Cos[n*t+1/n]*4^-n,{n,1,Infinity}]
y[t_] = Sum[Sin[n*t+1/n]*4^-n,{n,1,Infinity}]

ParametricPlot[{x[t],y[t]}, {t,0,2*Pi}]

ParametricPlot[{2*Cos[x], Sin[x]},{x,0,2*Pi}]

(* pfx = Fourier[px]; *)

ListPlot[Log[Abs[Take[pfx,100]]], PlotRange->All]

(* 34 is max *)

(* and has abs 6.89718*10^9 and arg -3.0011 *)

superfour[px,4]


pxi = Interpolation[px, InterpolationOrder -> 3]

(* pfi = FourierTransform[pxi[t],t,w] *)

pfi[w_] := NIntegrate[Exp[I*w*t]*pxi[t], {t,1,Length[px]}]

N[Abs[pfi[30]]]

Table[N[Abs[pfi[t]]],{t,30}]

Plot[N[Abs[pfi[t]]],{t,30,40}]

ListPlot[Take[Abs[pfx],200], PlotRange->All]

pxsample = px[[1;;Length[px];;1400]]

pxi = Interpolation[pxsample, InterpolationOrder -> 3]

Plot[pxi[x], {x,1,Length[px]/1400}]

pxi1 = Table[pxi[(x-1)/100 + 1], {x,1,Length[px]}]

d1 = Table[pxi[(x-1)/1400 + 1] - px[[x]], {x,1,Length[px]}]

diffs = Table[px[[i]] - px[[i-1]], {i,2,Length[px]}]


nlm = NonlinearModelFit[px, a*Cos[b+c*x], { {a,5.6469*10^7}, {b,2.31149},
 {c, 0.00297621}}, x]

nlm["FitResiduals"]/Max[Abs[px]]

superfourier[nlm["FitResiduals"]]

nlm2 = NonlinearModelFit[px, a*Cos[b+c*x], { {a,7.61125*10^6}, {b,2.31149},
 {c, 0.00297621}}, x]

ListPlot[superleft[px,1]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,3]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,5]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,7]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,9]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,13]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,20]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,25]/Max[Abs[px]], PlotRange->All]
ListPlot[superleft[px,30]/Max[Abs[px]], PlotRange->All]

t7 = Table[Max[Abs[superleft[px,i]]]/Max[Abs[px]], {i,1,16}]

ListPlot[t7, PlotJoined->True, PlotRange->All, AxesOrigin->{0,0}]

t8 = Table[superfour[px,1][i], {i,1,10000}]

Chop[TrigFactor[superfour[px,30][x]]]
Chop[TrigFactor[superfour[px,1][x]]]
Chop[TrigFactor[superfour[px,2][x]]]
Chop[TrigFactor[superfour[px,3][x]]]
Chop[TrigFactor[superfour[px,4][x]]]
Chop[TrigFactor[superfour[px,5][x]]]
Chop[TrigFactor[superfour[px,6][x]]]
Chop[TrigFactor[superfour[px,7][x]]]
Chop[TrigFactor[superfour[px,8][x]]]
Chop[TrigFactor[superfour[px,15][x]]]
Chop[TrigFactor[superfour[px,20][x]]]
Chop[TrigFactor[superfour[px,30][x]]]
Chop[TrigFactor[superfour[px,50][x]]]
Chop[TrigFactor[superfour[px,70][x]]]

Chop[TrigFactor[superfour[py,10][x]]]
Chop[TrigFactor[superfour[pz,10][x]]]

Chop[TrigFactor[superfour[py,100][x]]]
Chop[TrigFactor[superfour[pz,100][x]]]

Log[Abs[superleft[px,1]/Max[Abs[px]]]]
Log[Abs[superleft[px,70]/Max[Abs[px]]]]

ListPlot[{t8, px}, PlotStyle -> {PointSize[0.0001]}]

superfour[px,1]

pfx = refine[px, 0 &]
pfy = refine[px, 0 &]
pfz = refine[px, 0 &]

pfx = superfourier[px]
pfx2 = refine[px, pfx]
pfx3 = refine[px, pfx2]
pfx4 = refine[px, pfx3]
pfx5 = refine[px, pfx4]
pfx6 = refine[px, pfx5]
pfx7 = refine[px, pfx6]
pfx8 = refine[px, pfx7]
pfx9 = refine[px, pfx8]
cfx = Table[px[[i]] - pfx9[i], {i, 1, Length[px]}];
cfx = Table[px[[i]] - pfx2[i], {i, 1, Length[px]}];

cfx = Table[px[[i]] - pfx3[i], {i, 1, Length[px]}];

ListPlot[Take[px,88*24]]


t1 = Table[x[[2]], {x,planet199}];
t2 = Take[t1,30000];
t3 = Take[t1,{14000,16000}];
t3 = Take[t1,{14000,16000}];
t3 = Take[t1,{14900,15100}];
t3 = Take[t1,{14970,14990}];

(* jump from 2.45562*10^6 to 2.45593*10^6 at pos 14977-14978, why? *)

t4 = Select[planet199, #[[1]] == 2011 &];

In[45]:= Length[t4]

Out[45]= 14977

(* at 6m ints, expect 87600/yr *)

(* the Unix epoch; we'll be feeding results to Perl ultimately *)

epoch = AbsoluteTime[{1970,1,1}]

(* hardcoding "today" so others can verify my results, if desire *)

today = {2011,4,15}
mathtoday = AbsoluteTime[today]

(* the nearest vernal equinox + the one 25 years hence, declination-based *)

(* below: 20 Mar 2011 at 23:21:33.7893; agrees w wikipedia *)

ved0 = x /. FindRoot[
 AstronomicalData["Sun", {"Declination", ToDate[x]}] == 0, {x,mathtoday}]

ved25 = x /. FindRoot[AstronomicalData["Sun", {"Declination", ToDate[x]}] == 0,
  {x,mathtoday+365.2425*86400*25}]

(* average year length, according to declination *)

decyear = (ved25-ved0)/25

(* find Fourier coefficients numerically, and store *)

(* for easier calc [less CPU], use ved0 as x=0 *)

decfour[n_] := decfour[n] = NIntegrate[
 AstronomicalData["Sun", {"Declination", ToDate[ved0+x]}]*
 Exp[2*Pi*I*x*n/decyear],
 {x,0,ved25-ved0}]

(* <h> decten[data_] = bartender </h> *)

(* <h> Time passes...</h> *)

(* by storing results here, I avoid having to recalc them *)

decfour[0] = 2.982794797849734*^8
decfour[1] = -2.9677988934045434*^8 + 9.170689132027664*^9*I
decfour[2] = 1.432586534498814*^8 + 4.548038984377269*^7*I
decfour[3] = 7.830599335722238*^6 - 6.707145902500911*^7*I
decfour[4] = -2.97798216111644*^6 - 1.2071250071517676*^6*I

(* determine phase and amplitude *)

Table[{n, Abs[2*decfour[n]/(ved25-ved0)], 
          Arg[2*decfour[n]/(ved25-ved0)]}, 
{n,1,4}]

(* and now lets turn it into an equation (could've done this in one
step, but clearer this way); also add in constant term *)

decguess[x_] = Sum[Abs[2*decfour[n]/(ved25-ved0)]*Cos[2*Pi*n*x/decyear -
        Arg[2*decfour[n]/(ved25-ved0)]],
{n,1,4}] + decfour[0]/(ved25-ved0)

(* compare to real declination; commenting out in final form *)

(*

decdiff = Plot[decguess[x] - 
 AstronomicalData["Sun", {"Declination", ToDate[ved0+x]}], 
 {x, 0, ved25-ved0}]

*)

(* shows accurate to .007 degrees *)

(* now, same thing for RA, but take care of linear/sawtooth component first;
   Fourier will handle sawtooth, but only w/ infinite number of terms *)

vera0 = x /. FindRoot[
 AstronomicalData["Sun", {"RightAscension", ToDate[x]}] == 0, {x,mathtoday}]

vera25 = x /. FindRoot[AstronomicalData["Sun", {"RightAscension", 
 ToDate[x]}] == 0,
  {x,mathtoday+365.2425*86400*25}]

rayear = (vera25-vera0)/25

(* getting rid of pesky linear term; yielding (almost) equation of time
   <h>equations for love and tenderness appear elsewhere</h> *)

racorrected[x_]:= AstronomicalData["Sun",{"RightAscension", ToDate[x+vera0]}] -
 24*Mod[x/rayear,1]

(* when RA~0 this can yield spurious 24s, which we fix here *)

racorrected2[x_] = Mod[racorrected[x]-12,24]-12

(* and now, take it away, Mr Fourier *)

rafour[n_] := rafour[n] = NIntegrate[racorrected2[x]*Exp[2*Pi*I*x*n/rayear],
 {x,0,vera25-vera0}]

(* storing these results here prevents recalculation *)

rafour[0] = -9.753108862236838*^7
rafour[1] = 4.643901170298403*^7 + 1.3624915962714499*^7*I
rafour[2] = 4.454072138584064*^6 - 6.5070804901101105*^7*I
rafour[3] = -1.9589302261188729*^6 - 719022.6267241215*I
rafour[4] = -211981.0193558234 + 1.4253123615474603*^6*I

(* and now lets turn it into an equation *)

(* this actually guesses racorrected2[], not ra *)

raguess[x_] = Sum[Abs[2*rafour[n]/(vera25-vera0)]*Cos[2*Pi*n*x/rayear -
        Arg[2*rafour[n]/(vera25-vera0)]],
{n,1,4}] + rafour[0]/(vera25-vera0)

(* commenting out plotting, as we don't need it in final form *)

(* radiff = Plot[racorrected2[x] - raguess[x],{x,0,(vera25-vera0)}] *)

(* accurate to .0015 hour which is .0225 degrees *)

(* the raw formulas; ie, the ultimate result of this file *)

ved0 = 3.509652093789344*10^9

(* ved0 - epoch = 1.3006632937893438*10^9 *)

decguess[x_] = 0.37808401703940736 + 0.3810373468678206*
     Cos[0.3074066821871051 - 3.9821243192021897*^-7*x] + 
    23.260776335116*Cos[1.6031468236573432 - 1.9910621596010949*^-7*x] + 
    0.17118769496986821*Cos[1.4545723908701285 + 5.973186478803284*^-7*x] + 
    0.008146125242501636*Cos[2.756482750676952 + 7.964248638404379*^-7*x]

(* <h>pretend you don't notice ved0 and vera0 differ by ~39s</h> *)

vera0 = 3.5096520548642015*10^9

(* vera0 - epoch = 1.3006632548642015*10^9 *)

raguess[x_] = -0.12362547330377642 + 0.003653051241507621*
     Cos[1.7184400853442734 - 7.964247794495168*^-7*x] + 
    0.1226898815038194*Cos[0.2853850527151302 - 1.991061948623792*^-7*x] + 
    0.16534691830933743*Cos[1.502453306625312 + 3.982123897247584*^-7*x] + 
    0.005290041878837918*Cos[2.7898112178483023 + 5.973185845871376*^-7*x]

(* now, write in Perl format *)

(* TODO: not working; tailing backslashes really kill Perl *)

raperl = ToLowerCase[
 StringReplace[ToString[raguess[x], CForm], {{"x" -> "$x"}, {"\\" -> ""}}]]
decperl=ToLowerCase[StringReplace[ToString[decguess[x], CForm], {"x" -> "$x"}]]

{raperl, decperl} >> /tmp/perldecra.txt

(* and now... the Moon *)

(* better approach: compute and approximate xyz coords of moon (from Earth) *)

(* caching below for speed *)

moonpos[x_] := Module[{ra,dec,dist},
 ra = AstronomicalData["Moon", {"RightAscension", DateList[x]}]/12*Pi;
 dec = AstronomicalData["Moon", {"Declination", DateList[x]}]*Degree;
 dist = AstronomicalData["Moon", {"Distance", DateList[x]}];
 moonpos[x] = {dist*Cos[ra]*Cos[dec], dist*Sin[ra]*Cos[dec], dist*Sin[dec]}
]

(* lunar estimates over 1 year don't work well, so do by year *)

moonprox[year_, pos_] := FunctionInterpolation[moonpos[x][[pos]], 
 {x, AbsoluteTime[{year,1,1}], AbsoluteTime[{year+1,1,1}]}];

(* and now, calculate a big batch of them *)

t = Table[{year,pos,moonprox[year,pos]}, {year,2011,2021}, {pos,1,3}]

(* table above was saved to file *)

(* ra and dec based on approximations, just to test how close we are *)

(* in reality, Perl will compute based on xyz values *)

radecest[time_] := Module[{pos, x, y, z, ra, dec},
 (* which entry in table *)
 pos = ToDate[time][[1]]-2011+1;
 (* values of xyz at time time *)
 x = t[[pos,1,3]][time];
 y = t[[pos,2,3]][time];
 z = t[[pos,3,3]][time];
 ra = Mod[(ArcTan[x,y]+2*Pi),2*Pi]/Pi*12;
 dec =  ArcSin[z/Norm[{x,y,z}]]/Degree;
 {ra,dec}
]

(* accuracy testing *)

radiffplot[year_] := radiffplot[year] =
Plot[radecest[x][[1]] - 
 AstronomicalData["Moon", {"RightAscension", DateList[x]}],
{x, AbsoluteTime[{year,1,1}], AbsoluteTime[{year+1,1,1}]}]

radifftabplot = Table[radiffplot[year], {year,2011,2021}];

(* the Hermite <h>(not Hermione)</h> polynomials *)

h00[t_] = (1+2*t)*(1-t)^2
h10[t_] = t*(1-t)^2
h01[t_] = t^2*(3-2*t)
h11[t_] = t^2*(t-1)

(*

This confirms my understanding of InterpolatingFunction by calculating
the value in a different, Perl-friendly, way; this probably does NOT
work for all InterpolatingFunction's, just the ones I'm using here.

f = interpolating function, t = value to evaluate at

*)

altintfuncalc[f_, t_] := Module[
 {xvals, yvals, xint, tisin, tpos, m0, m1, p0, p1},

 (* figure out x values *)
 xvals = Flatten[f[[3]]];

 (* and corresponding y values *)
 yvals = Flatten[f[[4,3]]];

 (* and size of each x interval; there are many other ways to do this *)
 (* <h>almost all of which are better than this?</h> *)
 xint = (xvals[[-1]]-xvals[[1]])/(Length[xvals]-1);

 (* for efficiency, all vars above this point should be cached *)

 (* which interval is t in?; interval i = x[[i]],x[[i+1]] *)
 tisin = Min[Max[Ceiling[(t-xvals[[1]])/xint],1],Length[xvals]-1];

 (* and the y values for this interval, using Hermite convention *)
 p0 = yvals[[tisin]];
 p1 = yvals[[tisin+1]];

 (* what is t's position in this interval? *)
 tpos = (t-xvals[[tisin]])/xint;

 (* what are the slopes for the intervals immediately before/after this one? *)
 (* we are assuming interval length of 1, so we do NOT divide by int *)
 m0 = p0-yvals[[tisin-1]];
 m1 = yvals[[tisin+2]]-p1;

 (* return the Hermite approximation *)
 (* <h>Whoever wrote the wp article was thinking of w00t</h> *)
 h00[tpos]*p0 + h10[tpos]*m0 + h01[tpos]*p1 + h11[tpos]*m1
]

(* test cases *)

f1 = FunctionInterpolation[Sin[x],{x,0,2*Pi}]
f2 = FunctionInterpolation[x^2,{x,0,10}]
f3 = FunctionInterpolation[Exp[x],{x,0,10}]

Plot[{altintfuncalc[f1,t] - f1[t]},{t,0,2*Pi}]
Plot[{altintfuncalc[f2,t] - f2[t]},{t,0,10}]
Plot[{altintfuncalc[f3,t] - f3[t]},{t,0,10}]

(* TODO: more accuracy testing *)

(* TODO: at some point, document my failed attempts as well (why?) *)

(* lets get sun by approx by year too *)

(* again, caching for speed *)

sunpos[x_] := Module[{ra,dec,dist},
 ra = AstronomicalData["Sun", {"RightAscension", DateList[x]}]/12*Pi;
 dec = AstronomicalData["Sun", {"Declination", DateList[x]}]*Degree;
 dist = AstronomicalData["Sun", {"Distance", DateList[x]}];
 sunpos[x] = {dist*Cos[ra]*Cos[dec], dist*Sin[ra]*Cos[dec], dist*Sin[dec]}
]

intsunval[year_, pos_] := intsunval[year,pos] =
 intsunval[pos] = FunctionInterpolation[sunpos[x][[pos]], 
 {x, AbsoluteTime[{year,1,1}], AbsoluteTime[{year+1,1,1}]}]

t= Table[{year,pos, intsunval[year,pos]}, {year,2011,2021}, {pos,1,3}]

intmoonval[year_, pos_] := intmoonval[year,pos] =
 intmoonval[pos] = FunctionInterpolation[moonpos[x][[pos]], 
 {x, AbsoluteTime[{year,1,1}], AbsoluteTime[{year+1,1,1}]}]

(* this takes a while to run, so save return values *)

t2= Table[{year,pos, intmoonval[year,pos]} >>> data/moonxyz.txt, 
          {year,2011,2021}, {pos,1,3}]

t2= Table[{year,pos, intmoonval[year,pos]} >>> data/moonxyz.txt, 
          {year,2015,2021}, {pos,1,3}]

(* calculates domain of interpolating function *)

Flatten[intsunval[2012,2][[1]]][[1]]

diffsunval[year_, pos_] := diffsunval[year,pos] = 
Plot[sunpos[x][[pos]] - intsunval[year, pos][x],
 {x, Flatten[intsunval[year,pos][[1]]][[1]], 
 Flatten[intsunval[year,pos][[1]]][[2]]},
 PlotRange -> All]

diffsunval[2011,1]

Table[intsunval[y,p],{y,2011,2021},{p,1,3}]

(* convert interp function for Perl *)

perlify[f] := Module[{}]

(* <h>Tip: AbsoluteTime[{2011}] and AbsoluteTime[{2011,1,1}] mean the
same thing, but the first form is preferable as it annoys more
people</h> *)

Plot[{intsunval[2011, 1][x] - sunpos[x][[1]]},
 {x, AbsoluteTime[{2011}], AbsoluteTime[{2012}]},
 PlotRange -> All, PlotLabel -> "2011 Sun 'x' Position diff"]

diffsunval[year_, pos_] := diffsunval[year,pos] = 
Plot[sunpos[x][[pos]] - intsunval[year, pos][x],
 {x, AbsoluteTime[{year}], AbsoluteTime[{year+1}]},
 PlotRange -> All, PlotLabel -> 
 "Sun Deltas, Year: "<>ToString[year]<>", Axis: "<>ToString[pos]]

diffsunval[2011,1]

plots = Table[diffsunval[y,p],{y,2011,2021},{p,1,3}]

diffmoonval[year_, pos_] := diffmoonval[year,pos] = 
Plot[moonpos[x][[pos]] - intmoonval[year, pos][x],
 {x, AbsoluteTime[{year}], AbsoluteTime[{year+1}]},
 PlotLabel -> 
 "Moon Deltas, Year: "<>ToString[year]<>", Axis: "<>ToString[pos]]

diffmoonval[2011,1]

moonplots = Table[diffmoonval[y,p],{y,2011,2014},{p,1,3}]

moonplots >> data/moonplots.txt

moonplots = Flatten[moonplots,1]

Table[{
 Export["data/moonplots-"<>ToString[n]<>".png", moonplots[[n]], 
        ImageSize->{800,600}]
}, {n, 1, Length[moonplots]}]

Table[{
 Export["data/sunplots-"<>ToString[n]<>".png", t[[n]], 
        ImageSize->{800,600}]
}, {n, 1, Length[t]}]


(* TODO: would linear interpolation have worked just as well? *)

(* steps required for restore if mathematica session ends *)

t = <<data/sunxyz.txt

t = Flatten[t,1]

Table[intsunval[x[[1]], x[[2]]] = x[[3]], {x, t}]

(* slightly different for moon, stored differently *)

t = ReadList["data/moonxyz.txt"]

Table[intmoonval[x[[1]], x[[2]]] = x[[3]], {x, t}]

(* below is a more minimal way to store this data, more useful to Perl *)

Table[{i[[1]], i[[2]], Flatten[i[[3,3]]], Flatten[i[[3,4,3]]]}, {i,t}]

(* As of 18 May 2011, everything above this line is pretty much unused
(though not useless; may have use to somebody, so leaving it here,
not just in CVS repo) *)

moondata = ReadList["/home/barrycarter/BCGIT/tmp/moon.csv", {Real,Real,Real}];
sundata = ReadList["/home/barrycarter/BCGIT/tmp/sun.csv", {Real,Real,Real}];

(* convert into bizarro xy coords... theta is x, r is y+90 degrees *)
(* no need to convert declination to degrees, but what the heck; note
that r is always between "90 degrees" and "270 degrees" *)
(* converting to Unix time while we're at it *)

xt1 = Table[
 {(i[[1]]-2440587.5)*86400, 
 (Pi+i[[3]]*Degree)*Cos[i[[2]]*Degree]}, 
{i,sundata}];

yt1 = Table[
 {(i[[1]]-2440587.5)*86400,
 (Pi+i[[3]]*Degree)*Sin[i[[2]]*Degree]},
{i,sundata}];

datareduce[data_, n_] := Module[{halfdata, inthalfdata, tabhalfdata, origdata},
 halfdata = Take[data, {1,Length[data],2^n}];
 inthalfdata = Interpolation[halfdata, InterpolationOrder -> 1];
 tabhalfdata = Table[inthalfdata[data[[i,1]]], {i, 1, Length[data]}];
 Return[tabhalfdata];
]

(* original ra/dec (doesn't change) *)
origra = Table[i[[2]], {i,sundata}];
origdec = Table[i[[3]], {i,sundata}];

(* TEST CASE: 1305936000 or 33601 position *)

(* number notes below:

Select[xt1, #[[1]] == 1305936000 &]
Select[yt1, #[[1]] == 1305936000 &]
Select[sundata, #[[1]] == 1305936000/86400+2440587.5 &]


1.305936`*^9, 1.8879330495375595 = x
1.305936`*^9, 2.936784526484251 = y
2.4557025`*^6, 57.2647718`, 20.0352687 = true

(Pi+20.0352687*Degree)*Sin[57.2647718*Degree]
(Pi+20.0352687*Degree)*Cos[57.2647718*Degree]


*)

(* reduce and compare *)
xred = datareduce[xt1, 7];
yred = datareduce[yt1, 7];

(* reconstruct ra and dec *)
rared=Table[Mod[ArcTan[xred[[i]],yred[[i]]]/Degree,360],
 {i,1,Length[sundata]}];
decred=Table[Norm[{xred[[i]],yred[[i]]}]/Degree-180, {i, 1, Length[sundata]}];

Max[180-Abs[rared-origra]]-180
Max[Abs[decred-origdec]]

(* store every 2048th value of sun moon xy we created above *)

Take[xt1,{1,Length[xt1],2048}] >> /home/barrycarter/BCGIT/data/sunfakex.txt
Take[yt1,{1,Length[xt1],2048}] >> /home/barrycarter/BCGIT/data/sunfakey.txt


