// Attempts to re-create the functions I had in Mathematica, just so I
// can get a hang of the SPICE C kernel (have been trying to do too
// much w/ it?)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

// actually declaring entire functions here, not just prototype
double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}

// icky defining functions first

void posxyz(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  spkezp_c(planet, jd2et(time),"J2000","NONE",0,position,&lt);
}

void earthvector(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  // TODO: make this 399 for production
  spkezp_c(planet, jd2et(time),"J2000","NONE",3,position,&lt);
}

double earthangle(double time, int p1, int p2) {
  SpiceDouble pos[3], pos2[3];
  earthvector(time, p1, pos);
  earthvector(time, p2, pos2);
  printf("P1: %f -> %f %f %f\n",time,pos[0],pos[1],pos[2]);
  printf("P2: %f -> %f %f %f\n",time,pos2[0],pos2[1],pos2[2]);
  return vsep_c(pos,pos2);
}

int main (int argc, char **argv) {

  SpiceDouble pos[3];
  SpiceDouble lt;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  if (!strcmp(argv[1],"posxyz")) {
    double time = atof(argv[2]);
    int planet = atoi(argv[3]);
    posxyz(time,planet,pos);
    printf("%f -> %f %f %f\n",time,pos[0],pos[1],pos[2]);
  };

  if (!strcmp(argv[1],"earthvector")) {
    double time = atof(argv[2]);
    int planet = atoi(argv[3]);
    earthvector(time,planet,pos);
    printf("%f -> %f %f %f\n",time,pos[0],pos[1],pos[2]);
  };

  if (!strcmp(argv[1],"earthangle")) {
    double time = atof(argv[2]);
    int p1 = atoi(argv[3]);
    int p2 = atoi(argv[4]);
    SpiceDouble sep = earthangle(time,p1,p2);
    printf("%f -> %f\n",time,sep);
  };

}
