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

  //  printf("%d SPK files loaded\n", count);

  // create strings to hold results
  SpiceChar fname[100], type[100], source[100];
  SpiceBoolean found2;
  SpiceInt handle;

  // hold ids for given kernel
  SPICEINT_CELL(ids, 10000);
    
  for (int i=0; i < count; i++) { 
    kdata_c(i, "spk", 100, 100, 100, fname, type, source, &handle, &found2);
    //    printf("FNAME: %s\n", fname);
    spkobj_c(fname, &ids);

    for (int j=0; j < card_c(&ids); j++) {

      SpiceInt obj = SPICE_CELL_ELEM_I(&ids, j);
      printf("%d\n", obj);
    }
  }

  exit(-1);

  SpiceInt n1, lenout=100, room=10000;
  SpiceBoolean found;
  SpiceChar kvars[room][lenout];



  gnpool_c("*", 0, room, lenout, &n1, kvars, &found);

  for (int i=0; i < room; i++) {
    printf("%s\n", kvars[i]);
  }
}

