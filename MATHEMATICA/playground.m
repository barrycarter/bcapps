(* can mathematica find the most isolated of, say 2M points? *)

t = Table[RandomReal[1,3], {i, 1, 10^6}];

g = NearestNeighborGraph[t];

lens = Table[{i, Norm[i[[2]]-i[[1]]]}, {i, EdgeList[g]}];

lens2 = Sort[lens, #1[[2]] < #2[[2]] &];


Take[EdgeList[g], 10]

VertexIndex[g, t[[7]]]

AdjacencyList[g, t[[7]]]

Nearest[t][{0,0,0}]

(* TODO: canonize this *)

alertme := Run["xmessage -geometry 1024 mathematica done &"];

(* however, I actually have 200M+ stars, so... *)

t = Table[RandomReal[1,3], {i, 1, 5*10^8}]; alertme

g = NearestNeighborGraph[t]; alertme





(* Mercator stuff *)

(* below from bclib.pl, trying to find inverse *)

(* lat only, that's the hard one, first *)

slippy2lat[x_,y_,zoom_,px_,py_] =
 -90 + (360*ArcTan[Exp[Pi-2*Pi*((y+py/256)/2^zoom)]])/Pi

slippy2latrad[x_,y_,zoom_,px_,py_] = slippy2lat[x,y,zoom,px,py]/180*Pi

s = Solve[slippy2lat[x,y,zoom,px,py] == lat, py, Reals]

srad = Solve[slippy2latrad[x,y,zoom,px,py] == lat, py, Reals]

s2 = s[[1,1,2,1]]

FullSimplify[s2,{Element[{y,zoom},Integers],Element[lat,Reals]}]




