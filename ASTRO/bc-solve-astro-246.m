(* Explore http://astronomy.stackexchange.com/questions/246/do-any-known-exoplanetary-solar-bodies-have-annular-eclipses-similar-to-earth?rq=1 *)

(* compute angular diameter from target diameter and distance *)

(* NOTE: for the distances/diameters we're dealing with this is
effectively ArcTan[diam/dist] but I'm being pedantic *)

ang[dist_,diam_] = 2*ArcTan[(diam/2)/dist]

(* the angular diameter of sun from planet p *)

angsun[p_] := ang[AstronomicalData[p, "SemimajorAxis"], 
 AstronomicalData["Sun", "Diameter"]];

(* angular diameter of satellite s as viewed from its planet p *)

(* could actually have combined this function w earlier one using
OrbitCenter, but nah *)

angmoon[s_, p_] := ang[AstronomicalData[s, "SemimajorAxis"], 
 AstronomicalData[s, "Diameter"]];

plans = Union[AstronomicalData["Planet"], {"Pluto"}]

t = Sort[Flatten[Table[{p, s, angmoon[s,p]/angsun[p]}, 
 {p, plans},
 {s, AstronomicalData[p, "Satellites"]}],1], #1[[3]] > #2[[3]] &]

(* doing both periapsis and apoapsis to get ranges *)

angsun2[p_] := {
ang[AstronomicalData[p, "Periapsis"],  AstronomicalData["Sun", "Diameter"]],
ang[AstronomicalData[p, "Apoapsis"],  AstronomicalData["Sun", "Diameter"]]
};

angmoon2[s_, p_] := {
ang[AstronomicalData[s, "Apoapsis"], AstronomicalData[s, "Diameter"]],
ang[AstronomicalData[s, "Periapsis"], AstronomicalData[s, "Diameter"]]
};

(* doing this as a module to catch Missing[NotAvailable] which messes
up Sort *)

angmoonsun[s_, p_] := Module[{},
 Table[data[x,y] = AstronomicalData[x,y], {x, {"Sun",p,s}},  
 {y, {"Periapsis","Apoapsis","Diameter"}}];
 Print[data[s,"Diameter"]];
]

plans2 = Union[AstronomicalData["Planet"], {"Pluto"}]

t2 = Sort[Flatten[Table[{p, s, angmoon2[s,p]/angsun2[p]}, 
 {p, plans2},
 {s, AstronomicalData[p, "Satellites"]}],1], #1[[3,1]] > #2[[3,1]] &]

t2 = Flatten[Table[{p, s, angmoon2[s,p]/angsun2[p]}, {p, plans2}, 
 {s, AstronomicalData[p, "Satellites"]}], 1]

t2 = Table[{p, s, angmoon2[s,p]/angsun2[p]}, {p, plans2}, 
 {s, AstronomicalData[p, "Satellites"]}]

t3 = Flatten[t2,1]

t4 = Sort[t3, #1[[3,1]] > #2[[3,1]] &]






