(*

math -initfile ~/BCGIT/ASTRO/bc-astro-formulas.m

http://astronomy.stackexchange.com/questions/19619/how-to-make-motion-of-the-sun-more-apparent-at-seconds-scale

TODO: sun has angular width, and oblong at horizon

TODO: note when setting, asymptotic to infinity

TODO: note ra/dec fixed is reasonable

TODO: link to formulas

TODO: sid day length and fixed ra cancel each other out

conds = {Element[{dec,ha,lat}, Reals]}
az[dec_,ha_,lat_] = FullSimplify[decHaLat2azEl[dec,ha,lat][[1]],conds]
el[dec_,ha_,lat_] = FullSimplify[decHaLat2azEl[dec,ha,lat][[2]],conds]

(* we want to put points everywhere EXCEPT on the hour where we use text *)

t = Select[Table[i,{i,0,24,1/4}], !IntegerQ[#] &]
t = Table[i,{i,0,24,1/4}]

pts[dec_,lat_] = 
 Table[
 Point[{Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, el[dec,ha/12*Pi,lat]/Degree}], 
 {ha,t}];

pts2[dec_,lat_] = 
 Table[
 {Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, el[dec,ha/12*Pi,lat]/Degree}, 
 {ha,t}];

(* the stick length at various times and azimuths *)

pts3[dec_,lat_] = 
 Table[
 {Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, Cot[el[dec,ha/12*Pi,lat]]}, 
 {ha,t}];

txt[dec_,lat_] = 
 Table[Text[Style[ToString[Mod[ha-12,24]], FontSize -> 5], 
 {Mod[az[dec,ha/12*Pi,lat],2*Pi]/Degree, el[dec,ha/12*Pi,lat]/Degree},
 {0,0}],
 {ha,0,24,1}];

xtics = Table[i,{i,0,360,30}];
ytics = Table[i,{i,-90,90,10}];

ytics3 = Table[i,{i,0,5,.5}];

g2 = ListLogPlot[{
 pts3[0,35*Degree], pts3[23.5*Degree,35*Degree], pts3[-23.5*Degree,35*Degree]
}, Ticks -> {xtics, Automatic}, PlotLegends -> {"Equinox", "Summer Solstice", 
   "Winter Solstice"}, PlotMarkers -> {Automatic, 2}, PlotRange -> {0,5},
 PlotRangeClipping -> True]

g2 = ListPlot[{
 pts3[0,35*Degree], pts3[23.5*Degree,35*Degree], pts3[-23.5*Degree,35*Degree]
}, Ticks -> {xtics, ytics3}, PlotLegends -> {"Equinox", "Summer Solstice", 
   "Winter Solstice"}, PlotMarkers -> {Automatic, 2}, PlotRange -> {0,5}]

g0 = ListPlot[{
 pts2[0,35*Degree], pts2[23.5*Degree,35*Degree], pts2[-23.5*Degree,35*Degree]
}, Ticks -> {xtics, ytics}, PlotLegends -> {"Equinox", "Summer Solstice", 
   "Winter Solstice"}, PlotMarkers -> {Automatic, 2}]

g1 = Graphics[{
 txt[0, 35*Degree], txt[-23.5*Degree, 35*Degree], txt[23.5*Degree, 35*Degree]
}];

Show[{g0,g1}]
showit

(* angle and radius, using north as up, east as right *)

rad[dec_,ha_,lat_] = FullSimplify[Cot[el[dec,ha,lat]],conds]
ang[dec_,ha_,lat_] = 3*Pi/2-az[dec,ha,lat]


xy[dec_,ha_,lat_]=  rad[dec,ha,lat]*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}


xy[dec_,ha_,lat_]=  Max[rad[dec,ha,lat],0]*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}

xyt[dec_,lat_] = Table[xy[dec,ha/12*Pi,lat], {ha,0,24,1/4}]

ListPlot[xyt[23.5*Degree,35*Degree]]

TODO: consider projecting at an angle instead of flat surface, and note sun is not a point light source, but has width

Graphics[{txt[0,35*Degree], txt[23.5*Degree, 35*Degree],
          txt[-23.5*Degree, 35*Degree]}]
showit


ListPlot[{t0717[0,35*Degree], t0717[23.5*Degree, 35*Degree], 
         t0717[-23.5*Degree,35*Degree]}]
showit

TODO: mention this file



ParametricPlot[{az[tdec,ha,tlat], el[tdec,ha,tlat]}, {ha,-Pi,Pi}]

(* radius and angle of gnomon; note 'rad' is existing function, sigh *)

(* and the corresponding xy point *)

xy[dec_,ha_,lat_]=  radi[dec,ha,lat]*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}

xyfake[dec_,ha_,lat_]=  1*
 {Cos[ang[dec,ha,lat]],Sin[ang[dec,ha,lat]]}

xy[dec_,ha_,lat_]=  {
 radi[dec,ha,lat]*Cos[ang[dec,ha,lat]],
 radi[dec,ha,lat]*Sin[ang[dec,ha,lat]]
};

xy[dec_,ha_,lat_]=  {
 radi[dec,ha,lat]*Sin[ang[dec,ha,lat]],
 radi[dec,ha,lat]*Cos[ang[dec,ha,lat]]
};







t2244 = Table[xy[0,ha,35*Degree], {ha,-Pi/4,Pi/4,Pi/48}]





tdec = 0
tlat = 35*Degree;

Plot[Cot[el[tdec,ha,tlat]], {ha,-Pi,Pi}]



decHaLat2azEl[dec,ha,lat]

decHaLat2azEl[dec,0,lat]

D[decHaLat2azEl[dec,ha,lat],ha]

FullSimplify[% /. ha -> 0]

{-(Cos[dec] Csc[dec - lat]), 0}

Solve[D[-Cos[dec]*Csc[dec-lat],dec]==0, dec]

decHaLat2azEl[dec,ha,lat]

decHaLat2azEl[0,ha,35*Degree]

ParametricPlot[decHaLat2azEl[0,ha,35*Degree], {ha,-Pi,Pi}]

ParametricPlot[decHaLat2azEl[0,ha,35*Degree]/Degree, {ha,-Pi,Pi}]

TODO: actually list parametric plot so we can see distances and stuff

helper function below makes az range 0-360 because we want center

fix[pair_] := {Mod[pair[[1]],2*Pi], pair[[2]]}

t = Table[N[fix[decHaLat2azEl[0,ha,35*Degree]]]/Degree,{ha,-Pi,Pi,2*Pi/48}]
ListPlot[t, PlotRange -> {{0,360}, {-55,55}}]
showit

t = Table[N[fix[decHaLat2azEl[0,ha,35*Degree]]]/Degree,{ha,-Pi,Pi,2*Pi/48}]
ListPlot[t, PlotRange -> {{0,360}, {-55,55}}]
showit

tab[dec_] = Table[N[fix[decHaLat2azEl[dec,ha,35*Degree]]]/Degree,
 {ha,-Pi,Pi,2*Pi/48}];

(* hours and degrees *)

fix[pair_] := {Mod[pair[[1]]/Pi*180,360], pair[[2]]/Degree}

tab[dec_] = Table[fix[decHaLat2azEl[dec,ha,35*Degree]], {ha,-Pi,Pi,2*Pi/48}];

pts[dec_] = Table[
 Text[ToString[Mod[ha/Pi*12+12,24]],
 fix[decHaLat2azEl[dec,ha,35*Degree]]], {ha,-Pi,Pi,2*Pi/24}];
Graphics[pts[0]]
showit

g1 = ListPlot[{tab[-23.5*Degree], tab[0*Degree], tab[23.5*Degree]}];
g2 = Graphics[{pts[-23.5*Degree], pts[0*Degree], pts[23.5*Degree]}];
Show[{g1,g2}]
showit




TODO: label points with hours!


*)

