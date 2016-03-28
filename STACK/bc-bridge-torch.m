(*

 http://mathematica.stackexchange.com/questions/111255/toms-family-how-to-cross-the-bridge

people = {"t", "b", "f", "m", "g"};

times = {1, 3, 6, 8, 12};

Table[f[people[[i]]] = times[[i]], {i,1,Length[people]}]

states = Subsets[people];

<h>torch = flashlight</h>

(* TODO: except at last state, having 1 person go across doesnt work,
but it doesnt work anyway because he couldnt possibly have torch *)

trips[state_] := Module[{pairs, ret},
 pairs = Subsets[state,{2}];
 ret = Table[{{i,i[[1]]}, {i,i[[2]]}}, {i,pairs}];
 Return[ret];
]



