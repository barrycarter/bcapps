#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SpiceDouble iss[3], lt;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  spkezp_c(-125544, jd2et(2457412.5), "J2000", "CN+S", 399, iss, &lt);

}
