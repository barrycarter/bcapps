#!/bin/perl

# does pretty much what the other bc-email-horizons scripts do, but
# gains 200 years worth of daily data per email (~246 years is the
# limit per request)

require "/usr/local/lib/bclib.pl";

# I can't really use a tmpdir here, since I want to look at these
# pre-mailing them
system("mkdir -p /tmp/horizons");
chdir("/tmp/horizons");

$template = << "MARK";
From: Barry Carter <carter.barry\@gmail.com>
To: HORIZONS <horizons\@ssd.jpl.nasa.gov>
Subject: JOB

!\$\$SOF
COMMAND= '%SOURCE%'
CENTER= '500@0'
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

open(A,"> /tmp/horizons/runme.sh");

# 10K years, all planets + Earth moon + Pluto
@planets = (10, 199, 299, 399, 499, 599, 699, 799, 899, 301);


for ($i=1; $i<=9999; $i+=200) {
  for $j (@planets) {

    # and convert template
    $email = $template;
    $email=~s/%SOURCE%/0/isg;
    $i1 = $i + 200;
    $email=~s/%STARTYEAR%/$i/isg;
    $email=~s/%ENDYEAR%/$i1/isg;
    $email=~s/%OBJECT%/${j}/isg;
    write_file($email, "mail.$i.$j");

  # and command to actually send it
  print A "/usr/lib/sendmail -v -fcarter.barry\@gmail.com -t < /tmp/horizons/mail.$i.$j\n";
  }
}

close(A);
