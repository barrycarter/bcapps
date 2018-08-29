(*

attempts to solve https://astronomy.stackexchange.com/questions/26167/how-far-out-can-the-sun-keep-celestial-objects-revolving

*)

<oneoff>

(* load star data using newer "Entity" model *)

slist = EntityList["Star"];

solarMass = Entity["Star", "Sun"]["Mass"]

(* not sure why I can't do it all at once, but... *)

data[j_] := data[j] = Table[{i["Name"], i["Mass"]/solarMass, 
 i["HelioCoordinates"]/Quantity["Light Year"]}, {i, 
 Take[slist, {j*10000+1, (j+1)*10000}]}];



data = Table[{i["Name"], i["Mass"]/solarMass, 
 i["HelioCoordinates"]/Quantity["Light Year"]}, {i, slist}];

data >> starnamepos.m

</oneoff>

<formulas>







</formulas>

note: voronoi doesn't suffice because of combined star forces (2
nearby stars could be stronger)-- would need to find entire circle
where force is towards sun and roughly constant or has props of
elliptical orbit


(* note: the export only needs to be done once *)

a = AstronomicalData["Star"];

(* a[[1]] is the sun *)

solarMass = AstronomicalData[a[[1]], "Mass"]
lightYear = UnitConvert["light year", "m"]

(* having x y z separately is ugly, but only way to export to CSV *)

data = Table[{
 AstronomicalData[s, "Name"],
 AstronomicalData[s, "Mass"]/solarMass,
 AstronomicalData[s, "Position"][[1]]/lightYear,
 AstronomicalData[s, "Position"][[2]]/lightYear,
 AstronomicalData[s, "Position"][[3]]/lightYear
}, {s, a}];

Export["starnamemasspos.csv", data];

data = Import["!bzcat /home/user/BCGIT/ASTRO/starnamemasspos.csv.bz2", "CSV"];

(* get rid of missing masses and positions *)

data2 = Select[data, NumericQ[#[[2]]]&&NumericQ[#[[3]]]&];



(* force exerted on given point in light years by the ith star *)

force[x_, y_, z_, i_] := data2[[i,2]]/Norm[Take[data2[[i]], {3,5}]-{x,y,z}]^2

Table[{i, force[1,1,1,i]}, {i, Length[data2]}]

Table[force[1,1,1,i], {i, Length[data2]}]






(AstronomicalData[s, "Mass"]/solarMass)/
Norm[AstronomicalData[s, "Position"]/lightYear - {x,y,z}]^2

Table[force[10,10,10,s], {s,a}]


