#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

// a trivial function for gfuds_c to determine function direction

void isDecreasing(void(* udfuns)(SpiceDouble et,SpiceDouble *value),
                  SpiceDouble et, SpiceBoolean *isdecr) {
  SpiceDouble res1, res2;
  udfuns(et-1, &res1);
  udfuns(et+1, &res2);
  *isdecr = (res2 < res1);
}

// this is a minimal example with hardcoded values

int main(int argc, char **argv) {

  // create a cell to hold endpoints, another to hold result, and two doubles
  // to hold start and end of each result window
  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(result, 2);
  SpiceDouble beg, end;

  // artificial elevation function that is 0 when et is 100*86400
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = et/86400-390;
  }

  // loop for 400 days but early abort
  for (int i=0; i<400; i++) {

    printf("I: %d\n", i);

    wninsd_c(86400*i, 86400*(i+1), &cnfine);

    // search within that window
    gfuds_c(elevationFunction, isDecreasing, "=", 0., 0., 60., 1000, &cnfine, &result);

    // if at least 1 result, break out of for loop
    if (wncard_c(&result) >= 1) {break;}

  }

  // return the first or last result
  wnfetd_c(&result, 0, &beg, &end);

  return 0;

}
