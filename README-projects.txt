Title: OSM data server that only returns "information you'd want to show"

Description: There are existing OSM dataservers (eg, http://lz4.overpass-api.de/) that will return *all* data in a given latitude/longitude bounding box.

However, this is generally far more data than is required to render a slippy tile.

For example, to render the 0/0/0 slippy tile, we need data for pretty much the entire world. However, we don't need *all* the data for the world: just the shapes and names of the larger continents and countries for example.

In theory, any existing tileserver could be modified to give text output instead of image output.

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

Title: Find formula for geodesic minimum distance to given point

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

Note to self: This should really be bc-travel2orion to avoid naming conflicts

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

URL:

https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land-2.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land-3.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land-4.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.grass
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.m
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.pl
https://github.com/barrycarter/bcapps/tree/master/STACK/bc-buffer-land.sql

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

Description: create a semantic wiki from a single (or few) pages of data

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
Description: Finish answering questions in STACK/README.status

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

  - game on real world map ('YAMC'/'terramapadventure')

  - most files in my git that are not answers to questions relate to
  some project


TODO: add line splitting question and prime number question

TODO: order these

