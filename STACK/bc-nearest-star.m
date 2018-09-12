(*

https://astronomy.stackexchange.com/questions/27605/of-the-stars-in-the-gaia-hipparchos-catalogs-which-one-is-the-most-isolated

Header is in data[[1]]

<answer>

TODO: THE ANSWER

119615 total, 109399 with accurate xyz coords

107741 with HIP numbers (possibly -1 for empty)

91808 have HD

8800 have hr

young star = 300K LY

TODO: convert pc to ly

</answer>

*)

headids = Table[{i, data[[1,i]]}, {i,1,Length[data[[1]]]}]

data = Import["!zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "CSV"];

data2 = Select[data, #[[10]] < 100000 &];

name[i_] := If[NumericQ[i[[2]]], "HIP"<>ToString[i[[2]]], 
              If[NumericQ[i[[3]]], "HD"<>ToString[i[[3]]],
                If[NumericQ[i[[4]]], "HR"<>ToString[i[[4]]],
                  i[[5]]
            ]]];

t1831 = Table[{i[[1]], name[i]}, {i, data2}];

Select[t1831, #[[2]] == "test" &]



Length[DeleteDuplicates[Transpose[data2][[1]]]]

(not all stars have a HIP, rats)

Length[DeleteDuplicates[Transpose[data2][[2]]]]

Length[DeleteDuplicates[Transpose[data2][[3]]]]

Length[DeleteDuplicates[Transpose[data2][[4]]]]

Short[Transpose[data2][[2]], 10]

Short[Transpose[data2][[4]], 10]

starxyz = Table[Take[i, {18,20}], {i, data2}];

nearfunc = Nearest[starxyz -> {"Index", "Distance"}]

dists = Sort[Table[Flatten[{i, nearfunc[starxyz[[i]], 2][[2]]}],  
 {i, 1, Length[starxyz]}], #1[[3]] < #2[[3]] &];

dupes = Select[Tally[starxyz], #[[2]] > 1 &];








data[[1]]


(* we intentionally skip the header element below, and take only the "interesting" fields: hip, x, y, z *)

data2 = Table[Flatten[{i[[2]], Take[i, {18,20}]}], {i,Drop[data, 1]}];

starxyz = Table[Take[i, {2,4}], {i, data2}];

nearfunc[starxyz[[5]], 2][[2]]





(* dists = Table[{i, Norm[nearfunc[starxyz[[i]], 2][[2]] - starxyz[[i]]]}, 
 {i, 2, Length[starxyz]}];

*)

dists2 = Sort[dists, #1[[2]] < #2[[2]] &];

Out[35]= {58336, 8528.57}

In[42]:= starxyz[[58336]]                                                       

Out[42]= {-5241.98, 1.3163, 99862.5}

In[48]:= Take[data[[58337]],{18,20}]                                            

Out[48]= {-5241.98, 1.3163, 99862.5}









