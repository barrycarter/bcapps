(*

http://mathematica.stackexchange.com/questions/111371/plots-of-united-states-states-with-non-standard-labels

Using (local copy of): 

http://code.google.com/apis/kml/documentation/us_states.kml

usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];

Graphics[usa[[1,2,2,1]]]

is AL; usa[[1,2,2,49]] is WI

usa[[1,6,2,1]] is text Alabama

usa[[1,2,2,1,1]] is quasi-centroid of Alabama

cheating: state 2 is alaska, state 11 is HI

states = Table[i, {i,Flatten[{1,Range[3,10],Range[12,50]}]}];

test2120 = Table[{
 EdgeForm[Thin],
 RGBColor[Random[], Random[], Random[]],
 usa[[1,2,2,i,1]],
 Text["hello", usa[[1,2,2,i,1,1]]],
 Opacity[0.1],
 usa[[1,2,2,i]]
}, {i,states}]

Graphics[test2120]
showit

Graphics[{
 usa[[1,2,2,1,1]],
 Text["hello", usa[[1,2,2,1,1,1]]],
 Opacity[0.1],
 usa[[1,2,2,1]],
}]
showit
