(* Mathematica stuff for NADEX *)

(* nadex2: experimenting w/ buyback at $3 *)

Print["USING EXPERIMENTAL VERSION!"]

(* TODO: really seriously clean this up *)

(* this stuff changes each time *)

(* load NADEX data from bc-nadex-vol.pl output *)
(* <h>no, there are no parities other than USDCAD and USDJPY!</h> *)
If[$CommandLine[[4]] == "cad", Get["/tmp/nadex.m.USDCAD"],
 Get["/tmp/nadex.m.USDJPY"]]

(* second argument is now `date +%s -d 'whatever'` so Mathematica
no longer needs to calculate it *)

expdate = ToExpression[$CommandLine[[5]]]

(**

Load my positions; this file looks something like this:

(* long FOREX positions I hold, 10K each *)
mypos = Table[.9871+.0012*i,{i,0,19}];

(* options I've already sold: {number, strike, price-i-sold-at} *)

myoptpos = {{2, .9925, 18}, {8, .9975, 9.5}}

*)

(* this file now contains all info *)
<< /home/barrycarter/forexall.txt

(* find last prices for parities, and build table of values when requested *)

usdcad := Mean[Take[Flatten[ReadList["!tail -1 /home/barrycarter/USDCAD.log", {Number,Number,Number}]], {2,3}]]

usdjpy := Mean[Take[Flatten[ReadList["!tail -1 /home/barrycarter/USDJPY.log", {Number,Number,Number}]], {2,3}]]/100

t1cad := t1cad = Table[{p,tab[p][[1]]}, {p, usdcad, usdcad+.01, .0001}]
t1jpy := t1jpy = Table[{p,tab[p][[1]]}, {p, usdjpy, usdjpy+.01, .0001}]

mypos = If[$CommandLine[[4]] == "cad", myposcad, myposjpy]
myoptpos = If[$CommandLine[[4]] == "cad", myoptposcad, myoptposjpy]

(* select options w/ given expiration time/date *)
(* TODO: selling options w/ different expiries may be useful! *)

(* kludge to get rid of null that ends 'nadex' var *)

nadex = Select[nadex, Length[#]>2 &]

nadex = Select[nadex, #[[2]] == expdate &]

(* TODO: sublibrary to include in all .m files *)

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* value of spread from lo to hi at price p *)

spread[p_, lo_, hi_] = Min[Max[p,lo],hi]

(* profit at price p if you sell a q option for $r [incl NADEX fees;
if trading over 7 contracts, reduce fee as needed] + buyback at $3 *)

optionprofit[p_, q_, r_] =  r + If[p>=q,-101,-5]

(* suppose you buy back at $3 [which is the min ask I've ever seen],
so that you can profit from a 2nd upswing? *)

Print["EXPERIMENTAL PROCEDURE"]

optionprofit[p_, q_, r_] =  r + If[p>=q,-101,-5]

(* profit at price q if you buy 1 unit of parity at price p; not
directly NADEX, but useful for hedging *)

profit[p_, q_] = (q/p-1)

(* This formula comes from box-option-value.m, but I'm sadistically
changing some of the parameters:

 p0 - current price of underlying instrument
 v - volatility of underlying instrument (per year)
 s - strike price of binary option
 e - time to option expiration, in YEARS [was hours]

 Output: probability binary call will be in money
*)

bincallv[p0_, v_, s_, e_] =
 1-CDF[NormalDistribution[Log[p0],Sqrt[e]*v], Log[s]]

(* Greeks *)

bincalldelta[p0_, v_, s_, e_] = D[bincallv[p0,v,s,e],p0]
bincalltheta[p0_, v_, s_, e_] = D[bincallv[p0,v,s,e],e]

(* implied volatility, given other numbers (p1 = current price of
option as fraction) *)

impvol[p0_, s_, e_, p1_] = v /. Solve[bincallv[p0,v,s,e]==p1, v][[1]]

(* deciding what to buy below (sample) *)

(* underlying profit from my positions; per position and then total
[each pos is 10K] *)

(* formula below was wrong for a long time!

profitunder[p_, x_] = If[p>x, (p/x-1)*10000, 0]

 *)

profitunder[p_, x_] = If[p>x, (1-x/p)*10000, 0]

profitundertot[p_] = Sum[profitunder[p,x],{x,mypos}]

(* current time in Unix seconds; kludge for MST *)
now := AbsoluteTime[] - AbsoluteTime[{1970}, TimeZone->0]

(* compute midpoint vol for each option *)

Table[vol[a[[1]],a[[2]]] = 
 impvol[a[[5]], a[[1]], (a[[2]]-a[[6]])/365.2425/86400, (a[[3]]+a[[4]])/2/100],
{a,nadex}]

(* and note price if I want to use it elsewhere *)

Table[midprice[a[[1]],a[[2]]] = (a[[3]]+a[[4]])/2/100., {a,nadex}]

(* expected price of option when underlying is p *)

price[p_, s_, e_] := bincallv[p, vol[s,e], s, (e-now)/86400/365.2425]

(* table of option prices at given underlying price, rounding to nearest quarter and converting to [0,100] *)

opttab[p_] := Table[{a[[1]], a[[2]], Round[400*price[p,a[[1]],a[[2]]]]/4},
 {a, nadex}]

(* loss due to options I've already sold *)
alreadysold[p_] :=  Sum[x[[1]]*If[p>=x[[2]], x[[3]]-101, 0], {x,myoptpos}]

(* strike prices *)

strikes = Table[opt[[1]], {opt,nadex}]

(* strikes from options I've already sold, even if now worthless *)

strikes2 = Table[x[[2]], {x,myoptpos}]

strikes = Union[strikes, strikes2]

(* I sell n[strike][exp] of each option, and let Mathematica optimize
the values of n *)

(*

My total profit when underlying is at price p, assuming I sold options
when underlying was at price p0. Since I sell options "one at a time",
this only includes options that are in-the-money (ie, ones where I've
lost money) so that I never lose money

*)

totalprofit[p_, p0_] := profitundertot[p] +
 Sum[n[a[[1]],a[[2]]] * If[p>=a[[1]], optionprofit[p, a[[1]], a[[3]]], 0],
 {a, opttab[p0]}] +
 Sum[x[[1]]*If[p>=x[[2]], x[[3]]-101, 0], {x,myoptpos}]

(* 

constraints if I sold when underlying was at price p0:
  - totalprofit must be > 0 for all values of p (but it only changes discontinously at strike prices)
  - can't sell negative options (buying != selling negative, since prices are different, commissions, etc)

*)
  
cons[p0_] := Table[{totalprofit[s,p0] >= 0, n[s,expdate]>=0}, {s, strikes}]

(* extra constraint: max loss can't exceed cash *)

cashcons[p_] := Sum[n[a[[1]],a[[2]]] * (a[[3]]-101), {a,opttab[p]}] > - cash

(* never sell in-money options *)

consitm[p_] := Table[n[s,expdate]==0, {s,Select[strikes, #<=p&]}]

(* variables we use [Mathematica needs these to Maximize] *)

vars = Table[n[i,expdate], {i, strikes}]

(* total premiums = thing to maximize *)

(* using optionprofit[] here for consistency, this is just r-5 *)

premiums[p_] := Sum[n[a[[1]],a[[2]]] * optionprofit[0, 1, a[[3]]], 
 {a,opttab[p]}]

maxi[p_] := Maximize[premiums[p], {cons[p], cashcons[p], consitm[p]}, 
 vars, Integers]

(* TODO: below is ugly, I should be able to use opttab directly *)

tab[p_] := N[{maxi[p][[1]], maxi[p][[1]]/(expdate-now)*86400 , Sort[
 Select[Table[{s, n[s,expdate], 
 Round[400*price[p,s,expdate]]/4,
  n[s,expdate]*(Round[400*price[p,s,expdate]]/4-5)}, 
 {s, strikes}] /. maxi[p][[2]], #[[2]]>0&]
, #1[[3]] > #2[[3]] &]}]

(* below does not work; needs to curry, methinks *)
f[p_,q_] := totalprofit[p] /. maxi[q][[2]]
