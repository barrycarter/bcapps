(*

TODO: result here

If we assume the Riemann Hypothesis and https://en.wikipedia.org/wiki/Prime_number_theorem#Prime-counting_function_in_terms_of_the_logarithmic_integral we have:

[math]\left| \pi (x)-\text{li}(x) \right|<\frac{\sqrt{x} \log (x)}{8 \pi }[/math]

Using Mathematica, we find that 114253594378425466185108504215921573260523944025925 (114,253,594,378,425,466,185,108,504,215,921,573,260,523,944,025,925) is the integer n such that li(n) is closest to [math]10^{48}[/math].

n2 = 114253594378425466185102853920130817319525886680866

TODO: more in para above?

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

TODO: other values

TODO: purposes COle


Abs[PrimePi[x] - LogIntegral[x]] < range[x]                            

http://www.jstor.org/stable/2005976?origin=crossref&seq=1#page_scan_tab_contents 



(* inverse logintegral function of sorts *)

ili[x_] := t /. FindRoot[LogIntegral[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]

range[x_] = Log[x]*Sqrt[x]/8/Pi

ili2[x_] := t /. FindRoot[LogIntegral[t]+range[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]






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

