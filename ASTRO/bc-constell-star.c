#include <stdio.h>
#include <stdlib.h>
#include "/home/user/BCGIT/ASTRO/bclib.h"

/*

Notes: 

  - not all stars have const values in hygdata

*/

int main(int argc, char **argv) {

  char line[10000], s[100][500];
  int i;
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");


  FILE *fh = popen("zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "r");

  while (!feof(fh)) {

    fgets(line, 10000, fh);

    int fcount = 0, ccount = 0;

    for (i=0; i < strlen(line); i++) {

      if (line[i] == ',') {
	s[fcount][ccount] = '\0';
	fcount++;
	ccount = 0;
	continue;
      }

      s[fcount][ccount] = line[i];
      ccount++;
    }

    s[fcount][ccount] = '\0';

    // fields we want:
    // 0=id, 13=mag 7=ra, 8=dec, 17-22 are xyz vxvyvz, 

    int id = atoi(s[0]);
    double ra = atof(s[7]), dec = atof(s[8]);
    double x = atof(s[17]), y = atof(s[18]), z = atof(s[19]);
    double vx = atof(s[20]), vy = atof(s[21]), vz = atof(s[22]);
    char aster1[40], aster2[40], aster3[40];
    strcpy(aster1, s[29]);
    
    strcpy(aster2, constellationName(constellationNumber(ra/12*pi_c(), dec/180*pi_c())));

    double dist = sqrt(x*x + y*y + z*z);
    double rac = atan2(y,x)/pi_c()*12;

    // adjust for proper motion
    //    printf("VX: %f, VY: %f, VZ: %f\n", vx, vy, vz);

    double old[3] = {x - 125*vx, y - 125*vy, z - 125*vz};
    double ora, odec, odist;

    // ra and dec from proper motioned coords
    recsph_c(old, &odist, &odec, &ora);
    //    printf("ODEC: %f vs %f, ORA: %f vs %f\n", odec, dec, ora, ra);
    odec = halfpi_c() - odec;

    strcpy(aster3, constellationName(constellationNumber(ora, odec)));

    double oldra, olddec;

    j2000tob1875(ra/12*pi_c(), dec/180*pi_c(), &oldra, &olddec);
    oldra *= 12/pi_c();
    olddec *= 180/pi_c();

    if (oldra < 0) {oldra += 24;}

    // skip case where aster1 (from file) is empty
    if (!strcmp(aster1, "")) {continue;}

    // skip Sun
    if (id == 0) {continue;}

    // lower case last 2 of aster2
    aster2[1] += 32;
    aster2[2] += 32;

    if (strcasecmp(aster1, aster2)) {
      //      printf("%d %s %s %f %f %f %f\n", id, aster1, aster2, ra, dec, oldra, olddec);
      printf("Star %d: expected %s, found %s at B1875 RA= %f, DEC= %f, pm =%s\n",
	     id, aster1, aster2, oldra, olddec, aster3);

    }
  }
}

