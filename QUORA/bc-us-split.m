(* attempts to answer: https://www.quora.com/unanswered/If-you-drew-a-single-straight-line-bisecting-America-so-that-both-land-and-population-were-nearly-equally-divided-which-way-would-the-line-point 

https://www.census.gov/geo/maps-data/data/gazetteer2010.html

TODO: direct URL to cousub

TODO: better sources exist (more recent)

TODO: tracts points

below from bc-state-names.m

*)

<</home/barrycarter/BCGIT/QUORA/metros.txt
<</home/barrycarter/BCGIT/QUORA/tracts.m
usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];
state[n_] := usa[[1,2,2,n]]
name[n_] := usa[[1,6,2,n]]
centroid[n_] := Flatten[Apply[List,state[n][[1]]]]
ewpoints[n_] := Transpose[Partition[Flatten[Apply[List,state[n],1]],2]]
width[n_] := Max[ewpoints[n][[1]]]-Min[ewpoints[n][[1]]]

states = Table[i, {i,Flatten[{1,Range[3,10],Range[12,50]}]}];

(* state outlines *)
ostates = Table[state[i],{i,states}];

(* text for cities *)

ctext = Table[Text[i[[2]], {i[[4]], i[[3]]}, {-1.1,0.5}],
 {i, metros}];

(*
ctext = Table[Text[i[[1]], Reverse[CityData[i, "Coordinates"]], {-1,0.5}], 
 {i, cities}]

*)

(* points for cities *)
cpts = Table[Point[{i[[4]],i[[3]]}], {i, metros}];

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

(* note 58 degrees wide, 48 degrees high *)

g1 = Show[{g0,g2}, AspectRatio -> 48/2/44.43,
 PlotRange -> {{-125,-67}, {24.5,49.5}}]

Export["/tmp/test.gif", g1, ImageSize -> {44.43*40*2,48*40}]
Run["display -geometry 800x600 /tmp/test.gif&"]


Export["/tmp/test.gif", g1, ImageSize -> {1024*4,768*4}]


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

