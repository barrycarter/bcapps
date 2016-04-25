(* formulas start here *)

world = CountryData["World", "FullPolygon"];

worldpoly = Table[world[[1,i]], {i,1,Length[world[[1]]]}];

antpoly = Table[CountryData["Antarctica", "FullPolygon"][[1,i]], 
 {i, 1, Length[CountryData["Antarctica", "FullPolygon"][[1]]]}];

(* Mathematica won't give Antarctica polygons south of -89.9, this
fills them in *)

spole = {{-180,-90}, {-180,-89.9}, {180, -89.9}, {180, -90}};

(* forcing Rasterize to show the north pole insures the rasterization
includes the whole world; we compensate for this rectangle later *)

npole = {{-180,90}, {180,90}, {180,89}, {-180, 89}};

worldreal = Union[worldpoly,antpoly,{spole,npole}];

r = Rasterize[Graphics[Polygon[worldreal]], ImageResolution -> 2500,
Method -> {"ShrinkWrap" -> True}];

(* 

FAIL: did this as a one off, so it is commented out (hardcoded image
size is from Dimensions[r[[1,1]]])

Export["/tmp/wholething.gif", r, ImageSize -> {12500, 6481}];

*)

(* number of points for each raster line of latitude *)

pointsPerLat0 = Map[Count[#,{0,0,0}]&, r[[1,1]]];

(* even with the undocumented ShrinkWrap option, Mathematica adds
padding; we remove it below and also normalize to [0,1] *)

nonzero = Position[pointsPerLat0, val_/;val>0];
first = Min[nonzero];
last = Max[nonzero];
pointsPerLat = Take[pointsPerLat0, {first,last}]/Max[pointsPerLat0];

(* we now remove the npole rectangle we added above; we actually
remove anything north of 88 degrees, since we have some wiggle room
here *)

(* NOTE: this may not work for extremely low resolution rasterization *)

(* where the range 88-90 occurs on the list *)

lat88 = Ceiling[2/180*Length[pointsPerLat]];

(* this table just assigns, return value is irrelevant *)

Table[pointsPerLat[[-i]] = 0, {i,1,lat88}];

(* convert row number in pointsPerLat to latitude; the -1 is since our
array indices start with 1, not 0; note that this assumes -90 is
exactly row 1 and +90 is exactly the last row, which may not be true;
however, with high resolution, and since the latitude circles are
short near the pole, this shouldn't be a major issue *)

row2lat[i_] = Simplify[-90 + 180*(i-1)/(Length[pointsPerLat]-1)];

(* we now get km of land per latitude by applying cosine and
multiplying by the Earth's circumference *)

(* NOTE: doing N[] here could lose accuracy, but we're in km, so I'm
OK w that *)

latLandKM = N[Table[{row2lat[i], 
 pointsPerLat[[i]]*40700*Cos[row2lat[i]*Degree]}, {i,1,Length[pointsPerLat]}]];

(* for smooth graphing and because we plan to add negative and
positive latitudes later, convert to function *)

flatLandKM[lat_] = Interpolation[latLandKM, InterpolationOrder -> 1][lat];

(* 

graphics for the points themselves commented out, too crowded at high DPI 

g1 = ListPlot[latLandKM, PlotStyle -> RGBColor[1,0,0]];

*)

(* and the function *)

xtics = Table[i, {i,-90,90,10}]

ytics = Table[i, {i,0,16000,1000}]

g2 = Plot[flatLandKM[x], {x,-90,90}, Ticks -> {xtics, ytics}, PlotLabel ->
 Text[Style["Kilometers of Land vs Latitude", FontSize->25]]];

Export["/tmp/image17.gif", g2, ImageSize -> {1024,768}]

(* TODO: there are deviances in the interpolation and the original, hmmm *)

(* absolute latitude *)

fabsLatLandKM[lat_] = flatLandKM[lat] + flatLandKM[-lat];

(* and plotting *)

ytics2 = Table[i, {i,0,24000,1000}]

g4 = Plot[fabsLatLandKM[x], {x,0,90}, Ticks -> {xtics, ytics2}, PlotLabel ->
 Text[Style["Kilometers of Land vs Absolute Latitude", FontSize->25]],
 PlotRange -> { {0,90}, {0,24000}}]

Export["/tmp/image18.gif", g4, ImageSize -> {1024,768}]

(* in theory, we could integrate fabsLatLandKM, but, in reality, that
turns out to be a mess; instead, we go back to latLandKM and use
Accumulate *)

cumul0 = Accumulate[Transpose[latLandKM][[2]]];

(* the actual values in cumul0 are meaningless and depend on the
fineness of our grid; we now re-add the latitudes and normalize *)

cumul = Table[{row2lat[i], cumul0[[i]]/Max[cumul0]}, {i, 1, Length[cumul0]}];

(* functionalize *)

fCumul[lat_] = Interpolation[cumul, InterpolationOrder -> 1][lat];

(* TODO: consider plotting above before we absolute-ify *)

(* the absolute function *)

fCumulAbs[lat_] = fCumul[lat] - fCumul[-lat];

(* figure out where it touches 50% *)

median = lat /. FindRoot[fCumulAbs[lat]==.5, {lat,0,90}]

(* and plot it *)

(* TODO: this works, but yields an error *)

ytics3 = Table[{i, ToString[PaddedForm[i*100,{3}]]<>"%"}, {i,0,1,1/10}]

g5 = Plot[fCumulAbs[x], {x,0,90}, Ticks -> {xtics, ytics3}, PlotLabel ->
Text[Style["Percentage of Total Land Below Given Absolute Latitude",
FontSize->25]], PlotRange -> { {0,90}, {0,1}}];

g6 = Graphics[{
 RGBColor[1,0,0], Dashed,
 Line[{{0,.5},{median,.5}}],
 Line[{{median,0},{median,.5}}]
}]

g7 = Show[g5,g6];

Export["/tmp/image19.gif", g7, ImageSize -> {1024,768}]

(* TODO: plot where x axis distance shrinks as x increases like lat land *)

(* formulas end here *)


(*

http://gis.stackexchange.com/questions/190753/using-gis-to-determine-average-land-distance-from-equator

**DISCLAIMER: Please see important caveats at end of message.**

**SHORT ANSWER:** The average absolute latitude of land on Earth is
33.2924 degrees, or about 3764 km from the equator.

<h4>Longer Answer</h4>

[[image17.gif]]

The plot above shows the kilometers of land intersected by line of
latitude sampled every 1.8' (6000 samples total). Some notes:

  - The large bump on the left is Antarctica. As far north as $75 S
  {}^{\circ}$, Antarctica encircles 71.43% of the South Pole, a total
  of:

$(71.43 \%) \cos (-75 {}^{\circ}) (40700 km)\approx 7525 km$

  - If the equator were covered with land, the graph would peak at
  40700km at the equator. However, only about 21.60% of the equator is
  covered with land.

  - The actual maximum occurs at about $30 {}^{\circ} 28' N$, where
  15846 km (45.17% of this 35081 km) circle is covered by land.

Of course, you're interested in the absolute latitude:

[[image18.gif]]

And since you're interested in the total accumulated land measured
from the equator, we "integrate" to get:

[[image19.gif]]

which shows the answer (the precise answer earlier was computed from
functions, not approximated by looking at the graph).

<h4>Methodology and Caveats</h4>

I used Mathematica's 5743 world polygons and 232 additional Antarctica
polygons to create a virtual 12000x6000 monochrome equiangular image
of the world.

I never actually used the image directly, and it turns out my machine
has insufficient memory to export it in any supported image format.

Here's a 1/4 size (6000x3000) version:

[[image21.gif]]

Note that I added a black bar near the north pole to help with
scaling. My calculations ignore this bar.

I then simply counted the number of pixels per line of latitude,
multiplied by the cosine of the latitude, and then by the Earth's
circumference. I assumed a spherical Earth with a circumference of
40,700 km.

Since Mathematica gives world polygons to a precision of 0.0001
degrees (although they're not necessarily always accurate to the last
digit), using a rasterization size of 1.8 minutes of arc (0.03
degrees) introduces rounding/pixellation  errors.

My work is here:

https://github.com/barrycarter/bcapps/blob/master/STACK/bc-equ-dist.m

As always, it's possible I made an error, so please doublecheck my
work before using it for anything important.

As noted above, Mathematica doesn't consider Antarctica to be part of
the world. There are also several other known inaccuracies in
Mathematica's model of the world:

http://mathematica.stackexchange.com/questions/10229

<h4>Improvements</h4>

There are several possible improvements to this answer if anyone's
interested:

  - Use a more accurate set of world polygons.

  - Instead of rasterizing, use the polygons themselves to determine
  land length per line of latitude.

  - See how the results change if Antarctica is excluded.

  - I was hoping to provide a map $30 {}^{\circ} 28' N$ (the latitude
  line with the most land), but I couldn't find a good way to create a
  map that was 360 degrees wide and only a few degrees high.

*)
