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
 PlotLegends -> 
 Placed[{"Winter Solstice","Equinox","Summer Solstice"}, {0.1,0.2}],
 PlotLabel -> "Solar Azimuth vs Elevation",
 AxesLabel -> {"Azimuth", "Elevation"}
];
showit


p1=ParametricPlot[{
 f[ha/12*Pi,-23.5*Degree,35*Degree]/Degree,
 f[ha/12*Pi,23.5*Degree,35*Degree]/Degree,
 f[ha/12*Pi,0*Degree,35*Degree]/Degree
}, {ha,-12,12}, 
 PlotLabel -> "Solar Azimuth vs Elevation",
 AxesLabel -> {"Azimuth", "Elevation"}];

t0922[dec_]=
 Table[{
  Point[f[ha/12*Pi,dec,35*Degree]/Degree],
  Text[Style[ToString[ha], FontSize -> 10], 
 f[ha/12*Pi,dec,35*Degree]/Degree+{0,5}]},
  {ha,-12,11}]

Show[{p1,Graphics[t0922[-23.5*Degree]], 
 Graphics[t0922[0*Degree]], Graphics[t0922[23.5*Degree]]}]

(* temp change due to size weirdness *)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {2048, 768*2}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]



Graphics[t0922]
showit



t0923=Table[Point[f[ha/12*Pi,23.5*Degree,35*Degree]/Degree],{ha,-12,12}]
t0924=Table[Point[f[ha/12*Pi,0*Degree,35*Degree]/Degree],{ha,-12,12}]











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

TODO: add key!

NSolve[{
 az[ha, dec, 35*Degree] == 87*Degree,
 el[ha, dec, 35*Degree] == 29*Degree
}, ha]

t0852=Solve[az[ha,dec,35*Degree] == 87*Degree, dec][[1,1,2,1]]-Pi*C[1]

el[ha,t0852,35*Degree] == 29*Degree

(* Complaint for mathematica.SE *)

Subject: Using "PlotLegends" makes plot much smaller

$Version
11.1.0 for Linux x86 (64-bit) (March 13, 2017)

(* a simple plot, turns out nice *)

t1 = Plot[x^2,{x,-5,5}];
Export["/tmp/test1.png", t1, ImageSize -> {800,600}];

(* let's add a legend, turns out small *)

t2 = Plot[x^2,{x,-5,5},PlotLegends -> {"x^2"}]
Export["/tmp/test2.png", t2, ImageSize -> {800,600}]

(* if we make image bigger, plot still turns out small *)

t3 = Plot[x^2,{x,-5,5},PlotLegends -> {"x^2"}]
Export["/tmp/test3.png", t3, ImageSize -> {800*2,600*2}]

test1.png from the above looks very nice and uses up the entire 800x600 canvas:

[[IMAGE]]

test2.png's plot uses up only a fraction of the 800x600 canvas:

[[IMAGE]]

test3.png has a larger canvas (2 times larger in each direction), but the plot is exactly the same size as in test2.png. I'd at least expect it to be two times bigger in each direction, even if it didn't use up the entire 1600x1200 canvas. My hope for test3.png was to create a larger image that didn't fill the canvas and then use ImageMagick to crop.

Why does this PlotLegends problem occur and how can I fix it?

I've skimmed similar questions on this site, but I don't think any address this issue exactly. Several of these questions suggest "homebrew" solutions, which I'd prefer to avoid if at all possible.
