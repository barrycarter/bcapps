(*

Using the TIF file (which loads amazingly fast)

*)

(* Import runs surprisingly fast *)

data = Import["/home/user/20180807/GMT_intermediate_coast_distance_01d.tif", 
 "Data"];

(*

Ran these once to find values defined after comment

flat = Flatten[data];

max = Max[flat];
min = Min[flat];

*)

{min, max} = {30255, 35463};

(* this is testing orientation *)

t1103 = Downsample[data, 10];

hue[x_] = (x-min)/(max-min);

hued = Map[hue, t1103, {2}];

r = Graphics[Raster[hued]];





gfx = Graphics[Raster[Map[hue, t1103, {2}], ColorFunction -> Hue]];





Clear[color]
Table[color[i] = RandomReal[1,3], {i, min, max}];

colored = Map[color, data, {2}];

Dimensions[colored];

graf = Graphics[Raster[colored]];

Export["/tmp/supermap.png", graf, ImageSize -> {36000, 18000}];

t0849 = Take[colored, {1, 4500}, {1, 9000}];

Graphics[Raster[t0849]]





