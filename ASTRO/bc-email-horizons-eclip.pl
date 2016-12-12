#!/bin/perl

# Given lines from the out of bc-zodiac.c, crufts emails to HORIZONS
# to check accuracy

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
CENTER= '500@399'
MAKE_EPHEM= 'YES'
TABLE_TYPE= 'OBSERVER'
START_TIME= '%STARTTIME%'
STOP_TIME= '%ENDTIME%'
STEP_SIZE= '1 m'
CAL_FORMAT= 'CAL'
TIME_DIGITS= 'FRACSEC'
ANG_FORMAT= 'HMS'
OUT_UNITS= 'KM-S'
RANGE_UNITS= 'AU'
APPARENT= 'AIRLESS'
SOLAR_ELONG= '0,180'
SUPPRESS_RANGE_RATE= 'NO'
SKIP_DAYLT= 'NO'
EXTRA_PREC= 'NO'
R_T_S_ONLY= 'NO'
REF_SYSTEM= 'J2000'
CSV_FORMAT= 'NO'
OBJ_DATA= 'YES'
QUANTITIES= '2,31'
!\$\$EOF
MARK
;

while (<>) {

  $email = $template;

  my($era, $date, $ptime, $planet, $enters, $const, $grade, $time, $short) =
    split(/\s+/, $_);

  # this MAY not work :59 or :00 times, but don't care
  $ptime=~s/:\d\d:\d\d//;

  $email=~s/%STARTTIME%/$date $ptime:00/;
  $email=~s/%ENDTIME%/$date $ptime:59/;

  debug("EMAIL: $email");
#  debug("SHORT: $short, $date, $ptime");
}

die "TESTING";

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
