(* http://physics.stackexchange.com/questions/228542/calculating-time-from-altitude-of-the-sun *)

(* TODO: note not worth bounty, but still *)

(* tropical year from http://hpiers.obspm.fr/eop-pc/models/constants.html *)

tyear = 365.242190402;

(* NOTE: this should work without Date[] but doesn't *)

AstronomicalData["Sun", {"Declination", Date[]}]

start = AbsoluteTime[{2016,1,1}]
end = AbsoluteTime[{2017,1,1}]

t[day_] = day*86400+AbsoluteTime[{2016,1,1}]-43200

(* TODO: explain my day convention *)

Plot[AstronomicalData["Sun", {"Declination", DateList[t[day]]}],
 {day,1,366}]

sundec[d_] := AstronomicalData["Sun", {"Declination", DateList[t[d]]}];
sunra[d_] := AstronomicalData["Sun", {"RightAscension", DateList[t[d]]}];

res  = NIntegrate[Exp[2*Pi*I*x/tyear]*sundec[x],{x,0,tyear}]

(* res = -4184.99 + 729.51 I *)

amp = Norm[res]/tyear*2

phase = Arg[res]/Degree

Plot[{amp*Cos[2*Pi*x/tyear-phase*Degree],sundec[x]},{x,0,tyear}]

(* about 0.8 degree accuracy *)

Plot[{amp*Cos[2*Pi*x/tyear-phase*Degree]-sundec[x]},{x,0,tyear*10}]

Plot[fakederv[sunra,d,.01],{d,0,tyear}]

Plot[If[sunra[d]>sunra[0],sunra[d]-24,sunra[d]],{d,0,tyear}]



