(*

https://www.quora.com/Which-country-location-has-minimum-temperature-variation-throughout-the-year

https://www.quora.com/unanswered/Which-city-has-the-minimum-temperature-of-22-C-and-doesnt-go-much-below-it-and-has-a-maximum-temperature-of-27-C-and-doesnt-go-much-above-it-almost-throughout-the-year

*)


cities = WeatherData[];
start = {1986,7,1};
end = {2016,6,30};

(* get the data and store it *)

data[stat_] := data[stat] = 
 WeatherData[stat, "MaxTemperature", {start, end, "Day"}];

(* this just forces evaluation *)

Table[{Print[i], data[i]}, {i,cities}];




temp2042 = WeatherData["Albuquerque", "Temperature", { {1986,7,1}, 
{2016,6,30}}];

temp2044 = WeatherData["Boston", "Temperature", { {1986,7,1}, 
{2016,6,30}}];

(* takes about 25s to get 30y of data per location *)

temp2049 = WeatherData["Boston", "Temperature", 
 {{2015,7,1}, {2016,6,30}, "Hour"}];


temp2049 = WeatherData["Boston", "Temperature", 
 {{2015,7,1}, {2016,6,30}, "Hour"}];

WeatherData["Boston", "MaxTemperature",  {{2015,7,1}, {2016,6,30}, "Day"}]

WeatherData["Boston", {"MaxTemperature", "MinTemperature"},  
 {{2015,7,1}, {2016,6,30}, "Day"}]

max[stat_] := Transpose[WeatherData[stat, "MaxTemperature", 
 {{1986,7,1}, {2016,6,30}, "Day"}]][[2]];

temp2309 = 
 WeatherData["KABQ", "MaxTemperature", {{1986,7,1}, {2016,6,30}, "Day"}];

temp2315 = 

GatherBy[temp2309, Take[#[[1]],-2] &]

maxfunc[stat_] := maxfunc[stat] = 
 superfour[Select[Transpose[WeatherData[stat, "MaxTemperature",
 {{1986,7,1}, {2016,6,30}, "Day"}]], NumberQ[#] &][[2]],1];

minfunc[stat_] := minfunc[stat] = 
 superfour[Transpose[WeatherData[stat, "MinTemperature",
 {{1986,7,1}, {2016,6,30}, "Day"}]][[2]],1];

(* good stuff starts here *)

cities = WeatherData[];

max[stat_] := Transpose[WeatherData[stat, "MaxTemperature", 
 {{1986,7,1}, {2016,6,30}, "Day"}]][[2]];

min[stat_] := Transpose[WeatherData[stat, "MinTemperature", 
 {{1986,7,1}, {2016,6,30}, "Day"}]][[2]];

maxfunc[stat_] := maxfunc[stat] = superfour[Select[max[stat],NumberQ],1]
minfunc[stat_] := minfunc[stat] = superfour[Select[min[stat],NumberQ],1]

(* this just forces computation *)

Table[{minfunc[stat], maxfunc[stat]}, {stat, Take[cities,50]}]


 



TODO: note SJSU

(* this test is for 10 years, really do 30 years *)

$TimeZone = 0;
sdate = {1986,7,1};
edate = {2016,6,30};
city = "KABQ";

kbos = Select[
 WeatherData[city, "Temperature", {sdate,edate}, TimeZone -> 0],
 NumberQ[#[[2]]] &];

kbos2 = N[Table[{FromDate[i[[1]]], i[[2]]}, {i, kbos}]];

kbos3 = Mean /@ GatherBy[kbos2, First];

kbos4[x_] = Interpolation[kbos3, x, InterpolationOrder -> 1]

kbos5 = Table[kbos4[x], {x, FromDate[sdate], FromDate[edate], 3600}];

sdate = {2015,7,1};
edate = {2016,6,30};

dumpdata[station_] := Module[{file},
 file = "/home/barrycarter/20160702/WEATHER/"<>station<>".dat";
 Print[file];
 WeatherData[city, "Temperature", {sdate,edate}, TimeZone -> 0] >> file;
];





kbos = Select[
 WeatherData["Boston", "Temperature", {sdate,edate}, TimeZone -> 0],
 #[[2]] == Missing["NotAvailable"] &];





kbos2 = N[Table[{(FromDate[i[[1]]]-FromDate[sdate])/3600, i[[2]]}, {i, kbos}]];
kbos3 = Mean /@ GatherBy[kbos2, First];
kbos4[x_] = Interpolation[kbos3, x]



kbos = Table[WeatherData["Boston", "Temperature", ToDate[i]],
 {i, FromDate[sdate], FromDate[edate], 3600}];




kbos2 = N[Table[{(FromDate[i[[1]]]-FromDate[sdate])/3600, i[[2]]}, {i, kbos}]];


kbos2 = DeleteDuplicates[
Table[{(FromDate[i[[1]]]-FromDate[sdate])/3600, i[[2]]}, {i, kbos}],
#1[[1]] == #2[[1]] &];

kbos3 = Union[kbos, SameTest -> (#1[[1]] == #2[[1]] &)];





