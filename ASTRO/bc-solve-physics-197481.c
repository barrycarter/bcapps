#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// Usage: $0 naif-id-of-planet naif-id-of-planet  naif-id-of-planet  ...

static SpiceInt planets[6];
static int planetcount;

void gfq ( SpiceDouble et, SpiceDouble *value ) {

  // max separation between all non-0 planets in planets
  int i,j;
  SpiceDouble sep, lt, max=0.;
  SpiceDouble position[planetcount+1][3];
  // TODO: why do I need a temp var here?
  SpiceDouble temp[3];

  // compute positions
  for (i=1; i<=planetcount; i++) {
    spkezp_c(planets[i], et, "J2000", "LT+S", 10, temp, &lt);
    // copy from temp var (argh!)
    for (j=0; j<=2; j++) {position[i][j] = temp[j];}
  }


  // and now the angle diffs (keep only min)
  for (i=1; i<=planetcount; i++) {
    for (j=i+1; j<=planetcount; j++) {
      sep = vsep_c(position[i],position[j]);
      if (sep>max) {max=sep;}
    }
  }

  *value=max;
  return;
}
 
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
	      SpiceDouble et, SpiceBoolean * isdecr ) {
 SpiceDouble dt = 10.;
 uddc_c( udfuns, et, dt, isdecr );
 return;
}

int main( int argc, char **argv ) {

  SpiceInt i,count,j;
  SPICEDOUBLE_CELL(result, 2*MAXWIN);
  SPICEDOUBLE_CELL(cnfine,2);
  char stime[255];
  SpiceDouble beg, end, ang;

  // fill the static planets array
  for (i=1; i<argc; i++) {planets[i] = atoi(argv[i]);}
  planetcount = argc-1;

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // DE431 limits
  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1970 to 2038 (all "Unix time") for testing
  //  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);
  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    // we don't use 'end' but need to pass it
    wnfetd_c(&result,i,&beg,&end);
    // find the angle at this time
    gfq(beg,&ang);
    // format time nicely
    timout_c(beg, "ERA YYYY##-MM-DD HR:MN:SC ::MCAL",255,stime);

    // print et and separation as degree
    printf("%f %f",beg,ang*dpr_c());
    // print out the planets involved (redundant, but useful)
    for (j=1; j<argc; j++) {printf(" %s",argv[j]);}
    printf(" %s\n",stime);



  }
  return 0;
}

