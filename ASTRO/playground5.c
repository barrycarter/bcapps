// Solve http://astronomy.stackexchange.com/questions/12940/22nd-is-shortest-day-in-some-places-but-the-21st-is-shortest-in-other-places-c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main(void) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  double stime = 1448953200, etime = 1454310000;
  double lat=40., lon=100., dl, noon, mindl, minnoon;

  double *results = bcriset(lat*rpd_c(),lon*rpd_c(), 0, stime, etime,
			    "Sun", -5/6.*rpd_c(), ">");

  mindl = 0.;
  minnoon = 0.;

  // we intentionally ignore first result, expect it to be wrong
  for (int i=2; i<=100; i++) {

    // if we start seeing 0s, we are out of true answers
    if (results[2*i] < .001) {break;}

    // if the end result is too close to etime, result is inaccurate
    if (abs(results[2*i+1]-etime)<1) {continue;}

    // length of day and "noon"
    dl = results[2*i+1]-results[2*i];
    noon = (results[2*i+1]+results[2*i])/2;

    // if day length is less than mindl (or mindl = 0), set mindl and
    // minnoon to current

    if (mindl < .01 || dl < mindl) {
      mindl = dl;
      minnoon = noon;
    }
  }
  
  // the start of December for this longitude (1448928000 = GMT
  // midnight Dec 1)
  double sod = 1448928000-240.*lon;

  // this is: minimal time of noon and length of day
  printf("%f %f %f %f %f\n", lat, lon, minnoon, mindl, 1+(minnoon-sod)/86400);


  return 0;
}

