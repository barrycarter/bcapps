// dumps the equatorial coordinates for planet as viewed from earth in format useful to bc-equator-map.pl

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

/*

Arguments to this program in order:

naifid: the integer id of observed body
obs: the integer id of the observing body (399 = Earth)
syear: the decimal starting year (approx) (eyear > syear> -13199.6509168566)
eyear: the decimal ending year (approx) (syear < eyear < 17191.1606672279)

-13199.6509168566 < syear < eyear < 17191.1606672279 required

note: unlike bc-equator-2.c, this outputs unix time, not jd

*/

int main (int argc, char **argv) {

  // if insufficient argc, complain, don't just seg fault
  if (argc != 5) {
    printf("Usage: observed observer syear eyear\n");
    exit(-1);
  }

  int planet = atoi(argv[1]);
  int obs = atoi(argv[2]);
  double syear = atof(argv[3]);
  double eyear = atof(argv[4]);

  // TODO: this needs to be a debugging statement, not actually printed, confuses fly
  // printf("YEAR: %f to %f\n", syear,eyear);

  SpiceDouble i,lt,ra,dec,range;
  SpiceDouble v[3];
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // below allows one day of tolerance
  for (i=(syear-1970.)*31556952-86400; i<=(eyear-1970.)*31556952+86400; i+=3600) {

    // planet equatorial coords as viewed from earth, converted to spherical
    spkezp_c(planet, unix2et(i),"EQEQDATE","NONE",obs,v,&lt);
    recrad_c(v,&range,&ra,&dec);
    
    // 8 decimal digits is sort of a compromise
    printf("%d %d %.8f %.8f %.8f\n", obs, planet, i, ra, dec);

  }
  return(0);
}
