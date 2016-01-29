#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main( int argc, char **argv ) {

  SPICEDOUBLE_CELL(result, 4);
  SpiceDouble beg, end;
  SpiceInt count, i;

  //  char arch[100], type[100];
  //  getfat_c("/home/barrycarter/SPICE/KERNELS/jup310.bsp", 100, 100, arch, type);
  //  printf("%s %s\n",arch,type);

  spkcov_c ("/home/barrycarter/SPICE/KERNELS/jup310.bsp", 502, &result);

  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("min %f %f\n",et2jd(beg),et2jd(end));
  }

  return 0;
}
