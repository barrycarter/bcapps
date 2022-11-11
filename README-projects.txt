see also TWITCH/README

see also any/all TODO files in various directories

====================================================================

Title: Hyperlocalized data

This project will attempt to provide highly localized information
using open source data. A lot of free data is provided at the 30
arcsecond level, which effectively divides the world into 43200 points
of longitude and 21600 points of latitude, providing a total of
`43200*21600` or 933,120,000 grid points, which is close to a billion
or one gig (thus the project name).

Thirty of seconds of arc equates to approximately 1 km of longitude at
the equator and 1 km of latitude anywhere. Thus, each grid area is 1
km^2 or less.

For a given area, the project hopes to provide the following information:

  - Elevation (SRTM) (raster)

  - Climate (Koeppen-Geiger) (http://koeppen-geiger.vu-wien.ac.at/) (raster)

  - Landuse and landcover (ESACCI) (https://www.esa-landcover-cci.org/) (raster)

  - Solar energy availability (raster)

  - Ethnicity data (GREG) (https://icr.ethz.ch/data/greg/) (vector)

  - Population count and density data (GPW) (https://sedac.ciesin.columbia.edu/data/collection/gpw-v4) (raster)

  - Administrative data (gadm) (https://gadm.org/) (vector)

  - Animal habitat data (IUCN) (https://www.iucnredlist.org/) (raster)

  - Timezone (Natural Earth) (vector)

  - Other Natural Earth data that isn't in OSM or another source (mostly vector)

  - computed data such as average time of noon, earliest/latest
  sunrise/sunset/dawn/dusk/etc, coastal distance, and so on (raster)

  - postal code (vector)

  - area code (vector)

  - voting district (at city, county, state, national levels) (vector)

  - neighborhood name (vector)

  - number of lane miles (roads) (raster)

I have sources for most of this information, but it's general in a
format that's not useful for localization.

The challenge will be to store, retrieve, and map this information
efficiently, leveraging existing APIs when possible.

The first iteration is focused on providing semi-permenant data and
isn't interested in real time data such as weather or traffic,
although this may be added later.

Data we will generally NOT want:

  - list of addresses, streets, individual names

====================================================================

Title: Weighted spherical polygonal Voronoi diagrams

What points are 3 times closer to Missouri than to Kansas?

Answering this question requires creating Voronoi diagrams on a
sphere, where the "points" are actually polygons. Additionally,
instead of simple equidistancing, we are using weighted
distance. Wowsers!

Note this project subsumes some of the other Voronoi projects below.

====================================================================

Title: Break this massive ugly git into smaller more correct gits

My laziness led me to create everything I did in one git, which is now
a huge mess. I should work on breaking out projects (and figuring out
which ones are actually git worthy) and uploading them
separately. This will automatically subsume the "fix git comments"
project as well.

TODO: in all cases, check to see if projects exist on github already

TODO: in all cases, make sure these are finished projects, not planned

Projects worth re-gitting:

compute planetary brightness, quasi-fit to known data

list of conjunctions, including venus transits, venus-jupiter-regulus conjunctions (and other conjunctions involving fixed stars, not just planets)

when planets change "houses" astrologically

when planets change constellations astronomically

official names and abbreviations of timezones (windows-fixed.txt)

Projects NOT worth re-gitting:


Projects I've reviewed but am not sure about re-gitting:



====================================================================

Title: Redraw "states" to be Voronoi areas of largest metro areas

Description: Attempts to answer
https://www.reddit.com/r/geography/comments/8qzl3p/if_we_redrew_us_state_lines_by_voronoi_of_the_top/
"If we re-drew US state lines by Voronoi of the top 50 most populous
metro areas, do the new "states" keep the same population rank as the
city they were based on?"

Code:

https://github.com/barrycarter/bcapps/tree/master/REDDIT/bc-metro.m

URL:

http://test.barrycarter.info/bc-image-overlay.pl?url=metrovor.kml&center=37,-95.5&zoom=5&maptypeid=ROADMAP

====================================================================

Title: How much of Earth's land has antipodal land?

Description: Answer the StackExchange question
https://earthscience.stackexchange.com/questions/14132/how-much-of-earths-land-area-has-antipodal-land-area
(what percentage of land has antipodal land vs antipodal water?)

Code:

https://github.com/barrycarter/bcapps/tree/master/STACK/bc-antipodes.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-antipodes.pl

URLs:

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=180&w=-180&n=90&s=-90&center=0,0&url=antipodes.gif&zoom=3&maptypeid=ROADMAP

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=180&w=-180&n=90&s=-90&center=0,0&url=superantipodes.gif&zoom=3&maptypeid=ROADMAP
[large image, may load slowly]

====================================================================

Title: OSM data server that only returns "information you'd want to show"

Description: There are existing OSM dataservers (eg, http://lz4.overpass-api.de/) that will return *all* data in a given latitude/longitude bounding box.

However, this is generally far more data than is required to render a slippy tile.

For example, to render the 0/0/0 slippy tile, we need data for pretty much the entire world. However, we don't need *all* the data for the world: just the shapes and names of the larger continents and countries for example.

In theory, any existing tileserver could be modified to give text output instead of image output. The key appears to be in the SELECT queries used to select features at a given zoom level

A major advantage would be that the end user how to display various types of features, choose what language they want to see those features in, choose what meta-data they want to see, and even dynamically control the display of these features.

====================================================================

Title: Find position of planet using osculating elliptical parameters

Description: Finding the position of a planet in an elliptical orbit
is non-trivial, primarily because the "first" step involves solving
Kepler's Equation (converting mean anomaly to true anomaly). There is
no closed form solution, but an approximation or iterative approach
might work.

Code: https://github.com/barrycarter/bcapps/tree/master/ASTRO/bc-elliptical-orbit.m

See also: https://github.com/skyfielders/python-skyfield/issues/302

====================================================================

Title: Find formula for sun/moon etc positions

Description: Find reasonably accurate functions that return the Sun,
Moon, etc's right ascension and declination at any time. The actual
computations are quite complex, but, using existing data, we might be
able to curve-fit, at least for a given time period (eg, a year)
within a certain tolerance.

Code: 

https://github.com/barrycarter/bcapps/tree/master/bc-approx-sun-ra-dec.m
https://github.com/barrycarter/bcapps/tree/master/bc-approx-ra-dec.pl
https://github.com/barrycarter/bcapps/tree/master/ASTRO/bc-approx-sun-ra-dec.m

(yes, I have a file called bc-approx-sun-ra-dec.m in two locations and
they are not equal-- and yes, that is a mistake I need to fix)

====================================================================

Title: Solar system eclipses, occultations  and transits from various locations

Description: Inspired by https://astronomy.stackexchange.com/questions/34048/how-often-are-there-lunar-eclipses-on-jupiter/34051#34051 we ask the question: when seen from X, how often does Y appear to be obscured, even partially, by any third object Z. Examples for Earth:

  - solar eclipse: X = Earth, Y = Sun, Z = Moon

  - lunar eclipse: X = Earth, Y = Moon, Z = Earth

  - Venus transit: X = Earth, Y = Sun, Z = Venus

This should be solvable by running through all the combinations in CSPICE, but it might be useful to find "interesting" obscurations such as where X, Y, or Z is a planet and/or a large planetary moon.

====================================================================

Title: Display shadows of tall buildings using OpenStreetMap or similar

Description: Using the sun's altitude and azimuth at a given point,
show where the tip of the shadow of tall buildings would touch the
ground.

Note: In this project, I plan to assume the Earth is locally flat, the
surface elevation doesn't change drastically, there are no major
obscurations between the building and where the shadow falls, and
that, if the shadow falls on another building, that building is small
enough that we can assume it's effectively at ground level.

Can't do this for mountains (like Mount Fuji diamond below) because
curvature of the Earth, change in surface elevation, and obscuration
are all issues, since mountains are much taller than buildings (in
general).

Inspired by https://astronomy.stackexchange.com/questions/33902/can-i-use-the-tokyo-skytree-as-clock (using Tokyo Skytree as a clock)

List of tall buildings: https://en.wikipedia.org/wiki/List_of_tallest_towers and https://en.wikipedia.org/wiki/List_of_tallest_buildings

====================================================================

Title: Rewrite Firefox notification code to run external command instead

Description: Firefox's pop-up notification feature is nice, but you
can't control how long the pop-ups remain on screen, and can miss them
entirely if you're away from the computer for more than a few seconds.

This project seeks to rewrite the notification functions so they call
an external program with the text of the notification, adding much
needed flexibility to this feature.

====================================================================

Title: How does number of electoral votes relate to coalition "power"?

Description:
http://politics.stackexchange.com/questions/15180/number-of-winning-coalitions-of-state-in-the-electoral-college
asks a seemingly political question that, as some comments note, is
actually mathematical.

The question: if a state has k votes out of n votes total, what is the
state's "power" in terms of forming coalitions with other states. More
specifically:

  - If a state is part of a winning coalition and leaves, what are the
  chances the coalition will not become a losing coalition?

  - If a state is NOT part of a losing coalition and joins, what are
  the chances the coalition will now become a winning coalition.

Code: https://github.com/barrycarter/bcapps/tree/master/STACK/bc-coalition.m

====================================================================

Title: Convert series of complete backups to incremental backups

Description: Convert a series of complete backups that are nearly
identical and fairly large (thus taking up a lot of space) into
incremental backups that are much smaller, perhaps using something
like git to store incrementals

Code: https://github.com/barrycarter/bcapps/tree/master/BACKUP/bc-targz2git.pl

====================================================================

Title: Find correlations in weather data

Description: There's a lot of weather data out there, including both
time series data (temperature, dew point, sky cover, etc) and fixed
data (latitude, longitude, elevation). It would be interesting to see
if there are any correlations in such data by putting it into some
program (or writing one) that does basic correlation analysis.

Of course, the actual formula between some of these data may be far
from linear, so additional "correlation" functions may be needed.

Can also use weather data to determine when "summer" starts and ends
for various locations, for example: summer begins 45 days on either
side of highest high maybe?

This "mass correlation" project could be used to answer questions like:

https://earthscience.stackexchange.com/questions/18151/deserts-and-humidity

https://earthscience.stackexchange.com/questions/18158/precipitation-and-elevation

https://earthscience.stackexchange.com/questions/18663/weather-forecast

https://earthscience.stackexchange.com/questions/18591/is-there-any-link-between-the-weekly-human-cycle-and-weather (using weekday as an input variable)

https://earthscience.stackexchange.com/questions/18183/local-weather-forecast-self-learning-algorithm

https://earthscience.stackexchange.com/questions/3160/statistical-weather-prediction

https://earthscience.stackexchange.com/questions/4480/predicting-school-closures-with-historical-weather-prediction-data (using school closure as an output variable)

https://earthscience.stackexchange.com/questions/8716/how-does-elevation-affect-the-amount-of-rainfall-received

https://earthscience.stackexchange.com/questions/18447/predicting-the-weather-in-two-months

https://earthscience.stackexchange.com/questions/16366/weather-forecast-based-on-pressure-temperature-and-humidity-only-for-implement

https://earthscience.stackexchange.com/questions/9306/is-it-typically-colder-after-a-storm

and probably many others.

====================================================================

Title: Find formula for geodesic (great circle) minimum distance to given point

Description: Find the minimum distance between a given geodesic and a
given point on the sphere, and also the point on the geodesic where
this minimum occurs. This answers the stackexchange question below:

Reference: https://math.stackexchange.com/questions/23054/how-to-find-the-distance-between-a-point-and-line-joining-two-points-on-a-sphere

Code: https://github.com/barrycarter/bcapps/tree/master/MAPS/bc-geodesic.m

====================================================================

Title: Determine center of population for all countries

Description: Somewhat surprisingly, I couldn't find a site that lists
the mean center of population for countries like Norway. Neither of
these pages has it:

https://en.wikipedia.org/wiki/Demographics_of_Norway

https://en.wikipedia.org/wiki/Norway

and a google search for "Norway center of population" (without quotes)
yields nothing helpful.

This doesn't appear to be a difficult problem, so I am coding it.

Code: https://github.com/barrycarter/bcapps/tree/master/COW/bc-coc.pl

====================================================================

Title: Use SRTM1 data and Three.js for realistic citiscapes

Description: there's a program (TODO: find its name) that uses
openstreetmap.org data to create a 3D map of a city. Can we do the
same thing just using SRTM1 data instead? openstreetmap.org has enough
data to map some places really well, but not every place. SRTM1 is
limited by latitude, but covers more major cities. Note .BIL files may
work better, but my early attempts don't seem to be working well

====================================================================

Title: Download wordpress sites using Wordpress API

Description: find or write program (like tumblr_backup.py) to download
a wordpress blog, primarily from wordpress.com

Note: This might be trivial.

====================================================================

Title: Convert particle systems from libgd to JavaScript

Description: Convert the particle systems in
https://github.com/barrycarter/bcapps/tree/master/PARTICLEMAN/ to
JavaScript and perhaps create new ones.

Note: This might be trivial.

====================================================================

Title: Determine which constellation a given ra/dec is

Description: Using the original IAU boundaries, figure out a
reasonably efficient way to determine what constellation a given
right ascension/declination is.

In practice, the target location will be precessed to B1875.0
coordinates, which seems easier than precessing the constellation
lines themselves.

Note: https://github.com/skyfielders/python-skyfield/commit/348f03caa3e0398dbce02d8be15117d851782f26
may be useful here

TODO: Sun was in CET and ORI year +-10000, do something with this

====================================================================

Title: Implicit semantic information for OpenStreetMaps + more

Description: Many OpenStreetMap tags are redundant; instead of
massively tagging every feature, create a set of logic rules that
determine which tags imply which other tags, and create an engine that
adds these new "virtual" tags when someone requests an API call.

Simple example: OSM recently decided that all Dunkin Donuts should
have "amenity" tag "fast_food" (see
https://maproulette.org/browse/challenges/3705). Currently, this is a
manual task because it's possible the location is no longer a Dunkin
Donuts. Part of this task could be automated by simply declaring all
Dunkin Donuts are amenity:fast_food as a virtual tag.

====================================================================

Title: Text adventure "game" using OpenStreetMaps

In client-side Javascript, use the OSM API to describe where someone
is, allow them to move in cardinal directions, enter buildings,
teleport, and so on. Mostly just for fun, provide a textual
description of where they are using OSM API

====================================================================

Title: JavaScript showing travel between stars

Description: Using a list of stars whose three-dimensional positions
are known (which is NOT GAIA2, since the parallaxes (and thus the
computed distances) are too inaccurate), allow people to wander
through our galaxy seeing the sky from different places.

URL:

https://github.com/barrycarter/bcapps/tree/master/ASTRO/hygdata_v3.csv.gz
https://github.com/barrycarter/bcapps/tree/master/ASTRO/travel2orion.m
https://github.com/barrycarter/bcapps/tree/master/ASTRO/travel2orion.pl
https://repl.it/@barrycarter/HYGStarMap

Note to self: This should really be bc-travel2orion (not simply
travel2orion) to avoid naming conflicts

====================================================================

Title: Brightest star in night sky of exoplanets + brightest city in location

Description: Two very different but related projects:

From various exoplanets, which stars are the brightest? For us,
Sirius is the brightest star in the night sky. What is it for other
exoplanets? A more general question is: how does the night sky differ
between Earth and other exoplanets (since most exoplanets are fairly
close, probably not by much, but the small changes that do occur might
be interesting).

From various places on the world, what is the "brightest" city
visible, assuming city brightness is proportional to population (which
isn't really true) and possible including "urban areas" instead of
just cities.

URL:

https://github.com/barrycarter/bcapps/blob/master/ASTRO/bc-solve-astro-13115.m

https://astronomy.stackexchange.com/questions/13115/from-which-exoplanets-is-our-sun-the-brightest-star-on-the-night-sky/13119?noredirect=1#comment60646_13119

====================================================================

Title: Solve special relativity problems from "eyeball" point of view

Description: Physicists have developed formulas to solve relativity
based problems (ie, Lorentz contraction and time dilation effects when
objects are traveling a high relative velocity to each other), but
almost all of these depend on assigning fictional times to events,
leading to things like the Andromeda Paradox.

I'd like to solve these problems with a "what would you see if you
were actually doing this" approach. This would combine mundane effects
such as the Doppler Effect with relativity equations.

URL:

https://github.com/barrycarter/bcapps/tree/master/STACK/bc-accel.m

====================================================================

Title: What great circle line splits US into equal areas and populations?

Description: There are many ways to split the US into two pieces that
have equal area or equal population, but only one line that does
both. The goal is to find this line. I've done this incorrectly
assuming equirectangular lines, but now want to do it correctly.

Notes: Uses Census "blockgroup" data so lines can split cities, does
not treat cities as "point masses".

URL: 

https://github.com/barrycarter/bcapps/tree/master/QUORA/bc-us-split.m
https://github.com/barrycarter/bcapps/tree/master/QUORA/bc-us-split.pl

====================================================================

Title: Fix all git commits/comments

Description: I've gotten very lazy with commenting git commits, partly
because I often update multiple unrelated files at once. It would be
nice to look at the diffs for each file individually and create a git
commit/comment history from that. Of course, this would mean creating
a new git repository entirely, or finding a way to "parallel" git's
structure to add my own comments.

Note that these per-file changes could also be documented separately,
outside of gits own log structure.

====================================================================

Title: Better coastal distance/water distance maps

Description: There are existing maps that show a given point's
distance from land/water, but they ignore inland seas and treat things
like the Caspian Sea as land. I want to improve these maps to be more
accurate. I've done some work using GRASS and want to expand on that.

Languages: GRASS GIS

Code:

https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land-2.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land-3.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land-4.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.grass
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.pl
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.sql

URLs:

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=180&w=-180&n=90&s=-90&center=0,0&url=map3.png&zoom=3

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=180&w=-180&n=90&s=-90&center=0,0&url=coasthundredth.png&zoom=2
[large image, may load slowly]

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=180&w=-180&n=90&s=-90&center=0,0&url=supercoast.png&zoom=2
[rivers]

====================================================================

Title: Find trigonometric properties of triangle algebraically

Description: Given a triangle (possibly in the complex plane), compute
the medians (lengths, formulas, intersections, etc), angle bisectors,
altitudes, etc, algebraically, possibly to see if we can find any new
geometric relations.

Perhaps extend this to other geometric figures.

URL: 

https://github.com/barrycarter/bcapps/tree/master/MATHEMATICA/bc-triangle-man.m
https://github.com/barrycarter/bcapps/tree/master/MATHEMATICA/bc-triangle-man2.m
https://github.com/barrycarter/bcapps/tree/master/MATHEMATICA/bc-triangle.m

====================================================================

Title: Nagyerass, a nagios replacement

Description: My version of "nagios" that works, in my opinion, slightly better.

URL: https://github.com/barrycarter/bcapps/tree/master/NAGYERASS

====================================================================

Title: Map server/data server

Description: Create a server that provides data, primarily for
mapping, but which can theoretically be used for any purpose. Will
include both 'fixed' data (such as elevation), current data (such as
current weather conditions) and computed data (such as time of
sun/moon rise/set)

URL: https://github.com/barrycarter/bcapps/tree/master/MAPS/README

====================================================================

Title: Generate passwords from answers to questions w/o storing password

Description: For any given site, user creates a list of questions, and
the answers to those questions, joined with semicolons (or whatever)
is SHA1 hashed and the hash is converted to a password, perhaps with
fixed salting. The password generation is in JavaScript and occurs
completely client side. The password isn't stored anywhere-- when the
user types in the same answers, it's simply re-generated. Will have
options for password length, required complexity, permitted
characters, etc.

Site names and questions and password options (ie, complexity, length,
and character requirements) will be stored server side, but the
password itself won't be.

URL: https://github.com/barrycarter/bcapps/tree/master/bc-generate-pw.html

====================================================================

Title: Orthographically project OpenStreetMaps (OSM)

URL: https://barrycarter.github.io/pages/MAPS/bc-test-3d.html

Description: Instead of displaying OSM on a Google-like Web Mercator
map, use a more natural orthographic projection.

====================================================================

Title: Docker container for CSPICE (and other things?)

Description: Create Docker containers for CSPICE astronomical
libraries so that people can start writing code immediately. Include
something like de430.bsp for the "lite" version and de431 both parts
for the "heavy" version.

Perhaps create Docker containers for other useful software that is
nontrivial to setup (no graphical software however)

====================================================================

Title: GAIM-ify (not gamify) or Pidgin-ify the console

Description: I use GAIM (Pidgin) for a variety of accounts, but it
would be nice if I could access the console from GAIM, particularly
since I could use command-line clients directly from Pidgin. This
shouldn't be hard to do, since Pidgin already connects to IRC and it
seems you could just hack around to get this to work.

A telnet (or ncat) interface would suffice, and allow connections to
MOOs, MUSHes, etc (like tinyfugue aka tf), although few exist today.

My stack question on the subject: https://unix.stackexchange.com/questions/22791/can-i-use-gaim-pidgin-to-telnet-for-moos-mushes-muds-etc-like-tf/33518

====================================================================

Title: Better ad blocker: download ads but don't display them

NOTE: ublock may already be doing this

URL: none

Description: Sites can detect ad blockers, so create a new one that
downloads their ad but never displays it to you, making it much harder
for them to tell you are blocking their ads.

====================================================================

Title: Jekyll-Wordpress fusion: locally edited blog w/ WP features

URL: none yet (but see "sub post_to_wp" in bclib.pl)

Description: allow local editing of a wordpress wiki as though it were
a jekyll wiki (ie, allow mirroring and easy post creations)

====================================================================

Title: Rosetta: convert code (especially mathematical formulas) between languages

URL: https://github.com/barrycarter/bcapps/blob/master/ROSETTA

Description: Convert Mathematica formulas into various other
programming languages

====================================================================

Title: Mt Fuji diamond: where can people see this phenomena?


URL: https://github.com/barrycarter/bcapps/blob/master/STACK/bc-fuji.m

Description: predict where people can see "Diamond Fuji", the sun
appearing as a "diamond ring" as it sets over Mount Fuji. An extended
version is https://github.com/barrycarter/bcapps/blob/master/DEM/
which attempts to determine the true horizon for any location using
digital elevation map (DEM) data. Diamond Fuji URLS/images:
https://www.tripadvisor.com/LocationPhotoDirectLink-g1104179-d1369080-i115862499-Lake_Yamanaka-Yamanakako_mura_Minamitsuru_gun_Yamanashi_Prefecture_Chub.html
https://www.fujiyama-navi.jp/en/entries/xZ0rQ
https://tripla.jp/cool-japan-diamond-fuji/
http://yamanakako.info/photo_diamond.php (page is in Japanese, and may
do what this project tries to do)
http://www2e.biglobe.ne.jp/%7Ewoody/mt97.jpg
http://www.gettyimages.fr/%C3%A9v%C3%A9nement/diamond-fuji-observed-156231577
https://www.garyjwolff.com/diamond-fuji-viewing-spots-dates-and-times-in-tokyo.html

====================================================================

Title: True sunrise and sunset times allowing for local topography

URL: https://github.com/barrycarter/bcapps/tree/master/DEM/

Description: A generalization of sorts of the project above, this
would use SRTM/DEM data to let people calculate where and when the sun
will set over non-flat/mountainous horizons

====================================================================

Title: Astronomical conjunctions

URL: https://github.com/barrycarter/bcapps/blob/master/ASTRO 

Showcase: http://search.astro.barrycarter.info/

Status: pretty much finished

=====================================================================

Title: OSM/Google Maps for stars, with a few more features

URL: https://github.com/barrycarter/bcapps/blob/master/JAVA

Notes: Sort of google maps for stars, probably already done to death though

=====================================================================

Title: Reprojected world maps from slippy tiles

URL: https://github.com/barrycarter/bcapps/blob/master/MAPS

Description: create images similar to the ones in the directory above,
but qgis and other GIS programs may already do this

=====================================================================

Title: Semantify existing wikis, eg, Full(er) House, maybe from wikia

Description: Create semantic annotations for existing wikis by
downloading the source, editing it, and republishing it with semantic
information; similar to "Auto-populated wikis using meta-wiki pages"
but for existing wikis.

=====================================================================

Title: Auto-populated wikis using meta-wiki pages

URL: https://github.com/barrycarter/bcapps/blob/master/METAWIKI/

Showcase: http://pbs3.referata.com/wiki/Main_Page

Description: create a semantic wiki from a single (or few) pages of
data and/or locally create a regular wiki like thing from a single
page with all the meta work being done client-side (so result is
simple HTML on other side?)

=====================================================================

Title: Determine characteristics of "concatenate d10 until prime" number game

Description: Roll a ten sided dice repeatedly and concatenate digits
until the result is prime. Question: what are the characteristics of
this game (does it always end? [ie, with 100% probability] how long
does it take to end?)

URL: https://github.com/barrycarter/bcapps/tree/master/QUORA/bc-primes.m

=====================================================================

Title: (META) Answer various questions on StackExchange, Reddit, Quora, etc

Description: I've tried to answer many questions from the q-and-a
sites above, and would like to write up what I have so far or actually
finish solving the problem. Some of these questions have been broken
out above, others are only in the URLs below or just dangling in
various files.

URL: 

https://github.com/barrycarter/bcapps/tree/master/STACK/README.status
https://github.com/barrycarter/bcapps/tree/master/QUORA/README.status
https://github.com/barrycarter/bcapps/tree/master/REDDIT/README.status

=====================================================================

Title: Find or create calendar that gives dates in various formats

Description: I vaguely remember a calendar program that would give
dates in various formats, such as Chinese calendar, Muslim calendar,
Discordian calendar, and many others; either find this program or
create one that replicates it.

See also:

  - https://en.wikipedia.org/wiki/Solar_term

  - http://www.public.asu.edu/~checkma/today.html

  - https://isotropic.org/date/

  - https://askubuntu.com/questions/909908/linux-program-with-hebrew-islamic-coptic-discordian-and-other-calendars (my question)

  - https://github.com/vinc/cadate (written by someone else as an answer to my question above, uses Javascript's Luxon library, but still not complete)

  - https://en.wikipedia.org/wiki/Module:Year_in_various_calendars

  - https://en.wikipedia.org/wiki/Template:Calendars

Notes:

  - List of calendar systems I could find so far (striving to keep these in alpabetical order, some have been Romanicized):

    - (French) Republican (TODO: same as "French" below?)
    - Ab urbe condita
    - Armenian
    - Assyrian
    - Aztec
    - Bahai
    - Balinese saka
    - Bengali
    - Berber
    - British Regnal
    - Buddhist
    - Burmese
    - Byzantine
    - Chinese
    - Church of the SubGenius
    - Coptic
    - Discordian
    - Ethiopic (Coptic)
    - French 
    - Galactic Milieu
    - Goddess Lunar Calendar
    - Gregorian [this is the most commonly used system]
    - Hebrew 
    - Hindu (Civil)
    - Hindu: Kali Yuga
    - Hindu: Shaka Samvat
    - Hindu: Vikram Samvat
    - Holocene
    - Human Calendar
    - Igbo
    - Illuminati
    - International Fixed Calendar
    - Iranian (TODO: same as Persian?)
    - Islamic 
    - Jalali/Persian
    - Japanese
    - Javanese
    - Juche
    - Jusanotoron
    - Korean
    - Mayan
    - Millennium Mars Calendar
    - Minguo
    - Moonwise Calendar
    - Nanakshahi
    - New Science Calendar
    - Pataphysique
    - Positivist
    - Quaker (Friend)
    - Symmetry
    - Thai solar
    - Thelema
    - Tibetan
    - World Season Calendar
    - Worldsday
    - Zoroastrian (Fasli)

  - TODO: cleanup list below (from https://en.wikipedia.org/w/index.php?title=Template:Calendars&action=edit) and merge into list above

| group3 = In wide use
| list3 =
* [[Astronomical year numbering|Astronomical]]
* [[Bengali calendars|Bengali]]
* [[Chinese calendar|Chinese]]
* [[Ethiopian calendar|Ethiopian]]
* [[Hebrew calendar|Hebrew]]
* [[Hindu calendar|Hindu]]
* [[Iranian calendars|Iranian]]
* [[Islamic calendar|Islamic]]
* [[ISO week date|ISO]] 
* [[Unix time]]
* [[Akan calendar|Akan]]
* [[Armenian calendar|Armenian]] 
* [[Assyrian calendar|Assyrian]]
* [[Bahá'í calendar|Bahá'í]]
** Badí
* [[Pawukon calendar|Balinese pawukon]]
* [[Balinese saka calendar|Balinese saka]]
* [[Berber calendar|Berber]]
* [[Buddhist calendar|Buddhist]]
* [[Burmese calendar|Burmese]]
* [[Chinese calendar|Chinese]]
** [[Earthly Branches]]
** [[Heavenly Stems]]
* [[Gaelic calendar|Gaelic]]
* [[Heathen holidays|Germanic heathen]]
* [[Georgian calendar|Georgian]]
* [[Hindu calendar|Hindu or Indian]]
** [[Vikram Samvat]]
** [[Indian national calendar|Saka]]
* [[Igbo calendar|Igbo]]
* [[Iranian calendars|Iranian]]
** [[Jalali calendar|Jalali]]
*** medieval
** [[Solar Hijri calendar|Hijri]]
*** modern
** [[Zoroastrian calendar|Zoroastrian]]
* [[Islamic calendar|Islamic]]
** [[Fasli calendar|Fasli]]
** [[Tabular Islamic calendar|Tabular]]
* [[Vira Nirvana Samvat|Jain]]
* [[Japanese calendar|Japanese]]
* [[Javanese calendar|Javanese]]
* [[Korean calendar|Korean]]
** [[North Korean calendar|''Juche'']]
* [[Kurdish calendar|Kurdish]]
* [[Lithuanian calendar|Lithuanian]]
* [[Malayalam calendar|Malayalam]]
* [[Mongolian calendar|Mongolian]]
* [[Melanau calendar|Melanau]]
* [[Nanakshahi calendar|Nanakshahi]]
* [[Nepal Sambat]]
* [[Nisga'a#Nisgaa calendar/life|Nisga'a]]
* [[Borana calendar|Oromo]]
* [[Romanian months|Romanian]]
* [[Somali calendar|Somali]]
* [[Sotho calendar|Sesotho]]
* [[Slavic calendar|Slavic]]
** [[Slavic Native Faith's calendars and holidays|Slavic Native Faith]]
* [[Tamil calendar|Tamil]]
* [[Thai calendar|Thai]]
** [[Thai lunar calendar|lunar]]
** [[Thai solar calendar|solar]]
* [[Tibetan calendar|Tibetan]]
* [[Vietnamese calendar|Vietnamese]]
* [[Xhosa calendar|Xhosa]]
* [[Yoruba calendar|Yoruba]]

  | group2 = Types
  | list2 =
* [[Runic calendar|Runic]]
* [[Mesoamerican calendars|Mesoamerican]]
** [[Mesoamerican Long Count calendar|Long Count]]
** [[Calendar round]]

  | group3 = Christian variants
  | list3 =
* [[Coptic calendar|Coptic]]
* [[Julian calendar|Julian]]
** [[Revised Julian calendar|Revised]]
* [[Liturgical year]]
** [[Eastern Orthodox liturgical calendar|Eastern Orthodox]]
* [[Calendar of saints|Saints]]
 }}

<!--------------------------------------------------------->
| group5 = Historical
| list5 =
* [[Attic calendar|Attic]]
* [[Aztec calendar|Aztec]]
** [[Tnalphualli]]
** [[Xiuhphualli]]
* [[Babylonian calendar|Babylonian]]
* [[Bulgar calendar|Bulgar]] 
* [[Byzantine calendar|Byzantine]]
* [[Cappadocian calendar|Cappadocian]]
* [[Celtic calendar|Celtic]]
* [[Cham calendar|Cham]]
* [[Chula Sakarat|Culsakaraj]]
* [[Egyptian calendar|Egyptian]]
* [[Florentine calendar|Florentine]]
* [[French Republican Calendar|French Republican]]
* [[Germanic calendar|Germanic]]
* [[Ancient Greek calendars|Greek]]
* [[Hindu calendar|Hindu]]
* [[Inca calendar|Inca]]
* [[Ancient Macedonian calendar|Macedonian]]
* [[Maya calendar|Maya]]
** [[Haab']]
** [[Tzolk'in]]
* [[Muisca calendar|Muisca]]
* [[Pentecontad calendar|Pentecontad]]
* [[Pisan calendar|Pisan]]
* [[Rapa Nui calendar|Rapa Nui]]
* [[Roman calendar]]
* [[Rumi calendar|Rumi]]
* [[Soviet calendar|Soviet]]
* [[Swedish calendar|Swedish]]
* [[Renaming of Turkmen months and days of week, 2002|Turkmen]]

<!--------------------------------------------------------->
| group6 = By specialty
| list6 = <!--Alphabetically by specialty:-->
* [[Holocene calendar|Holocene]]
** anthropological
* [[Proleptic Gregorian calendar|Proleptic Gregorian]]{{\}}[[Proleptic Julian calendar|Proleptic Julian]]
** historiographical
* [[Darian calendar|Darian]]
** Martian
* [[Dreamspell]]
** New Age
* [[Discordian calendar|Discordian]]
* [['Pataphysics#Pataphysical calendar|'Pataphysical]]

<!--------------------------------------------------------->
| group7 = [[:Category:Proposed calendars|Proposals]]
| list7 =
* [[Calendar reform]]
* [[HankeHenry Permanent Calendar|HankeHenry Permanent]]
* [[International Fixed Calendar|International Fixed]]
* [[Pax Calendar|Pax]]
* [[Positivist calendar|Positivist]]
* [[Symmetry454]]
* [[World Calendar|World]]
** [[New Earth Time]]


<!--------------------------------------------------------->
| group8 = Fictional
| list8 =
* [[Discworld (world)#Calendar|Discworld]] (''[[Discworld]]'')
* [[Flanaess#Calendar|Greyhawk]] (''[[Dungeons & Dragons]]'')
* [[Middle-earth calendar|Middle-earth]] (''[[The Lord of the Rings]]'')
* [[Stardate]] (''[[Star Trek]]'')
* [[Yavin|Galactic Standard Calendar]] (''[[Star Wars]]'')

<!--------------------------------------------------------->
| group9 = {{longitem|Displays and<br/>applications}}
| list9 =
* [[Calendaring software|Electronic]]
* [[Perpetual calendar|Perpetual]]
* [[Calendar (stationery)|Wall]]

<!--------------------------------------------------------->
| group10 = {{longitem|Year naming<br/>and<br/>numbering}}
| list10 =
 {{Navbox|subgroup |groupstyle=font-weight:normal;

  | group1 = Terminology
  | list1 =
* [[Calendar era|Era]]
* [[Epoch (reference date)|Epoch]]
* [[Regnal name|Regnal name]]
* [[Regnal year]]
* [[Year zero]]

  | group2 = Systems
  | list2 =
* [[Ab urbe condita]]
* [[Anno Domini]]/[[Common Era]]
* [[Anno Mundi]]
* [[Eponym dating system|Assyrian]]
* [[Before Present]]
* [[Chinese era name|Chinese Imperial]]
* [[Minguo calendar|Chinese Minguo]]
* [[Holocene calendar|Human Era]]
* [[Japanese era name|Japanese]]
* [[Korean era name|Korean]]
* [[Seleucid era|Seleucid]]
* [[Spanish era|Spanish]]
* [[Yuga|Yugas]]
** [[Satya Yuga|Satya]]
** [[Treta Yuga|Treta]]
** [[Dvapara Yuga|Dvapara]]
** [[Kali Yuga|Kali]]
* [[Vietnamese era name|Vietnamese]]
 }}

  - TODO: maybe trim the list of calendars above to ones that realistically exist and not completely invented and were never used

  - TODO: some of the calendar systems above are reformatting of the Gregorian calendar; identify these are they don't actually use separate "dates"

  - TODO: The weekdays and months in the Gregorian calendar are different in different languages, but I do not consider these to be separate calendars

  - Emacs `calendar` mode does this to some extent, and has extensions for more calendar systems

  - Per emacs "bindings for calendar-mode", some calendar systems are: 
  - Other calendars include Discordian, but there are others

  - gcal can show Chinese calendar months and holidays, but I haven't found out how to make it show the actual Chinese calendar itself

  - It's possible the program I remember was just a shell script
  around programs like `ddate` and `hebcal` (which does this for the Discordian and Hebrew calendars)

  - This program is not related to https://github.com/barrycarter/bcapps/tree/master/CALENDAR/ which is a standard Gregorian calendar that strives to list "important" dates

====================================================================


Subject: M.U.L.E. (game)
URL: https://github.com/barrycarter/bcapps/blob/master/YAMC
Showcase: none
Notes: a M.U.L.E. clone that can be played on an arbitrary sized map

Subject: Geolocation
URL: https://github.com/barrycarter/bcapps/blob/master/GEOLOCATION
Showcase: none yet, help me create one

Subject: Geography
URL: https://github.com/barrycarter/bcapps/blob/master/GEONAMES/
Showcase: http://albuquerque.weather.94y.info/ gives Albuquerque
current conditions for nearest weather station; in theory, any dotted
city notation in place of Albuquerque should work
TODO: Add sun/moon rise/set and dusk/dawn

Subject: Closed Captioning
URL: https://github.com/barrycarter/bcapps/blob/master/data/
Showcase: none really, attempt to collect DVD CC rips

Subject: Choose Your Own Adventure (books)
URL: https://github.com/barrycarter/bcapps/blob/master/CYOAGRAPH/
Showcase: none yet, help me create one

Subject: FreeDink (game)
URL: https://github.com/barrycarter/bcapps/blob/master/DINK
Showcase: none yet, help me create one

Subject: Misc
URL: https://github.com/barrycarter/bcapps/
Showcase: none, poke around and see if anything interests you

Subject: Entertainment
URL: https://github.com/barrycarter/bcapps/blob/master/VIDEO/
Showcase: https://www.youtube.com/watch?v=c5zBq0bPnW8 (but sucks)
Description: view multiple videos (eg, all episodes of a given series) very rapidly, multiple videos at a time (using tiling), no sound
TODO: improve showcase

Subject: Astronomy
URL: none yet
Description: Use the Hipparcos/HYG catalog (the largest one w/ distances) to create video of zooming around the universe; Celestia lets you view from other stars but not sure it allows you to see video of the travel

Subject: Astronomy
URL: https://github.com/barrycarter/bcapps/blob/master/ASTRO/bc-astro-formulas.m
Description: Closed form formulas for astronomy (useful when doing "meta astronomy" and not numerically precise astronomy)

Subject: Various
URL: NA
Description: Finish answering questions in STACK/README.status and STACK/unsolved.txt

Subject: Blogging
URL: WORDPRESS/README
Description: Command line Wordpress posting + actual things I want to post

TODO: write up these mini-ideas

  - fictitious UNIX time zones

  - abusing DNS text records to provide small chunks of info over UDP

  - automated character time measurement, scene measurement is another
  (in TV shows) [ie, conclusively figure out how much screen time each
  actor/character has w/o watching the movie/show]

  - GAIA2 star catalog in 3D

  - triangle dissection/shapes in general

  - game on real world map ('YAMC'/'terramapadventure') [geogigagrid and G1GG are possible other names]

  - most files in my git that are not answers to questions relate to
  some project


TODO: library of well known sha1sums for various distributions etc (perhaps as shortcut to backing up apps and important files)

TODO: add line splitting question and prime number question

TODO: order these

TODO: look thru starred SE questions

TODO:
https://astronomy.stackexchange.com/questions/27468/table-of-dates-for-planet-retrograde-motion/27479#27479
? perhaps combine with
https://astronomy.stackexchange.com/questions/27914/tables-of-aphelion-perihelion-dates-for-other-planets/27955#27955
(and similar, but these should already exist somewhere?)

TODO: magnitude computations (Lambertian and almost +1 if normalized), add to CSPICE if possible

TODO: fuse filesystem that treats multiple files as single longer file (useful for sites with individual file size limits but not file size limits?)

TODO: client-side javascript wiki

TODO: overlay antipodal map (good for beginners)

TODO: for a great circle between A and B, there are two points C and D
that form the north and south poles if the great circle is the
equator-- formula or something to find these points

TODO: f(f(x)) = x^2 + 1 (using linear algebra)

TODO: leaflet starmap where zooming in gives you fainter stars, in theory up to the billion limit of GAIA2 (but someone might already be doing that)

TODO: get xclock to display fractional seconds (which may require tweaking strftime or xclock.c)

TODO: dynamic scale OSM

TODO: OSM move tiles w/ reshaping

TODO: use DFQs to compute planetary and other planet moons position without using prepackaged BSP files

TODO: miniproject: people sometimes enter arguments on the command line and other times via pipeline into stdin-- write a perl subroutine that uses ARGV when present and stdin when not-- of course, it would only apply to some programs not all, and it obviously wouldnt apply to programs that use both stdin and command line args

TODO: more aggressively look to see if people have already done these things

TODO: overlay UTM grid on openstreetmaps (good for beginners)
