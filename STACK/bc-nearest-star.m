(*

https://astronomy.stackexchange.com/questions/27605/of-the-stars-in-the-gaia-hipparchos-catalogs-which-one-is-the-most-isolated

Header is in data[[1]]

*)

data = Import["!zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "CSV"];

data[[1]]

headids = Table[{i, data[[1,i]]}, {i,1,Length[data[[1]]]}]

(* we intentionally skip the header element below, and take only the "interesting" fields: hip, x, y, z *)

data2 = Table[Flatten[{i[[2]], Take[i, {18,20}]}], {i,Drop[data, 1]}];

starxyz = Table[Take[i, {2,4}], {i, data2}];

nearfunc = Nearest[starxyz -> {"Index", "Distance"}]

dists = Sort[Table[Flatten[{i, nearfunc[starxyz[[i]], 2][[2]]}],  
 {i, 1, Length[starxyz]}], #1[[3]] < #2[[3]] &];

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









