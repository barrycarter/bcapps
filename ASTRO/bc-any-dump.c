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

int index;

int ret = getopt_long(argc, argv, "", options, &index);
 
 printf("RET: %d, INDEX: %d, %s, %s\n", ret, index, options[index].name, optarg);


}
