#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "/home/user/BCGIT/ASTRO/bclib.h"

int main(int argc, char **argv) {

    furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");
    double rotate[3][3];

    pxform_c("J2000", "ECLIPJ2000", 0, rotate);

    FILE *fh = popen("zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "r");

    char line[10000], s[100][500];

    while (!feof(fh)) {

      fgets(line, 10000, fh);

      int fcount = 0, ccount = 0;

      for (int i=0; i < strlen(line); i++) {

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

      // we now have one line

      int id = atoi(s[0]);
      double ra = atof(s[7])/12*pi_c(), dec = atof(s[8])/180*pi_c();

      // convert ra/dec to rect
      
      double rectan[3];

      sphrec_c(1, halfpi_c()-dec, ra, rectan);

      printf("%d %f %f %f\n", id, rectan[0], rectan[1], rectan[2]);
    }
}

