#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main(int argc, char **argv) {
    SpiceDouble pos[3], et, v[3], lt;
    furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

    // Compute the elevation of the Sun at latitude 35.05, longitude
    // -106.5, elevation 0 at 1900 hours UTC 25 Dec 2015

    // HORIZONS say: 31.5462

    // the fixed position of latitude 35.05, longitude -106.5, elevation 0
    // in the ITRF93 frame (6378.14 and 6356.755 = earth equatorial
    // and polar radii)
    georec_c (-106.5*rpd_c(), 35.05*rpd_c(), 0, 6378.140, (6378.140-6356.755)/6378.137, pos);
    // below yields: -1484.617280,-5011.983943,3642.409386
    printf("POS: %f,%f,%f\n",pos[0],pos[1],pos[2]);

    // convert 1900 hours UTC 25 Dec 2015 to et
//    utc2et_c("2015-12-25 19:00:00 UTC",&et);
    str2et_c("2015-12-25 19:00:00 UTC",&et);
    // below yields: 504342068.183730
    printf("ET: %f\n",et);

    // position of sun from geocenter in ICRF93 coordinates at et above
    spkezp_c(10, 504342068.183730, "ITRF93", "CN+S", 399, v, &lt);
    // below yields: -34921696.421160,-130449973.180741,-58394048.589065
    printf("SUN: %f,%f,%f\n",v[0],v[1],v[2]);

    // position of sun from latitude 35.05, longitude -106.5, elevation 0
    // by subtraction:
    // -3492021.180388, -13044496.1196798, -5839769.0998451

    // angle between above and vector to latitude 35.05, longitude
    // -106.5, elevation 0 to earth center

    // answer turns out to be: 58.2732, so elevation: 31.7268






}

    
