#include <stdio.h>
#include <stdlib.h>
#include "SpiceUsr.h"

int main(int argc, char *argv[])
{
  // Check if the correct number of command line arguments were provided
  if (argc != 3) {
    printf("Usage: sunset latitude longitude\n");
    return 1;
  }

  // Set the latitude and longitude
  SpiceDouble latitude = atof(argv[1]);
  SpiceDouble longitude = atof(argv[2]);

  // Load the required SPICE kernels
  // I had to change this
  furnsh_c("/home/barrycarter/SPICE/KERNELS/de431_part-2.bsp");
  furnsh_c("/home/barrycarter/SPICE/KERNELS/pck00010.tpc");
  furnsh_c("/home/barrycarter/SPICE/KERNELS/naif0011.tls");

  // Set the time format for output
  utc2et_c("2022 JAN 1 12:00:00", &et);
  str2et_c("YYYY MON DD HR:MN:SC.### ::TDB", &et, 31, timstr);
  
  // Set the observer's location
  SpiceDouble obsrvr[3];
  georec_c(longitude, latitude, 0.0, 6378.140, 0.0, obsrvr);

  // Set the target body to be the Earth
  ConstSpiceChar *target = "EARTH";

  // Set the reference frame to be the IAU_EARTH frame
  ConstSpiceChar *ref    = "IAU_EARTH";

  // Set the aberration correction to be "CN+S" (geometric position)
  ConstSpiceChar *abcorr = "CN+S";

  // Set the observer-target state to be the position of the Earth
  // relative to the observer
  SpiceDouble state[6];
  spkezr_c(target, et, ref, abcorr, "Sun", state, &lt);

  // Compute the sun's altitude above the horizon
  SpiceDouble sunAlt;
  recrad_c(state, obsrvr, &sunAlt);
  sunAlt = halfpi_c() - sunAlt;

  // Set the step size for the search in seconds
  SpiceDouble step = 300.0;

  // Set the convergence tolerance in seconds
  SpiceDouble tol = 1e-6;

  // Set the maximum number of iterations
  SpiceInt maxn = 1000;

  // Search for the time of sunset
  SpiceDouble sunsetET;
  SpiceBoolean found;
  gfsstp_c(et, target, ref, abcorr, obsrvr, step, tol, maxn, &sunsetET, &found);

  // If the sunset time was found, convert it to a UTC calendar string
  if (found) {
    timout_c(sunsetET, "YYYY MON DD HR:MN:SC.### ::TDB", 31, timstr);
    printf("Sunset time: %s\n", timstr);
  } else {
    printf("Sunset time not found.\n");
  }

  return 0;
}
