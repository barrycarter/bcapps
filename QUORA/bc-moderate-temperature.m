(*

https://www.quora.com/Which-country-location-has-minimum-temperature-variation-throughout-the-year

https://www.quora.com/unanswered/Which-city-has-the-minimum-temperature-of-22-C-and-doesnt-go-much-below-it-and-has-a-maximum-temperature-of-27-C-and-doesnt-go-much-above-it-almost-throughout-the-year

https://www.quora.com/unanswered/Which-cities-have-the-greatest-variation-of-seasonal-temperatures

You would probably be happiest in these locations:

[[image16.gif]]

where High* is the 99th percentile of the high temperatures and Low* is the 1st percentile of low temperatures. In other words, the high and low temperatures remain within these ranges 99% of the time. Details follow.

It turns out that other people have considered this question before:

http://www.city-data.com/top2/c458.html
http://www.city-data.com/forum/weather/1161324-place-world-least-temperature-variation.html
http://www.weatherpages.com/variety/least.html
https://www.sciencedaily.com/releases/2014/03/140320173249.htm

but I found the question interesting and ended up doing some research on my own:

  - I visited ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ and downloaded the 2.9G file "ghcnd_all.tar.gz" which contains high and low temperature data (and more) for over 100,000 weather stations around the world, dating back as far as 1763 in some cases. Quoting http://link.springer.com/article/10.1023/A:1014923027396

"Daily meteorological observations have been made at the Brera astronomical observatory in Milan since 1763. Even if the data have always been collected at this observatory, the Milan series are far from being homogeneous as several changes were made to instruments, station location and observation methods."

  - I then limited this list to the 8479 stations that have continuous data through 2016 and going back at least 30 years to 1986. Some of these stations have high and low temperatures dating back to 1824. The Brera observatory unfortunately stopped making observations after 2008, and is not on this list.

  - I then used:

    - https://github.com/barrycarter/bcapps/blob/master/WEATHER/bc-parse-ghcnd.pl
    - https://github.com/barrycarter/bcapps/blob/master/WEATHER/bc-get-hilo.pl
    - https://github.com/barrycarter/bcapps/blob/master/QUORA/bc-moderate-temperature.sql

to create an SQLite3 database of extreme high and low temperatures, plus slightly less extreme highs and lows: for example, the 99th percentile of the highs (only 1% of days have high temperatures higher than this) and the 1st percentile of the lows (only 1% of days have low temperatures lower than this). You can see/query this database at: http://extremes.db.94y.info/

  - I first looked at locations with smallest difference between record high and record low temperatures: http://8276c2de574266eab81412fc23ac786b.extremes.db.94y.info/ (apologies for the location names, they come directly from GHCN and are kind of ugly):

[[image13.gif]]

Although these locations have smallish differences in record high and record low temperatures, the temperatures themselves are very warm. In other words, these locations are almost always warmer than room temperature, which is probably not what you're looking for.

If we accept that room temperature is 68F, it would be nice to find locations where the temperature always remains within 20 degrees of 68F. Unfortunately there are no such locations: http://6cdd23bae8e09f285bd8ec4ccef902e0.extremes.db.94y.info/

If we push to within 25 degrees, we do get a few results: http://a334acc8265c4a76852f5ee7bffecf2a.extremes.db.94y.info/

[[image14.gif]]

However, perhaps we're being too strict by looking at the absolute record highs and lows. Presumably, you're looking for places that are comfortable most of the time, but are OK with the temperature getting "too hot" or "too cold" a few days out of the year, since you can't have everything.

So now, let's look at the 99th percentile of high temperatures (it's cooler than this 99% of the time, or ~361+ days of the year) and the 1st percentile of low temperatures (it's warmer than this ~361+ days of the year): http://22d8937ad74179bcf75142f4862708ff.extremes.db.94y.info/

[[image15.gif]]

where the "*" indicates the 99th or 1st percentile.

Once again, the results are a bit on the warm side. Restricting to 68F plus or minus 20F, we have: http://edb0759f49c0816c8c0b70b92f2f5d84.extremes.db.94y.info/

[[image16.gif]]

which is what I give as the answer.

Several notes and caveats:

  - You may find 68F plus/minus 20F a bad choice of range. There might be better choices for greater comfort.

  - Most people are out and about during the day, and don't care as much about the temperature at night. It would be interesting to do an analysis that includes only daytime temperatures. If anyone wants to do this as a project, let me know.

Possible TODOs:

  - When giving a list of results, the database could also show a Google map of the locations listed.

  - The cumulative distribution function (CDF) of both the high and low temperatures is nearly a straight line (which is somewhat surprising, although I'm not the first person to observe this: http://www.sjsu.edu/faculty/watkins/normalvariation.htm ) but looks more like the tangent function on a balanced interval around 0 (but smaller than pi/2 obviously). There may or may not be something in this, if anyone is interested in researching.

Whining:

  - I originally tried doing this with Mathematica's WeatherData[] function, but it turns out that function really really sucks.


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





