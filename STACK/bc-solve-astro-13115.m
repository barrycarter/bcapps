(* http://astronomy.stackexchange.com/questions/13115/from-which-exoplanets-is-our-sun-the-brightest-star-on-the-night-sky *)

(* Mathematica takes forever to compute this, so computing it once and
storing it *)

(* START SKIP FROM HERE TO NEXT "SKIP" IF USING MX FILE BELOW:

math -initfile /home/barrycarter/20160107/stardata.mx

 *)

stars = AstronomicalData["Star"];
exos = AstronomicalData["Exoplanet"];

(* To avoid
http://astronomy.stackexchange.com/questions/13126/absolute-apparent-magnitude-and-distance-for-hip31978-inconsistent
situation, using apparent magnitude to compute absolute magnitude *)

Table[pos[s] = AstronomicalData[s, "PositionLightYears"], {s,stars}];
Table[mag[s] = AstronomicalData[s, "ApparentMagnitude"], {s,stars}];
Table[oc[p] = AstronomicalData[p, "OrbitCenter"], {p,exos}];
exostars = Union[Table[oc[p], {p,exos}],{}];

DumpSave["/home/barrycarter/20160107/stardata.mx", 
 {stars,exos,pos,mag,oc,exostars}];

(* END SKIP FROM HERE *)

(* convert solar apparent magnitudes to absolute magnitudes *)

absmag[s_] := absmag[s] = Log[10, 32.6/Norm[pos[s]]]*5 + mag[s]

(* special case for Sun *)

absmag["Sun"] = 4.83;

(* the distance between stars s1 and s2 *)
dist[s1_,s2_] :=  Norm[pos[s1]-pos[s2]];

(* magnitude of s2 as viewed from s1 *)
(* if s2 = s1, don't want it on list *)
magXY[s1_,s2_]:=If[s1==s2, +Infinity,absmag[s2] - Log[10,32.6/dist[s1,s2]]*5];

(* brightness of top 10 stars from given star system [11 incl primary]
and also of our own Sun [and its position in list] *)

(* TODO: save; print below just so I can see progress *)

brightstars[s_] := brightstars[s] = Module[{t,t2,sun}, 
 Print[s];
 t = Sort[Table[{s, s1, magXY[s, s1]}, {s1,stars}], #1[[3]] < #2[[3]] &];
 t2 = Table[Flatten[{i,t[[i]]}],{i,1,Length[t]}];
 t2 = Select[t2, #[[1]] <=11 || #[[3]] == "Sun" &];
 Return[t2];
]

print = Table[brightstars[s], {s,exostars}];

(* stars with exoplanets; 464 stars with 552 exoplanets *)

(* TODO: brightness of primary from exoplanet *)

(* some cleanup later *)

print = Flatten[print,1];
print = Select[print, NumericQ[#[[4]]] &]

