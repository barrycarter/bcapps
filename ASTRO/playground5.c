#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main( int argc, char **argv ) {

  SPICEDOUBLE_CELL(result, 20000);
  SPICEDOUBLE_CELL(cnfine, 2);
  SpiceInt i, count;
  SpiceDouble beg, end;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // these ET limits for jup310.bsp should be consistent
  spkcov_c ("/home/barrycarter/SPICE/KERNELS/jup310.bsp", 502, &cnfine);

  printf("SIZE: %d\n", card_c(&cnfine));
  printf("%f\n", SPICE_CELL_ELEM_D(&cnfine,0));
  printf("%f\n", SPICE_CELL_ELEM_D(&cnfine,1));
  printf("%f\n", SPICE_CELL_ELEM_D(&cnfine,2));
  printf("%f\n", SPICE_CELL_ELEM_D(&cnfine,3));
  printf("%f\n", SPICE_CELL_ELEM_D(&cnfine,4));
  printf("%f\n", SPICE_CELL_ELEM_D(&cnfine,5));

  gfoclt_c("ANY", "502", "ELLIPSOID", "IAU_EUROPA", "10", "ELLIPSOID", 
	   "IAU_SUN", "CN", "501", 60, &cnfine, &result);

  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("min %f %f\n",et2jd(beg),et2jd(end));
  }

  return 0;
}
