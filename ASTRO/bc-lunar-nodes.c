/* 

Files referenced here are in
https://github.com/barrycarter/bcapps/blob/master/ASTRO/

See also:
http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/index.html for
function reference and download information

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// the next two includes are part of the CSPICE library
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000

// Computes the moon's z value in the ecliptic plane (zero = moon is
// at either ascending or desending node)

void gfq (SpiceDouble et, SpiceDouble *value) {

  // array to hold the XYZ and lt results from spkezp_c
  SpiceDouble res[3];
  SpiceDouble lt;

  // 301 is the moon's "NAIF ID" and 399 is the Earth's NAIF ID; see
  // planet-ids.txt (it git directory referenced above) for details
  spkezp_c(301, et, "ECLIPDATE", "LT+S", 399, res, &lt);

  *value = res[2];
}



  
