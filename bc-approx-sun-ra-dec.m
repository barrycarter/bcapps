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

(* work around "new" graphics handling in Mathematica 7 *)

showit := Module[{},
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

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

(* TODO: at some point, document my failed attempts as well (why?) *)

