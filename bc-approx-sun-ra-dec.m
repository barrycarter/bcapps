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

