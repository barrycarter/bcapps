#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

// Usage: $0 -i naif_id -t time_in_unix_seconds -n num_pts [-u 0]

// TODO: use longopts later?

// TODO: error to set refraction for non-Earth

// TODO: refraction? (can I do it?)

// TODO: indicate which side is sunlight and dark

int main(int argc, char **argv) {

  char optid;
  SpiceInt npts=100, frameID, id=399;
  SpiceDouble time=0;
  SpiceChar frame[100], name[100], type[100];
  SpiceBoolean found;

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // default value for type
  strcpy(type, "UMBRAL");
  

  // assign from opts
  while ((optid = getopt(argc, argv, "i:t:n:u:")) != -1) {
    if (optid == 'i') {id = atoi(optarg);}
    if (optid == 't') {time = unix2et(atof(optarg));}
    if (optid == 'n') {npts = atoi(optarg);}
    if (optid == 'u') {if (atoi(optarg) == 0) {strcpy(type,"PENUMBRAL");}}
  }

  //  printf("I: %d, T: %f, N: %d, U: %s\n", id, time, npts, type);

  // convert planet to string, complain if not found

  bodc2n_c(id, 100, name, &found);
  if (!found) {printf("Name for NAIF ID %d not found\n", id); exit(-1);}

  // get frame from planet
  cnmfrm_c(name, 100, &frameID, frame, &found);
  if (!found) {printf("FRAME NOT FOUND: %d (%s)\n", id, name); exit(-1);}

  //  printf("NAME: %s, FRAME: %s\n", name, frame);

  SpiceDouble trgepc, obspos[3], trmpts[npts][3], r, lng, lat;

  // TODO: does not include refraction
  edterm_c(type, "10", name, time, frame, "CN+S", name, npts,
  	   &trgepc, obspos, trmpts);

  // print out all meta-data

  printf("i=%d&t=%f&n=%d&type=%s&name=%s&frame=%s&\n", id, et2unix(time), npts, type, name, frame);

  for (int i=0; i<npts; i++) {
    reclat_c(trmpts[i], &r, &lng, &lat);
    printf("lng%d=%f&lat%d=%f&\n", i, lng*dpr_c(), i, lat*dpr_c());
  }
  return 0;
}
