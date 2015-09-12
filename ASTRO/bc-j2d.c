// Uses SPICE library to convert SPICE dates (ie, ET) to calendar dates

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"

SpiceChar s[255];

double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}

int main( int argc, char **argv ) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  SpiceDouble et;

  for (et=-479654654399.+300.; et<= 479386728000.; et+=86400.*1.) {
  //  for (et=-479654654399.+300.; et<= 479386728000.; et+=86400.*1.*365.) {
    timout_c(et,"YYYY##-MM-DD HR:MN:SC ::MCAL",255,s);
    printf("%f %f %s\n",et,et2jd(et),s);
  }
}
