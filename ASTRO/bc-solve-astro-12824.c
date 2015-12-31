// http://astronomy.stackexchange.com/questions/12824/how-long-does-a-sunrise-or-sunset-take

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// since the sun travels no more than 362 degrees per day, and has an
// angular diameter of no less than 31 minutes, the fastest possible
// sunrise is 31 minutes/362 degrees or 2 minutes; thus, 120 below in
// bc_between below is valid

int main(int argc, char **argv) {

  SpiceDouble radii[3];
  SpiceInt n;
  char direction[10];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // the year 2015
  //  double stime = 1419984000, etime = 1451692800;

  // test
  double stime =  1388559600, etime = 1419984000;

  // lat/lon from argv
  double lat = atof(argv[1]), lon = atof(argv[2]);

  // the sun's radii
  bodvrd_c("SUN", "RADII", 3, &n, radii);


  double *results = bc_between(9, lat*rpd_c(), lon*rpd_c(), 0., stime, etime,
			       "Sun", -34/60.*rpd_c(), 120., radii[0]);

      for (int i=2; i<1000; i++) {

	// if we start seeing 0s, we are out of true answers
	if (results[2*i] < .001) {break;}

	// if the end result is too close to etime, result is inaccurate
	if (abs(results[2*i+1]-etime)<1) {continue;}

	double rstart = results[2*i], rend = results[2*i+1];

	// TODO: this really inefficient
	if (bc_sky_elev(6, lat, lon, 0., rstart, "Sun", 0.) >
	    bc_sky_elev(6, lat, lon, 0., rend, "Sun", 0.)) {
	  strcpy(direction,"SET");
	} else {
	  strcpy(direction,"RISE");
	}
    
	// the "day" and length of sunrise/sunset
	printf("%f %f %s %f %f %f\n", lat, lon, direction, rstart, rend, rend-rstart);
      }
  return 0;
}
