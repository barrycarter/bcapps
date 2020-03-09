// Lists all variables in loaded kernels

// output of this can be piped to:
// sort -u | fgrep BODY | perl -nle '/body(\d+)/i; print $1' | sort -u

// look at spkobj_c (list objects in kernel)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // how many SPK files loaded
  SpiceInt count;
  ktotal_c ("spk", &count);

  printf("%d SPK files loaded\n", count);

  exit(-1);

  SpiceInt n1, lenout=100, room=10000;
  SpiceBoolean found;
  SpiceChar kvars[room][lenout];



  gnpool_c("*", 0, room, lenout, &n1, kvars, &found);

  for (int i=0; i < room; i++) {
    printf("%s\n", kvars[i]);
  }
}

