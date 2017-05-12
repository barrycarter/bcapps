TODO: summary

(* this forced the az to be between 0 and 360 for graphing *)

f[ha_,dec_,lat_] = {
 Mod[HADecLat2azEl[ha,dec,lat][[1]],2*Pi],
 HADecLat2azEl[ha,dec,lat][[2]]
};


p1=ParametricPlot[{
 f[ha/12*Pi,-23.5*Degree,35*Degree]/Degree,
 f[ha/12*Pi,23.5*Degree,35*Degree]/Degree,
 f[ha/12*Pi,0*Degree,35*Degree]/Degree
}, {ha,-12,12}, 
 PlotLegends -> {"Winter Solstice","Equinox","Summer Solstice"}];

t0922[dec_]=
 Table[{
  Point[f[ha/12*Pi,dec,35*Degree]/Degree],
  Text[Style[ToString[ha], FontSize -> 10], 
 f[ha/12*Pi,dec,35*Degree]/Degree+{0,5}]},
  {ha,-12,11}]

Graphics[t0922]
showit



t0923=Table[Point[f[ha/12*Pi,23.5*Degree,35*Degree]/Degree],{ha,-12,12}]
t0924=Table[Point[f[ha/12*Pi,0*Degree,35*Degree]/Degree],{ha,-12,12}]

Show[{p1,Graphics[t0922[-23.5*Degree]], 
 Graphics[t0922[0*Degree]], Graphics[t0922[23.5*Degree]]}]










p9=Plot[HADecLat2azEl[ha/12*Pi,23.5*Degree,35*Degree][[1]]/Degree,{ha,-12,12}]
p8=Plot[HADecLat2azEl[ha/12*Pi,-23.5*Degree,35*Degree][[1]]/Degree,{ha,-12,12}]
p7=Plot[HADecLat2azEl[ha/12*Pi,0,35*Degree][[1]]/Degree,{ha,-12,12}]

HADecLat2azEl[ha,dec,lat]

(*

c1 = observed az
c2 = observed el
c3 = latitude

 *)

Solve[{
HADecLat2azEl[ha,dec,lat][[1]] == c1, HADecLat2azEl[ha,dec,lat][[2]] == c2
  }, dec]


Solve[HADecLat2azEl[ha,dec,c3][[1]] == c1, ha]

Solve[HADecLat2azEl[ha,dec,c3][[2]] == c2, ha]

conds = {-Pi < ha < Pi, -Pi/2 < dec < Pi/2, -Pi/2 < lat < Pi/2, 
         -Pi < c1 < Pi, -Pi/2 < c2 < Pi/2, -Pi/2 < c3 < Pi/2}

simp = ArcTan[x_,y_] -> ArcTan[y/x]

az[ha_,dec_,lat_] = FullSimplify[HADecLat2azEl[ha,dec,lat][[1]] /. simp,conds];

el[ha_,dec_,lat_] = FullSimplify[HADecLat2azEl[ha,dec,lat][[2]] /. simp,conds];

Solve[{az[ha,dec,c3] == c1, el[ha,dec,c3] == c2}, {ha,dec}]

FullSimplify[Solve[az[ha,dec,c3] == c1, dec],conds]

t0830=FullSimplify[Solve[az[ha,dec,lat] == c1, dec],conds] [[1,1,2,1]]-Pi*C[1]

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {800, 600}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


Table[HADecLat2azEl[ha,0,40*Degree], {ha,0,2*Pi,.01}]

Table[HADecLat2azEl[ha,23*Degree,40*Degree], {ha,-Pi,Pi,.01}]

p1=ParametricPlot[HADecLat2azEl[ha,0,40*Degree],{ha,-Pi,Pi}]
p2=ParametricPlot[HADecLat2azEl[ha,23*Degree,40*Degree],{ha,-Pi,Pi}]
p3=ParametricPlot[HADecLat2azEl[ha,-23*Degree,40*Degree],{ha,-Pi,Pi}]

p4=ParametricPlot[
 HADecLat2azEl[ha,-23*Degree,40*Degree]-HADecLat2azEl[ha,0,40*Degree],
{ha,-Pi,Pi}]


Show[{p1,p2,p3}, PlotRange -> All]


****** TODO: disclaim geometric not true; also equinox so can't determine date but it doesnt matter-- almost can

(* numerical below *)

suppose: az 87, el 29, lat +35

Solve[{
 az[ha, dec, 35*Degree] == 87*Degree,
 el[ha, dec, 35*Degree] == 29*Degree
}, {ha,dec}]

t0846=Table[HADecLat2azEl[ha,23.5*Degree,40*Degree],{ha,-Pi,Pi,.01}]

Fit[t0846,Table[x^i,{i,0,10}],x]


NSolve[{
 az[ha, dec, 35*Degree] == 87*Degree,
 el[ha, dec, 35*Degree] == 29*Degree
}, ha]

t0852=Solve[az[ha,dec,35*Degree] == 87*Degree, dec][[1,1,2,1]]-Pi*C[1]

el[ha,t0852,35*Degree] == 29*Degree





