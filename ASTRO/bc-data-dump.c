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
#define MAXSEP 0.10471975511965977462
#define MAXWIN 1000000

// this lets me change function definition and times in all place
#define GFQ gfq2
#define REF "J2000"
#define COND "LOCMIN"
#define LABEL "mercury-peri"
// these are only approx!
// DE431 starts -13199.6509168566, ends 17191.1606672279 is my scheme
// #define SYEAR -13199
// #define EYEAR 17191

#define SYEAR 2000
#define EYEAR 2016

// given a prefix (string), window (collection of intervals) and a
// function, display (print) the value of the function at each
// endpoint of each interval with prefix (which I will use to tell me
// what I am computing)

int main (int argc, char **argv) {

  SpiceDouble i,lt,ra,dec,range;
  SpiceDouble v[3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (i=(SYEAR-2000.)*31556952; i<=(EYEAR-2000.)*31556952; i+=86400) {

    // TODO: consider subroutinizing this
    spkezp_c(5,i,"ECLIPJ2000","NONE",399,v,&lt);
    recrad_c(v,&range,&ra,&dec);
    printf("%f: %f %f %f\n",i,ra*12/pi_c(),dec*180/pi_c(),range);


  }
  return(0);
}
