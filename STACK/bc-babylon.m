(* one off for https://astronomy.stackexchange.com/questions/21301/can-someone\
-explain-me-this-diagram-from-an-article *)

sh = Sin[ha];
ch = Cos[ha];
sd = Sin[dec];
cd = Cos[dec];
sl = Sin[lat];
cl = Cos[lat];

x = - ch * cd * sl + sd * cl;
y = - sh * cd;
z = ch * cd * cl + sd * sl;
r = Sqrt[x^2 + y^2];

az = ArcTan[x,y];
alt = ArcTan[r,z];

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, -Pi<ha<Pi, -Pi<lon<Pi};

HADecLat2azEl[ha_, dec_, lat_] = 
 {FullSimplify[az,conds], FullSimplify[alt,conds]};


raDecLatLonHA2az[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[
 az /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

raDecLatLonHA2alt[alpha_, delta_, lambda_, psi_, t_] = FullSimplify[
 alt /. {lat -> lambda, dec -> delta, ha -> t - alpha},
 conds];

Clear[sh, ch, sd, cd, sl, cl, x, y, z, r, az, alt];

(* TODO: is my condition for alpha bad below? *)

conds = {alpha > -Pi, alpha < Pi, delta > -Pi/2, delta < Pi/2, lambda > -Pi/2,
 lambda < Pi/2, psi > -Pi, psi < Pi, t > -Pi, t < Pi};

rise = FullSimplify[alpha - ArcCos[-(Tan[delta] Tan[lambda])],conds];
set = FullSimplify[alpha + ArcCos[-(Tan[delta] Tan[lambda])],conds];

riseAz=FullSimplify[raDecLatLonHA2az[alpha, delta, lambda, psi, rise], conds];
setAz=FullSimplify[raDecLatLonHA2az[alpha, delta, lambda, psi, set], conds];

(* above is cut and paste *)

32.5408299291629

riseAz/Degree /. {delta -> -23.5*Degree, lambda -> 32.5408299291629*Degree}
riseAz/Degree /. {delta -> 23.5*Degree, lambda -> 32.5408299291629*Degree}

118.23 vs 61.77

This is almost too short to be answer. Using the "rise" formula at https://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time/14508#14508 and plugging in 32.54 degrees for Babylon's latitude, we get:

  - When an object's declination is +23.5 degrees (the Sun at summer solstice), it rises 61.77 degrees east of north.

  - When an object's declination is -23.5 degrees (the Sun at winter solstice), it rises 118.23 degrees east of north, which is more conveniently expressed as 61.77 degrees east of south (note the expected symmetry here)

  - The azimuth degree difference between these positions is 56.46 degrees, close to the 59 degrees in the diagram.

  - The calculations for the Sun setting are very similar.

Why the difference?

  - If the Sun were a point and there were no refraction, the numbers above would be more accurate. Because the Sun is a disk and because of refraction, the sun actually rises when the geometric position of the center of its disk is 50 minutes below the horizon.

  - Minor: I'm using +-23.5 degrees as an approximation of the Sun's declination at the solstices: the actual number is a little different.

To be fair, even after applying some corrections, I couldn't quite get 59 degrees or even anything about 58.5 degrees, but I'm sure this is what they're talking about.

TODO: I invite someone to create a graph showing how the "59 degrees" varies with latitude.

(* also https://astronomy.stackexchange.com/questions/2408/why-is-twilight-longer-in-summer-than-winter-and-shortest-at-the-equinox *)

dec = 23.5*Degree

xtics1 = Table[{i,ToString[i]<>"am"}, {i,6,11}]
xtics2 = Table[{i,ToString[i-24]<>"am"}, {i,25,30}]
xtics3 = Table[{i,ToString[i-12]<>"pm"}, {i,13,23}]
xtics4 = { {12, Text[Style["noon", {Bold, Larger}]]}, 
           {24, Text[Style["mid", {Bold, Larger}]]}};

xtics5= { {3, "3am"}, {6, "6am"}, {9, "9am"} }

xtics = Join[xtics1, xtics2, xtics3, xtics4]

ytics = Table[{10*i, i*10*Degree}, {i,-9,9}]

p1 = Plot[{
 HADecLat2azEl[(ha-12)/12*Pi, dec, 35*Degree][[2]]/Degree,
 HADecLat2azEl[(ha-12)/12*Pi, 0*Degree, 35*Degree][[2]]/Degree,
 HADecLat2azEl[(ha-12)/12*Pi, -dec, 35*Degree][[2]]/Degree,
 -6, -12, -18
}, {ha,6,30}, Ticks -> {xtics, ytics}, Axes -> True,
 PlotStyle -> {Red, Green, Blue, {Dashed, RGBColor[.5,.5,1]},
 {Dashed, Blue}, {Dashed, Black}},
 PlotLegends -> {"Summer Solstice", "Equinoxes", "Winter Solstice",
  "Civil Twilight", "Nautical Twilight", "Astronomical Twilight"},
 PlotRange -> { {6,30}, {-78.5,78.5}}, ImageSize -> {1024,768},
 PlotLabel -> 
 Text[Style["Solar elevation at 35N for solstices and equinoxes",
 {Bold, Larger}]]]
showit


(* PlotLegends -> {"Summer Solstice","Equinoxes","Winter Solstice"}]  *)

g = Graphics[{Dashed, 
 RGBColor[0.5,0.5,1], Line[{ {6,-6}, {30,-6}}],
 RGBColor[0,0,1], Line[{ {6,-12}, {30,-12}}],
 RGBColor[0,0,0], Line[{ {6,-18}, {30,-18}}]
}];

Show[{g,p1}, PlotRange -> {{6,30},{-90,90}}, ImageSize -> {800,600},
 AspectRatio -> 1, AxesOrigin -> {6, 0},
 FrameLabel -> {a,b,c,d}]
showit

[[image39.gif]]

This isn't really an answer, but more of a visualization based on the
formulas from https://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time/14508#14508 -- hope it helps

