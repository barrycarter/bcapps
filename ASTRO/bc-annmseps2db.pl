#!/bin/perl

# The final final step of the quest to find conjunctions: this takes
# the annmsepsdump dump files and converts them to a MySQL database

require "/usr/local/lib/bclib.pl";

# this is the dump file for all conjunctions, including 3+ planets
open(A,">/tmp/conjuncts.txt");
# and mysql queries
open(B,">/tmp/ams2-queries.txt");
print B "BEGIN;\n";

for $i (glob "/home/barrycarter/SPICE/KERNELS/annmsepsdump*.txt") {
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

-- The schema of the MySQL tables:

CREATE TABLE p2 (
p1 TEXT, p2 TEXT, 
jd DOUBLE, year INT, month INT, day INT, time TIME,
sep DOUBLE, solarsep DOUBLE, star TEXT, starsep DOUBLE
);

-- The others are identical, but with more planets

CREATE TABLE p3 (
p1 TEXT, p2 TEXT, p3 TEXT, 
jd DOUBLE, year INT, month INT, day INT, time TIME,
sep DOUBLE, solarsep DOUBLE, star TEXT, starsep DOUBLE
);

CREATE TABLE p4 (
p1 TEXT, p2 TEXT, p3 TEXT, p4 TEXT,
jd DOUBLE, year INT, month INT, day INT, time TIME,
sep DOUBLE, solarsep DOUBLE, star TEXT, starsep DOUBLE
);

CREATE TABLE p5 (
p1 TEXT, p2 TEXT, p3 TEXT, p4 TEXT, p5 TEXT, 
jd DOUBLE, year INT, month INT, day INT, time TIME,
sep DOUBLE, solarsep DOUBLE, star TEXT, starsep DOUBLE
);

-- there is only one conjunction of all 6 planets

CREATE TABLE p6 (
p1 TEXT, p2 TEXT, p3 TEXT, p4 TEXT, p5 TEXT, p6 TEXT,
jd DOUBLE, year INT, month INT, day INT, time TIME,
sep DOUBLE, solarsep DOUBLE, star TEXT, starsep DOUBLE
);

-- indexes are also similar

CREATE INDEX p11 ON p2(p1(10));
CREATE INDEX p12 ON p2(p2(10));
CREATE INDEX p13 ON p2(jd);
CREATE INDEX p14 ON p2(year);
CREATE INDEX p15 ON p2(month);
CREATE INDEX p16 ON p2(day);
CREATE INDEX p17 ON p2(time);
CREATE INDEX p18 ON p2(sep);
CREATE INDEX p19 ON p2(solarsep);
CREATE INDEX p1a ON p2(star(10));
CREATE INDEX p1b ON p2(starsep);

=cut
