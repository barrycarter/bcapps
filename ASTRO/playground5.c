#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main( int argc, char **argv ) {

  char arch[100], type[100];

  getfat_c("/home/barrycarter/SPICE/KERNELS/jup310.bsp", 100, 100, arch, type);
  printf("%s %s\n",arch,type);

  return 0;
}
