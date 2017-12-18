(* 

https://astronomy.stackexchange.com/questions/23987/occultations-of-triton 

TODO: mention xkcd?

TODO: pluto, its satellites, 4 big asteroids?

TODO: this is fairly ghetto

TODO: 1.1 billion stars but also n bright stars

TODO: overlap planet occultation, other satellites

TODO: stellar density

TODO: CSPICE??

TODO: ecliptic vs galactic equator tilt per planet

*)

(* the minor planets w/ largeish angular diameters from Earth *)



(* define distance from Sun = avg distance from Earth, in meters *)

minors = Select[AstronomicalData["MinorPlanet"]

planets = AstronomicalData["Planet"]

sats = Flatten[Table[AstronomicalData[p, "Satellites"], {p, planets}]]

Table[dist[p] = AstronomicalData[p, "SemimajorAxis"][[1]], {p, planets}]

Table[dist[s] = dist[p], {p, planets}, {s, AstronomicalData[p, "Satellites"]}]

(* angular diameter *)

Table[ang[x] = 2*ArcTan[AstronomicalData[x,"Diameter"][[1]]/dist[x]/2],
 {x, Flatten[{planets,sats}]}]











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
