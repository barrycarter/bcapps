(* Mathematica stuff for NADEX *)

(* this stuff changes each time *)

(* load NADEX data *)
<< /tmp/nadex.m.USDJPY

(* load my positions [file is of form mypos=Table[...]] *)
<< /home/barrycarter/usdjpypos.txt

(* and cash "cash = 123" *)
<< /home/barrycarter/nadexcash.txt

(* select options w/ given expiration time/date *)
(* TODO: selling options w/ different expiries may be useful! *)
expdate = AbsoluteTime[{2011,8,19,19}, TimeZone->0]

(* changing stuff stops here *)

expdate = Round[expdate - AbsoluteTime[{1970}, TimeZone->0]]
(* kludge to get rid of null that ends 'nadex' var *)
nadex = Select[nadex, Length[#]>2&]

nadex = Select[nadex, #[[2]] == expdate &]

(* TODO: sublibrary to include in all .m files *)

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* value of spread from lo to hi at price p *)

spread[p_, lo_, hi_] = Min[Max[p,lo],hi]

(* profit at price p if you sell a q option for $r [incl NADEX fees;
if trading over 7 contracts, reduce fee as needed] *)

optionprofit[p_, q_, r_] =  r + If[p>=q,-101,-2]

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

(* implied volatility, given other numbers (p1 = current price of
option as fraction) *)

impvol[p0_, s_, e_, p1_] = v /. Solve[bincallv[p0,v,s,e]==p1, v][[1]]

(* deciding what to buy below (sample) *)

(* underlying profit from my positions; per position and then total
[each pos is 10K] *)

profitunder[p_, x_] = If[p>x, (p/x-1)*10000, 0]
profitundertot[p_] = Sum[profitunder[p,x],{x,mypos}]

(* current time in Unix seconds; kludge for MST *)
now := AbsoluteTime[] - AbsoluteTime[{1970}, TimeZone->0]

(* compute midpoint vol for each option *)

Table[vol[a[[1]],a[[2]]] = 
 impvol[a[[5]], a[[1]], (a[[2]]-a[[6]])/365.2425/86400, (a[[3]]+a[[4]])/2/100],
{a,nadex}]

(* expected price of option when underlying is p *)

price[p_, s_, e_] := bincallv[p, vol[s,e], s, (e-now)/86400/365.2425]

(* table of option prices at given underlying price, rounding to nearest quarter and converting to [0,100] *)

opttab[p_] := Table[{a[[1]], a[[2]], Round[400*price[p,a[[1]],a[[2]]]]/4},
 {a, nadex}]

(* strike prices *)

strikes = Table[opt[[1]], {opt,nadex}]

(* I sell n[strike][exp] of each option, and let Mathematica optimize
the values of n *)

(* My total profit at price p when options expire = profit from
underlying + gain/loss from sold options; however, only count options
less than or equal to current price, since I often sell them "one at a
time" *)

totalprofit[p_] := profitundertot[p] +
 Sum[n[a[[1]],a[[2]]] * If[p>=a[[1]], optionprofit[p, a[[1]], a[[3]]], 0],
 {a, opttab[p]}]

(* constraints: totalprofit must be > 0 for all values of p [but only
need to test at strike values]; n > 0 because I can't really buy at same prices I sell [commissions, etc] *)

cons = Table[{totalprofit[s] >= 0, n[s,expdate]>0}, {s, strikes}]

(* extra constraint: max loss can't exceed cash *)

cashcons[p_] := Sum[n[a[[1]],a[[2]]] * (a[[3]]-101), {a,opttab[p]}] > - cash

(* variables we use [Mathematica needs these to Maximize] *)

vars = Table[n[i,expdate], {i, strikes}]

(* total premiums = thing to maximize *)

premiums[p_] := Sum[n[a[[1]],a[[2]]] * a[[3]], {a,opttab[p]}]

maxi[p_] := Maximize[premiums[p], {cons, cashcons[p]}, vars, Integers]

(* TODO: below is ugly, I should be able to use opttab directly *)

tab[p_] := N[{maxi[p][[1]], Sort[
 Select[Table[{s, n[s,expdate], 
 Round[400*price[p,s,expdate]]/4,
  n[s,expdate]*(Round[400*price[p,s,expdate]]/4-2)}, 
 {s, strikes}] /. maxi[p][[2]], #[[2]]>0&]
, #1[[4]] > #2[[4]] &]}]

(* below does not work; needs to curry, methinks *)
f[p_,q_] := totalprofit[p] /. maxi[q][[2]]
