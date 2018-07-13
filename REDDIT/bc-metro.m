(*

https://www.reddit.com/r/geography/comments/8qzl3p/if_we_redrew_us_state_lines_by_voronoi_of_the_top/

*)

(* run these commands first to build caches *)

metrosAll = EntityList["MetropolitanArea"];

tab = Table[{i, i["Name"], i["Population"], i["Position"], i["Country"]},
 {i, metrosAll}]

tab >> ~/BCGIT/REDDIT/metro-area-data.m

(* end run these commands first *)

(* find US metro areas *)

metrosAll = << ~/BCGIT/REDDIT/metro-area-data.m

metrosUSA = Select[metrosAll, 
 #[[5]] == Entity["Country", "UnitedStates"]&];

(* top 50 by pop *)

metrosUSASorted = Sort[metrosUSA, #1[[3]] > #2[[3]] &]

metrosUSATop = Take[metrosUSASorted, 50];

geopos = Transpose[metrosUSATop][[4]]

In[50]:= Nearest[Table[i[[4]] -> i[[1]], {i, metrosUSATop}], metrosUSASorted[[55
5,4]]]                                                                          
above works

(* table of important values, including XYZ pos for distance *)

(* this assumes ellipsoidal Earth, shiny! *)

(* the Print[i] is just to track progress, not used for anything *)

metrosTable = Table[
 {i["Name"], i["Population"], i["Latitude"], i["Longitude"], 
  GeoPositionXYZ[i], Print[i]},
 {i, metrosUSA}];








(* Avoid long delays *)

EntityList["MetropolitanArea"] lists all

a2311 = Entity["MetropolitanArea"]["Properties"]                           

a2256 = EntityList["MetropolitanArea"];

a2257 = Entity["Country", "UnitedStates"]

a2258 = Select[a2256, #["Country"] == a2257 &];

a2259 = Select[a2256, #["Country"][[2]] == "UnitedStates" &];

a2303 = Table[{i, i["Country"][[2]], Print[i]}, {i, a2256}];

a2309 = Select[a2303, #[[2]] == "UnitedStates" &]

a2309[[5,1]]["Population"]
a2309[[5,1]]["Latitude"]
a2309[[5,1]]["Longitude"]


a2312 = Transpose[a2309][[1]]

a2313 = Table[
 {i["Name"], i["Population"], i["Latitude"], i["Longitude"], Print[i]},
 {i, a2312}];

a2328 = Table[
 {i["Name"], i["Population"], i["Latitude"], i["Longitude"], Print[i]},
 {i, a2258}];

Total[Transpose[a2328][[2]]]

292138739 people

That brings the country's total urban population to 249,253,271, a number attained via a growth rate of 12.1 percent between 2000 and 2010, outpacing the nation as a whole, which grew at 9.7 percent.

from https://www.citylab.com/equity/2012/03/us-urban-population-what-does-urban-really-mean/1589/

292138739/328122776. 

is 89% so quasi-reasonable

https://mathematica.stackexchange.com/questions/56172/speed-of-curated-data-calls-in-version-10
optimization (do NOT set `$AllowInternet = False`, that breaks stuff)

Take[Sort[a2328, #1[[2]] > #2[[2]] &],10]
