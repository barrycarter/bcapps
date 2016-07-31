#!/bin/perl

# attempt to put ISD hourly temperature data into MySQL, but worried
# that, even though MySQL should handle big data, my machine may not

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  debug("PROCESSING: $i");
  open(A,"zcat $i|");

  # TODO: for now, more interested in seeing how much data MySQL can
  # take, so not parsing fields intelligently (or at all)

  while (<A>) {
    s/\s+/\t/g;
    # TODO: trim station name
    print "$i\t$_\n";
  }
}

=item comment


time to do 2011 all stations: 391.873u 37.663s 8:48.09 81.3%  0+0k 1220904+9341720io 12pf+0w

4782908219 (4.7GB) bytes

=cut

=item schema

13 fields test

CREATE TABLE sizetest (
 f1 INT,
 f2 INT,
 f3 INT,
 f4 INT,
 f5 INT,
 f6 INT,
 f7 INT,
 f8 INT,
 f9 INT,
 f10 INT,
 f11 INT,
 f12 INT,
 f13 INT
);

LOAD DATA INFILE "/home/barrycarter/WEATHER/isd-lite/2011/bcisd2mysql.out"
INTO TABLE sizetest;

Query OK, 67156552 rows affected, 65535 warnings (3 min 0.52 sec)
Records: 67156552  Deleted: 0  Skipped: 0  Warnings: 67156552
x
=cut
