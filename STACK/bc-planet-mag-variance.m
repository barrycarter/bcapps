(* 

See also: http://www.stjarnhimlen.se/comp/ppcomp.html

3155716800 = 1 Jan 2000 at noon UTC

*)

EntityProperty["Jupiter", "ApparentMagnitude"]



PlanetData["Jupiter", {"ApparentMagnitude", {"Date" ->
ToDate[3155716800]}}]

mag[planet_, d1_, d2_] := 
 PlanetData[planet, 
  Table[EntityProperty["Planet", 
    "ApparentMagnitude", {"Date" -> DateObject[date]}], {date, 
    DateRange[d1, d2, "Week"]}]]

mag[planet_, d1_] :=
 PlanetData[planet, 
  EntityProperty["Planet", "ApparentMagnitude", 
  {"Date" -> unix2Date[d1]}]];

NMaximize[mag["Mercury", d], d]

Plot[mag["Mercury", d], {d, 0, 100*86400*366}]

Table[mag["Mercury", d], {d, 0, 86400*100, 86400}]

