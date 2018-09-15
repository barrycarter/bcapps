(*

Using the TIF file (which loads amazingly fast)

*)

data = Import["/home/user/20180807/GMT_intermediate_coast_distance_01d.tif", 
 "Data"];

flat = Flatten[data];

max = Max[flat];
min = Min[flat];

Clear[color]
Table[color[i] = RandomReal[1,3], {i, min, max}];

colored = Map[color, data, {2}];

t0849 = Take[colored, {1, 4500}, {1, 9000}];



t1103 = Table[{i,j}, {i,1,10}, {j,1,10}]

Map[f, t1103, {2}]



