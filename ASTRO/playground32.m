(* http://astronomy.stackexchange.com/questions/12824/how-long-does-a-sunrise-or-sunset-take *)

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

sundec[e_] = ArcSin[Sin[-23.44*Degree]*Sin[e]]

elev[dec_,lat_,ha_] = Sin[dec]*Sin[lat] - Cos[dec]*Cos[lat]*Sin[ha]

sunel[e_,lat_,ha_] = elev[sundec[e],lat,ha]

Plot[sunel[e,Pi/2,e*24]/Degree,{e,0,4}]

