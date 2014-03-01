#!/bin/perl

# Parses HTML statements from secureaccountservice.com; pretty much
# useless to everyone, almost including me

require "/usr/local/lib/bclib.pl";

$all = read_file("/home/barrycarter/Download/sas-20140301.html");

for $i (split(/\n/,$all)) {
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
  my($date, $type, $description, $amount) = split(/\,/, $i);

  # convert date
  debug("DATE: *$date*");
  ($date=~s/^(\d{2})\/(\d{2})\/(\d{4})$/$3-$1-$2/s);
#  ($date=~s/^(\d{2})\/(\d{2})\/\//$2-$1/);
  debug("DATE: $date");
}

=item schema

CREATE TABLE sas (date DATE, type TEXT, description TEXT, amount DOUBLE,
comments TEXT);

=cut
