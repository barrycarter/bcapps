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

Title: Find trignometric properties of triangle algebratically

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

  - fictious unix time zones

  - abusing dns text records to provide small chunks of info over UDP

  - automated character time measurement, scene measurement is another
  (in tv shows) [ie, conclusively figure out how much screen time each
  actor/character has w/o watching the movie/show]

  - GAIA2 star catalog in 3D

  - triangle dissection/shapes in general

  - game on real world map ('yamc'/'terramapadventure')

  - most files in my git that are not answers to questions relate to
  some project


TODO: add line splitting question and prime number question

TODO: order these

