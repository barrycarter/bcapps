x = WeatherData["KTTN", "Temperature", {{1973,1,1},{1973,12,31}}]





(* going to isd-lite *)

USA,US,United States,NJ,Mercer County,Trenton|Altura,Mercer County Airport,,USa KTTN,KTTN,TTN,,14792,TTN,m,KTTN,A,ICA12 ICA10 ICA09,TTN,A,FAA13 FAA12 FAA11 FAA10,,,,724095,,14792,,,40.27669111,-74.81346833,N,FAA13 FAA12 FAA11 FAA10,64.6,A,FAA13 FAA12 FAA11 FAA10,59,,,America/New_York,US-08628,,,,,ADJ/20120717,40,-74

724095

\zcat */724095-14792-*.gz > temp.724095-14792.1

perl -pnle 's/\s+/,/g;s/^/{/;s/$/},/;' temp.724095-14792.1>temp.724095-14792.2

echo "all = {" > 724095-14792.m
\cat temp.724095-14792.2 >> 724095-14792.m
echo "};" >> 724095-14792.m

(* back to mathematica here *)

<<"!bzcat /home/barrycarter/BCGIT/STACK/724095-14792.m.bz2";

http://www.bragg.army.mil/www-wx/wxcalc.htm
http://www.srh.noaa.gov/bmx/tables/rh.html

http://www.weather.gov/media/epz/wxcalc/rhWetBulbFromTd.pdf

https://web.archive.org/web/20060617214924/http://www.srh.noaa.gov:80/bmx/tables/rh.html

(* temps must be in celsius, result is fractional *)

tdp2rh1[t_, dp_] = Min[((112-0.1*t+dp)/(112+0.9*t))^8,1]

tdp2rh2[t_, dp_] = Min[Exp[17.67*dp/(243.5+dp)]/Exp[17.67*t/(243.5+t)],1]

ContourPlot[tdp2rh1[t,dp]-tdp2rh2[t,dp],{t,-40,40},{dp,-40,40}, 
 ColorFunction -> Hue, Contours -> 64, PlotLegends -> True,
 ImageSize -> {800,600}]

ContourPlot[tdp2rh1[t,dp]-tdp2rh2[t,dp],{t,40,50},{dp,-40,50}, 
 ColorFunction -> Hue, Contours -> 64, PlotLegends -> True,
 ImageSize -> {800,600}]

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


(* filter it down to where we have both temp and dp *)

all2 = Select[all, !SameQ[#,Null] && #[[5]] > -9999 && #[[6]] > -9999 &];

229381 of 276507

2015-1973+1 = 43 years worth of data

tab = Table[{i[[5]]/10, i[[6]]/10, tdp2rh1[i[[5]]/10, i[[6]]/10]}, {i,all2}];

tab2 = Table[{i[[5]]/10, tdp2rh1[i[[5]]/10, i[[6]]/10]}, {i,all2}];

tab3 = Gather[tab2, #1[[1]] == #2[[1]] &];

tab4 = Table[{i[[1,1]], Mean[Transpose[i][[2]]]}, {i,tab3}];


{tab3[[5,1,1]],Mean[Transpose[tab3[[5]]][[2]]]}










