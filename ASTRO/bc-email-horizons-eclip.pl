#!/bin/perl

# Given lines from the out of bc-zodiac.c, crufts emails to HORIZONS
# to check accuracy

require "/usr/local/lib/bclib.pl";

# I can't really use a tmpdir here, since I want to look at these
# pre-mailing them
system("mkdir -p /var/tmp/horizons");
chdir("/var/tmp/horizons");

open(A,"> /var/tmp/horizons/runme.sh");

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
TIME_DIGITS= 'MINUTES'
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
CSV_FORMAT= 'YES'
OBJ_DATA= 'NO'
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

  # set the start and end time to be the hour in question
  $email=~s/%STARTTIME%/$date $ptime:00/;
  $email=~s/%ENDTIME%/$date $ptime:59/;

  # the object is the first letter of $short
  $short= substr($short,0,1);

  # if its a digit, this is just {digit}99
  my($object);
  if ($short=~/\d/) {
    $object = $short;
  } elsif ($short eq "M") {
    $object = 301;
  } elsif ($short eq "S") {
    $object = 10;
  } else {
    die "CANNOT INTERPRET: $short";
  }

  $email=~s/%OBJECT%/$object/;

  my($fname) = "$object-$date-$ptime.csv";
  write_file($email, $fname);

  print A "/usr/lib/sendmail -v -fhorizons\@barrycarter.info -t < /var/tmp/horizons/$fname\n";
}
