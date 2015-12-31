// http://astronomy.stackexchange.com/questions/12824/how-long-does-a-sunrise-or-sunset-take

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main(int argc, char **argv) {

  SpiceDouble radii[3];
  SpiceInt n;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // the year 2015
  //  double stime = 1419984000, etime = 1451692800;

  // test
  double stime = 1419984000, etime = 1419984000+86400*10;

  // lat/lon from argv
  double lat = atof(argv[1]), lon = atof(argv[2]);

  // the sun's radii
  bodvrd_c("SUN", "RADII", 3, &n, radii);


  double *results = bc_between(9, lat*rpd_c(), lon*rpd_c(), 0., stime, etime,
			       "Sun", -34/60.*rpd_c(), 30., radii[1]);

      for (int i=2; i<1000; i++) {

	// if we start seeing 0s, we are out of true answers
	if (results[2*i] < .001) {break;}

	// if the end result is too close to etime, result is inaccurate
	if (abs(results[2*i+1]-etime)<1) {continue;}
    
	// the "day" and length of sunrise/sunset
	printf("%f %f %f %f\n", lat, lon,
	       ((results[2*i+1]+results[2*i])/2.-stime)/86400., 
	       results[2*i+1]-results[2*i]);
      }
  return 0;
}
