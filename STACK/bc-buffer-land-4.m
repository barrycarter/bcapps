(*

Using the TIF file (which loads amazingly fast)

in real file, -2513.32 is lowest, 2694.96 is max

first suggests 32768 == 0, so does last

TODO: whine 01d vs old

TODO: all complaints from others

TODO: color scheme changes are too small

*)

<formulas>

landfunc = ColorData["SandyTerrain"];
waterfunc = ColorData["DeepSeaColors"];

Clear[distance2Color];
distance2Color[32768] = {0, 0, 0};

distance2Color[d_] := distance2Color[d] = 
 N[Apply[List, If[d>32768, waterfunc[1-Floor[(d-32768)/1600,1/16]],
 landfunc[1-Floor[-(d-32768)/1600,1/16]]]]];

</formulas>

(* Import runs surprisingly fast *)

data0 = Import["/home/user/20180807/GMT_intermediate_coast_distance_01d.tif",
"Data"];

(* even though I got the raster right, what does this data tell me? *)

lat[i_] = N[90+1/200-i/100]

lon[j_] = N[-180-1/200+j/100]

data = Flatten[Table[{lon[j], lat[i], data0[[i,j]]-32768}, 
 {i, 1, 18000}, {j, 1, 36000}], 1];

(*
data = Flatten[Table[{{lon[j], lat[i]}, data0[[i,j]]-32768}, 
 {i, 1, 18000}, {j, 1, 36000}], 1];
*)

gather = Gather[data, #1[[3]] == #2[[3]] &];

dataTest = Flatten[Table[{lon[j], lat[i], data0[[i,j]]-32768}, 
 {i, 1, 18000, 100}, {j, 1, 36000, 100}], 1];


dataTest = Table[{{lon[j], lat[i]}, data0[[i,j]]-32768}, 
 {i, 1, 18000, 100}, {j, 1, 36000, 100}];

dataTestF = Interpolation[Flatten[dataTest,1]]

ContourPlot[dataTestF[lon, lat], {lon, -180, 180}, {lat, -90, 90}]




data0[[2,2]]-32768 == 1

data0[[-2,2]]-32768 == 1

data0[[2,-2]] - 32768 == 1

data0[[-2, -2]] - 32768 == -1274 (deeply inland, so antarctica)

(* get area straight from data0 *)

using same as dist2coast.signed.txt.bz2

-179.98 89.98 to 


TODO: leftmost pixel in each row is always 32769 and thus 1?


data4Area = Table[{lon[i], lat[j], data0[[i,j]]-32768}, 
 {i, 1, 18000}, {j, 1, 36000}];

ABOVE IS WRONG!!!

data = Reverse[data0];

(* mathematica won't rasterize 36000x18000 so cut into chunks *)

dataChunk = data[[12001;;18000, 24001;;36000]];

image = Graphics[
 Raster[Map[distance2Color, dataChunk, {2}]],
 ImagePadding -> 0, PlotRangePadding -> 0, Frame -> False
];

Export["/var/tmp/output.png", image, ImageSize -> {12000, 6000}]




(*

Ran these once to find values defined after comment

flat = Flatten[data];

max = Max[flat];
min = Min[flat];

*)

{min, max} = {30255, 35463};

minidata = data[[;;;;100, ;;;;100]];

(* Same colors as bc-buffer-land-2.m *)

(* clear function and the border is black; with 1km values cahcing may
actually be useful *)

(* in addition to testing, this sets the value for almost all d *)

t1344 = Graphics[Raster[
 Partition[Table[distance2Color[30255+i], {i,0,5199}], 100]
 ]]

(* test on minidata 

temp1405 = Graphics[
 Raster[Map[distance2Color, minidata, {2}]],
 ImagePadding -> 0, PlotRangePadding -> 0, Frame -> False
];

Export["/tmp/output.png", temp1405, ImageSize -> {360, 180}]

*)

(* the real thing *)

image = Graphics[
 Raster[Map[distance2Color, data, {2}]],
 ImagePadding -> 0, PlotRangePadding -> 0, Frame -> False
];

Export["/var/tmp/output.png", image, ImageSize -> {36000, 18000}]







Graphics[Raster[temp1405]]
showit

TODO: leftmost pixels are all 32768 or 32769














(* breaking it into 3*3 pieces, the whole thing won't digitize properly *)

Clear[color]
Table[color[i] = RandomReal[1,3], {i, min, max}];

colored = Map[color, data, {2}];

Dimensions[colored]

(* doing these in "order" *)

chunk = Take[colored, {12001, 18000}, {24001, 36000}];
rchunk = Graphics[Raster[chunk], PlotRangePadding -> 0, ImagePadding -> 0];
Export["/tmp/9.png", rchunk, ImageSize -> {12000, 6000}];
Run["xmessage all finished sir &"]






(* this is testing orientation *)

t1103 = Reverse[Downsample[data, 10]];

hue[x_] = N[(x-min)/(max-min)];

hue[x_] = If[Abs[x-32768] < 10, 0, 1];

hued = Map[hue, t1103, {2}];

r = Graphics[Raster[hued]]
showit

gfx = Graphics[Raster[Map[hue, t1103, {2}], ColorFunction -> Hue]];

(* end orientation testing *)


Clear[color]
Table[color[i] = RandomReal[1,3], {i, min, max}];

colored = Map[color, data, {2}];

Dimensions[colored];

graf = Graphics[Raster[colored]];

Export["/tmp/supermap.png", graf, ImageSize -> {36000, 18000}];

t0849 = Take[colored, {1, 4500}, {1, 9000}];

Graphics[Raster[t0849]]





