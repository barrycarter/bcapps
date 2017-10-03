// Several useful C functions that can be used across many programs

// Putting this in a .h file is even worse!

// The correct way to do this would be to compile these into an object
// (.o) file and then compile my programs against that object file. I
// know this, but am too lazy (and dislike C too much) to do this

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

// DE431 limits below (spkcov_c gives a useless range)
// TODO: whine about spkcov_c() uselessness
// TODO: the numbers below are stime+4042 and etime-12 but WHY?

#define STIME -479654740758.815430+4042
#define ETIME 479386728067.184631-12

// convert miles to km and vice versa
double mi2km(double d) {return d*1.609344;}
double km2mi(double d) {return d/1.609344;}

// TODO: have this routine return STIME or ETIME if out of bounds

// this routine *very roughly* converts years to to et for testing only
double year2et(double d) {
  double r = (d-2000)*31556952;
  if (r>ETIME) {return ETIME;}
  if (r<STIME) {return STIME;}
  return r;
}

/*

TODO: possible alternate formulation for above
  double r;
  char s[2000];
  sprintf(s, "%d-JAN-01 00:00:00", d);
  str2et_c(s, &r);
  return r;

*/

// TODO: these are wrong because I don't account for TDB-UTC (using
// deltet_c) like I should (but now fixing for unix conversions)

double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}

// print a message if environment variable DEBUG is set
int debug(void) {return strcmp(getenv("DEBUG"),"1")==0;}

double unix2et(double d) {
  // compute delta
  SpiceDouble delta;
  deltet_c(d-946728000,"UTC",&delta);
  return d-946728000.+delta;
}

double et2unix(double d) {
  // compute delta
  SpiceDouble delta;
  deltet_c(d,"ET",&delta);
  return d+946728000.-delta;
}

// TODO: replace this with rpd_c or dpr_c everywhere it appears
double r2d(double d) {return d*180./pi_c();}

// TODO: maybe rewrite posxyz and earthvector to return array of double
void posxyz(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  spkezp_c(planet, time,"J2000","NONE",0,position,&lt);
}

void earthvector(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  spkezp_c(planet, time,"J2000","NONE",399,position,&lt);
}

double earthangle(double time, int p1, int p2) {
  SpiceDouble pos[3], pos2[3];
  earthvector(time, p1, pos);
  earthvector(time, p2, pos2);
  return vsep_c(pos,pos2);
}

double earthmaxangle(double time, int arrsize, SpiceInt *planets) {
  double max=0, sep;

  int i,j;

  for (i=0; i<arrsize; i++) {
    if (planets[i]==0) {continue;}
    for (j=i+1; j<arrsize; j++) {
      if (planets[j]==0) {continue;}
      sep = earthangle(time, planets[i], planets[j]);
      if (sep>max) {max=sep;}
    }
  }
  return max;
}

// min angle from sun of given planets at given time

double sunminangle(double time, int arrsize, SpiceInt *planets) {

  // max angle is actually pi/2, so 3.1416 is overkill
  double min=3.1416, sep;
  int i;

  for (i=0; i<arrsize; i++) {
    if (planets[i]==0) {continue;}
    sep = earthangle(time, planets[i], 10);
    if (sep<min) {min=sep;}
  }
  return min;
}


// determine (sky) elevation of body at given time and place (radians
// and meters) on Earth

double bc_sky_elev (int num,...) {

  SpiceDouble radii[3], pos[3], normal[3], state[6], lt;
  SpiceInt n;

  va_list valist;
  va_start(valist, num);

  // the variables
  double latitude = va_arg(valist, double);
  double longitude = va_arg(valist, double);
  double elevation = va_arg(valist, double);
  double unixtime = va_arg(valist, double);
  char *target = va_arg(valist, char *);
  double radius = va_arg(valist, double);

  // 'radius' is the radius of the target; return position of upper
  // limb (using 0 treats target as single point)
  
  // the Earth's equatorial and polar radii
  bodvrd_c("EARTH", "RADII", 3, &n, radii);

  // position of latitude/longitude/elevation on ellipsoid
  georec_c(longitude, latitude, elevation/1000., radii[0], 
	   (radii[0]-radii[2])/radii[0], pos);

  // surface normal vector to ellipsoid at latitude/longitude (this is
  // NOT the same as pos!)
  surfnm_c(radii[0], radii[1], radii[2], pos, normal);

  // find the position
  spkcpo_c(target, unix2et(unixtime), "ITRF93", "OBSERVER", "CN+S", pos, 
	   "Earth", "ITRF93", state,  &lt);

  // TODO: vsep_c below uses first 3 members of state, should I be
  // more careful here?

  return halfpi_c() - vsep_c(state,normal) + atan(radius/vnorm_c(state));
}

// for this functional version, angles are in radians, elevation in m
// stime, etime: start and end Unix times
// direction = "<" or ">", whether elevation above/below desire

SpiceDouble *bcriset (int num,...) {

  static SpiceDouble beg, end, results[10000];

  va_list valist;
  va_start(valist, num);

  // variables
  double latitude = va_arg(valist, double);
  double longitude = va_arg(valist, double);
  double elevation = va_arg(valist, double);
  double stime = va_arg(valist, double);
  double etime = va_arg(valist, double);
  char *target = va_arg(valist, char *);
  double desired = va_arg(valist, double);
  char *direction = va_arg(valist,char *);
  double radius = va_arg(valist, double);
  
  // TODO: compute this more efficiently, assuming no more than n
  // rises/day?
  SPICEDOUBLE_CELL(result, 10000);
  SPICEDOUBLE_CELL(cnfine,2);
  wninsd_c(stime, etime, &cnfine);

  // define gfq for geometry finder (nested functions ok per gcc)
  void gfq (SpiceDouble unixtime, SpiceDouble *value) {
    *value = bc_sky_elev(5, latitude, longitude, elevation, unixtime, target, radius);
  }

  // TODO: this is silly and semi-pointless
  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		SpiceDouble et, SpiceBoolean * isdecr ) {
    SpiceDouble dt = 10.;
    uddc_c(udfuns, et, dt, isdecr);
  }
    
  // and now the geometry finder
  // TODO: is 3600 below excessive or too small?
  gfuds_c(gfq, gfdecrx, direction, desired, 0, 3600, 10000, &cnfine, &result);

  SpiceInt count = wncard_c(&result); 

  for (int i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    results[i*2] = beg;
    results[i*2+1] = end;
  }

  return results;
}

// Determine when at least one part of target is at given sky
// elevation (radius >= 0, otherwise not useful)

SpiceDouble *bc_between (int num,...) {

  static SpiceDouble beg, end, results[10000];

  va_list valist;
  va_start(valist, num);

  // varibles
  double latitude = va_arg(valist, double);
  double longitude = va_arg(valist, double);
  double elevation = va_arg(valist, double);
  double stime = va_arg(valist, double);
  double etime = va_arg(valist, double);
  char *target = va_arg(valist, char *);
  double desired = va_arg(valist, double);
  double delta = va_arg(valist, double);
  double radius = va_arg(valist,double);

  // TODO: default delta if not provided
  
  // TODO: compute this more efficiently?
  SPICEDOUBLE_CELL(result, 10000);
  SPICEDOUBLE_CELL(cnfine,2);
  wninsd_c(stime, etime, &cnfine);

  // define gfq for geometry finder (nested functions ok per gcc)
  void gfq ( void (*udfuns) (SpiceDouble et, SpiceDouble  *value ),
	     SpiceDouble unixtime, SpiceBoolean * xbool ) {

    // TODO: this is really really really inefficient
    double elev=bc_sky_elev(6, latitude, longitude, elevation, unixtime, target, 0);
    double angrad = bc_sky_elev(6, latitude, longitude, elevation, unixtime, target, radius) - elev;

    //    printf("ELEV: %f, DESIRED: %f, ANGRAD: %f, WHICHIS: %d\n",elev*dpr_c(), desired*dpr_c(), angrad*dpr_c(), elev>=desired-angrad && elev<=desired+angrad);

    *xbool = (elev>=desired-angrad && elev<=desired+angrad);
  }

  // and now the geometry finder (assume condition met for at least 30s)
  // TODO: let 30 be a variable sent to this routine
  gfudb_c(udf_c, gfq, delta, &cnfine, &result);

  int count = wncard_c(&result); 

  printf("NUMBER OF RSULTS: %d\n",count);

  for (int i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    results[i*2] = beg;
    results[i*2+1] = end;
  }

  return results;
}

int signum(double x) {
  // shouldnt compare double to zero, but ok here
  if (x==0) {return 0;}
  return x>0?1:-1;
}

void eqeq2eclip(doublereal et, SpiceDouble matrix[3][3]) {

  doublereal nut[4], obq, dobq, sobq, cobq;

  // these functions are nonstandard, don't end with "c" and take et
  // as a pointer

  // the obliquity of the ecliptic, excluding nutation
  zzmobliq_(&et, &obq, &dobq);

  // the nut array gives nutation in obliquity (which I need), and
  // nutation in longitude (which I dont need since Im already using
  // EQEQDATE), and the derivatives of these angles (which I also
  // dont need)
  zzwahr_(&et, nut);

  // sin and cos of angle of transformation

  // TESTING!!!
  sobq = sin(obq+nut[0]);
  cobq = cos(obq+nut[0]);

  // there MUST be a better way to do this
  matrix[0][0] = 1;
  matrix[0][1] = 0;
  matrix[0][2] = 0;
  matrix[1][0] = 0;
  matrix[1][1] = cobq;
  matrix[1][2] = sobq;
  matrix[2][0] = 0;
  matrix[2][1] = -sobq;
  matrix[2][2] = cobq;

  // note that matrix is its own Jacobian

}

// wrapper around spkez_c that returns the XYZ and spherical
// coordinates, their derivatives, and whether these derivates are
// positive or negative

// TODO: check to see if spherical coords give lat or colat

SpiceDouble *geom_info(SpiceInt targ, SpiceDouble et, ConstSpiceChar *ref, 
		       SpiceInt obs) {

  static SpiceDouble results[19];
  // extra is just for ECLIPDATETRUE subroutine
  SpiceDouble lt, jacobi[3][3], extra[6];
  SpiceInt i;

  // TODO: details spherical coords order a bit better

  // special case for ECLIPDATETRUE (not a real frame)
  if (!strcmp(ref,"ECLIPDATETRUE")) {

    // TODO: remember to else the other condition!

    // find for EQEQDATE but put in extra, not results
    spkez_c(targ, et, "EQEQDATE", "CN+S", obs, extra, &lt);
    // obtain transform (which is also jacobian)
    eqeq2eclip(et, jacobi);
    // apply to position results
    mxv_c(jacobi, extra, results);
    // and to derivs
    mxv_c(jacobi, extra+3, results+3);
  } else {
    // general case
    spkez_c(targ, et, ref, "CN+S", obs, results, &lt);
  }

  // signum of the x y z dervs are entries 6-8
  for (i=6; i<=8; i++) {results[i] = signum(results[i-3]);}

  // the spherical of the coordinates are next 3 (9-11)
  recsph_c(results, &results[9], &results[10], &results[11]);

  // change in spherical coordinates (12-14)
  dsphdr_c(results[0], results[1], results[2], jacobi);
  mxv_c(jacobi, &results[3], &results[12]);

  // and the sign of that change (15-17)
  for (i=15; i<=17; i++) {results[i] = signum(results[i-3]);}

  // light time correction (18)
  results[18] = lt;

  return results;
}

