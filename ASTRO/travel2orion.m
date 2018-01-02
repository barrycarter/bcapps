(* might be easier in Mathematica, sigh *)

s = StarData[];

StarData[s[[5]], "Constellation"][[2]]

orion = Select[s, StarData[#, "Constellation"][[2]] == "Orion" &];

Entity["Constellation"]["Properties"]

only has bright stars


StarData[s[[7]], "Constellation"] == Entity["Constellation", "Sculptor"]

above is true

orion = Select[s, StarData[#, "Constellation"] ==
Entity["Constellation", "Orion"] &];

(* above takes forever, why? *)

StarData[s[[15]], "ApparentMagnitude"]

bright = Select[s, StarData[#, "ApparentMagnitude"] < 5 &]

Property[Entity["Constellation", "Orion"], "BrightStars"]

orionBright = EntityValue[Entity["Constellation", "Orion"], "BrightStars"];

EntityValue[orionBright[[7]], "Color"]

g3d[s_] := {

Graphics3D[{
 RGBColor[{1,0,0}],
 Point[{0,0,0}]
}]


