(* 

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

(*

RAW RESULTS (not sure why constant term is non-0):

decfour[0] = 2.982794797849734*^8
decfour[1] = -2.9677988934045434*^8 + 9.170689132027664*^9*I
decfour[2] = 1.432586534498814*^8 + 4.548038984377269*^7*I
decfour[3] = 7.830599335722238*^6 - 6.707145902500911*^7*I
decfour[4] = -2.97798216111644*^6 - 1.2071250071517676*^6*I

*)

(* determine phase and amplitude *)

Table[{n, Abs[2*decfour[n]/(ved25-ved0)], 
          Arg[2*decfour[n]/(ved25-ved0)]}, 
{n,1,4}]

(* and now lets turn it into an equation (could've done this in one
step, but clearer this way; also add in constant term *)

decguess[x_] = Sum[Abs[2*decfour[n]/(ved25-ved0)]*Cos[2*Pi*n*x/decyear -
        Arg[2*decfour[n]/(ved25-ved0)]],
{n,1,4}] + decfour[0]/(ved25-ved0)

(* compare to real declination *)

decdiff = Plot[decguess[x] - 
 AstronomicalData["Sun", {"Declination", ToDate[ved0+x]}], 
 {x, 0, ved25-ved0}]

(* shows accurate to .007 degrees *)

(* now, same thing for RA, but take care of linear/sawtooth component first;
   Fourier will handle sawtooth, but only w/ infinite number of terms *)

vera0 = x /. FindRoot[
 AstronomicalData["Sun", {"RightAscension", ToDate[x]}] == 0, {x,mathtoday}]

vera25 = x /. FindRoot[AstronomicalData["Sun", {"RightAscension", 
 ToDate[x]}] == 0,
  {x,mathtoday+365.2425*86400*25}]

rayear = (vera25-vera0)/25

(* getting rid of that pesky linear term; when RA~0 this can yield
   spurious 24s; hopefully, Fourier can ignore them *)

racorrected[x_]:= AstronomicalData["Sun",{"RightAscension", ToDate[x+vera0]}] -
 24*Mod[x/rayear,1]

(* the below looks odd but workable; should get back equation of time 
   <h>equations for love and tenderness appear elsewhere</h> *)

Plot[racorrected[x], {x,0,vera25-vera0}]

(* and now, take it away, Mr Fourier *)

rafour[n_] := rafour[n] = NIntegrate[
 AstronomicalData["Sun", {"RightAscension", ToDate[vera0+x]}]*
 Exp[2*Pi*I*x*n/rayear],
 {x,0,vera25-vera0}]

Table[rafour[n], {n,0,4}]

(* Same sum as before *)

raguess[x_] = Sum[Abs[2*rafour[n]/(vera25-vera0)]*Cos[2*Pi*n*x/rayear -
        Arg[2*rafour[n]/(vera25-vera0)]],
{n,1,4}] + rafour[0]/(vera25-vera0)

radiff = Plot[racorrected[x] - raguess[x], {x, 0, vera25-vera0}]

(* result is hideous!; pushing to git and trying different approach *)

(* TODO: have Mathematica manipulate equations to make them Perl friendly?? *)

(* TODO: at some point, document my failed attempts as well (why?) *)

