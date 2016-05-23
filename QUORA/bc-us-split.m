(* attempts to answer: https://www.quora.com/unanswered/If-you-drew-a-single-straight-line-bisecting-America-so-that-both-land-and-population-were-nearly-equally-divided-which-way-would-the-line-point 

https://www.census.gov/geo/maps-data/data/gazetteer2010.html

TODO: direct URL to cousub

TODO: better sources exist (more recent)

below from bc-state-names.m

*)

usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];
state[n_] := usa[[1,2,2,n]]
name[n_] := usa[[1,6,2,n]]
centroid[n_] := Flatten[Apply[List,state[n][[1]]]]
ewpoints[n_] := Transpose[Partition[Flatten[Apply[List,state[n],1]],2]]
width[n_] := Max[ewpoints[n][[1]]]-Min[ewpoints[n][[1]]]

states = Table[i, {i,Flatten[{1,Range[3,10],Range[12,50]}]}];
cities = CityData[{Large, "United States"}];

(* remove Honolulu and Anchorage *)

cities = Select[cities, #[[1]] != "Anchorage" && #[[1]] != "Honolulu" &];

t2108 = Table[Text[Style[i[[1]]], Reverse[CityData[i, "Coordinates"]]], 
 {i, cities}];

g3 = Graphics[t2108]

g4= Table[Point[Reverse[CityData[i, "Coordinates"]]], {i, cities}]
Graphics[g4]
showit


TODO: add major cities
TODO: weird gray dots? (do I have capitals included by mistake?)

g1 = Graphics[{Opacity[0.1], EdgeForm[Thin],Table[state[i],{i,states}]}];
g2 = Plot[-0.093365*x + 29.8953056335449, {x,-125,-67}]

Show[{g1,g2,g3}, AspectRatio -> 1]
showit

g = Table[{
 EdgeForm[Thin],
 Opacity[0.1],
 state[i]
}, {i,states}];

