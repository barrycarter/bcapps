(*

https://www.quora.com/We-randomly-generate-digits-of-a-decimal-number-until-we-obtain-a-prime-number-Are-we-sure-to-ultimately-get-one

**Somewhere between 90% and 95%, probably, though it's difficult to find an exact number; it may even be 100%**

I found this problem interesting and did some work on it at https://github.com/barrycarter/bcapps/blob/master/QUORA/bc-primes.m and am summarizing the more important results below.

If and when you end on a prime number, it must be a member of https://oeis.org/A069090 "Primes none of whose proper initial segments are primes".

For example, you can stop at 91351901 since 91351901 is prime, but as you remove digits right to left:

* 9135190 is not prime (2*5*149*6131)
* 913519 is not prime (149*6131)
* 91351 is not prime (13*7027)
* 9135 is not prime (3*5*7*29)
* 913 is not prime (11*83)
* 91 is not prime (7*13)
* 9 is not prime (3*3)

However, you can NOT stop at 91535303, because, even though 91535303 itself is prime, here's what happens when you start removing digits right to left:

* 9153530 is not prime (2*5*915353)
* 915353 IS prime

That means you would've stopped at 915353 without generating any additional random digits.

I constructed the 1,411,151 members of A069090 that are 8 digits or fewer with the compressed results at https://github.com/barrycarter/bcapps/blob/master/QUORA/A069090-thru-8-digits.txt.bz2

Minor caveats for the discussion below:

* Generating one or more zeros at the start of your number does not change the probability since you will eventually (with probability 1) generate a non-zero digit, at which point your probability count starts.

* Consistent with A069090, I regard 1 as non-prime. Regarding 1 as prime may or may not drastically change the results below, and it would be an interesting extension of this problem to see if that is the case.

Suppose we generate eight random digits in a row, ignoring for the moment whether we hit any primes on the way or not. This means we are equally likely to generate any of the 9*10^7 numbers from 10000000 to 99999999. Now, let's see how many of these 9*10^7 numbers yield prime numbers:

* If the generated number is one of the 4*10^7 numbers that start with {2,3,5,7}, we have found a prime number on the first digit, regardless of what the remaining 7 digits are.

* There are 12 two digit members of A069090 (two digit primes where the first digit isn't prime). If the number we generate is one of 12*10^6 numbers that starts with a two digit member of A069090, we have found a prime number on the second digit, regardless of what the remaining 6 digits are. Note that we are not double counting the primes found in the first step because we only count primes where the first digit isn't prime.

* There are 60 three digit members of A069090 (three digit primes where neither the first digit nor the first two digits are prime). If we generate any number starting with these three digits, the remaining 5 digits can be anything, giving us additional 60*10^5 where we find a prime, again not doublecounting the ones we already found.

* Similarly there are 381 four digit members of A069090 giving us another 381*10^4 eight digit numbers, 2522 five digit members for another 2522*10^3, 19094 six digit members for another 19094*10^2, 151286 seven digit members for another 151286*10, and 1237792 eight digit members for a final 1237792 more.

* Adding these up, we see that, of the 9*10^7 to generate 8 digits, we will hit a prime number 68992052 times, or about 68992052/(9*10^7) (76.66%) of the time.

There are 4 one-digit members of A069090 (namely {2,3,5,7}), so there is a 4/9 (44.44...%) chance you will generate a prime on your first digit. 

* There is a 5/9 chance you won't generate a prime as your first digit, in which case there are 50 possible numbers (10 for each of {1,4,6,8,9}) after you've generated your second digit. Of these, 12 are prime, so there's a 12/50 (24%) chance your second number will be prime, 

TODO: make sure I don't use "roll" as in "dice roll" anywhere


Plot[LogIntegral[10^n]/10^n,{n,0,100}]

Plot[LogIntegral[10^n]/Log[10^n],{n,0,100}]

Plot[LogIntegral[10^n]/10^n,{n,100,200}]

Plot[10^n/LogIntegral[10^n],{n,1,200}]

Plot[10^n/LogIntegral[10^n]/n,{n,1,200}]

Plot[10^n/LogIntegral[10^n]/n,{n,100,200}]

Limit[10^n/LogIntegral[10^n]/n, n -> Infinity]
Log[10]

Limit[Exp[n]/LogIntegral[Exp[n]]/n, n -> Infinity]

(above is 1, but we need 10 version)

PrimePi[10]/10

(1-PrimePi[10]/10)*PrimePi[10^2]/10^2

(* cant choose 0 as first digit *)

a[1] = 4/9;

(* below should be 1-a[n-1] but not fixing, not using *)

a[n_] := a[n-1]*PrimePi[10^n]/10^n

appears to be eulergamma number

but above is wrong, because all prev numbers must be nonprime

Clear[a]

a[1] = 4/9;

a[n_] := (1-Sum[a[i],{i,1,n-1}])*PrimePi[10^n]/10^n

Sum[a[i],{i,1,10}]

bigger than one, something wrong, fixed

Clear[a]

a[1] = 4/9;

a[n_] := (1-Sum[a[i],{i,1,n-1}])*LogIntegral[10^n]/10^n

Sum[a[i],{i,1,10}]

prime1 = {2,3,5,7}

comp1 = Complement[Range[1,9], prime1]

digitify[l_] := Flatten[Table[Range[i*10,i*10+9],{i,l}]]

prs = Select[digitify[comp1], Not[PrimeQ[#]]&]

TODO: note leading 0s irrelev, assuming 1 is nonprime

(* START: the following lines compute actual values *)

digitify[l_] := Flatten[Table[Range[i*10,i*10+9],{i,l}]]

tab[1] = Range[1,9];
primes[1] = Select[tab[1], PrimeQ];
comps[1] = Complement[tab[1], primes[1]];

tab[n_] := tab[n] = digitify[comps[n-1]];
primes[n_] := primes[n] = Select[tab[n], PrimeQ];
comps[n_] := comps[n] = Complement[tab[n], primes[n]];

(* length below is 1,411,151 *)

Export["/tmp/A069090-thru-8-digits.txt",Flatten[Table[primes[i],{i,1,8}]]];

(* values of length of primes(n) *)

lens = {4, 12, 60, 381, 2522, 19094, 151286, 1237792};

(* probability computation using first 8 elts *)

Sum[lens[[i]]/10^i,{i,1,8}]

17248013/25000000 ~ 0.6899

(* confirms that primes[8] is correct *)

Length[Select[primes[8], PrimeQ]]

test1 = DeleteDuplicates[Floor[primes[8]/10]];

Select[test1, PrimeQ]

test2 = DeleteDuplicates[Floor[test1/10]];

(and so on, didnt actually finish)


(* END *)

Your search - A069090 10000019 - did not match any documents. 

https://oeis.org/A069090 is the sequence above

http://math.stackexchange.com/questions/437759/number-of-digits-until-a-prime-is-reached

(* START: estimation of primecount using PrimePi *)

tabcount[1] = 9
primecount[1] = 4
compcount[1] = 5

tabcount[n_] := tabcount[n] = 10*compcount[n-1]

primecount[n_] := primecount[n] = 
 (PrimePi[10^n]-PrimePi[10^(n-1)])/10^n*tabcount[n]

compcount[n_] := compcount[n] = tabcount[n] - primecount[n]

Table[Length[primes[i]],{i,1,8}]

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}

Round[Table[primecount[i],{i,1,8}],1]

{4, 10, 56, 359, 2531, 19107, 151317, 1238813}

Round[Table[primecount[i],{i,9,14}],1]

{10399793, 89032403, 774220364, 6819205872, 60704716094, 545274480340}

(* estimation of probability using first 14 terms *)

Sum[primecount[i]/10^i,{i,1,14}]

1786805970005556358589622202867229148721311186239138049375581435066120643541526713898117360601862600017/2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

about 0.714722388

(* END *)


(* START: estimation of primecount using LogIntegral *)

litabcount[1] = 9
liprimecount[1] = 4
licompcount[1] = 5

litabcount[n_] := litabcount[n] = 10*licompcount[n-1]

liprimecount[n_] := liprimecount[n] = 
 (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*litabcount[n]

licompcount[n_] := licompcount[n] = litabcount[n] - liprimecount[n]

Table[Length[primes[i]],{i,1,8}]

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}

Round[Table[liprimecount[i],{i,1,8}],1]

{4, 12, 56, 346, 2427, 18300, 144768, 1184837}

Round[Table[liprimecount[i],{i,9,18}],1]

{9946023, 85146113, 740424460, 6521526613, 58054734442, 521471180218, 
 4720263362679, 43012760609353, 394239380902044, 3632078476341029}

(* estimation of probability using first 18 terms *)

Sum[N[liprimecount[i]]/10^i,{i,1,18}]

approx 0.739406

ListLogPlot[Table[liprimecount[i],{i,1,18}]]

ListPlot[Table[liprimecount[i]/10^i,{i,1,18}]]

(* END *)

(* START: estimation of primecount using Prime number theorem *)

pnttabcount[1] = 9
pntprimecount[1] = 4
pntcompcount[1] = 5

pnttabcount[n_] := pnttabcount[n] = 10*pntcompcount[n-1]

pntprimecount[n_] := pntprimecount[n] = 
 (10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/10^n*pnttabcount[n]

pntcompcount[n_] := pntcompcount[n] = pnttabcount[n] - pntprimecount[n]

Table[Length[primes[i]],{i,1,8}]

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}

Round[Table[pntprimecount[i],{i,1,8}],1]

{4, 9, 51, 341, 2494, 19317, 155616, 1290484}

Round[Table[pntprimecount[i],{i,9,17}],1]

{10941430, 94403150, 826111488, 7314060016, 65393087389, 589557053955, 
5353515181972, 48917846233104, 449448883740210}

(* estimation of probability using first 17 terms *)

Sum[N[pntprimecount[i]]/10^i,{i,1,17}]

approx 0.707647

FullSimplify[(10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/10^n, {Element[n
,Integers], n>2}]

(* END *)

f[n_] = FullSimplify[(10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/10^n, 
 {Element[n  ,Integers], n>2}]

moretabcount[1] = 9
moreprimecount[1] = 4
morecompcount[1] = 5

moretabcount[n_] := moretabcount[n] = 10*morecompcount[n-1]

moreprimecount[n_] := moreprimecount[n] = f[n]*moretabcount[n]

morecompcount[n_] := morecompcount[n] = moretabcount[n] - moreprimecount[n]

mtc[n] = 10*mcc[n-1] = 10*(mtc[n-1] - mpc[n-1]) =
 10*(mtc[n-1] - (f[n-1]*mtc[n-1])) = 10*mtc[n-1]*(1-f[n-1])

RSolve[{mtc[1] == 9, mtc[2] == 50, 
 mtc[n] == 10*(1-f[n-1])*mtc[n-1]}, mtc[n], n]

(* below works!!! *)

mtcc[n_] = mtc[n] /.
RSolve[{mtc[2] == 50, 
 mtc[n] == 10*(1-f[n-1])*mtc[n-1]}, mtc[n], n][[1]]

(* the above actually does mtc well *)

mpcc[n_] = mtcc[n]*f[n]

Sum[mpcc[n]/10^n,{n,9,Infinity}]

about 0.255484 + 0.6899 = 0.945405

N[Sum[mpcc[n]/10^n,{n,15,Infinity}]] + 0.714722388 about 0.921815

Sum[mpcc[n]/10^n,{n,19,Infinity}]

about 0.188203 + 0.739406 = 0.927609



FullSimplify[mpcc[n], {Element[n,Integers],n>2}]

mpc2[n_] = 
(2^(-2 + n)*5^(-1 + n)*(-10 + 9*n)*
  Pochhammer[(-9 + 30*Log[10] + Sqrt[81 + 20*Log[10]*(-11 + 5*Log[10])])/
    (20*Log[10]), -2 + n]*Pochhammer[
   3/2 - (9 + Sqrt[81 + 20*Log[10]*(-11 + 5*Log[10])])/(20*Log[10]), -2 + n])/
 (n!*Gamma[n]*Log[10])









(* below is just test *)

mtc[1] = 9
mtc[2] = 50
mtc[n_] := 10*(1-f[n-1])*mtc[n-1]
Clear[mtc]






TODO: use N versions of these, might be much faster

TODO: you can get full list at...

sum = Sum[Length[primes[n]]/10^n,{n,1,8}]

17248013/25000000

0.689921, li approx is 0.679404

close to natural log of 2

est length for longer than 8 digits

tab[n] will be 10*comps[n-1]

primes[n] will be (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n times that

comps[n] will be 10*comps[n-1] - above

tabcount[1] = 9
primecount[1] = 4
compcount[1] = 5

tabcount[n_] := tabcount[n] = 10*compcount[n-1]

primecount[n_] := primecount[n] = 
 (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabcount[n]

compcount[n_] := compcount[n] = tabcount[n] - primecount[n]


RSolve[{
 tabcount[n] == 10*compcount[n-1],
 primecount[n] == (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabcount[n],
 compcount[n] == tabcount[n] - primecount[n],
 tabcount[1] == 9,
 primecount[1] == 4,
 compcount[1] == 5
}, primecount, n]

RSolve[{
 tabcount[n] == 10*(tabcount[n-1] - primecount[n-1]),
 primecount[n] == (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabcount[n],
 tabcount[1] == 9,
 primecount[1] == 4
}, primecount[n], n]

RSolve[{
tabcount[n] == 10*(tabcount[n-1] - (
 LogIntegral[10^(n-1)]-LogIntegral[10^(n-2)])/10^(n-1)*tabcount[n-1]
), tabcount[1] == 9, tabcount[2] == 21}, tabcount[n], n]

tabtest[1] = 9;
tabtest[2] = 50;
tabtest[n_] := tabtest[n] = 10*(tabtest[n-1] - (
 LogIntegral[10^(n-1)]-LogIntegral[10^(n-2)])/10^(n-1)*tabtest[n-1]);

primetest[n_] := 
 (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabtest[n]

TODO: sequence of primes meeting condition is itself interesting

(* above is confirmed accurate with tabcount earlier *)


RSolve[{
tabcount[n] == 10*(tabcount[n-1] - (
 LogIntegral[10^(n-1)]-LogIntegral[10^(n-2)])/10^(n-1)*tabcount[n-1]
), tabcount[1] == 9, tabcount[2] == 50}, tabcount[n], n]






0.745892 with first 20

above is remarkably good!


TODO: if posting as stack, note awareness of other question



"4,21,139,1032" = num primes exactly n digits

Table[PrimePi[10^n]-Sum[PrimePi[10^i],{i,1,n-1}],{n,1,8}]

WRONG: {4, 21, 139, 1032, 8166, 67480, 575063, 5007360}

Table[PrimePi[10^n]-PrimePi[10^(n-1)],{n,1,8}]

https://oeis.org/A006879 is that

primes will be 

TODO: different bases (trivial for 2), what if 1 is prime, OEIS

primes[8][[Floor[Length[primes[8]]*Random[]]]]

91351901 (where 1 is considered composite)

tab[8] is highest w/o out of memory

















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

