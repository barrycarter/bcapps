(*

https://earthscience.stackexchange.com/questions/14545/longest-land-path-on-afro-eurasia

*)

GeoEntities[Entity["World"], "Continent"]

Entity["Continent", "Africa"]

EntityValue[]

no continents

p1 = EntityValue[Entity["Country", "SouthAfrica"] , "Polygon"][[1,1,1]]

p2 = EntityValue[Entity["Country", "Russia"] , "Polygon"][[1,1,1]]

t = Table[GeoDistance[x,y], {x,p1}, {y,p2}];




