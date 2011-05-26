#!/bin/perl

# This (not terribly instructive) script emails HORIZONS for planetary
# data for the next 10 years.

# <h>Damn the IAU, I hereby re-dub Pluto a planet!</h>

require "bclib.pl";

$template = << "MARK";

!\$\$SOF
COMMAND= '%OBJECT%'
CENTER= '500@399'
MAKE_EPHEM= 'YES'
TABLE_TYPE= 'OBSERVER'
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

# 10 years, all planets

for $i (2011..2020) {
  for $j (1..9) {

    # exclude Earth <h>(I usually know where it is)</h>
    if ($j==3) {next;}

    # and convert template (note obj number is ${j}99, not $j)
    $email = $template;
    $i1 = $i + 1;
    $email=~s/%STARTYEAR%/$i/isg;
    $email=~s/%ENDYEAR%/$i1/isg;
    $email=~s/%OBJECT%/${j}99/isg;

  debug("I: $i, I1: $i1, J: $j");

    debug($email);
}
}
