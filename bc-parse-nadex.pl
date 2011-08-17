#!/bin/perl

# NOTE: this script is fairly trivial and makes me wonder if I should
# be git-ting everything I do

# Parses a NADEX statement, which looks like below into MySQL format.
# Assumes file contains ALL NADEX transactions (impossible to find dupes, sigh)

=item sample

Type,Date,Time,Description,Amount,
Credit Adjustment,10/18/10,09:45:23,RTAF Given,250.00,
Sell,10/18/10,10:18:12,4 USD/CAD >1.0194 (11AM) @ 48,-208.00,
Fee Payment,10/18/10,10:18:12,4 USD/CAD >1.0194 (11AM) @ 48,-4.00,
Buy to Close,10/18/10,10:49:47,1 USD/CAD >1.0194 (11AM) @ 5,95.00,
Fee Payment,10/18/10,10:49:47,1 USD/CAD >1.0194 (11AM) @ 5,-1.00,
Buy to Close,10/18/10,10:49:58,1 USD/CAD >1.0194 (11AM) @ 5,95.00,

SCHEMA:

CREATE TABLE forex.nadex_trans (
 type TEXT,
 date DATETIME,
 descr TEXT,
 amt DOUBLE,
 comments TEXT
);

=cut

require "bclib.pl";
($cont, $name) = cmdfile();

for $i (split(/\n/,$cont)) {
  ($type, $date, $time, $descr, $amt) = split(/\,/, $i);

  # ignore header line
  if ($type=~/type/i) {next;}

  # fix date
  $date=~m%(\d+)/(\d+)/(\d+)%;
  $date=sprintf("20%0.2d-%0.2d-%0.2d", $3, $1, $2);


  push(@queries, "INSERT IGNORE INTO forex.nadex_trans 
 (type, date, descr, amt) VALUES ('$type', '$date $time', '$descr', $amt)");

}

write_file(join(";\n",@queries).";", "/tmp/nadex-queries.txt");
system("mysql < /tmp/nadex-queries.txt");




