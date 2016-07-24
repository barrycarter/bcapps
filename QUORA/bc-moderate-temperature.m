(*

https://www.quora.com/Which-country-location-has-minimum-temperature-variation-throughout-the-year

https://www.quora.com/unanswered/Which-city-has-the-minimum-temperature-of-22-C-and-doesnt-go-much-below-it-and-has-a-maximum-temperature-of-27-C-and-doesnt-go-much-above-it-almost-throughout-the-year

https://www.quora.com/unanswered/Which-cities-have-the-greatest-variation-of-seasonal-temperatures

TODO: answer goes here!

It turns out that other people have considered this question before:

http://www.city-data.com/top2/c458.html
http://www.city-data.com/forum/weather/1161324-place-world-least-temperature-variation.html
http://www.weatherpages.com/variety/least.html
https://www.sciencedaily.com/releases/2014/03/140320173249.htm

but I found the question interesting and ended up doing some research on my own:

  - I visited ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ and downloaded the 2.9G file "ghcnd_all.tar.gz" which contains high and low temperature data (and more) for over 100,000 weather stations around the world, dating back as far as 1763 in some cases. Quoting http://link.springer.com/article/10.1023/A:1014923027396

"Daily meteorological observations have been made at the Brera astronomical observatory in Milan since 1763. Even if the data have always been collected at this observatory, the Milan series are far from being homogeneous as several changes were made to instruments, station location and observation methods."

  - I then limited this list to the 8479 stations that have continuous data through 2016 and going back at least 30 years to 1986. Some of these stations have high and low temperatures dating back to 1824. The Brera observatory unfortunately stopped making observations after 2008, and is not on this list.

  - 

(ended up doing this w/o Mathematica, but text of answer is here)

http://76e16f70164ddee1ab3ceb023a57002a.extremes.db.94y.info/

http://bd88be6b5d7e37a69bcbd03b63cde9d1.extremes.db.94y.info/

http://d0374d197fed95ba52d81a66b178c057.extremes.db.94y.info/

http://ede67c03c7523db7ddeb87524545940d.extremes.db.94y.info/

http://24cb18ed989d2239ef47fff5b4b354c5.extremes.db.94y.info/

http://75071eb30a826dcaec4143805e0daaaf.extremes.db.94y.info/

TODO: use select on above since it incorps state correctly (actually, changing view)

http://727007a49c37b740835bfc56b47c9822.extremes.db.94y.info/

http://930cf0e0bd2b5b3361805733a9a0d92b.extremes.db.94y.info/

TODO: apologize for crap names

TODO: include google maps of all locations in "final" answer

http://08e6563cc414c66bc0dbe03dd12fea04.extremes.db.94y.info/

http://6ed6837753adea5adf3cc884bb99e7ee.extremes.db.94y.info/

http://59ee3ff761e18a624f72047559561d16.extremes.db.94y.info/

TODO: these URLs

TODO: night and day temps (ie, temps while sun is up only?)

TODO: apologize for odd name casing

TODO: mention Perl script

TODO: mention data source

TODO: mention procedure

TODO: summarize answer at top



*)

(* starting here, trying to use "pure" Mathematica *)

cities = WeatherData[];

extrema[stat_] := Module[{piles, max, min, start, end},

 (* this does nothing but helps me keep track *)
 Print[stat];

 (* these are the percentiles we will print *)
 piles = {0, .01, .05, .5, .95, .99, 1};

 start = {1986,7,1};
 end = {2016,6,30};

 max = WeatherData[stat, "MaxTemperature", {start, end, "Day"}];
 min = WeatherData[stat, "MinTemperature", {start, end, "Day"}];

 (* ignore those with too little data *)
 If[Length[max]<5000, Return[]];
 If[Length[min]<5000, Return[]];

 Return[{stat,
 Table[Quantile[Select[Transpose[max][[2]], NumericQ], i], {i,piles}],
 Table[Quantile[Select[Transpose[min][[2]], NumericQ], i], {i,piles}],
 Length[max], Length[min],
 WeatherData[stat, "Latitude"],
 WeatherData[stat, "Longitude"],
 WeatherData[stat, "Elevation"]
 }]
]

extremes = Table[extrema[i], {i,cities}];
extremes2 = DeleteCases[extremes, Null];

(* converts it into a format thats easier for sqlite3 to parse, see oneliners.sh for more *)

Table[Flatten[i], {i,extremes2}] >> /home/barrycarter/20160712/4sqlite.txt

max0 = SortBy[Table[{i[[1]], Round[i[[2,-1]]*1.8+32,0.1],
 Round[i[[3,1]]*1.8+32, 0.1], Round[(i[[2,-1]]-i[[3,1]])*1.8, 0.1],
 Take[i,-3]}, {i,extremes2}], #[[4]] &];

max1 = SortBy[Table[{i[[1]], Round[i[[2,-2]]*1.8+32,0.1],
 Round[i[[3,2]]*1.8+32, 0.1], Round[(i[[2,-2]]-i[[3,2]])*1.8, 0.1],
 Take[i,-3]}, {i,extremes2}], #[[4]] &];


https://maps.googleapis.com/maps/api/staticmap?center=1.36,103.91&size=640x400
https://maps.googleapis.com/maps/api/staticmap?center=-10.453,105.688&zoom=10

https://maps.googleapis.com/maps/api/staticmap?center=1.36,103.91&size=640x400&zoom=10







sortext1 = SortBy[extremes2, (#[[2,-1]]-#[[3,1]]) &];




(* more Mathematica-y way ends here *)

(* ZYYY = last station *)

cities = WeatherData[];
start = {1986,7,1};
end = {2016,6,30};

(* this assumes data has been saved to file as below *)

printstuff[x_] := Module[{max, min, piles, maxte, minte, maxt, mint},

 (* these are the percentiles we will print *)
 piles = {0, .01, .05, .5, .95, .99, 1};
 
 (* get the max data *)
 max = Get["/home/barrycarter/20160702/WEATHER/"<>x<>".max"];
 min = Get["/home/barrycarter/20160702/WEATHER/"<>x<>".min"];

 maxte = Select[Transpose[max][[2]], NumericQ];
 minte = Select[Transpose[min][[2]], NumericQ];

 maxt = Table[Quantile[maxte, i], {i,piles}];
 mint = Table[Quantile[minte, i], {i,piles}];

 Print[{x, maxt, mint, Length[maxte], Length[minte]}];
]

(*

The above is really ugly, and I had to make the following corrections
before SQLITE3-ifying it:

fgrep -v Quantile math.out | perl -pnle 's/\r//g; s/[{}]//g;s/\s+/ /g' | 
 egrep -v '^ *$' > math2.out

: use emacs to edit math2.out

CREATE TABLE temperatures (
 station TEXT,
 max0 DOUBLE, max1 DOUBLE, max5 DOUBLE, max50 DOUBLE,
 max95 DOUBLE, max99 DOUBLE, max100 DOUBLE,
 min0 DOUBLE, min1 DOUBLE, min5 DOUBLE, min50 DOUBLE,
 min95 DOUBLE, min99 DOUBLE, min100 DOUBLE,
 maxdays INT, mindays INT,
 latitude DOUBLE, longitude DOUBLE, elevation DOUBLE
);

; after import...

DELETE FROM temps WHERE maxdays < 5000 OR mindays < 5000;

6280 remain

TODO: sunlight data only?

TODO: use isd-lite instead of mathematica?

TODO: convert other data into "mathematica" form?

TODO: add lookup table for WMO stations?

*)

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

temp2042 = WeatherData["Albuquerque", "Temperature", { {1986,7,1}, {2016,6,30}}];

temp2044 = WeatherData["Boston", "Temperature", { {1986,7,1}, {2016,6,30}}];

(* takes about 25s to get 30y of data per location *)

temp2049 = WeatherData["Boston", "Temperature",  {{2015,7,1}, {2016,6,30}, "Hour"}];


temp2049 = WeatherData["Boston", "Temperature",  {{2015,7,1}, {2016,6,30}, "Hour"}];

WeatherData["Boston", "MaxTemperature",  {{2015,7,1}, {2016,6,30}, "Day"}]

WeatherData["Boston", {"MaxTemperature", "MinTemperature"},   {{2015,7,1}, {2016,6,30}, "Day"}]

max[stat_] := Transpose[WeatherData[stat, "MaxTemperature",  {{1986,7,1}, {2016,6,30}, "Day"}]][[2]];

temp2309 =  WeatherData["KABQ", "MaxTemperature", {{1986,7,1}, {2016,6,30}, "Day"}];

temp2315 = 
GatherBy[temp2309, Take[#[[1]],-2] &]

maxfunc[stat_] := maxfunc[stat] =  superfour[Select[Transpose[WeatherData[stat, "MaxTemperature",
 {{1986,7,1}, {2016,6,30}, "Day"}]], NumberQ[#] &][[2]],1];

minfunc[stat_] := minfunc[stat] =  superfour[Transpose[WeatherData[stat, "MinTemperature",
 {{1986,7,1}, {2016,6,30}, "Day"}]][[2]],1];

(* good stuff starts here *)

cities = WeatherData[];

max[stat_] := Transpose[WeatherData[stat, "MaxTemperature",  {{1986,7,1}, {2016,6,30}, "Day"}]][[2]];

min[stat_] := Transpose[WeatherData[stat, "MinTemperature",  {{1986,7,1}, {2016,6,30}, "Day"}]][[2]];

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





