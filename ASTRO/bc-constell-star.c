#include "/home/user/BCGIT/ASTRO/bclib.h"

/*

To use this program, uncompress bc-stars.c.bz2 and put it in /tmp/bc-stars.c

To create the bc-stars.c file in the first place I did:

zcat hygdata_v3.csv.gz | perl -F, -anle 'if ($F[29] eq "") {next;} $F[29] = uc($F[29]); print "printf(\"$F[0] $F[29] %s\\n\", constellation($F[7]*15/180*pi_c(), $F[8]/180*pi_c()));"' | tail -n +2 > /tmp/bc-stars.c

which basically prints the HYG id and constellation of each star
 followed by the computed constellation of each star

*/

int main(int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

#include "/tmp/xab"

}
