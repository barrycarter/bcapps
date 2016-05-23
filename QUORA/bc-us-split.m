(* attempts to answer: https://www.quora.com/unanswered/If-you-drew-a-single-straight-line-bisecting-America-so-that-both-land-and-population-were-nearly-equally-divided-which-way-would-the-line-point 

https://www.census.gov/geo/maps-data/data/gazetteer2010.html

TODO: direct URL to cousub

TODO: better sources exist (more recent)

TODO: tracts points

below from bc-state-names.m

*)

<</home/barrycarter/BCGIT/QUORA/metros.txt
usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];
state[n_] := usa[[1,2,2,n]]
name[n_] := usa[[1,6,2,n]]
centroid[n_] := Flatten[Apply[List,state[n][[1]]]]
ewpoints[n_] := Transpose[Partition[Flatten[Apply[List,state[n],1]],2]]
width[n_] := Max[ewpoints[n][[1]]]-Min[ewpoints[n][[1]]]

states = Table[i, {i,Flatten[{1,Range[3,10],Range[12,50]}]}];

(* state outlines *)
ostates = Table[state[i],{i,states}];

(* cities then remove Honolulu and Anchorage *)
cities = CityData[{Large, "United States"}];
cities = Select[cities, #[[1]] != "Anchorage" && #[[1]] != "Honolulu" &];

(* text for cities *)

ctext = Table[Text[Style[i[[1]], TextAlignment -> Right],
Reverse[CityData[i, "Coordinates"]]], {i, cities}];

ctext = Table[Text[i[[1]], Reverse[CityData[i, "Coordinates"]], {-1,0.5}], 
 {i, cities}]

(* points for cities *)
cpts = Table[Point[Reverse[CityData[i, "Coordinates"]]], {i, cities}]

(* the line *)
g2 = Plot[-0.093365*x + 29.8953056335449, {x,-125,-67}]

g0 = Graphics[{
 ctext,
 EdgeForm[Thin],
 Opacity[0.1],
 ostates,
 RGBColor[1,0,0],
 Opacity[1],
 cpts
}];

g1 = Show[{g0,g2}, AspectRatio -> .75];
Export["/tmp/test.gif", g1, ImageSize -> {1024*4,768*4}]
Run["display -geometry 800x600 /tmp/test.gif&"]


showit



Show[{g1,g2,g3}, AspectRatio -> 1]
showit

g = Table[{
 EdgeForm[Thin],
 Opacity[0.1],
 state[i]
}, {i,states}];

TODO: weird gray dots? (do I have capitals included by mistake?)

TODO: map not to scale

