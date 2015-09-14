#!/bin/perl

# Converts the output of pconjuncts (in the CONJUNCTIONS subdir) to MySQL

require "/usr/local/lib/bclib.pl";

# NOTE: we dont print Earth, but need Mars in position 4, so...
@plist = ("", "Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus");

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
    @planets=split(/\s+/,$1);
    map($_=$plist[$_],@planets);
    next;
  }

  # range for conjunction (just record, wont print until min line)
  if (/^R\s+(.*?)\s+(.*?)$/) {@range=($1,$2);next;}

  # TODO: should never see two range lines in a row without at least
  # one min line, maybe check for this bad case

  # the min line where we actually do print stuff
  my($m,$jd,$sep,$sunsep) = split(/\s+/, $_);

  # the dates for the conjunction, and containing range
  my(@date) = jd2mixed_ymdhms($jd);
  my(@sdate) = jd2mixed_ymdhms($range[0]);
  my(@edate) = jd2mixed_ymdhms($range[1]);

  # print the "datetime string" for all three
  # TODO: if changing this to TEXT, add leading 0s for sort
  $cdate = sprintf("%04d-%02d-%02d %02d:%02d:%02d",@date);
  $sdate = sprintf("%04d-%02d-%02d %02d:%02d:%02d",@sdate);
  $edate = sprintf("%04d-%02d-%02d %02d:%02d:%02d",@edate);

  # cleanup hms for conjunct time (since we print it in multiple fields)
  my($hms) = sprintf("%02d:%02d:%02d",@date[3..5]);

  # the values for MySQL
  my(@vals) = (@planets, $jd, $cdate, @date[0..2], $hms, $sep, $sunsep,
	       $range[0], $sdate, $range[1], $edate);
  map($_="'$_'",@vals);
  my($vals) = join(", ",@vals);

  # TODO: printing to stdout just for testing
  print B "INSERT INTO conjunctions (p1, p2, p3, p4, p5, p6, jd, cdate, year, 
         month, day, time, sep, sunsep, sjd, sdate, ejd, edate) VALUES 
         ($vals);\n";
  print A join(",",@vals),"\n";
}

print B "COMMIT;\n";

=item schema

-- The schema of the MySQL table:

-- (using DATETIME for sdate and edate even though they exceed ranges)
-- TODO: change to filled text if this doesnt work

CREATE TABLE conjunctions (p1 TEXT, p2 TEXT, p3 TEXT, p4 TEXT, p5
TEXT, p6 TEXT, jd DOUBLE, cdate TEXT, year INT, month INT, day
INT, time TIME, sep DOUBLE, sunsep DOUBLE, sjd DOUBLE, sdate TEXT,
ejd DOUBLE, edate TEXT);

CREATE INDEX p1 ON conjunctions(p1(10));
CREATE INDEX p2 ON conjunctions(p2(10));
CREATE INDEX p3 ON conjunctions(p3(10));
CREATE INDEX p4 ON conjunctions(p4(10));
CREATE INDEX p5 ON conjunctions(p5(10));
CREATE INDEX p6 ON conjunctions(p6(10));
CREATE INDEX p7 ON conjunctions(jd);
CREATE INDEX pi ON conjunctions(cdate(12));
CREATE INDEX p8 ON conjunctions(year);
CREATE INDEX p9 ON conjunctions(month);
CREATE INDEX pa ON conjunctions(day);
CREATE INDEX pb ON conjunctions(time);
CREATE INDEX pc ON conjunctions(sep);
CREATE INDEX pd ON conjunctions(sunsep);
CREATE INDEX pe ON conjunctions(sdate(12));
CREATE INDEX pf ON conjunctions(edate(12));
CREATE INDEX pg ON conjunctions(sjd);
CREATE INDEX ph ON conjunctions(ejd);

=cut
