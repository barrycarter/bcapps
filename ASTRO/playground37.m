(* http://astronomy.stackexchange.com/questions/13115/from-which-exoplanets-is-our-sun-the-brightest-star-on-the-night-sky *)

(* Mathematica takes forever to compute this, so computing it once and
storing it *)

(* START SKIP FROM HERE TO NEXT "SKIP" IF USING MX FILE BELOW:

math -initfile /home/barrycarter/20160107/magpos.mx

 *)

pos[s_] := pos[s] = AstronomicalData[s, "PositionLightYears"];

(* this just forces evaluation of above, doesn't actually do anything *)

Table[pos[s],{s, AstronomicalData["Star"]}];

mag[s_] := mag[s] = AstronomicalData[s, "AbsoluteMagnitude"];

Table[mag[s],{s, AstronomicalData["Star"]}];

stars = AstronomicalData["Star"];

exos = AstronomicalData["Exoplanet"];

oc[p_] := oc[p] = AstronomicalData[p, "OrbitCenter"];

Table[oc[p],{p, AstronomicalData["Exoplanet"]}];

(* stars that have exoplanets *)

exostars = Union[Table[oc[p], {p,exos}],{}];

(* some stars have position and apparent magnitude but no absolute magnitude *)

badstars = Select[stars, !NumberQ[mag[#]]  &];

Table[mag[s] = Log[10,32.6/Norm[AstronomicalData[s, "PositionLightYears"]]]*5 +
 AstronomicalData[s, "ApparentMagnitude"], {s,badstars}]

(* remove stars we have no luminosity info for (but store them first) *)

realbadstars = Select[stars, !NumberQ[mag[#]]  &];

(* testing to see if I can add any more, result is empty, so no *)

test0 = Table[{s,AstronomicalData[s, "ApparentMagnitude"]}, {s,realbadstars}]
test1 = Select[test0, NumberQ[#[[2]]] &];
test2 = Table[{s,AstronomicalData[s, "PositionLightYears"]}, {s,realbadstars}]
test3 = Select[test2, NumberQ[#[[2,1]]] &]
test4 = Table[i[[1]],{i,test1}]
test5 = Table[i[[1]],{i,test3}]
Intersection[test4,test5]

DumpSave["/home/barrycarter/20160107/magpos3.mx", 
 {mag,pos,stars,exos,oc,exostars,realbadstars}];

(* END SKIP FROM HERE *)

(* the distance between stars s1 and s2 *)
dist[s1_,s2_] :=  Norm[pos[s1]-pos[s2]];

(* magnitude of s2 as viewed from s1 *)
magXY[s1_,s2_] := mag[s2] - Log[10,32.6/dist[s1,s2]]*5;

(* brightness of top 10 stars from given star system [11 incl primary]
and also of our own Sun [and its position in list] *)

(* TODO: memoize and save *)

brightstars[s_] := Module[{t}, 
 t = Sort[Table[{s, s1, magXY[s, s1]}, {s1,stars}], #1[[3]] < #2[[3]] &];
 Return[Take[t,11]];
]

test = brightstars[exostars[[7]]];

test2 = Sort[test, #1[[2]] < #2[[2]] &];


(* convert absolute magnitude and distance in light years to apparent
magnitude *)

abs2app[mag_, dist_] = Simplify[mag-Log[10,32.6/dist]*5]


(* stars with exoplanets; 464 stars with 552 exoplanets *)

swex = Union[Table[AstronomicalData[p, "OrbitCenter"], 
 {p, AstronomicalData["Exoplanet"]}], {}];

(* magnitudes of all stars as viewed from given exoplanet (TODO:
special case for its own primary *)

stars = AstronomicalData["Star"];

starsAtNight[p_] := Module[{s0},
 s0 = AstronomicalData[p, "OrbitCenter"];
 Return[Table[dist[s0,s], {s, stars}]];
];

t = starsAtNight["Nu2CanisMajoris"];



(* for now, just nearby stars, but expand this *)

stars = AstronomicalData["StarNearest100"]

(* note: AverageOrbitDistance *)


dist = 8.6 light years
absmag = 1.45
appmag = -1.44

parsec = 32.6 ly



