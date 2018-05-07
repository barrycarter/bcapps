(*

 attempts to solve https://astronomy.stackexchange.com/questions/26167/how-far-out-can-the-sun-keep-celestial-objects-revolving

*)


(* mathematica is too slow, so using HYG db *)

data = Import["!zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "CSV"];

(* data[[1]] tells me which fields I need *)

(* hyg doesnt have mass argh! *)

a = AstronomicalData["Star"];

data = Table[{
 AstronomicalData[s, Name],
 AstronomicalData[s, "Mass"]/kilograms,
 AstronomicalData[s, "Position"]
}, {s, Take[a,20]}]

data = Table[{

(* this is the sun *)

solarMass = AstronomicalData[a[[1]], "Mass"]
lightYear = UnitConvert["light year", "m"]

(* TODO: consider writing this to file, Mathematica is terribly slow *)

mass[s_] := mass[s] = AstronomicalData[s, "Mass"]/solarMass
pos[s_] := pos[s] = AstronomicalData[s, "Position"]/lightYear

(* just to get the memoization done *)

tab = Table[{mass[s], pos[s]}, {s, a}];

temp1845 = Read["!zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", String]

AstronomicalData[a[[2]],"Mass"]/solarMass
AstronomicalData[a[[2]],"Position"]/lightYear


AstronomicalData[a[[1]], "Properties"]

Mass
Position

AstronomicalData[a[[1]], "Position"]

9460730472580800 meters = light year 

(* force exerted on given point in light years by given star *)

force[x_, y_, z_, s_] := (AstronomicalData[s, "Mass"]/solarMass)/
Norm[AstronomicalData[s, "Position"]/lightYear - {x,y,z}]^2

Table[force[10,10,10,s], {s,a}]


