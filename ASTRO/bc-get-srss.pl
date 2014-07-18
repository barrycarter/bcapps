#!/bin/perl

# Obtains sunrise/sunset info from
# http://aa.usno.navy.mil/data/docs/RS_OneYear.php and puts it into an
# SQLite3 db

require "/usr/local/lib/bclib.pl";

# values of $type below
my(@types)=("SR", "SS", "MR", "MS", "CTS", "CTE", "NTS", "NTE", "ATS", "ATE");

# I probably shouldn't do it this way
open(A,"|tee /tmp/sql.txt|sqlite3 /home/barrycarter/BCGIT/db/abqastro.db");
print A "BEGIN;\n";
print A "DELETE FROM abqastro;\n";

# major lunar phase data (moved from bc-moon-phases.pl)
for $i (split(/\n/, `cat /home/barrycarter/BCGIT/db/moon-phases* | fgrep -v 'phase'`)) {
  @fields = csv($i);

  # convert to local time
  my($time) = strftime("%Y-%m-%d %H:%M:%S",localtime($fields[5]));
  print A "INSERT INTO abqastro VALUES ('$fields[2]', '$time');\n";
}

# In theory, the POST form,
# http://aa.usno.navy.mil/cgi-bin/aa_rstablew.pl, accepts only POST
# data, but it actually accepts GET data as well

# TODO: move this declaration much further inside
my(%data);
for $year (2009..2024) {
  for $type (0..4) {
    # 100 day cache, could be even longer
    my($out,$err,$res) = cache_command2("curl 'http://aa.usno.navy.mil/cgi-bin/aa_rstablew.pl?FFX=1&xxy=$year&type=$type&st=NM&place=albuquerque&ZZZ=END'","age=8640000");

    # parse result
    for $k (split(/\n/, $out)) {
      # TODO: need header lines to determine what data I have, but skip for now
      # determine day (if not one, skip)
      unless ($k=~/^\s*(\d+)\s*/) {next;}
      my($day) = $1;
      # data is positional and has blanks, so can't use split() here
      for $month ("01".."12") {
	my($times) = substr($k,$month*11-7,9);
	# can't use \d below because of blanks
	$times=~/^(..)(..) (..)(..)$/;
	my(@times) = ("$1:$2", "$3:$4");
	for $i (0..1) {
	  # ignore blanks
	  if ($times[$i]=~/^\s*:\s*$/) {next;}
	  # bizarre hack for DST
	  # TODO: generalize MST, the webpage does include this information
	  my($time) = strftime("%Y-%m-%d %H:%M", localtime(str2time("$year-$month-$day $times[$i] MST")));
	  print A "INSERT INTO abqastro VALUES ('$types[2*$type+$i]', '$time');\n";
	}
      }
    }
  }
}

# the lunar phase data does NOT include whether moon is waxing or
# waning; this fixes it (full/new moons might be left as is)
print A << "MARK";

-- changing the events via postfix to avoid breaking sorting for other querys

UPDATE abqastro SET event = event||"+"
WHERE oid IN (
 SELECT a1.oid FROM abqastro a1, abqastro a2 
 WHERE a2.time = datetime(a1.time, '+1 day')
 AND a1.event LIKE 'PHASE %' AND a2.event LIKE 'PHASE%'
 AND a1.event < a2.event
);

UPDATE abqastro SET event = event||"-"
WHERE oid IN (
 SELECT a1.oid FROM abqastro a1, abqastro a2 
 WHERE a2.time = datetime(a1.time, '+1 day')
 AND a1.event LIKE 'PHASE %' AND a2.event LIKE 'PHASE%'
 AND a1.event > a2.event
);

MARK
;

print A "COMMIT;\n";

close(A);

=item schema

CREATE TABLE abqastro (event TEXT, time DATETIME);
CREATE INDEX i_event ON abqastro(event);
CREATE INDEX i_time ON abqastro(time);

=cut
