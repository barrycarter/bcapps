// Uses SPICE library to convert SPICE dates (ie, ET) to calendar dates

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"

SpiceChar s[255];
SpiceDouble time = 0.;
SpiceInt len = 255;

int main( int argc, char **argv ) {
  etcal_c(time,len,s);
  printf("%s\n",s);
}

