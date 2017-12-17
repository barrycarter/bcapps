(* 

https://astronomy.stackexchange.com/questions/23987/occultations-of-triton 

TODO: mention xkcd?

TODO: pluto, its satellites, 4 big asteroids?

TODO: this is fairly ghetto

TODO: 1.1 billion stars but also n bright stars

*)

(* define distance from Sun = avg distance from Earth, in meters *)

planets = AstronomicalData["Planet"]

Table[dist[p] = AstronomicalData[p, "SemimajorAxis"][[1]], 
    {p, AstronomicalData["Planet"]}];

Table[dist[s] = dist[p], {s, AstronomicalData[p, "Satellites"]},
 {p, AstronomicalData["Planet"]}]



AstronomicalData[p, "SemimajorAxis"][[1]], 
    {p, AstronomicalData["Planet"]}];



p = AstronomicalData["Planet"]

s = Table[AstronomicalData[i, "Satellites"], {i,p}]

OrbitPeriod Diameter

  WRONG, need SemimajorAxis too

ang[x_] := 2*ArcTan[AstronomicalData[x,"Diameter"]/2]




