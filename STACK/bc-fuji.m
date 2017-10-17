(*

https://astronomy.stackexchange.com/questions/23165/viewing-diamond-fuji

TODO: refraction, Earth's curvature, Earth's ellipticity, ask Japanese Twitter peeps, DEM files for viewer, historical images

*)

(* some approximations *)

(* 

NOTES:

highest mountain in Japan at 3,776.24 m (12,389 ft)

35°21#29#N 138°43#52#ECoordinates: 35°21#29#N 138°43#52#E#[2]

so at 5 degrees...

tan 5 = height / dist so dist = height / tan 5 or 43.162 km

14km at 15 degrees

6.5km at 30 degrees

flon = (138+43/60+52/3600)*Degree
flat = (35+21/60+29/3600)*Degree

(* kilometers *)
fele = 3776240/1000

sph2xyz[flon, flat, rad[flat]+fele]

*)

(*

diamond fuji pics:

https://ca.wikipedia.org/wiki/Diamond_Fuji Catalan

https://commons.wikimedia.org/wiki/File:Diamond_Fuji.jpg#globalusage

convert from frame at lan/lon/el to "earth frame"

local frame: north is y axis (map style)

testing/guessing

test = rotationMatrix[z,lon].rotationMatrix[x,lat-Pi/2]

test.{0,1,0} /. lat -> 0

THIS IS WRONG!!

that takes north to

test.{0,1,0}

what we need

at lat/lon 0, {0,1,0} goes to {0,0,1}

anywhere on eq in fact


*)



