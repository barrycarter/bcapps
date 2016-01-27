p = AstronomicalData["Planet"];

vr = AstronomicalData["Venus","Radius"]

(* closest possible approach *)

dist = AstronomicalData["Earth", "Periapsis"] -
AstronomicalData["Venus","Apoapsis"];

2*ArcTan[vr/dist]/Degree

(* about 1 minute of arc *)



