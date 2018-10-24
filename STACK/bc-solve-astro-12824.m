(*
http://astronomy.stackexchange.com/questions/12824/how-long-does-a-sunrise-or-sunset-take
*)



(* t = days from vernal equinox *)

sundec[t_] = 23.44*Degree*Sin[2*Pi*t/365.2425]
sunra[t_] = 2*Pi*t/365.2425

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

sunel[t_,lat_,lon_] = raDec2AzEl[sunra[t],sundec[t],lat,lon,t+365.2425/4-10]

Plot[sunel[t,Pi/2,0][[2]]/Degree,{t,-3,0}]

(* -2.06706 = -50 min, -0.744007 = -18 min *)

(* that's 1.32305 days or 31.7533 hours *)

Plot[sunel[t,Pi/2,0][[2]]/Degree,{t,-2.06706,-0.744007}]

Plot[sunel[t,Pi/2-.1*Degree,0][[2]]/Degree,{t,-2.06706,-0.744007},
PlotRange->{-50/60,-18/60}]

Plot[sunel[t,Pi/2-0*Degree,0][[2]]/Degree,{t,-2.06706,-0.744007},
PlotRange->{-50/60,-18/60}]

Plot[sunel[t,Pi/2-0*Degree,0][[2]]/Degree,{t,-3,-0},
PlotRange->{-50/60,-18/60}]

Plot[sunel[t,Pi/2-1*Degree,0][[2]]/Degree,{t,-3,-0},
PlotRange->{-50/60,-18/60}]

Plot[sunel[t,Pi/2-0.3*Degree,0][[2]]/Degree,{t,-3,-0},
PlotRange->{-50/60,-18/60}]

Plot[sunel[t,Pi/2-0.3*Degree,Pi/2][[2]]/Degree,{t,-3,-0},
PlotRange->{-50/60,-18/60}]

Plot[sunel[t,Pi/2-0.1*Degree,0][[2]]/Degree*60,{t,-3,-0},
PlotRange->{-50,-18}]

Plot[sunel[t,Pi/2-0.1*Degree,Pi][[2]]/Degree*60,{t,-3,-0},
PlotRange->{-50,-18}]

Plot[sunel[t,Pi/2-0.1*Degree,-Pi/2][[2]]/Degree*60,{t,-3,-0},
PlotRange->{-50,-18}]

Plot[sunel[t,Pi/2-0.1*Degree,-105*Degree][[2]]/Degree*60,{t,-3,-0},
PlotRange->{-50,-18}]

(* sun: 1 minute arc/hour, elevation at 90-6min: changes 1 minute arc/hour *)

Plot[sunel[t,Pi/2-0.3*Degree,0][[2]]/Degree*60,{t,-3,-0},
PlotRange->{-50,-18}]

Plot[{sunel[t,Pi/2-0.1*Degree,90*Degree][[2]]/Degree*60,
      sundec[t]/Degree*60
},
{t,-3,-0},
PlotRange->{-50,-18}]


Plot[{sunel[t,Pi/2-0.1*Degree,30*Degree][[2]]/Degree*60,
      sundec[t]/Degree*60
},
{t,-3,-0},
PlotRange->{-50,-18}]

(* scenario:

6m south of the north pole (so 12m variance from north/south)

rise due south sun dec -62 min arc (elev = -50 min)

when due north, -50 min arc (elev = -50 min)

when due south, -38 min arc (elev = -26 min)

when due north, -26 min arc (elev = -26 min)

rise will occur here

when due south, -14 min arc (elev = -2 min arc)

*)

dip[m_] = Sqrt[2*m/6.4/10^6]








