#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SpiceDouble iss[3], lt;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  spkgps_c(-125544, jd2et(2457405.5), "J2000", 399, iss, &lt);

  // spkpos_c ("-125544", jd2et(2457412.5), "EQEQDATE", "CN+S", "Earth", iss, &lt);
  //  spkezp_c(-125544, jd2et(2457412.5), "IAU_EARTH", "CN+S", 399, iss, &lt);

}
