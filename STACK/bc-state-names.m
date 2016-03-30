(*

http://mathematica.stackexchange.com/questions/111371/plots-of-united-states-states-with-non-standard-labels

Using (local copy of): 

http://code.google.com/apis/kml/documentation/us_states.kml

usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];

Graphics[usa[[1,2,2,1]]]

is AL; usa[[1,2,2,49]] is WI

usa[[1,6,2,1]] is text Alabama

usa[[1,2,2,1,1]] is quasi-centroid of Alabama

Graphics[{
 usa[[1,2,2,1,1]],
 Text["hello", usa[[1,2,2,1,1,1]]],
 Opacity[0.1],
 usa[[1,2,2,1]],
}]
showit
