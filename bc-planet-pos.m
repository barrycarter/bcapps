(*

Obtains planetary positions [xyz position in heliocentric coordinates
in meters] directly from Mathematica (probably easier to use than
converting from HORIZONS, although HORIZONS data is slightly
different.

Note from Mathematica: Positions are given in FK5 heliocentric
coordinates in the equinox of the date used.

*)

showit := Module[{},
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

(* every 6m *)

xyz[planet_, year_] := Module[{x,s},
 x = Table[{t, AstronomicalData[planet, {"Position", DateList[t]}]},
 {t, AbsoluteTime[{year,1,1}], AbsoluteTime[{year+1,1,1}], 300}];
 s = StringJoin[{"/home/barrycarter/BCGIT/planetdata/xyz-",
 ToString[planet], "-", ToString[year],  ".txt"}];
 Print[s];
 Put[x,s];
]

p = {"Mercury", "Venus", "Earth", "Moon", "Mars", "Jupiter", "Saturn",
 "Uranus", "Neptune", "Pluto"}

Table[xyz[pl,y], {pl, p}, {y,2011,2021}]




