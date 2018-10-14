#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main( int argc, char **argv ) {

  // the input/output vars
  double et, retval;
  ConstSpiceChar target[100], illmn[100], obsrvr[100], abcorr[100];

  // the kernels
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // the call

  for (int i=1; i <= 36600; i++) {
    retval = phaseq_c(unix2et(946684800+86400*(i-1)),
		      "Moon", "Sun", "Earth", "CN+S");
    printf("%f\n", i, retval);
  }
}
