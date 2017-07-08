// dumps the equatorial coordinates for planet as viewed from earth in format useful to bc-equator-map.pl

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

/*

Arguments to this program in order:

naifid: the integer id of observed body
obs: the integer id of the observing body (399 = Earth)
syear: the decimal starting year (approx) (eyear > syear> -13199.6509168566)
eyear: the decimal ending year (approx) (syear < eyear < 17191.1606672279)

-13199.6509168566 < syear < eyear < 17191.1606672279 required

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
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (i=(syear-2000.)*31556952; i<=(eyear-2000.)*31556952; i+=3600) {

    // planet equatorial coords as viewed from earth, converted to spherical
    spkezp_c(planet,i,"J2000","NONE",obs,v,&lt);
    recrad_c(v,&range,&ra,&dec);

    printf("%d %f %f %f %f\n", planet, et2jd(i), ra, dec,
	   earthangle(i,planet,10));

  }
  return(0);
}
