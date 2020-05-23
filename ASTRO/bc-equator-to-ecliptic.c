#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "/home/user/BCGIT/ASTRO/bclib.h"

int main(int argc, char **argv) {

    furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

    double rotate[3][3], et = 9999999999;

    pxform_c("J2000", "ECLIPJ2000", et, rotate);

    printf("ET: %f\n", et);

    for (int i=0; i<=2; i++) {
      for (int j=0; j<=2; j++) {
	printf("%f ", rotate[i][j]);
      }
      printf("\n");
    }
}
