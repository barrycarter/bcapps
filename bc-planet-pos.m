(*

Obtains planetary positions [xyz position in heliocentric coordinates
in meters] directly from Mathematica (probably easier to use than
converting from HORIZONS, although HORIZONS data is slightly
different.

Note from Mathematica: Positions are given in FK5 heliocentric
coordinates in the equinox of the date used.

*)

(* necessary constants/functions *)

epoch = AbsoluteTime[{1970,1,1}]

showit := Module[{},
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* every 6m *)

xyz[planet_, year_] := Module[{x,s},
 x = Table[{t, AstronomicalData[planet, {"Position", DateList[t]}]},
 {t, AbsoluteTime[{year,1,1}], AbsoluteTime[{year+1,1,1}], 86400}];
 s = StringJoin[{"/home/barrycarter/BCGIT/planetdata/xyz-",
 ToString[planet], "-", ToString[year],  ".txt"}];
 Print[s];
 Put[x,s];
]

t1 = xyz["Mars", 2011]

AstronomicalData["Mars", "Position"]



