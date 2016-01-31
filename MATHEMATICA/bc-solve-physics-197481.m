(*

This is an interesting question. I've previously computed planetary
conjunctions *as viewed from Earth*:
https://astronomy.stackexchange.com/questions/11141 but not as viewed
from the Sun.

It turns out this is much easier to compute, since the planets follow
nearly circular orbits around the Sun.

TODO: note significantly more accurate calculations with CSPICE

TODO: note that I've ignored dwarf planets except for Pluto

TODO: ecliptic latitude (and show "bad" conjunctions?)

TODO: snapshots from orrery

TODO: 3+ planets (including specific n years mention in question)

TODO: inner planets

TODO: does Bode's "law" help?

TODO: note EMBary vs E

TODO: does R^3/T^2 help any? (I don't think so, but...)

TODO: mention this program

*)

(* http://ssd.jpl.nasa.gov/txt/p_elem_t2.txt *)

(* below is raw cut and paste, I clean it up later *)

plans = {

{Mercury, 0.38709843, 0.20563661, 7.00559432, 252.25166724,
77.45771895, 48.33961819, 0.00000000, 0.00002123, -0.00590158,
149472.67486623, 0.15940013, -0.12214182},

{Venus, 0.72332102, 0.00676399, 3.39777545, 181.97970850,
131.76755713, 76.67261496, -0.00000026, -0.00005107, 0.00043494,
58517.81560260, 0.05679648, -0.27274174},

{EMBary, 1.00000018, 0.01673163, -0.00054346, 100.46691572,
102.93005885, -5.11260389, -0.00000003, -0.00003661, -0.01337178,
35999.37306329, 0.31795260, -0.24123856},

{Mars, 1.52371243, 0.09336511, 1.85181869, -4.56813164, -23.91744784,
49.71320984, 0.00000097, 0.00009149, -0.00724757, 19140.29934243,
0.45223625, -0.26852431},

{Jupiter, 5.20248019, 0.04853590, 1.29861416, 34.33479152,
14.27495244, 100.29282654, -0.00002864, 0.00018026, -0.00322699,
3034.90371757, 0.18199196, 0.13024619},

{Saturn, 9.54149883, 0.05550825, 2.49424102, 50.07571329, 92.86136063,
113.63998702, -0.00003065, -0.00032044, 0.00451969, 1222.11494724,
0.54179478, -0.25015002},

{Uranus, 19.18797948, 0.04685740, 0.77298127, 314.20276625,
172.43404441, 73.96250215, -0.00020455, -0.00001550, -0.00180155,
428.49512595, 0.09266985, 0.05739699},

{Neptune, 30.06952752, 0.00895439, 1.77005520, 304.22289287,
46.68158724, 131.78635853, 0.00006447, 0.00000818, 0.00022400,
218.46515314, 0.01009938, -0.00606302},

{Pluto, 39.48686035, 0.24885238, 17.14104260, 238.96535011,
224.09702598, 110.30167986, 0.00449751, 0.00006016, 0.00000501,
145.18042903, -0.00968827, -0.00809981} }

(* the format above is:

name, a, e, I, L, long.peri., long.node., AU, AU/Cy, rad, rad/Cy, deg,
deg/Cy, deg, deg/Cy, deg, deg/Cy, deg, deg/Cy

*)

(* fields of interest:

1 = name
2 = distance (AU)
5 = longitude at epoch (2000-01-01 12:00:00?) (degrees)
11 = increase in longitude per century (degrees)

For consistency, NOT using AstronomicalData below

*)

Table[{
data[i[[1]]][period] = 36525/i[[11]],
data[i[[1]]][sangle] = i[[5]],
data[i[[1]]][distance] = i[[2]]
}, {i,plans}]

pos[i_][t_] = data[i][distance]*
              {Cos[data[i][sangle]*Degree + 2*Pi*t/data[i][period]],
	      Sin[data[i][sangle]*Degree + 2*Pi*t/data[i][period]]};

(* TODO: consider changing these *)

data[Saturn][color] = RGBColor[{0.9,0.9,0}]
data[Jupiter][color] = RGBColor[{0,1,0}]

angle[i_][t_] = data[i][sangle] + t*360/data[i][period]

t0 = FindInstance[angle[Jupiter][t] == angle[Saturn][t], t][[1,1,2]]

tend = Solve[angle[Jupiter][t]==360+angle[Saturn][t],t][[1,1,2]]

pp[t_] := ParametricPlot[{pos[Jupiter][u], pos[Saturn][u]}, {u,t0,t0+t},
 PlotStyle -> {data[Jupiter][color], data[Saturn][color]}]

g0[t_] = Graphics[{
 Line[{{0,0}, pos[Saturn][t0]}],
 data[Saturn][color], 
 Line[{{0,0}, pos[Saturn][t0+t]}],
 data[Jupiter][color], 
 Line[{{0,0}, pos[Jupiter][t0+t]}],
 RGBColor[{0,0,0}],
 Dashed, Line[{{0,0}, pos[Saturn][tend]}],
 PointSize[0.05],
 data[Jupiter][color], Point[pos[Jupiter][t0+t]],
 data[Saturn][color], Point[pos[Saturn][t0+t]]
}];

text[t_] := Graphics[{Text[Style["Years: "<>ToString[t], Large], 
 Scaled[{.84,.03}]]}];

g1[t_] := Show[{g0[t],pp[t],text[t]}, Axes -> True, Ticks -> False,
 PlotRange -> {{-data[Saturn][distance]-.5, data[Saturn][distance]+.5},
  {-data[Saturn][distance]-.5, data[Saturn][distance]+.5}}]

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".jpg"]; 
     Export[file, %, ImageSize -> {600, 400}]; 
     Run[StringJoin["display ", file, "&"]]; ]
g1[5]
showit2

(* t1 = Table[g1[t],{t,-0.50,tend-t0,0.15}]; *)

t1 = Table[g1[t],{t,-0.01,data[Saturn][period],0.15}];

Export["/tmp/orbits.gif",t1, ImageSize -> {600,400}]

ParametricPlot[{pos[Jupiter][t], pos[Saturn][t]}, {t,0,data[Jupiter][period]}]

ParametricPlot[{pos[Jupiter][t], pos[Saturn][t]}, {t,0,6}]

(* 47 degrees = arb starting lineup *)


Show[jup[5], AxesOrigin -> {0,0}, Axes -> True]




