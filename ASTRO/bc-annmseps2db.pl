#!/bin/perl

# Converts the output of pconjuncts (in the CONJUNCTIONS subdir) to MySQL

require "/usr/local/lib/bclib.pl";

# this is the dump file for all conjunctions, including 3+ planets
open(A,">/tmp/conjuncts.txt");
# and mysql queries
open(B,">/tmp/ams2-queries.txt");
print B "BEGIN;\n";

open(C,"bzcat $bclib{githome}/ASTRO/CONJUNCTIONS/*.out.bz2|");

my(@planets,@range);

while (<C>) {

  # new set of planets?
  if (/CONJUNCTIONS FOR.*planets: (.*?)$/i) {
    @planets = ();
    for $i (split(/\s+/,$1)) {if ($i) {push(@planets,$i);}}
    next;
  }

  # range for conjunction (just record, wont print until min line)
  if (/^R\s+(.*?)\s+(.*?)$/) {@range=($1,$2);next;}

  # the min line where we actually do print stuff
  my($m,$jd,$sep,$sunsep) = split(/\s+/, $_);
  my($numplans) = scalar(@planets);
  my(@date) = jd2mixed_ymdhms($jd);
  # the start and end dates for the range containing this conjunction
  my(@sdate) = jd2mixed_ymdhms($range[0]);
  my(@edate) = jd2mixed_ymdhms($range[1]);

  # cleanup hms
  my($hms) = sprintf("%02d:%02d:%02d",@date[3..5]);
  debug("HMS: $hms");

  debug("DATE",@date);

  # build up field list (this is ugly and non-normalized)
  my($flist) = "p1";
  for $j (2..$numplans) {$flist.=", p$j";}

  my(@printlist) = (@planets,$jd,@date[0..2],join(":",@date[3..5]),$sep,$sun,$star,$sunsep);
  map($_="'$_'",@printlist);
  my($print) = join(", ",@printlist);

  # TODO: printing to stdout just for testing
  print "INSERT INTO p$numplans 
($flist, jd, year, month, day, time, sep, solarsep) VALUES ($print);\n";

  print A join(",",(join("+",@planets),$jd,@date[0..2],join(":",@date[3..5]),$sep,$sunsep)),"\n";

}

die "TESTING";

for $i (glob "$bclib{githome}/ASTRO/CONJUNCTIONS/*.out.bz2") {
  debug("READING: $i");
  my($all) = read_file($i);

  # remove empty sep lists
  while ($all=~s/(annminsep\[\{[a-z\s\,]+\}\] \= \{\})//) {debug("IGNORING: $1");}

  while ($all=~s/annminsep\[\{(.*?)\}\]\s*=\s*\{(\{.*?\})\}//s) {

    my($planets,$data) = ($1,$2);

    my(@planets) = split(/\,\s*/s,$planets);
    my($numplans) = scalar(@planets);

    while ($data=~s/\{(.*?)\}//s) {
      my($jd, $sep, $sun, $star, $ssep) = split(/\,\s*/s,$1);

      # get calendar date from Julian date
      # MySQL can't handle years < 100 so separate into fields
      $jd=~s/\*\^/e/;
      my(@date) = jd2mixed_ymdhms($jd);

      print A join(",",(join("+",@planets),$jd,@date[0..2],join(":",@date[3..5]),$sep,$sun,$star,$ssep)),"\n";

      my(@printlist) = (@planets,$jd,@date[0..2],join(":",@date[3..5]),$sep,$sun,$star,$ssep);
      map($_="'$_'",@printlist);
      my($print) = join(", ",@printlist);

      # build up field list (this is ugly and non-normalized)
      my($flist) = "p1";
      for $j (2..$numplans) {$flist.=", p$j";}

      print B "INSERT INTO p$numplans ($flist, jd, year, month, day, time, sep, solarsep, star, starsep) VALUES ($print);\n";

      # TODO: turn this into an INSERT statement
      # TODO: this won't work if more than 2 planets, fix
      # NOTE: including JD in final result can't use MySQL date, but also
      # doing year/month/day breakdown for ease of use
      if (scalar(@planets)>2) {next;}

#      print join("\t",@planets,$jd,@date[0..2],join(":",@date[3..5]),$sep,$sun,$star,$ssep),"\n";
      # for the dump file, we glue planets using plus since number can vary
    }
  }
}

print B "COMMIT;\n";

close(B);

=item schema

-- The schema of the MySQL table:

CREATE TABLE conjunctions (
p1 TEXT, p2 TEXT, p3 TEXT, p4 TEXT, p5 TEXT, p6 TEXT,
jd DOUBLE, year INT, month INT, day INT, time TIME,
sep DOUBLE, solarsep DOUBLE);

CREATE INDEX p1 ON conjunctions(p1(10));
CREATE INDEX p2 ON conjunctions(p2(10));
CREATE INDEX p3 ON conjunctions(p3(10));
CREATE INDEX p4 ON conjunctions(p4(10));
CREATE INDEX p5 ON conjunctions(p5(10));
CREATE INDEX p6 ON conjunctions(p6(10));
CREATE INDEX p7 ON conjunctions(jd);
CREATE INDEX p8 ON conjunctions(year);
CREATE INDEX p9 ON conjunctions(month);
CREATE INDEX pa ON conjunctions(day);
CREATE INDEX pb ON conjunctions(time);
CREATE INDEX pc ON conjunctions(sep);
CREATE INDEX pd ON conjunctions(solarsep);

=cut
