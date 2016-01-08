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

DumpSave["/home/barrycarter/20160107/magpos.mx", {mag,pos,stars,exos,oc}];

(* END SKIP FROM HERE *)

(* the distance between stars s1 and s2 *)

dist[s1_,s2_] :=  Norm[pos[s1]-pos[s2]];

(* magnitude of s2 as viewed from s1 *)

magXY[s1_,s2_] := mag[s2] - Log[10,32.6/dist[s1,s2]]*5;

(* brightness of all stars (excluding primary?) from given exoplanet *)

brightstars[p_] := Sort[Table[{s1, magXY[oc[p], s1]}, {s1,stars}], 
 #1[[2]] < #2[[2]] &];

test = brightstars[exos[[8]]];

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



