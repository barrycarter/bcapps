#!/bin/perl

# This (not terribly instructive) script emails HORIZONS for planetary
# data for the next 10 years.

# modified 10 Sep 2011 to obtain XYZ position and velocity from SSB
# (solar system barycenter <h>barrycenter!</h>)

# <h>Damn the IAU, I hereby re-dub Pluto a planet!</h>

require "bclib.pl";

# I can't really use a tmpdir here, since I want to look at these
# pre-mailing them
system("mkdir -p /tmp/horizons");
chdir("/tmp/horizons");

$template = << "MARK";
From: Barry Carter <carter.barry\@gmail.com>
To: HORIZONS <horizons\@ssd.jpl.nasa.gov>
Subject: JOB

!\$\$SOF
COMMAND= '%OBJECT%'
CENTER= '500\@0'
MAKE_EPHEM= 'YES'
TABLE_TYPE= 'VECTOR'
START_TIME= '%STARTYEAR%-01-01'
STOP_TIME= '%ENDYEAR%-01-01'
STEP_SIZE= '6 m'
CAL_FORMAT= 'JD'
TIME_DIGITS= 'FRACSEC'
ANG_FORMAT= 'DEG'
OUT_UNITS= 'KM-S'
RANGE_UNITS= 'AU'
APPARENT= 'AIRLESS'
SOLAR_ELONG= '0,180'
SUPPRESS_RANGE_RATE= 'YES'
SKIP_DAYLT= 'NO'
EXTRA_PREC= 'YES'
R_T_S_ONLY= 'NO'
REF_SYSTEM= 'J2000'
CSV_FORMAT= 'YES'
OBJ_DATA= 'NO'
QUANTITIES= '1'
!\$\$EOF

MARK
;

open(A,"> /tmp/horizons/runme.sh");

# 10 years, all planets + Earth moon + Pluto
@planets = (10, 199, 299, 399, 499, 599, 699, 799, 899, 301);


for $i (2011..2020) {
  for $j (@planets) {

    # exclude Earth <h>(I usually know where it is)</h>
    # for barycenter, I need earth
#    if ($j==3) {next;}

    # and convert template
    $email = $template;
    $i1 = $i + 1;
    $email=~s/%STARTYEAR%/$i/isg;
    $email=~s/%ENDYEAR%/$i1/isg;
    $email=~s/%OBJECT%/${j}/isg;
    write_file($email, "mail.$i.$j");

  # and command to actually send it
  print A "/usr/lib/sendmail -v -fcarter.barry\@gmail.com -t < /tmp/horizons/mail.$i.$j\n";
  

}
}

close(A);
