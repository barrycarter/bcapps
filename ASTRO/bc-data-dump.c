// show mercury ra and dec to see if plotting them against each other
// yields a pattern

// 2ndary (perhaps primary) goal is to create a template for dumping
// data; bc-periapses.c is a template for finding data when certain
// conditions are met; this program just dumps data daily or whatever

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"
#define PLANET 2

// this lets me change function definition and times in all place

// these are only approx!
// DE431 starts -13199.6509168566, ends 17191.1606672279 is my scheme
// #define SYEAR -13199
// #define EYEAR 17191
#define SYEAR 2000
#define EYEAR 2001

int main (int argc, char **argv) {

  SpiceInt planet = atoi(argv[1]);

  SpiceDouble i,lt,ra,dec,range;
  SpiceDouble v[3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (i=(SYEAR-2000.)*31556952; i<=(EYEAR-2000.)*31556952; i+=86400) {

    // TODO: consider subroutinizing this
    spkezp_c(planet,i,"ECLIPJ2000","NONE",10,v,&lt);
    recrad_c(v,&range,&ra,&dec);
    printf("%0.20f %0.20f %0.20f %0.20f\n",et2jd(i),ra,dec,earthangle(i,0,PLANET));

  }
  return(0);
}
