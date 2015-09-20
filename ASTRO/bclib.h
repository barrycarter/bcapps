// Several useful C functions that can be used across many programs

// Putting this in a .h file is even worse!

// The correct way to do this would be to compile these into an object
// (.o) file and then compile my programs against that object file. I
// know this, but am too lazy (and dislike C too much) to do this

double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}
double unix2et(double d) {return d-946684800.;}
double r2d(double d) {return d*180./pi_c();}

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

// this function may not work, I just wanted to get it out of bc-periapses.c

// find and print (icky) min seps in given interval

void findmins (SpiceDouble beg, SpiceDouble end) {

  SpiceInt i, count;

  // SPICEDOUBLE_CELLs are static, so must reinit them each time, sigh
  SPICEDOUBLE_CELL(result, 200);
  SPICEDOUBLE_CELL(cnfine,2);
  scard_c(0,&result);
  scard_c(0,&cnfine);

  // create interval
  wninsd_c(beg,end,&cnfine);

  // get results
  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);

  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    // becuase beg and end are equal, overwriting end with actual value
    gfq(beg,&end);
    printf("M %f %f %f\n",et2jd(beg),r2d(end),r2d(sunminangle(beg,planetcount,planets)));
  }
}

