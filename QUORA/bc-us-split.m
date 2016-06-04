(*

[[animation or link]]

The animation above shows the continental US (48 states + District of Columbia) divided into areas of approximately equal population (red line) and equal area (blue line) by straight equiangular lines at angles from [math]0 {}^{\circ}[/math] to [math]180 {}^{\circ}[/math] in [math]0.1 {}^{\circ}[/math] steps, based on US Census 2014 blockgroup data. Details:

  - The projection of the map is equiangular with a true scale at [math]37 {}^{\circ}N[/math] latitude.

  - I used the data from the 2014 US Census found here: 


https://www.epa.gov/enviro/state-fips-code-listing


https://www.census.gov/geo/reference/gtc/gtc_bg.html (def

TODO: see other caveats

TODO: mention other animation




(* attempts to answer: https://www.quora.com/unanswered/If-you-drew-a-single-straight-line-bisecting-America-so-that-both-land-and-population-were-nearly-equally-divided-which-way-would-the-line-point 

https://www.census.gov/geo/maps-data/data/gazetteer2010.html

[[ussplit.gif]]

With the several caveats below, the line above splits the continental
USA (48 contiguous states and the federal enclave District of
Columbia) into both equal areas and equal populations:

  - The formula for this line is:

$\text{latitude}=-0.093365 \text{longitude}+29.8953$

meaning it's ONLY A LINE in the equiangular map above. It would not be
a line in a Mercator or orthographic projection of the USA.

Although there's no such thing as a straight line on a spherical
surface, the best approximation is a great circle path (or
"geodesic"). The line above is NOT a geodesic.

  - The map above is not to scale: the horizontal scale is 58.75
  seconds of arc per pixel and the vertical scale is 1.5 minutes
  (90.00 seconds) of arc per pixel. This ratio would be accurate at
  49.25 degrees north latitude, which is only the northern edge of the
  map.

  - Based on the US Census 2010 data, there were 153,334,478 living
  below (south and west) of the line and 153,340,528 living above
  (north and east) of this line for a split of 49.999% to 50.001%

  - The area split isn't quite as good: 4,036,057,550,093 square
  meters below the line, and 4,045,809,542,357 square meters, for a
  split of 49.94% to 50.06%

  - To make this calculation I downloaded the census tract population
  and position data from
  https://www.census.gov/geo/maps-data/data/gazetteer2010.html under
  "Census Tracts" (direct link to 2.4MB file:
  http://www2.census.gov/geo/docs/maps-data/data/gazetteer/Gaz_tracts_national.zip)

  - The 74,002 census tract points appear are the small pink-purple
  dots on the map.

  - As an approximation, I assumed the entire population and area of a
  census tract was at a single point, which is, of course,
  incorrect. A more accurate model may yield better results.

  - I then created an SQLite3 database: it's tracts.db in
  https://github.com/barrycarter/bcapps/tree/master/QUORA.

  - I then wrote a Perl program (bc-us-split.pl in the same directory)
  to find various lines that divide the US into equal populations or
  areas, and then found the line that best satisfies both conditions.

  - The metropolitan areas on the map are from
  https://www.statcrunch.com/app/index.php?dataid=1232319 with some
  minor modifications.

  - Using census tract data (instead of city data, or county data as
  I'd originally planned) has an interesting effect: the city of
  Denver is split nearly in two by this line, and Provo and Virginia
  Beach are somewhat split as well.

  - The map was created using Mathematica, see bc-us-split.m in the
  directory noted earlier.

  - As noted on
  https://www.census.gov/geo/maps-data/data/gazetteer2010.html, the
  area of tract (which includes both land and water) has the note
  "Created for statistical purposes only", which may mean it's not
  super-accurate. To improve my result, you may want to use a better
  source.

  - This is not necessarily the only line that splits the US this
  way. There were several other almost-as-close candidates that I
  found, and perhaps much better candidates that I didn't
  find. Additionally, improving the accuracy of area or population
  counting could change this line dramatically, as one of the former
  almost-as-close candidates could become the closest candidate.

  - At some point, I'd like to extend this answer with lines that
  split equally among population or area, but not both, since I ended
  up incidentally computing these lines in my Perl script.

  - I used Census 2010 data since it was the easiest data I could
  find. More recent data is doubtless available.

  - I would appreciate anyone checking my results and/or extending
  what I've done.

  - If you want to extend what I've done here and get more accurate
  areas, you may want to consider the approach I used for:
  http://gis.stackexchange.com/a/191054/1462

*)

<</home/barrycarter/BCGIT/QUORA/metros.txt
<</home/barrycarter/BCGIT/QUORA/poparea.m
Read["!bzcat -v -k /home/barrycarter/BCGIT/QUORA/blockgroups.m.bz2"]
usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];
state[n_] := usa[[1,2,2,n]]
states = Table[i, {i,Flatten[{1,Range[3,10],Range[12,50]}]}];

(* state outlines *)
ostates = Table[state[i],{i,states}];

(* text for cities *)
ctext = Table[Text[i[[2]], {i[[4]], i[[3]]}, {-1.1,0.5}], {i, metros}];

(* points for cities *)
cpts = Table[Point[{i[[4]],i[[3]]}], {i, metros}];

(* bg points *)
bgpts = Table[Point[i], {i,blockgroups}];

(* given a list element from eqpop.m, return the portion of the line
crossing the US *)

elt2line[x_] := Line[{
 {-180, Tan[x[[1]]*Degree]*-180 + x[[3]]},
 {180, Tan[x[[1]]*Degree]*180 + x[[3]]}
}];

(* base graphics without bgpts and later with (will do two videos) *)

basegraphics = Graphics[{

 RGBColor[0,0,0],
 ctext,

 EdgeForm[Thin],
 Opacity[0.1],
 ostates,

 Opacity[1],
 RGBColor[1,0,1],
 cpts,

 RGBColor[0,0,0],
 Text[Style["https://tinyurl.com/bcussplit", FontSize -> 60], {-113.5, 28}]

}];

basegraphics = Graphics[{

 RGBColor[0,0,0],
 ctext,

 EdgeForm[Thin],
 Opacity[0.1],
 ostates,

 Opacity[0.25],
 RGBColor[1,0,1],
 PointSize[0.0001],
 bgpts,

 Opacity[1],
 RGBColor[0,0,0],
 Text[Style["https://tinyurl.com/bcussplit", FontSize -> 60], {-113.5, 28}]

}];

vargraphics[n_] := Graphics[{
 RGBColor[1,0,0], elt2line[eqpop[[n]]], RGBColor[0,0,1], elt2line[eqarea[[n]]]
}];

show[n_] := Show[{basegraphics, vargraphics[n]}, 
PlotRange -> {{-125,-67}, {24.5,49.5}}, AspectRatio -> 3/4*Cos[37*Degree],
 ImageSize -> {1024*2,768*2-320}];

export[n_] := Export["/home/barrycarter/20160602/image"<>ToString[n]<>".gif", 
 show[n]];

Table[export[n],{n,1648,1800}];

(*

The export above sometimes fails for specific images; this figures out
which ones and re-does them:

\ls image*.gif | perl -nle '/(\d+)/; print $1' | sort -n | bc-find-gaps.pl

*)

