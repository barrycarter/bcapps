(*

Using the TIF file (which loads amazingly fast)

in real file, -2513.32 is lowest, 2694.96 is max

first suggests 32768 == 0, so does last

TODO: whine 01d vs old

TODO: all complaints from others

TODO: color scheme changes are too small

*)

(* Import runs surprisingly fast, I should NOT reverse here, but its easier *)

data =
Reverse[Import["/home/user/20180807/GMT_intermediate_coast_distance_01d.tif",
"Data"]];

(*

Ran these once to find values defined after comment

flat = Flatten[data];

max = Max[flat];
min = Min[flat];

*)

{min, max} = {30255, 35463};

minidata = data[[;;;;100, ;;;;100]];

(* Same colors as bc-buffer-land-2.m *)

landfunc = ColorData["SandyTerrain"];
waterfunc = ColorData["DeepSeaColors"];

(* clear function and the border is black; with 1km values cahcing may
actually be useful *)

Clear[distance2Color];
distance2Color[32768] = {0, 0, 0};

distance2Color[d_] := distance2Color[d] = 
 N[Apply[List, If[d>32768, waterfunc[1-Floor[(d-32768)/1600,1/16]],
 landfunc[1-Floor[-(d-32768)/1600,1/16]]]]];

(* in addition to testing, this sets the value for almost all d *)

t1344 = Graphics[Raster[
 Partition[Table[distance2Color[30255+i], {i,0,5199}], 100]
 ]]

(* test on minidata *)

temp1405 = Map[distance2Color, minidata, {2}];



Graphics[Raster[temp1405]]
showit
















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





