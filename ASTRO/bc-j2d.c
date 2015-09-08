// Uses SPICE library to convert SPICE dates (ie, ET) to calendar dates

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"

SpiceChar s[255];

int main( int argc, char **argv ) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  timdef_c ("SET","CALENDAR",255,"MIXED");

  SpiceDouble et;

  //  for (et=-479654654399.+300.; et<= 479386728000.; et+=86400.*1.) {
  for (et=-479654654399.+300.; et<= 479386728000.; et+=86400.*1.*365.) {
    et2utc_c(et,"C",0,255,s);
    printf("%f %f %s\n",et,et/86400.+2451545.,s);
    et2utc_c(et,"D",0,255,s);
    printf("%f %f %s\n",et,et/86400.+2451545.,s);
    et2utc_c(et,"J",0,255,s);
    printf("%f %f %s\n",et,et/86400.+2451545.,s);
    etcal_c(et,48,s);
    printf("%f %f %s\n",et,et/86400.+2451545.,s);
    //    et2utc_c(et,"ISOC",0,255,s);
    //    printf("%f %f %s\n",et,et/86400.+2451545.,s);
    //    et2utc_c(et,"ISOD",0,255,s);
    //    printf("%f %f %s\n",et,et/86400.+2451545.,s);
  }
}
