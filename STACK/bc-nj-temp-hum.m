(*

In shell:

From ../WEATHER/master-location-identifier-database-20130801.csv:

USA,US,United States,NJ,Mercer County,Trenton|Altura,Mercer County Airport,,USa KTTN,KTTN,TTN,,14792,TTN,m,KTTN,A,ICA12 ICA10 ICA09,TTN,A,FAA13 FAA12 FAA11 FAA10,,,,724095,,14792,,,40.27669111,-74.81346833,N,FAA13 FAA12 FAA11 FAA10,64.6,A,FAA13 FAA12 FAA11 FAA10,59,,,America/New_York,US-08628,,,,,ADJ/20120717,40,-74

In the isd-lite directory

\zcat */724095-14792-*.gz > temp.724095-14792.1

perl -pnle 's/\s+/,/g;s/^/{/;s/$/},/;' temp.724095-14792.1>temp.724095-14792.2

echo "all = {" > 724095-14792.m
\cat temp.724095-14792.2 >> 724095-14792.m
echo "};" >> 724095-14792.m

*)

(* Formulas we need; sources are imperfect *)

(* https://web.archive.org/web/20060617214924/http://www.srh.noaa.gov:80/bmx/tables/rh.html
*)

tdp2rh1[t_, dp_] = Min[((112-0.1*t+dp)/(112+0.9*t))^8,1]

(* http://icoads.noaa.gov/software/other/profs_short *)

tdp2rh2[t_, dp_] = Min[Exp[17.67*dp/(243.5+dp)]/Exp[17.67*t/(243.5+t)],1]

(* kludge for Mathematica 11 *)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


(* grabs data into "all" variable *)

<<"!bzcat /home/barrycarter/BCGIT/STACK/724095-14792.m.bz2";

(* filter it down to where we have both temp and dp and ignore null end; function is idempotent and can be run many times w/o harm *)

all = Select[all, !SameQ[#,Null] && #[[5]] > -9999 && #[[6]] > -9999 &];

(* get data from tuple *)

getTemp[tuple_] := tuple[[5]]/10.
getDP[tuple_] := tuple[[6]]/10.

(* using second formula because its "less ugly" *)

getRH[tuple_] := tdp2rh2[getTemp[tuple], getDP[tuple]];

(* temp/RH table *)

tempRH = Table[{getTemp[tuple], getRH[tuple]}, {tuple, all}];

tempRHModel = LinearModelFit[tempRH, x, x];

(* 0.63519 + 0.000632149 x *)

gather1 = Gather[tempRH, Round[#1[[1]]] == Round[#2[[1]]] &];

gatherTempRH = Sort[Table[{Mean[Transpose[i][[1]]], Mean[Transpose[i][[2]]]},
 {i, gather1}]]

ListPlot[gatherTempRH, ImageSize -> {800,600}]

Fit[tempRH,{1,x,Abs[x-23],Abs[x-1]},x]



gather2 = Gather[tempRH, Round[#1[[1]],.5] == Round[#2[[1]],.5] &];

gatherTempRH2 = Sort[Table[{Mean[Transpose[i][[1]]], Mean[Transpose[i][[2]]]},
 {i, gather2}]]



















(* gather by rounded Celsius temperature over 2 -- this is ugly but prevents small sets from clouding .... *)

t1725 = Table[{i[[5]]/10.,i[[6]]/10.},{i,all2}];

t1727 = Table[{i[[5]]/10., tdp2rh1[i[[5]]/10., i[[6]]/10.]},  {i,all2}];

0.638495 + 0.000530782 x

t1733 = Gather[all2, Round[#1[[5]]/10] == Round[#2[[5]]/10] &];

t1736 = Sort[Table[{Round[test[[1,5]]/10],Mean[Transpose[test][[6]]]/10.},
 {test, t1733}]];








LinearModelFit[t1727,x,x]

LinearModelFit[t1725,x,x]

-6.54885 + 0.948003 x

ListPlot[t1725]



229381 of 276507

2015-1973+1 = 43 years worth of data

tab = Table[{i[[5]]/10, i[[6]]/10, tdp2rh1[i[[5]]/10, i[[6]]/10]}, {i,all2}];

tab2 = Table[{i[[5]]/10, tdp2rh1[i[[5]]/10, i[[6]]/10]}, {i,all2}];

tab3 = Gather[tab2, #1[[1]] == #2[[1]] &];

tab4 = Table[{i[[1,1]], Mean[Transpose[i][[2]]]}, {i,tab3}];


{tab3[[5,1,1]],Mean[Transpose[tab3[[5]]][[2]]]}

(* junk/garbage *)

(* confirms results agree between two calculations *)

ContourPlot[tdp2rh1[t,dp]-tdp2rh2[t,dp],{t,-40,40},{dp,-40,40}, 
 ColorFunction -> Hue, Contours -> 64, PlotLegends -> True,
 ImageSize -> {800,600}]

ContourPlot[tdp2rh1[t,dp]-tdp2rh2[t,dp],{t,40,50},{dp,-40,50}, 
 ColorFunction -> Hue, Contours -> 64, PlotLegends -> True,
 ImageSize -> {800,600}]

