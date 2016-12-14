// Attempts to re-create the functions I had in Mathematica, just so I
// can get a hang of the SPICE C kernel (have been trying to do too
// much w/ it?)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

// Return the true (not mean) matrix of transformation from EQEQDATE
// to ECLIPDATE at time et along with its Jacobian

int main (int argc, char **argv) {

  SpiceDouble et, mat[3][3], mat2[3][3], jac[3][3], nut, obq, dboq;
  SpiceDouble pos[3], newpos[3];
  SpiceDouble lt;
  SpiceInt planets[6], i;
  SPICEDOUBLE_CELL (range, 2);
  SpiceDouble beg,end,stime,etime,*array;
  char test2[2000];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  exit(-1);

  for (i=-20000; i<=20000; i++) {
    timout_c(year2et(i), "ERAYYYY##-MON-DD HR:MN:SC.############# ::MCAL", 50, test2);
    printf("TIME: %d %s\n", i, test2);
  }

  exit(-1);

  spkcov_c("/home/barrycarter/SPICE/KERNELS/de431_part-1.bsp", 399, &range);
  wnfetd_c (&range, 0, &stime, &end);
  spkcov_c("/home/barrycarter/SPICE/KERNELS/de431_part-2.bsp", 399, &range);
  wnfetd_c(&range, 0, &beg, &etime);

  printf("TIMES: %f %f\n", beg, etime);



  str2et_c("2017-10-17 07:59", &et);
  printf("ET: %f\n", et);
  spkezp_c(1, et, "EQEQDATE", "CN+S", 399, pos, &lt);
  printf("ET: %f\n", et);
  printf("POS: %f %f %f %f %f\n", et, pos[0], pos[1], pos[2], lt);

  //  eqeq2eclip(et, mat, jac);

  mxv_c(mat, pos, newpos);

  printf("NEWPOS: %f %f %f\n", newpos[0], newpos[1], newpos[2]);

  exit(0);

  zzwahr_(&et, &nut);
  zzmobliq_(&et, &obq, &dboq);

  printf("NUTATION: %f\n", nut);
  printf("OBLIQUITY: %f\n", obq);

  pxform_c("EQEQDATE", "ECLIPDATE", et, mat);

  for (i=0; i<=2; i++) {
    printf("ALPHA: %d %f %f %f\n", i, mat[i][0], mat[i][1], mat[i][2]);
  }

  eqeq2eclip(et, mat2);

  printf("ALPHATEST\n");

  for (i=0; i<=2; i++) {
    printf("BETA: %d %f %f %f\n", i, mat2[i][0], mat2[i][1], mat2[i][2]);
  }


  exit(0);

  str2et_c("10400-FEB-28 00:00:00", &et);
  printf("ET: %f\n", et);
  str2et_c("10400-MAR-01 00:00:00", &et);
  printf("ET: %f\n", et);


  exit(0);



  timout_c(0, "ERAYYYY##-MON-DD HR:MN:SC.############# ::MCAL", 41, test2);

  printf("%s\n", test2);

  exit(0);

  long long test = -pow(2,63);

  printf("TEST: %lld\n",test);

  exit(0);


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

  if (!strcmp(argv[1],"earthmaxangle")) {
    double time = atof(argv[2]);
    for (i=3; i<argc; i++) {planets[i-3] = atoi(argv[i]);}
    SpiceDouble sep = earthmaxangle(time,argc-3,planets);
    printf("%f -> %f\n",time,sep);
  };

}
