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




