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
// --frame: J2000, ECLIPJ2000, EQEQDATE, ECLIPDATE, any other frame OR "ALTAZ"

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
 char frame[100] = "J2000", raName[100], decName[100];

 while (-1 != getopt_long(argc, argv, "", options, &index)) {

   if (!strcmp("start", options[index].name)) {
     start = atof(optarg);
   } else if (!strcmp("end", options[index].name)) {
     end = atof(optarg);
   } else if (!strcmp("delta", options[index].name)) {
     delta = atof(optarg);
   } else if (!strcmp("id", options[index].name)) {
     id = atoi(optarg);
   } else if (!strcmp("lng", options[index].name)) {
     lng = atof(optarg);
   } else if (!strcmp("lat", options[index].name)) {
     lat = atof(optarg);
   } else if (!strcmp("frame", options[index].name)) {
     strcpy(frame, optarg);
   } else {
     printf("Something is quite wrong\n");
   }
 }

 // load the kernels
 furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

 printf("start=%f&end=%f&delta=%f&id=%d&lng=%f&lat=%f&frame=%s\n",
	start, end, delta, id, lng, lat, frame);

 // figure out the "RA" and "DEC" names based on frame

 if (!strcmp("J2000", frame) || !strcmp("EQEQDATE", frame)) {
   strcpy(raName, "RA");
   strcpy(decName, "DEC");
 } else if (!strcmp("ECLIPJ2000", frame) || !strcmp("ECLIPDATE", frame)) {
   strcpy(raName, "EclLng");
   strcpy(decName, "EclLat");
 } else if (!strcmp("ALTAZ", frame)) {
   strcpy(raName, "AZ");
   strcpy(decName, "EL");
 } else {
   printf("Could not convert frame to raName/decName\n");
   exit(-1);
 }

 // TODO: last two fields depend on what is being requested
 printf("format=et,unix,stardate,%s,%s\n", raName, decName);

 for (double i = start; i <= end; i += delta) {

   // the vector to hold results
   double v[3], lt, range, ra, dec, altaz[3];

   // the ephemeris
   double et = unix2et(i);

   if (!strcmp("ALTAZ", frame)) {
     azimuthAltitude(id, et, lat*rpd_c(), lng*rpd_c(), altaz);
     ra = altaz[0];
     dec = altaz[1];
   } else {
     spkezp_c(id, et, frame, "CN+S", 399, v, &lt);
     recrad_c(v, &range, &ra, &dec);
   }

   // print time
   printf("%f,%f,%s,%f,%f\n", et, i, stardate(et), ra*dpr_c(), dec*dpr_c());
 }

 // TODO: convert lng/lat to radians before use

}
