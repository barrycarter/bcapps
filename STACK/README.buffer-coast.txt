NON-ANSWER
==========

This is not an answer, but may be helpful.

Note that the answers/comments on https://gis.stackexchange.com/questions/294209/calculating-boundary-around-all-land-on-earth may also be helpful.

Short "answer": Yes, there are islands within islands, at least according to NASA. Details:

  - https://www.ngdc.noaa.gov/mgg/shorelines/ has a list of coastline shape files. If you download gshhg-shp-2.3.7.zip from https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/ unzip it, and read the SHAPEFILES.TXT file therein, it says in part:

<blockquote>
The shoreline data are distributed in 6 levels:

Level 1: Continental land masses and ocean islands, except Antarctica.
Level 2: Lakes
Level 3: Islands in lakes
Level 4: Ponds in islands within lakes
Level 5: Antarctica based on ice front boundary.
Level 6: Antarctica based on grounding line boundary.
</blockquote>

Because level 1 includes ocean islands, and level 2 includes lakes, level 3 would be islands in lakes in islands.

You can also get a flavor of this from https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/readme.txt which includes phrases like "ponds-in-islands-in-lakes".

Why stuff like this is (kind of) important:

  - If you download coastal distancing data from https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ you'll note the disclaimer:

<blockquote>
In this file, negative distances represent locations that are considered to be over land according to the GMT coastline database. Landlocked bodies of water (e.g. the Caspian Sea) are also considered to be land in these data sets.
</blockquote>

So, for accurate land-water distancing, you do need to account for inland seas, islands in seas, lakes on islands, islands in lakes on islands, etc. Of course, this could continue indefinitely, but we have data for at least the first 4 levels.

For even greater accuracy, you need to account for rivers, which are also included in the zip file I mention above. These 11 levels of rivers (quoting SHAPEFILES.TXT again):

<blockquote>
Level  1: Double-lined rivers (river-lakes).
Level  2: Permanent major rivers.
Level  3: Additional major rivers.
Level  4: Additional rivers.
Level  5: Minor rivers.
Level  6: Intermittent rivers - major.
Level  7: Intermittent rivers - additional.
Level  8: Intermittent rivers - minor.
Level  9: Major canals.
Level 10: Minor canals.
Level 11: Irrigation canals.
</blockquote>

Note that, except for Level 1, river widths aren't given, so you can't quite calculate hyper-accurate distance from land-water, but can get pretty close.

If you're insanely interested in coastal distancing calculations, please feel free to contact me.

NOTES
=====

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=180&w=-180&n=90&s=-90&center=0,0&url=map3.png&zoom=2

v.in.ogr "/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L1.shp"
v.in.ogr "/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L2.shp"
v.in.ogr "/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L3.shp"
v.in.ogr "/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L4.shp"
v.in.ogr "/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L5.shp"
v.in.ogr "/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L6.shp"

# quoting readme:
The shoreline data are distributed in 6 levels:
Level 1: Continental land masses and ocean islands, except Antarctica.
Level 2: Lakes
Level 3: Islands in lakes
Level 4: Ponds in islands within lakes
Level 5: Antarctica based on ice front boundary.
Level 6: Antarctica based on grounding line boundary.

https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/gshhg-shp-2.3.7.zip

SHAPEFILES.TXT

https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

dist2coast.signed.txt.bz2

https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/

https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/dist2coast.signed.txt.bz2

A signed version of the 0.04-degree data set is also available. In this file, negative distances represent locations that are considered to be over land according to the GMT coastline database. Landlocked bodies of water (e.g. the Caspian Sea) are also considered to be land in these data sets.



look at other SE question and link it

GMT_intermediate_coast_distance_01d.tif

mention song 'hole in bottom of the sea' 'tree that grows and in that tree...'

grass

mention files in github

mention this stream? (in youtube)

GSHHS_shp/c/GSHHS_c_L1.shp


