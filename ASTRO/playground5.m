(* simple astronomy to solve simple problems *)

(* magic formula for time up either side of ra? *)

ArcCos[Tan[dec]*Tan[lat]]

N[ArcCos[-Tan[0*Degree]*Tan[35*Degree]]]/2/Pi*24

(* set time, compared to objects culmination *)

decLat2Set[dec_,lat_] = ArcCos[-Tan[dec]*Tan[lat]];

Plot[decLat2Set[dec,35*Degree],{dec,-55*Degree,55*Degree}]

f1147[dec_,lat_] = D[decLat2Set[dec,lat],lat]

f1147[23*Degree,35*Degree]

decLat2SetDeg[dec_,lat_] = ArcCos[-Tan[dec*Degree]*Tan[lat*Degree]]/Pi*12

f1151[dec_,lat_] = D[decLat2SetDeg[dec,lat],lat]

(* 69.0412 miles per degree *)

(* per mile north *)

N[f1151[23,35]*60*60]/69.0412

Plot[f1151[23,lat]*60*60/69.0412,{lat,0,90}]

Plot[2*ArcCos[-Tan[dec*Degree]*Tan[35*Degree]]/2/Pi*24,{dec,-90,90}]

raDec2AzEl[ra_,dec_,lat_,lon_,d_] = 

{ArcTan[Cos[lat]*Sin[dec] + Cos[dec]*Sin[lat]*
    Sin[lon + ((11366224765515 + 401095163740318*d)*Pi)/200000000000000 - ra], 
  -(Cos[dec]*Cos[lon + ((11366224765515 + 401095163740318*d)*Pi)/
       200000000000000 - ra])], 
 ArcTan[Sqrt[Cos[dec]^2*Cos[lon + ((11366224765515 + 401095163740318*d)*Pi)/
         200000000000000 - ra]^2 + 
    (Cos[lat]*Sin[dec] + Cos[dec]*Sin[lat]*
       Sin[lon + ((11366224765515 + 401095163740318*d)*Pi)/200000000000000 - 
         ra])^2], Sin[dec]*Sin[lat] - Cos[dec]*Cos[lat]*
    Sin[lon + ((11366224765515 + 401095163740318*d)*Pi)/200000000000000 - ra]]}

(* testing above *)

N[raDec2AzEl[0,0,0,0,0],20]/Degree

N[raDec2AzEl[(22+57/60+18.5/3600)*15*Degree,
 (-7-33/60-29.1/3600)*Degree,0,0,0],20]/Degree

abqlat = (35+7/60+12/3600)*Degree;
abqlon = (-106-37/60-12/3600)*Degree;

(* at 10:49:22 6 Dec 2014 MST *)

curtime = 1417888162/86400;

(* using ra of date *)

sunra = (16+52/60+51/3600)*15*Degree;
sundec = (-22-32/60-33/3600)*Degree;

N[raDec2AzEl[sunra,sundec,abqlat,abqlon,curtime],20]/Degree

(* above is {161.75050713266716177, 30.111178395836822086} *)

(* or 1.82", 45m, 161 degrees so still not quite *)

(* and 30 deg 6m 20.24s so not quite but close *)

(* time of set *)

Solve[raDec2AzEl[ra,dec,lat,lon,d][[2]]==0,d]

(* angle between position on Earth and distant star *)

(* position on non-elliptical earth, h in siderial radians *)

temp1119 = {er Cos[lat] Cos[lon+h], er Cos[lat] Sin[lon+h], er Sin[lat]}

(* star position, sd = distance *)

temp1120 = {sd Cos[dec] Cos[ra], sd Cos[dec] Sin[ra], sd Sin[dec]}

temp1119.temp1120/Norm[temp1119]/Norm[temp1120]

(* below is cosine between nadir and star *)

temp1123 = Cos[dec] Cos[lat] Cos[h + lon - ra] + Sin[dec] Sin[lat]

temp1124 = Solve[temp1123==0,h]







(* I dislike Mathematica's spherical conventions so.. *)

sph2xyz[{th_,ph_,r_}] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]}
xyz2sph[{x_,y_,z_}] = {ArcTan[x,y], ArcTan[Sqrt[x^2+y^2],z], Norm[{x,y,z}]}

(* ra/dec in radians to xyz *)

f1034[ra_,dec_] = 

(* convert ra/dec in radians to xyz,
 flip ra so we have view at equator at 0h siderial time,
 rotate around z for actual siderial time h,
 rotate around y for latitude (90 degrees minus latitude),
 then back to spherical and simplify...
 *)

Simplify[xyz2sph[
 rotationMatrix[y,Pi/2-lat].rotationMatrix[z,h].sph2xyz[{-ra,dec,1}]
] /. ArcTan[x_,y_] -> ArcTan[y/x]]

temp1023 = Simplify[xyz2sph2[
 rotationMatrix[y,Pi/2-lat].rotationMatrix[z,h].sph2xyz[{-ra,dec,1}]
], {Element[ra,Reals], Element[dec,Reals], 
Element[lat,Reals], Element[h, Reals]}] /. (h-ra) -> ha;

Plot[temp1023[[1]] - ha /. 
 {lat -> 40*Degree, dec -> 22*Degree},
 {ha,Pi/2,3*Pi/2}]

Plot[Tan[temp1023[[1]]] /.
 {lat -> 40*Degree, dec -> 22*Degree},
 {ha,0,2*Pi}
]

temp1023[[1]] /. {ha -> ra-gmst[d]+lon} // InputForm

azimuth[ra_,dec_,lat_,lon_,d_] = 
ArcTan[(Cos[dec]*Sin[lon - ((-4394688633775234485 + 401095163740318*d)*Pi)/
      200000000000000 + ra])/(-(Cos[lat]*Sin[dec]) + 
   Cos[dec]*Cos[lon - ((-4394688633775234485 + 401095163740318*d)*Pi)/
       200000000000000 + ra]*Sin[lat])]

(* testing formula above *)

azimuth[0,0,0,0,0]



Simplify[xyz2sph2[
 rotationMatrix[y,Pi/2-lat].rotationMatrix[z,h].sph2xyz[{-ra,dec,1}],
{Element[ra, Reals], Element[dec, Reals]}]] /. h-ra -> ha

(* using "pure" formula, but taking out constants *)

ra-gmst[d]+lon


























