TODO: summary

(* this forces the az to be between 0 and 360 for graphing *)


TODO: confirm TeX on site, use images if not

TODO: fix plot or use w/o legends if needed

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


(* the setting time *)

Solve[HADecLat2azEl[ha, dec, lat][[2]] == 0, ha, Reals]


f[ha_,dec_,lat_] = {
 Mod[HADecLat2azEl[ha,dec,lat][[1]],2*Pi],
 HADecLat2azEl[ha,dec,lat][[2]]
};

g[ha_,dec_,lat_] = {
 Mod[HADecLat2azEl[ha,dec,lat][[1]],2*Pi]/Degree,
 HADecLat2azEl[ha,dec,lat][[2]]/Degree,
 dec/Degree
};

g2[ha_,dec_,lat_] = {
 Mod[HADecLat2azEl[ha,dec,lat][[1]],2*Pi]/Degree,
 HADecLat2azEl[ha,dec,lat][[2]]/Degree,
 ha/12*Pi
};

t1025 = Flatten[Table[
 N[Re[g2[ha,dec,35*Degree]]], {ha,-Pi,Pi, Pi/100}, {dec, -Pi, Pi, Pi/100}
],1];

t1025 = Flatten[Table[
 N[Re[g[ha,dec,35*Degree]]], {ha,0,2*Pi, Pi/100}, 
 {dec, -55*Degree, 55*Degree, Pi/100}
],1];

t1025 = Flatten[Table[
 N[Re[g2[ha,dec,35*Degree]]], {ha,0,2*Pi, Pi/100}, 
 {dec, -23.5*Degree, 23.5*Degree, 1*Degree}
],1];

ListContourPlot[t1025, Contours -> 25, ImageSize -> {800,600}, 
 PlotLegends -> Automatic]


ContourPlot[x+y,{x,0,3},{y,0,4}, PlotLegends -> Automatic]




(* test below for all decs *)

t1512=Table[f[ha/12*Pi,d,35*Degree]/Degree,{d,-55*Degree,55*Degree,10*Degree}]

t1512=Table[f[ha/12*Pi,d,35*Degree]/Degree,
 {d,-23.5*Degree,23.5*Degree,47/10*Degree}]

t1524= ParametricPlot[
 t1512, {ha,-12,11.99999},ImageSize->{1024,768},PlotRange->All]

t1523 = ParametricPlot[
 f[11/12*Pi, dec, 35*Degree]/Degree, {dec,-23.5*Degree,23.5*Degree}
]

t1525 = Table[f[h/12*Pi, dec, 35*Degree]/Degree, {h,-12,12,1}]

t1526 = ParametricPlot[
 t1525, {dec,-23.5*Degree,23.5*Degree},ImageSize->{1024,768},PlotRange->All]

Show[{t1524,t1526}]

t1520=Table[f[ha/12*Pi,d,35*Degree]/Degree,
 {d,-90*Degree,90*Degree,5*Degree}]

t1521= ParametricPlot[
 t1520, {ha,-12,11.99999},ImageSize->{1024,768},PlotRange->All]

t1522 = Table[f[h/12*Pi, dec, 35*Degree]/Degree, {h,-12,12,0.25}]

t1523 = ParametricPlot[
 t1522, {dec,-89*Degree,89*Degree},ImageSize->{1024,768},PlotRange->All]

Show[{t1521,t1523}]

t1520=Table[f[ha/12*Pi,d,35*Degree]/Degree,
 {d,-90*Degree,90*Degree,10*Degree}]

t1521= ParametricPlot[
 t1520, {ha,-12,11.99999},ImageSize->{1024,768},PlotRange->All, 
 PlotStyle -> Black]

t1522 = Table[f[h/12*Pi, dec, 35*Degree]/Degree, {h,-12,12,1}]

t1523 = ParametricPlot[
 t1522, {dec,-89*Degree,89*Degree},ImageSize->{1024,768},PlotRange->All,
 PlotStyle -> Red]

t1524 = Table[f[h/12*Pi, dec, 35*Degree]/Degree, {h,-12,12,0.25}]

t1525 = ParametricPlot[
 t1524, {dec,-89*Degree,89*Degree},ImageSize->{1024,768},PlotRange->All,
 PlotStyle -> {Pink, Dashed}]

Show[{t1525,t1523}]

Show[{t1521,t1523}]








p1=ParametricPlot[{
 f[ha/12*Pi,-23.5*Degree,35*Degree]/Degree,
 f[ha/12*Pi,23.5*Degree,35*Degree]/Degree,
 f[ha/12*Pi,0*Degree,35*Degree]/Degree
}, {ha,-12,12}, 
 PlotLegends -> 
  {"Winter Solstice","Summer Solstice","Equinox"},
 PlotLabel -> "Solar Azimuth vs Elevation (35N latitude)",
 AxesLabel -> {"Azimuth", "Elevation"},
 ImageSize -> {800,600}
];



p0827=ParametricPlot[{
 Pi-f[ha/12*Pi,-23.5*Degree,35*Degree][[1]]/Degree*
  Cos[f[ha/12*Pi,-23.5*Degree,35*Degree][[2]]],
 f[ha/12*Pi,-23.5*Degree,35*Degree][[2]]/Degree},
 {ha,-12,12}, 
 PlotLegends -> 
  {"Winter Solstice","Summer Solstice","Equinox"},
 PlotLabel -> "Solar Azimuth vs Elevation (35N latitude)",
 AxesLabel -> {"Azimuth", "Elevation"},
 ImageSize -> {800,600}
];



dots[dec_]= Graphics[
 Table[{
  Point[f[ha/12*Pi,dec,35*Degree]/Degree],
  Text[Style[ToString[ha], FontSize -> 10], 
 f[ha/12*Pi,dec,35*Degree]/Degree+{0,5}]},
  {ha,-11,11}]]

Show[{p1, dots[-23.5*Degree], dots[0*Degree], dots[23.5*Degree]}];


TODO: get bloody degree symbol in there somehow maybe

HADecLat2azEl[ha,dec,lat]

(*

c1 = observed az
c2 = observed el
c3 = latitude

 *)

ArcCos[-(Tan[dec] Tan[lat])

Flatten[{HADecLat2azEl[ha,dec,lat], ArcCos[-(Tan[dec] Tan[lat])]}]

Flatten[{HADecLat2azEl[ha,dec,35*Degree], ArcCos[-(Tan[dec] Tan[35*Degree])]}]

ParametricPlot3D[
Flatten[{HADecLat2azEl[ha,dec,35*Degree], ArcCos[-(Tan[dec] Tan[35*Degree])]}],
{ha, -Pi, Pi}, {dec, -Pi/2, Pi/2}, PlotRange -> All]

ContourPlot3D[
Flatten[{HADecLat2azEl[ha,dec,35*Degree], ArcCos[-(Tan[dec] Tan[35*Degree])]}],
{ha, -Pi, Pi}, {dec, -Pi/2, Pi/2}]

t1012 = Flatten[Table[
Flatten[{HADecLat2azEl[ha,dec,35*Degree], ArcCos[-(Tan[dec] Tan[35*Degree])]}],
{ha, -Pi, Pi, Pi/100}, {dec, -Pi/2, Pi/2, Pi/100}],1];







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

Table[HADecLat2azEl[ha,0,40*Degree], {ha,0,2*Pi,.01}]

Table[HADecLat2azEl[ha,23*Degree,40*Degree], {ha,-Pi,Pi,.01}]

p1=ParametricPlot[HADecLat2azEl[ha,0,40*Degree],{ha,-Pi,Pi}]
p2=ParametricPlot[HADecLat2azEl[ha,23*Degree,40*Degree],{ha,-Pi,Pi}]
p3=ParametricPlot[HADecLat2azEl[ha,-23*Degree,40*Degree],{ha,-Pi,Pi}]

ParametricPlot[{Cos[HADecLat2azEl[ha,-23*Degree,40*Degree][[1]]],
               HADecLat2azEl[ha,-23*Degree,40*Degree][[2]]},
{ha,-Pi,Pi}]



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

(* end question *)

t2 = Plot[x^2,{x,-5,5},PlotLegends -> {"x^2"}, ImageSize -> {800,600}]
Export["/tmp/test2.png", t2, ImageSize -> {800,600}]

TODO: stretch hour angle/sideral for sun (ie, 24 sidereal vs "real")

TODO: not easy for moon

TODO: high enough resolution chart = read it off

