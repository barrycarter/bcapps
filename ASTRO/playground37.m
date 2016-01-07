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

annular[p_] := Table[{i, angmoon[i, p]/angsun[p]}, 
 {i,AstronomicalData[p, "Satellites"]}];

t = Table[{p, annular[p]}, {p, AstronomicalData["Planet"]}]

plans = Union[AstronomicalData["Planet"], AstronomicalData["DwarfPlanet"]]
plans = Union[AstronomicalData["Planet"], {"Pluto"}]

t = Sort[Flatten[Table[{p, s, angmoon[s,p]/angsun[p]}, 
 {p, plans},
 {s, AstronomicalData[p, "Satellites"]}],1], #1[[3]] > #2[[3]] &]













2*ArcTan[AstronomicalData[p, "Periapsis"], 
 AstronomicalData["Sun", "EquatorialRadius"]]


p = AstronomicalData["Planet"]


AstronomicalData["Sun", "EquatorialDiameter"]
AstronomicalData["Jupiter", "EquatorialDiameter"]
AstronomicalData["Jupiter", "Periapsis"]
AstronomicalData["Jupiter", "Satellites"]

(* angular diameter of sun from planet *)

(* planet moons + radii + distances *)

AstronomicalData["Io", "Radius"]
AstronomicalData["Io", "Periapsis"]




