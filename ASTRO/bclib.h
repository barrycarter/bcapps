// Several useful C functions that can be used across many programs

// Putting this in a .h file is even worse!

// The correct way to do this would be to compile these into an object
// (.o) file and then compile my programs against that object file. I
// know this, but am too lazy (and dislike C too much) to do this

// TODO: these are wrong because I don't account for TDB-UTC (using
// deltet_c) like I should (but now fixing for unix conversions)

double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}

// TODO: check routines below, I may have delta backwards or for wrong era

double unix2et(double d) {
  // compute delta
  SpiceDouble delta;
  deltet_c(d-946728000,"UTC",delta);
  return d-946728000.+delta;
}

double et2unix(double d) {
  // compute delta
  SpiceDouble delta;
  deltet_c(et,"ET",delta);
  return d+946728000.-delta;
}

// TODO: replace this with rpd_c or dpr_c everywhere it appears
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
