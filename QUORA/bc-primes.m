(*

**Assuming the Riemann Hypothesis, the [math]10^{48}[/math]th prime is between 114,253,594,378,425,466,185,102,853,920,130,817,319,525,886,680,889 and 114,253,594,378,425,466,185,114,154,511,712,329,201,522,001,657,619, and most likely towards the middle of this range.**

If we assume the Riemann Hypothesis and https://en.wikipedia.org/wiki/Prime_number_theorem#Prime-counting_function_in_terms_of_the_logarithmic_integral we have:

[math]\left| \pi (x)-\text{li}(x) \right|<\frac{\sqrt{x} \log (x)}{8 \pi }[/math]
or
[math]\text{li}(x)-\frac{\sqrt{x} \log (x)}{8 \pi }<\pi(x)<\text{li}(x)+\frac{\sqrt{x} \log (x)}{8 \pi }[/math]
given that [math]x\geq 2567[/math] and thus [math]\pi (x)\geq 375[/math].

Using Mathematica, we find 114253594378425466185102853920130817319525886680866 (114,253,594,378,425,466,185,102,853,920,130,817,319,525,886,680,866) is the largest integer n satisfying [math]\text{li}(n)+\frac{\sqrt{n} \log (n)}{8 \pi }<10^{48}[/math] and thus necessarily [math]\pi (n)<10^{48}[/math].

That means our smallest candidate for the [math]10^{48}[/math]th prime is the next prime after that number, which turns out to be 114253594378425466185102853920130817319525886680889 (114,253,594,378,425,466,185,102,853,920,130,817,319,525,886,680,889).

Similarly, 114253594378425466185114154511712329201522001657687 (114,253,594,378,425,466,185,114,154,511,712,329,201,522,001,657,687) is the smallest integer n satisfying [math]\text{li}(n)-\frac{\sqrt{n} \log (n)}{8 \pi }>10^{48}[/math] and thus necessarily [math]\pi (n)>10^{48}[/math].

So our largest candidate for the [math]10^{48}[/math]th prime is the prime number prior to this number, which turns out to be 114253594378425466185114154511712329201522001657619 (114,253,594,378,425,466,185,114,154,511,712,329,201,522,001,657,619).

The integer closest to solving [math]\text{li}(n) = 10^{48}[/math] is 114253594378425466185108504215921573260523944025925 (114,253,594,378,425,466,185,108,504,215,921,573,260,523,944,025,925), but this turns out to be a surprisingly poor estimate of the [math]10^{48}[/math]th prime, per the wikipedia page earlier and per https://en.wikipedia.org/wiki/Skewes%27_number

Just for fun, I ran this process on other powers of 10, but excluding powers less than 3 since, as above, we need [math]\pi (x)\geq 375[/math] for these bounds to work.

Below are the results from [math]10^{3}[/math] to [math]10^{24}[/math] as compared to the actual values from https://oeis.org/A006988 as extended by https://oeis.org/A006988/b006988.txt

[[image18.gif]]

The 'whence' column shows where in the lower bound/upper bound interval the actual value occurs. Note that this number sort of appears to approach 0.5 with crossing it, but Skewes (ibid) shows that the 'whence' can be lower than 0.5, albeit probably not for [math]n \leq 200[/math]

For [math]10^{25}[/math] to [math]10^{100}[/math], we don't have actual values, so can only show the bounds:

[[image19.gif]]

All of the values (without commas, and going to [math]10^{200}[/math]) are also available at https://github.com/barrycarter/bcapps/blob/master/QUORA/ under bc-nth-prime.csv; the Mathematica code is in the same directory under bc-primes.m

*)

TODO: preview channel this

(* determine prime bounds using Schoenfield/Riemann *)

range[x_] = Log[x]*Sqrt[x]/8/Pi

bounds[x_] := bounds[x] = Module[{lb,ub},
 lb = NextPrime[t /. FindRoot[LogIntegral[t]+range[t] == x, {t,x*Log[x]},
  WorkingPrecision -> Log[x], AccuracyGoal -> Log[x],
  PrecisionGoal -> Log[x]],1];
 ub = NextPrime[t /. FindRoot[LogIntegral[t]-range[t] == x, {t,x*Log[x]},
  WorkingPrecision -> Log[x], AccuracyGoal -> Log[x],
  PrecisionGoal -> Log[x]],-1];
 Return[{lb,ub}]
];

tab1039 = Table[{x,bounds[10^x]},{x,3,200}]

actval[3] = 7919
actval[4] = 104729
actval[5] = 1299709
actval[6] = 15485863
actval[7] = 179424673
actval[8] = 2038074743
actval[9] = 22801763489
actval[10] = 252097800623
actval[11] = 2760727302517
actval[12] = 29996224275833
actval[13] = 323780508946331
actval[14] = 3475385758524527
actval[15] = 37124508045065437
actval[16] = 394906913903735329
actval[17] = 4185296581467695669
actval[18] = 44211790234832169331
actval[19] = 465675465116607065549
actval[20] = 4892055594575155744537
actval[21] = 51271091498016403471853
actval[22] = 536193870744162118627429
actval[23] = 5596564467986980643073683
actval[24] = 58310039994836584070534263

Table[actval[i]="", {i,25,200}]

tab1901 = Table[{i, bounds[10^i][[1]], bounds[10^i][[2]], actval[i]},
 {i,3,200}];

tab1803 = Table[{HoldForm[10]^i, 
 NumberForm[bounds[10^i][[1]], DigitBlock -> 3],
 NumberForm[bounds[10^i][[2]], DigitBlock -> 3]
 }, {i,25,100}]

tab1804 = Prepend[tab1803, 
 {"n", "<= \[Pi](n)", ">= \[Pi](n)"}]

grid2 = Grid[tab1804, Frame -> All, ItemStyle -> "Text", 
 Background -> {{LightGray, None}, {LightGray,None}}]
showit


tab1106 = Table[{HoldForm[10]^i, 
 NumberForm[bounds[10^i][[1]], DigitBlock -> 3],
 NumberForm[actval[i], DigitBlock -> 3],
 NumberForm[bounds[10^i][[2]], DigitBlock -> 3],
 N[(actval[i]-bounds[10^i][[1]])/(bounds[10^i][[2]]-bounds[10^i][[1]])]
 }, {i,3,24}]

tab1107 = Prepend[tab1106, 
 {"n", "\[Pi](x) lower bound", "\[Pi](x)", "\[Pi](x) upper bound", "Whence"}]

tab1107 = Prepend[tab1106, 
 {"n", "<= \[Pi](n)", "\[Pi](n)", ">= \[Pi](n)", "Whence"}]

grid = Grid[tab1107, Frame -> All, ItemStyle -> "Text", 
 Background -> {{LightGray, None}, {LightGray,None}}]
showit

grid = Grid[tab1107, Frame -> All]

grid = Grid[tab1107, Frame -> All]

PrimePi[x]

\[Sigma]
\[Sigma][x]
"\[Sigma](x)"


The, integer [note the middle int + why its not great]



LogIntegral[x]-range[x] < PrimePi[x] < LogIntegral[x]+range[x]

LogIntegral[x]+range[x] < HoldForm[10^48]

LogIntegral[x]-range[x] > HoldForm[10^48]


LogIntegral[n2]+range[n2] 


x-y < z

or x< z+y

y-x<z or -x < z-y or x > y-z

y-z < x < y+z


ili[x_] := t /. FindRoot[LogIntegral[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]

range[x_] = Log[x]*Sqrt[x]/8/Pi

ili2[x_] := Ceiling[t /. FindRoot[LogIntegral[t]+range[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]]

n2 = 114253594378425466185102853920130817319525886680867-1

LogIntegral[n2]+range[n2] > 10^48 and none smaller

ili3[x_] := Floor[t /. FindRoot[LogIntegral[t]-range[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]]

n3 = 114253594378425466185114154511712329201522001657687

Floor[LogIntegral[n3]-range[n3]]

LogIntegral[n3]-range[n3] < 10^48 and is largest such

https://oeis.org/A006988
https://oeis.org/A006988/b006988.txt


Using Mathematica, we find that 114253594378425466185108504215921573260523944025925 (114,253,594,378,425,466,185,108,504,215,921,573,260,523,944,025,925) is the integer n such that li(n) is closest to [math]10^{48}[/math].

n2 = 114253594378425466185102853920130817319525886680866

n2 = 114253594378425466185108553237030328694398437471430

N[LogIntegral[n2]-range[n2],53]


[math]

|x-y| < z



AccountingForm[N[LogIntegral[n-1],53], DigitBlock -> 3]               


with the following property:

[math]10^{48}-1 < \text{li}(n) < 10^{48} < \text{li}(n+1)[/math]

Computing [math]\frac{\sqrt{n} \log (n)}{8 \pi }[/math] to the nearest integer yields 49021108755433879077126144 (49,021,108,755,433,879,077,126,144). If we call this m, we have:

[math]\left| \pi (n)-\text{li}(n) \right|< m[/math]








Round[N[range[n]],1]






N[LogIntegral[n],53] // AccountingForm



NumberForm[n, DigitBlock -> 3]                                         

n = Rationalize[ili[10^48],1]+1

N[LogIntegral[n],53] // AccountingForm

Abs[PrimePi[x] - LogIntegral[x]] < range[x]                            

http://www.jstor.org/stable/2005976?origin=crossref&seq=1#page_scan_tab_contents 



(* inverse logintegral function of sorts *)






FindRoot[LogIntegral[t] == 10^48, {t,10^48*Log[10^48]},  
 WorkingPrecision -> 50, AccuracyGoal -> 50, PrecisionGoal -> 50]

 





Plot[LogIntegral[x],{x,0,1000}]


https://www.quora.com/What-is-the-10-48th-prime-number

https://en.wikipedia.org/wiki/Prime-counting_function

|pi(x) - li(x)| < 1/(8*pi)*log(x)*sqrt(x)

Integrate[1/Log[t],{t,0,x}]

LogIntegral is mathematica's name

Solve[LogIntegral[x]-2 == 10^48, x]

Plot[LogIntegral[x]-2,{x,10,1000}]

LogPlot[LogIntegral[x]-2,{x,10,10^48}]

LogPlot[LogIntegral[x]-2,{x,10,10^51}]

FindRoot[LogIntegral[x]-2-10^48,{x,10^48,10^52}]


FindRoot[LogIntegral[x]-2-10^48,{x,1.14*10^50,1.15*10^50}]

1.1425359437842517`*^50


LogIntegral[1.1425359437842517*10^50]-10^48

Solve[Log[LogIntegral[x]-2] == Log[10^48], x]

Plot[LogIntegral[x], {x,10^50,2*10^50}]

Plot[LogIntegral[x], {x,1.1*10^50,1.15*10^50}]

FindRoot[LogIntegral[x]-2-10^48,{x,Rationalize[1.14*10^50],
 Rationalize[1.15*10^50]}]

LogIntegral[Rationalize[1.14254*10^50,0]]

FindRoot[LogIntegral[x]-2-10^48,{x,Rationalize[1.142*10^50,0],
 Rationalize[1.143*10^50,0]}, Method -> Brent, PrecisionGoal -> 100,
 AccuracyGoal -> 100]

findroot2[LogIntegral[#]-10^48 &,1.14*10^50,1.15*10^50, 1]

Plot[LogIntegral[x], {x,1.1*10^50,1.15*10^50}]

Plot[LogIntegral[x], {x,1.14*10^50,1.15*10^50}]

FindRoot[LogIntegral[x] == 10^48, {x,10^50}]


FindRoot[LogIntegral[x] == 10^48, {x,1.14254*10^50}, PrecisionGoal -> 50,
 AccuracyGoal -> 50, WorkingPrecision -> 50]

test = 114253594378425466185108504215921573260523944025924

N[LogIntegral[test], 500]

|pi(x) - li(x)| < 1/(8*pi)*log(x)*sqrt(x)

Log[test]*Sqrt[test]/8/Pi

range = 49021108755433874493445505

114253594378425466185108455194812817826649450580733
114253594378425466185108553237030328694398437471393

