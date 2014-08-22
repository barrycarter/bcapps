#!/bin/perl

# 22 Aug 2014: this script emails HORIZONS to obtain ICRS
# (REF_PLANE="FRAME") data for major planets and a couple of
# non-Terran satellites

# NOTE: since this is just to verify my Chebyshev coefficients, only
# getting data for daily usage

require "/usr/local/lib/bclib.pl";

# I can't really use a tmpdir here, since I want to look at these
# pre-mailing them
system("mkdir -p /var/tmp/horizons");
chdir("/var/tmp/horizons");

$template = << "MARK";
From: Barry Carter <horizons\@barrycarter.info>
To: HORIZONS <horizons\@ssd.jpl.nasa.gov>
Subject: JOB

!\$\$SOF
COMMAND= '%OBJECT%'
CENTER= '500\@0'
MAKE_EPHEM= 'YES'
TABLE_TYPE= 'VECTORS'
START_TIME= '%STARTYEAR%-01-01'
STOP_TIME= '%ENDYEAR%-01-01'
STEP_SIZE= '1 d'
OUT_UNITS= 'KM-S'
VECT_TABLE= '3'
REF_PLANE= 'FRAME'
REF_SYSTEM= 'J2000'
VECT_CORR= 'NONE'
VEC_LABELS= 'NO'
CSV_FORMAT= 'YES'
OBJ_DATA= 'YES'
!\$\$EOF

MARK
;

open(A,"> /var/tmp/horizons/runme.sh");

# 60+ years, all planets + Earth moon + Pluto + Titan
@planets = (10, 199, 299, 399, 499, 599, 699, 799, 899, 301, 606);

for $i (1970..2040) {
  for $j (@planets) {
    # convert template
    $email = $template;
    $i1 = $i + 1;
    $email=~s/%STARTYEAR%/$i/isg;
    $email=~s/%ENDYEAR%/$i1/isg;
    $email=~s/%OBJECT%/${j}/isg;
    write_file($email, "mail.$i.$j");

  # and command to actually send it
  print A "/usr/lib/sendmail -v -fhorizons\@barrycarter.info -t < /var/tmp/horizons/mail.$i.$j\n";
  }
}

close(A);
