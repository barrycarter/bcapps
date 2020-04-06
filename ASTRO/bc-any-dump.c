// dumps ecliptic, equatorial, altazimuth data about a
// planet/satellite/etc in either J2000 of J-of-date epoch depending
// on options

// Options will be:

// --start: start time in unix seconds
// --end: end time in unix seconds
// --delta: the increment of time in seconds
// --id: the NAIF id of the object for which we want data
// --lng: the longitude (for altaz)
// --lat: the latitude (for altaz)
// --frame: J2000, JDATE, ECLIP2000, ECLIPDATE, ALTAZ

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <getopt.h>
#include <time.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

/*

struct option {
    const char *name;
    int         has_arg;
    int        *flag;
    int         val;
};

*/

int main (int argc, char **argv) {

/*

int verbose_flag;

struct option options[] = {
 {"verbose", no_argument, &verbose_flag, 1},
 {"brief", no_argument, &verbose_flag, 0},
 {"add", no_argument, 0, 'a'},
 {"append", no_argument, 0, 'b'},
 {"delete", required_argument, 0, 'd'},
 {"create", required_argument, 0, 'c'},
 {"file", required_argument, 0, 'f'},
 {0, 0, 0, 0}
   };

*/

struct option options[] = {
  {"start", required_argument, 0, 0},
  {"end", required_argument, 0, 0},
  {"delta", required_argument, 0, 0},
  {"id", required_argument, 0, 0},
  {"lng", required_argument, 0, 0},
  {"lat", required_argument, 0, 0},
  {"frame", required_argument, 0, 0}
};

 int index;

 // TODO: default values

 double start = time(NULL), end = time(NULL)+86400*10, delta = 3600, lng = 0, lat = 0;
 int id = 301;
 char frame[100] = "J2000";

 while (-1 != getopt_long(argc, argv, "", options, &index)) {

   //   printf("%s", options[index].name);

   if (!strcmp("start", options[index].name)) {
     start = atof(optarg);
   } else if (!strcmp("end", options[index].name)) {
     end = atof(optarg);
   } else {
     printf("Something is quite wrong\n");
   }
 }


 printf("start=%f&end=%f&delta=%f&id=%d&lng=%f&lat=%f&frame=%s\n",
	start, end, delta, id, lng, lat, frame);

 // TODO: convert lng/lat to radians before use

}
