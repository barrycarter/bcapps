#!/bin/perl

# Does pretty much what bc-track-foods.pl does with these enhancements:
#   - foods info in single file (foods.txt), better format/errorchecking
#   - uses dfoods.db, not spreadsheet
#   - records (but doesnt currently use) time I eat foods
#   - foods.txt is open source, easier to see what program does

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/,read_file("/home/barrycarter/BCGIT/FOODTRACK/foods.txt"))) {
  # ignore comments and blank lines
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  # ignore text-based lines like "2135 1 container cotto salami"
  if ($i=~/^\d{4}\s+/) {next;}
  # record date
  if ($i=~/^DATE: (\d{8})$/) {$date = $1; next;}
  # if anything other than SHORT: remains, complain
  unless ($i=~/^SHORT: /) {die "BAD LINE: $i";}




  debug("I: $i");
}



