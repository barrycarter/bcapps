#!/bin/perl

# Parses HTML statements from secureaccountservice.com; pretty much
# useless to everyone, almost including me

require "/usr/local/lib/bclib.pl";

$all = read_file("/home/barrycarter/Download/sas-20140301.html");

# since I reload all data each time, re-create table (which I concede is ugly)

print << "MARK";
DROP TABLE IF EXISTS sas;
CREATE TABLE sas (date DATE, type TEXT, payee TEXT, description TEXT,
method TEXT, amount DOUBLE, comments TEXT);
-- my standard way of adding an 'oid' column, probably not best way to do it
ALTER TABLE sas
ADD oid INT UNSIGNED NOT NULL AUTO_INCREMENT, ADD INDEX (oid);
MARK
;

for $i (split(/\n/,$all)) {
  chomp($i);
  # get rid of internal commas
  $i=~s/,//g;
  # get rid of dollar signs
  $i=~s/\$//g;
  # replace HTML with commas
  $i=~s/<.*?>/,/g;
  # replace multiple commas with comma
  $i=~s/,+/,/g;
  # trim commas at start end
  $i=~s/^\s*,//;
  $i=~s/,\s*$//;
  # normalize hyphens
  $i=~s/\s*\-\s*/\-/g;
  # ignore lines that don't start w a date (after changes above)
  unless ($i=~/^\d/) {next;}

  # split into fields
  my($date, $type, $payee, $description, $method, $amount) = split(/\,/, $i);

  # convert date
  ($date=~s/^(\d{2})\/(\d{2})\/(\d{4})$/$3-$1-$2/s)||die("BAD DATE: $date");

  # query...
  print "INSERT INTO sas (date, type, payee, description, method, amount)
 VALUES ('$date', '$type', '$payee', '$description', '$method', '$amount');\n";
}

