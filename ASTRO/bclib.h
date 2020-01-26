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

// list of planets for prettyprinting (planet2str() function)

// planets[0] = "SSB", solar system barycenter

const char *planets[] = {"SSB", "MERCURY", "VENUS", "EARTH", "MARS", "JUPITER",
                         "SATURN", "URANUS", "NEPTUNE", "PLUTO", "SUN"};

// convert planet to string, optionally in terse format (meaning
// return the planet number as a string or "M" for moon and "S" for
// sun) if second argument is string "TERSE"

char *planet2str(int planet, char *type) {

  // in case we need to return a string
  static char res[200];

  if (strcmp(type, "TERSE") == 0) {

    if (planet<=9) {
      sprintf(res, "%d", planet);
      return res;
    }

    if (planet==301) {return "M";}
    if (planet==10) {return "S";}
    return "?";
  }

  if (planet<=10) {return (char *) planets[planet];}
  if (planet == 301) {return "MOON";}
  return "?";
}

// convert miles to km and vice versa
double mi2km(double d) {return d*1.609344;}
double km2mi(double d) {return d/1.609344;}

SpiceDouble min(SpiceDouble x, SpiceDouble y) {return x<y?x:y;}
SpiceDouble max(SpiceDouble x, SpiceDouble y) {return x>y?x:y;}

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

  //  printf("NUMBER OF RSULTS: %d\n",count);

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


// return the azimuth and altitude of an object at a given time from a
// given location on Earth (topographicSpherical is the return value)

void azimuthAltitude(SpiceInt targ, SpiceDouble et, SpiceDouble lat, SpiceDouble lon, SpiceDouble *topographicSpherical) {

  SpiceDouble targetPosition[3], targetPositionTopographic[3];
  SpiceDouble observerPosition[3], surfaceNormal[3], eastVector[3];
  SpiceDouble itrf2TopographicMatrix[3][3], topographicPosition[3];
  SpiceDouble topoR, topoLat, topoLon;
  SpiceDouble lt;
  SpiceDouble northVector[3] = {0,0,1};

  // HACK: cheating a bit here hardcoding Earth's radii

  // find position of object in ITRF93 frame
  spkezp_c(targ, et, "ITRF93", "CN+S", 399, targetPosition, &lt);

  // find observer position in ITRF93
  georec_c(lon, lat, 0, 6378.137, 0.0033528128, observerPosition);

  // subtract to get topographic position
  vsub_c(targetPosition, observerPosition, targetPositionTopographic);

  // the surface normal vector from the observer (z axis)
  surfnm_c(6378.137, 6378.137, 6356.7523, observerPosition, surfaceNormal);

  // the north cross the normal vector yields an east pointing vector in plane
  vcrss_c(northVector, surfaceNormal, eastVector);

  // construct the matrix that converts ITRF to topographic, east = x
  twovec_c(surfaceNormal, 3, eastVector, 1, itrf2TopographicMatrix);

  // apply the matrix to the ITRF coords
  mxv_c(itrf2TopographicMatrix, targetPositionTopographic, topographicPosition);

  // convert to spherical coordinates
  recsph_c(topographicPosition, &topoR, &topoLat, &topoLon);

  // and "return"
  topographicSpherical[0] = halfpi_c()-topoLon;
  topographicSpherical[1] = halfpi_c()-topoLat;
  topographicSpherical[2] = topoR;
}

// helper functions

double azimuth(SpiceInt targ, SpiceDouble et, SpiceDouble lat, SpiceDouble lon) {
  SpiceDouble topographicSpherical[3];
  azimuthAltitude(targ, et, lat, lon, topographicSpherical);
  return topographicSpherical[0];
}

double altitude(SpiceInt targ, SpiceDouble et, SpiceDouble lat, SpiceDouble lon) {
  SpiceDouble topographicSpherical[3];
  azimuthAltitude(targ, et, lat, lon, topographicSpherical);
  return topographicSpherical[1];
}


void isDecreasing(void(* udfuns)(SpiceDouble et,SpiceDouble *value),
		  SpiceDouble et, SpiceBoolean *isdecr) {
  SpiceDouble res1, res2;
  udfuns(et-1, &res1);
  udfuns(et+1, &res2);
  *isdecr = (res2 < res1);
}

// returns the prev/next time (before/after et) target reaches
// elevation elev at lat/lon

SpiceDouble prevOrNextTime(SpiceInt target, SpiceDouble et, SpiceDouble elev, 
			   SpiceDouble lat, SpiceDouble lon, SpiceInt dir) {

  // just 1 result cell and cnfine has to be 2 big for beg and end
  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(result, 6);
  SpiceDouble beg, end;

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // loop for 200 days but early abort
  for (int i=0; i<200; i++) {

    // TODO: ssize here is super ugly
    ssize_c(2, &cnfine);
    ssize_c(6, &result);

    if (dir == 1) {
      wninsd_c(et+86400*i, et+86400*(i+1), &cnfine);
    } else {
      wninsd_c(et-86400*(i+1), et-86400*i, &cnfine);
    }
    // search within that window
    gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 3600., 1000, &cnfine, &result);

    // if at least 1 result, break out of for loop
    if (wncard_c(&result) >= 1) {break;}
  }

  // return the first or last result

  if (dir == 1) {
    wnfetd_c(&result, 0, &beg, &end);
  } else {
    wnfetd_c(&result, wncard_c(&result)-1, &beg, &end);
  }

  return beg;

}

SpiceDouble prevOrNextTime2(SpiceInt target, SpiceDouble et, SpiceDouble elev, 
			   SpiceDouble lat, SpiceDouble lon, SpiceInt dir) {

  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(result, 5000);
  SpiceDouble beg, end;

  // empty cnfine and result and then allow them to hold new intervals
  //  scard_c(0, &cnfine);
  //  scard_c(0, &result);
  //  scard_c(2, &cnfine);
  //  scard_c(800, &result);

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // single interval
  if (dir == 1) {
    wninsd_c(et, et+86400*200, &cnfine);
  } else {
    wninsd_c(et-86400*200, et, &cnfine);
  }

  gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 3600., 1000, &cnfine, &result);

  // return the first or last result

  if (dir == 1) {
    wnfetd_c(&result, 0, &beg, &end);
  } else {
    wnfetd_c(&result, wncard_c(&result)-1, &beg, &end);
  }

  return beg;

}

/**

Given the following: 

  - A light-generating object s (eg, "Sun") as a 3 elt position vector
  - Radius of s as sr
  - Another object t (eg, "Jupiter") as a 3 elt position vector
  - Radius of t as tr

Assumptions:

  - tr < sr (TODO: lift this assumption)

Returns:

  - umbPt: the point of the umbral cone
  - umbVec: the vector pointing from t to s
  - umbAng: the angle of the umbral cone

*/

void umbralData(SpiceDouble s[3], SpiceDouble sr, SpiceDouble t[3], SpiceDouble tr,
		SpiceDouble umbPt[3], SpiceDouble umbVec[3], SpiceDouble *umbAng) {

  // TODO: why do I need negative sign here? (removed temporarily)

  umbPt[0] = (-sr*t[0] + s[0]*tr) / (sr - tr);
  umbPt[1] = (-sr*t[1] + s[1]*tr) / (sr - tr);
  umbPt[2] = (-sr*t[2] + s[2]*tr) / (sr - tr);

  vsub_c(t, umbPt, umbVec);

  *umbAng = atan(tr/vnorm_c(umbVec));
}

/**

Given the following: 

  - A light-generating object s (eg, "Sun") as a 3 elt position vector
  - Radius of s as sr
  - Another object t (eg, "Jupiter") as a 3 elt position vector
  - Radius of t as tr

Returns:

  - 0 if sum of angular radii equals separation angle (sep == tar +
    sar) (as viewed from the origin)

  - -1 if seperation angle plus angular of radius of s equals angular
     radius of t (sep + sar == tar or sep == tar - sar) (as viewed
     from the origin)

Thus, ((sep-tar)/sar-1)/2 as viewed from the origin

*/

SpiceDouble separationData(SpiceDouble s[3], SpiceDouble sr, SpiceDouble t[3], 
			   SpiceDouble tr) {


  //  printf("S: {%f, %f, %f} SR: %f\n", s[0], s[1], s[2], sr);
  //  printf("T: {%f, %f, %f} TR: %f\n", t[0], t[1], t[2], tr);
  //  printf("RET: %f\n", ((vsep_c(s,t)-asin(tr/vnorm_c(t)))/asin(sr/vnorm_c(s))-1)/2);

  return ((vsep_c(s,t)-asin(tr/vnorm_c(t)))/asin(sr/vnorm_c(s))-1)/2;
}

/**

Given the following: 

  - Radius qr of a viewing object q at the origin
  - A light-generating object s (eg, "Sun") as a 3 elt position vector

Returns:

  - A vector p perpendicular to S of length qr

*/

void perpVector(SpiceDouble qr, SpiceDouble s[3], SpiceDouble p[3])  {

  SpiceDouble origin[3] = {0, 0, 0}, pt[3], vec1[3], vec2[3];
  SpicePlane perp;

  nvp2pl_c(s, origin, &perp);

  pl2psv_c(&perp, pt, vec1, vec2);

  p[0] = qr*vec1[0];
  p[1] = qr*vec1[1];
  p[2] = qr*vec1[2];

  //  printf("S: %f %f %f, PERPVECTOR: %f %f %f %f, OTHERPERP: %f %f %f %f\n", s[0], s[1], s[2], vec1[0], vec1[1], vec1[2], vnorm_c(vec1), vec2[0], vec2[1], vec2[2], vnorm_c(vec2));

}

/**

Given the following: 

  - An epehemeris time et
  - A light-generating object s (eg, "Sun") as a NAIF id
  - An eclipsing object t (eg, "Jupiter") as a NAIF id
  - An eclipsed object q (eg, "Io") as a NAIF id

Returns:

  - The minimum eclipse (as measured by separationData) at time et of the two
    points on q that are perpendicular to the vector qs

If the return value is <= -1, the all of q is eclipsed from s by t

*/

SpiceDouble minCornerEclipse(SpiceDouble et, SpiceInt s, SpiceInt t, SpiceInt q) {

  SpiceInt n;
  SpiceDouble lt, sr[3], tr[3], qr[3], spos[3], tpos[3], perp[3], sepn, seps;

  // radii of all 3 objects

  bodvcd_c(s, "RADII", 3, &n, sr);
  bodvcd_c(t, "RADII", 3, &n, tr);
  bodvcd_c(q, "RADII", 3, &n, qr);

  // position from q to s

  spkezp_c(s, et, "J2000", "CN+S", q, spos, &lt);
  spkezp_c(t, et, "J2000", "CN+S", q, tpos, &lt);

  perpVector(qr[0], spos, perp);

  // compute the position from the "southern" side of q by adding perp
  // vector to spos and tpos

  for (int i=0; i<3; i++) {
    spos[i] += perp[i];
    tpos[i] += perp[i];
  }

  sepn = separationData(spos, sr[0], tpos, tr[0]);

  // compute the position from the "northern" side of q by undoing
  // first transformation and then subtracting perp vector from spos
  // and tpos

  for (int i=0; i<3; i++) {
    spos[i] -= 2*perp[i];
    tpos[i] -= 2*perp[i];
  }

  seps = separationData(spos, sr[0], tpos, tr[0]);

  //  printf("SEPNS: %f %f\n", sepn, seps);

  return sepn>seps?sepn:seps;
}

/**

Given the following: 

  - An epehemeris time et
  - A light-generating object s (eg, "Sun") as a NAIF id
  - An eclipsing object t (eg, "Jupiter") as a NAIF id
  - An eclipsed object q (eg, "Ganymede") as a NAIF id

Returns:

  - When param=0, return:

    - < 0 if no eclipse of Q by T
    - 1 if central eclipse and center of Q
    - -1 if Q is closer to penumbral point than T
    - between 0 and 1 if partial eclipse somewhere on Q

   - When param=1, return:

     - < 0 if there is no total eclipse anywhere on Q
     - > 1 when all of Q is totally eclipsed
     - -1 if Q is further umbral point than T or is there is no penumbral eclipse
*/

SpiceDouble penUmbralData(SpiceDouble et, SpiceInt s, SpiceInt t, SpiceInt q, SpiceInt param) {

  SpiceDouble srtemp[3], trtemp[3], qrtemp[3], sr, tr, qr;
  SpiceInt n;

  // radii of all 3 objects
  bodvcd_c(s, "RADII", 3, &n, srtemp);
  bodvcd_c(t, "RADII", 3, &n, trtemp);
  bodvcd_c(q, "RADII", 3, &n, qrtemp);

  sr = srtemp[0];
  tr = trtemp[0];
  qr = qrtemp[0];

  // correct for Earth's radius based on https://eclipse.gsfc.nasa.gov/OH/OHres/LEshadow.html (only when Earth is eclipsing body)

  if (t == 399) {tr *= 86/85.;}

  // compute position of s and t with respect to Q

  SpiceDouble spos[3], tpos[3], lt;

  spkezp_c(s, et, "J2000", "CN+S", q, spos, &lt);
  spkezp_c(t, et, "J2000", "CN+S", q, tpos, &lt);

  SpiceDouble penUmbVec[3];
  vsub_c(spos, tpos, penUmbVec);

  // distance between s and t

  SpiceDouble st = vnorm_c(penUmbVec);

  // distance from to the penumbral point "p" to t

  SpiceDouble pt = st*tr/(sr+tr);

  // make penUmbVec length pt, subtract from t to find penUmbPt

  SpiceDouble penUmbPt[3];
  for (int i=0; i<3; i++) {penUmbPt[i] = tpos[i] + penUmbVec[i]/st*pt;}

  SpiceDouble penUmbAng = asin(tr/pt);

  // angle from penUmbVec to Q from P

  SpiceDouble angleQ = vsep_c(penUmbPt, penUmbVec);
  SpiceDouble angQDelta = asin(qr/vnorm_c(penUmbPt));

  // purely for understanding (temporarily), reduce problem to 2 dimensions

  SpiceDouble mat[3][3];
  twovec_c(penUmbVec, 1, spos, 2, mat);


  SpiceDouble stemp[3], ttemp[3], penumbvectemp[3], penumbpttemp[3];

  mxv_c(mat, spos, stemp);
  mxv_c(mat, tpos, ttemp);
  mxv_c(mat, penUmbVec, penumbvectemp);
  mxv_c(mat, penUmbPt, penumbpttemp);

  /*
  printf("STEMP: (%f, %f, %f)\n", stemp[0], stemp[1], stemp[2]);
  printf("TTEMP: (%f, %f, %f)\n", ttemp[0], ttemp[1], ttemp[2]);
  printf("PUVECTEMP: (%f, %f, %f)\n", penumbvectemp[0], penumbvectemp[1], penumbvectemp[2]);
  printf("PUPTTEMP: (%f, %f, %f)\n", penumbpttemp[0], penumbpttemp[1], penumbpttemp[2]);

  printf("UNIX: %f\n", et2unix(et));
  printf("SPOS: (%f, %f, %f)\n", spos[0], spos[1], spos[2]);
  printf("TPOS: (%f, %f, %f)\n", tpos[0], tpos[1], tpos[2]);
  printf("PENUMBVEC: (%f, %f, %f)\n", penUmbVec[0], penUmbVec[1], penUmbVec[2]);
  printf("LEN(ST), LEN(PT): %f %f\n", st, pt);
  printf("PENUMBPT (%f, %f, %f)\n", penUmbPt[0], penUmbPt[1], penUmbPt[2]);
  printf("ANG(PENUMB) %f, ANG(Q) %f, ANG(DELTA) %f\n", penUmbAng*dpr_c(), angleQ*dpr_c(), angQDelta*dpr_c());
 
  printf("VN %f PT %f ANGQ %f PENUMBANG %f ANGQDELTA %f\n", 
	 vnorm_c(penUmbPt), pt, angleQ, penUmbAng, angQDelta);

  */

  // TODO: find smoother way of returning function

  if (vnorm_c(penUmbPt) < pt) {return -1.;}

  SpiceDouble penValue = -fabs(angleQ)/(penUmbAng + angQDelta) + 1;

  if (param == 0) {return penValue;}

  if (penValue < 0 && param == 1) {return -1;}

  // compute pt from umbral case (reassign)

  pt = st*tr/(sr-tr);

  SpiceDouble umbPt[3];
  for (int i=0; i<3; i++) {umbPt[i] = tpos[i] - penUmbVec[i]/st*pt;}

  SpiceDouble umbAng = asin(tr/pt);

  angleQ = pi_c()-vsep_c(umbPt, penUmbVec);
  angQDelta = asin(qr/vnorm_c(umbPt));

  if (vnorm_c(umbPt) > pt) {return -1;}

  SpiceDouble umbpttemp[3];
  mxv_c(mat, umbPt, umbpttemp);

  //  printf("POSSIBLE UMBRAL\n");

  //  printf("\n");
  //  printf("UNIX: %f\n", et2unix(et));
  //  printf("STEMP: (%f, %f, %f)\n", stemp[0], stemp[1], stemp[2]);
  //  printf("TTEMP: (%f, %f, %f)\n", ttemp[0], ttemp[1], ttemp[2]);
  //  printf("UMBPT (%f, %f, %f)\n", umbpttemp[0], umbpttemp[1], umbpttemp[2]);
  //  printf("ANGQ: %f\n", angleQ*dpr_c());
  //  printf("ANGDELTA: %f\n", angQDelta*dpr_c());
  //  printf("UMBANG: %f\n", umbAng*dpr_c());
  //  printf("PUVECTEMP: (%f, %f, %f)\n", penumbvectemp[0], penumbvectemp[1], penumbvectemp[2]);
  //  printf("PUPTTEMP: (%f, %f, %f)\n", penumbpttemp[0], penumbpttemp[1], penumbpttemp[2]);

  //  printf("SPOS: (%f, %f, %f)\n", spos[0], spos[1], spos[2]);
  //  printf("TPOS: (%f, %f, %f)\n", tpos[0], tpos[1], tpos[2]);
  //  printf("PENUMBVEC: (%f, %f, %f)\n", penUmbVec[0], penUmbVec[1], penUmbVec[2]);
  //  printf("LEN(ST), LEN(PT): %f %f\n", st, pt);
  //  printf("ANG(PENUMB) %f, ANG(Q) %f, ANG(DELTA) %f\n", penUmbAng*dpr_c(), angleQ*dpr_c(), angQDelta*dpr_c());
 
  //  printf("VN %f PT %f ANGQ %f PENUMBANG %f ANGQDELTA %f\n", vnorm_c(penUmbPt), pt, angleQ, penUmbAng, angQDelta);

  //  printf("UNIXTIME: %f UMGANG: %f, ANGLEQ: %f, ANGQDELTA: %f\n", et2unix(et), umbAng*dpr_c(), angleQ*dpr_c(), angQDelta*dpr_c());

  SpiceDouble ret = 0.5 + (umbAng - fabs(angleQ))/(2*angQDelta);

  //  printf("RETURNING: %f\n", ret);
  
  return ret;
}

// TODO: allow dates beyond 0-9999
// TODO: note we are changing a static variable each time = bad?

char *stardate(SpiceDouble et) {

  char *result = malloc(sizeof(char)*1024);
    //  static char result[1024];
  char *format = "YYYYMMDD.HRMNSC";
  timout_c(et, format, 1024, result);
  return result;
}


/**

Given the ra and dec in J2000 radians, return the ra and dec in B1875 radians

TODO: improve for any date

*/

void j2000tob1875(double ra, double dec, double *raout, double *decout) {

  double matrix[3][3], pos[3], newpos[3], newr;

  // TODO: confirm -3944592000 is B1875 (may be off by some seconds:
  // leap seconds, noon vs midnight)

  // matrix to convert from J2000 to equator of date where -3944592000 is B1875
  pxform_c("J2000", "EQEQDATE", -3944592000, matrix);

  // convert input ra/dec to xyz (halfpi_c()-dec because function
  // wants "colatitude", not "latitude")

  sphrec_c(1, halfpi_c()-dec, ra, pos);

  // multiply converted input by matrix
  mxv_c(matrix, pos, newpos);

  // convert output xyz to ra/dec
  recsph_c(newpos, &newr, decout, raout);

  // fix decout to be declination, not "codeclination"
  *decout = halfpi_c()-*decout;

}

/**

Given the J2000 ra and dec in radians, return the constellation number of that ra and dec, where number is defined by the names[] array in constellationName

*/

int constellationNumber(double ra, double dec) {

#include "/home/user/BCGIT/ASTRO/CONSTELLATIONS/bc-large-arrays.h"

  // convert J2000 dec to B1875 ra/dec (in radians)
  double ra1875, dec1875;
  j2000tob1875(ra, dec, &ra1875, &dec1875);

  // correct ra1875 to lie between 0 and 2*pi

  if (ra1875 < 0) {ra1875 += twopi_c();}
  if (ra1875 > twopi_c()) {ra1875 -= twopi_c();}

  // convert ra in radians to ra in hours*3600
  ra1875 *= 180/pi_c()/15*3600;

  // convert dec in radians to dec in degrees*3600 (seconds)
  dec1875 *= 180/pi_c()*3600;

  int i, j, raSize = sizeof(ras)/sizeof(ras[0]), decSize = sizeof(decs)/sizeof(decs[0]);

 // find position of coordinate in ras and decs arrays
 // TODO: make this more efficient via binary search

 for (i=0; i < raSize; i++) {if (ra1875 < ras[i]) {break;}}
 for (j=0; j < decSize; j++) {if (dec1875 > decs[j]) {break;}}

 // position in consts containing constellation number
 int constVal = (j-1)*(raSize-1) + i-1;

 // return the constellation number from array
 return consts[constVal];
}

/**

Given an object (by NAIF id) and an ephemeris time et, return the
geocentric constellation number for that object in the EQEQDATE frame

*/

int obj2ConstellationNumber(int obj, double et) {

  double result[6], lt, r, ra, dec;

  spkezp_c(obj, et, "J2000", "CN+S", 399, result, &lt);

  recsph_c(result, &r, &dec, &ra);

  dec = halfpi_c()-dec;

  return constellationNumber(ra, dec);

}

/**

Given a constellation number as defined in constellationNumber (the
names array here), return the associated three letter IAU abbreviation

*/

char *constellationName(int constNumber) {

  char *names[] = {"AND", "ANT", "APS", "AQL", "AQR", "ARI", "ARA", "AUR", "BOO", "CAE", "CAM", "CAN", "CAP", "CAR", "CAS", "CEN", "CEP", "CET", "CHA", "CIR", "CMA", "CMI", "CNC", "COL", "COM", "CRA", "CRB", "CRT", "CRU", "CRV", "CVN", "CYG", "DEL", "DOR", "DRA", "EQU", "ERI", "FOR", "GEM", "GRU", "HER", "HOR", "HYA", "HYI", "IND", "LAC", "LEO", "LEP", "LIB", "LMI", "LUP", "LYN", "LYR", "MEN", "MIC", "MON", "MUS", "NOR", "OCT", "OPH", "ORI", "PAV", "PEG", "PER", "PHE", "PIC", "PSA", "PSC", "PUP", "PYX", "RET", "SCL", "SCO", "SCT", "SER", "SEX", "SGE", "SGR", "TAU", "TEL", "TRA", "TRI", "TUC", "UMA", "UMI", "VEL", "VIR", "VOL", "VUL"};

  return names[constNumber];

}
