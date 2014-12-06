(* simple astronomy to solve simple problems *)

(* I dislike Mathematica's spherical conventions so.. *)

sph2xyz[{th_,ph_,r_}] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]}
xyz2sph[{x_,y_,z_}] = {ArcTan[x,y], ArcTan[Sqrt[x^2+y^2],z], Norm[{x,y,z}]}

(* this simplified version isn't 100% accurate, but easier to simplify *)

xyz2sph2[{x_,y_,z_}] = {ArcTan[y/x], ArcTan[z/Sqrt[x^2+y^2]], Norm[{x,y,z}]}

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


























