#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {
  SpiceDouble v[3], lt;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  spkezp_c(10,unix2et(1426891500),"ITRF93","LT+S",399,v,&lt);
  printf("POS: %f %f %f\n",v[0],v[1],v[2]);
}
