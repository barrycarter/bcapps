(* 

https://astronomy.stackexchange.com/questions/23987/occultations-of-triton 

TODO: mention xkcd?

TODO: pluto, its satellites, 4 big asteroids?

TODO: this is fairly ghetto

TODO: 1.1 billion stars but also n bright stars

*)

(* minimal fail example *)

Table[{p,s}, {p, AstronomicalData["Planet"]}, 
 {s, AstronomicalData[p, "Satellites"]}]



(* define distance from Sun = avg distance from Earth, in meters *)

planets = AstronomicalData["Planet"]

Table[dist[p] = AstronomicalData[p, "SemimajorAxis"][[1]], {p, planets}]

Table[dist[s] = dist[p], {s, AstronomicalData[p, "Satellites"]},
 {p, Take[planets,{3,8}]}]

Table[{s,p}, {p, AstronomicalData["Planet"]},
 {s, AstronomicalData[p, "Satellites"]}]



 









AstronomicalData[p, "SemimajorAxis"][[1]], 
    {p, AstronomicalData["Planet"]}];



p = AstronomicalData["Planet"]

s = Table[AstronomicalData[i, "Satellites"], {i,p}]

OrbitPeriod Diameter

  WRONG, need SemimajorAxis too

ang[x_] := 2*ArcTan[AstronomicalData[x,"Diameter"]/2]




(*

posted as https://mathematica.stackexchange.com/questions/162140/iterator-order-breaks-table-when-using-astronomicaldata

Subject: Iterator order breaks Table when using AstronomicalData

<pre><code>

(* this breaks *)

Table[{s,p},
 {s,AstronomicalData[p,"Satellites"]},
 {p,AstronomicalData["Planet"]}
];

Table::iterb: Iterator {s, $Failed} does not have appropriate bounds.

(* but if you switch the iteration order, it works fine *)

Table[{s,p},
 {p,AstronomicalData["Planet"]},
 {s,AstronomicalData[p,"Satellites"]}
];

</code></pre>

Why?


*)
