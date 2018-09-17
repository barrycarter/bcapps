(*

Using the TIF file (which loads amazingly fast)

*)

(* Import runs surprisingly fast *)

data = Reverse[
Import["/home/user/20180807/GMT_intermediate_coast_distance_01d.tif", "Data"]];

(*

Ran these once to find values defined after comment

flat = Flatten[data];

max = Max[flat];
min = Min[flat];

*)

{min, max} = {30255, 35463};

(* breaking it into 3*3 pieces, the whole thing won't digitize properly *)

Clear[color]
Table[color[i] = RandomReal[1,3], {i, min, max}];

colored = Map[color, data, {2}];

Dimensions[colored];

nw = Take[colored, {1, 18000/3}, {1, 36000/3}];

rnw = Graphics[Raster[nw], PlotRangePadding -> 0, ImagePadding -> 0];

(* doing these in "order" *)

chunk = Take[colored, {1, 6000}, {12001, 24000}];
rchunk = Graphics[Raster[nw], PlotRangePadding -> 0, ImagePadding -> 0];
Export["/tmp/3.png", rchunk, ImageSize -> {36000/3, 18000/3}];
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





