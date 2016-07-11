(*

https://www.quora.com/Which-country-location-has-minimum-temperature-variation-throughout-the-year

https://www.quora.com/unanswered/Which-city-has-the-minimum-temperature-of-22-C-and-doesnt-go-much-below-it-and-has-a-maximum-temperature-of-27-C-and-doesnt-go-much-above-it-almost-throughout-the-year

*)

(* ZYYY = last station *)

cities = WeatherData[];
start = {1986,7,1};
end = {2016,6,30};

(* this assumes data has been saved to file as below *)

printstuff[x_] := Module[{max, f, g, temps},

 (* TODO: this assumes we have equal data for each day, otherwise skew *)

 (* get the max data *)
 max = Get["/home/barrycarter/20160702/WEATHER/"<>x<>".max"];

 (* TODO: selecting numeric here can mask bad data *)

 temps = Select[Sort[Transpose[max][[2]]], NumericQ];

 (* TODO: temporary for testing *)
 Return[temps];

 f[y_] = Fit[temps, {1,y}, y];

 (* TODO: just testing "linear" theory for now *)
 g[y_] = Interpolation[temps,y];

 Plot[{f[y],g[y]}, {y,1,Length[temps]}]

]

test0813 = printstuff["KBOS"];

test0856 = test0813-Mean[test0813];

test0904[x_] = Interpolation[test0856,x]

test0905[x_] = 20*Tan[x/Length[test0856]*Pi/1.8-Pi/1.8/2]^1

Plot[{test0904[x], test0905[x]}, {x,1,Length[test0856]}]
showit



Quantile[test0856,.99]/Quantile[test0856,.6]

5.77936

thats 49% vs 10%





temp0724[x_] = Fit[Sort[temp0618], {1,x}, x]

temp0723[x_] := Sort[temp0618][[Round[x]]]

Plot[{temp0723[x], temp0724[x]}, {x,1,366}]

Plot[{temp0723[x]-temp0724[x]}, {x,1,366}]


temp1729 = Get["/home/barrycarter/20160702/WEATHER/KABQ.max"];

temp1731 = GatherBy[temp1729, Take[#[[1]],-2] &];

temp0625 = SortBy[temp1731, #[[1,1,2]]*50 + #[[1,1,3]] &]

temp0618 = Table[Mean[Transpose[i][[2]]], {i, temp0625}]

temp0629[x_] := temp0618[[Round[x]]]

temp0627[x_] = superfour[temp0618,2][x];

Plot[{temp0627[x], temp0629[x]},{x,0.5,366.5}]

(* TODO: test that 366 elements, and at least n years of data for each *)

Mean[Transpose[temp1731[[5]]][[2]]]

(* get the data and store it to file *)

data[stat_] := Module[{str,dat},
 dat = WeatherData[stat, "MaxTemperature", {start, end, "Day"}];
 str = "/home/barrycarter/20160702/WEATHER/"<>stat<>".max";
 Put[dat,str];
];

data2[stat_] := Module[{str,dat},
 dat = WeatherData[stat, "MinTemperature", {start, end, "Day"}];
 str = "/home/barrycarter/20160702/WEATHER/"<>stat<>".min";
 Put[dat,str];
];

Table[{Print[i], data2[i]}, {i,cities}];

(* had to restart this, CWRM is first corrupt *)

temp1 = Take[cities, {Position[cities,"CWRM"][[1,1]],-1}];


(* this just forces evaluation *)

Table[{Print[i], data[i]}, {i,temp1}];

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





