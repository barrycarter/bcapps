(*

different and easier approach to solve 

https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)

*)

(* head just for testing:

bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2 | head -n 500 >
 /tmp/test.m

*)

<functions>

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

earthRadius = Entity["Planet", "Earth"]["Radius"]/Quantity[1,"km"];

</functions>

t1256 = ReadList["/tmp/test.m", {Number, Number, Number}];

t1257 = Timing[ReadList[
"!bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2", 
{Number, Number, Number}]];

(* about 34.65 seconds *)

t1258 = t1257[[2]];

ListPlot3D[t1258] (* times out *)

4500 points per line of longitude? (yes)

t1705 = Interpolation[t1258];

ContourPlot[t1705[lon,lat], {lon, -180, 180}, {lat, -90, 90}]

t1709 = ContourPlot[t1705[lon,lat], {lon, -180, 180}, {lat, -90, 90},
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64,  
 PlotLegends -> True, ImageSize -> {8192, 4096}]

.04 longitude times .04 latitude (= fixed)

area = (4/100/360*earthRadius*2*Pi)^2

t1717 = Table[{area*Cos[i[[2]]*Degree], i[[3]]}, {i, t1258}];

t1722 = Gather[t1717, #1[[2]] == #2[[2]] &];












