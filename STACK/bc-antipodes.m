(*

Better answer to
https://earthscience.stackexchange.com/questions/14132/how-much-of-earths-land-area-has-antipodal-land-area
using coastal data?

*)

coast0 = ReadList[
 "!bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2", {Number,
Number, Number}];

coast = Partition[coast0, 9000];
anticoast = Reverse[Map[RotateRight[#, 4500] &, coast]];

minicoast = Map[#[[;;;;10]] &, coast, {1}][[;;;;10]];
minianticoast = Reverse[Map[RotateRight[#, 450] &, minicoast]];

t2021 = Table[{minicoast[[i,j]], 
       2*Sign[minicoast[[i,j,3]]] + Sign[minianticoast[[i,j,3]]]},
 {i, 1, 450}, {j, 1, 900}];

t2022 = Partition[Flatten[t2021], 4];

f[3] = {0, 0, 1};
f[1] = {0, 1, 0};
f[-1] = {1, 1, 0};
f[-3] = {1, 0, 0};

t2023 = Map[f,Transpose[t2022][[4]]];
t2024 = Reverse[Partition[t2023, 900]];
Graphics[Raster[t2024]];


t2042 = Table[{coast[[i,j]], 
       2*Sign[coast[[i,j,3]]] + Sign[anticoast[[i,j,3]]]},
 {i, 1, 4500}, {j, 1, 9000}];

t2043 = Partition[Flatten[t2042], 4];

f[3] = {0, 0, 1};
f[1] = {0, 1, 0};
f[-1] = {1, 1, 0};
f[-3] = {1, 0, 0};

t2044 = Map[f,Transpose[t2043][[4]]];
t2045 = Reverse[Partition[t2044, 9000]];
Graphics[Raster[t2045]];










t1948 = Reverse[Map[RotateRight[#, 4500] &, coast]];

(* Dimensions[coast] and Dimensions[t1948] *) are now {4500, 9000, 3}

t1950 := Module[{r, c},
 r = RandomInteger[{1,4500}];
 c = RandomInteger[{1,9000}];
 Return[{coast[[r,c]], t1948[[r,c]]}];
];

t1951[x_] := {x, Apply[antipode, Take[x[[1]],2]] == Take[x[[2]], 2]};

t1951[x_] := {x, 
 Abs[Apply[antipode, Take[x[[1]],2]] - Take[x[[2]], 2]] < 10^-6};

t1957 = Table[t1951[t1950], {i, 1, 10^6}];

Select[t1957, #[[2]] == False &]

empty list so we are good

2*Sign[1] + Sign[-1]

the function above gives:

3 for both positive (water vs water)
1 for first positive and second negative (water vs land)
-1 for first negative and second positive (land vs water)
-3 for both negative (land vs land)

t2010 = Table[2*Sign[coast[[i,j,3]]] + Sign[anticoast[[i,j,3]]], 
 {i, 1, 4500}, {j, 1, 9000}];

f[3] = {0,0,1}
f[1] = {0,1,0}
f[-1] = {1,1,0}
f[-3] == {1,0,0}

t2014 = Map[f, t2010, {2}];










(* trying to find position directly based on symmetry *)

RotateRight[coast[[1]], 4500];

t1517 = coast0[[;;;;100]];



(* the antipode, determined in a way thats consistent with coast0 [ie,
longitude between -180 and 180 and latitude between -90 and 90] *)

antipode[lon_, lat_] = {If[lon<0, lon+180, lon-180], -lat};





