(* http://mathematica.stackexchange.com/questions/85235/inaccurate-heliocentric-coordinates-of-planetarymoondata *)

AstronomicalData["Jupiter", "Position"]
AstronomicalData["Io", "Position"]
AstronomicalData["Sun", "Position"]

t = AstronomicalData["Io", "Properties"];

t2=Table[{i,AstronomicalData["Io",i]},{i,AstronomicalData["Io","Properties"]}];
