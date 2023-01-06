#!/bin/perl

# Another program that's really just for me, this checks the following
# for the doordash receipts in my database:
#
# - in total, receipts should match "download your data"
# - category should be RESTAURANT
# - all receipts have a reference number and match url
# - the reference numbers are in date order
# - I have a PDF receipt for each reference number
# - the reference number appears somewhere in the comments
# - the date inside comments comes before charge date
# - the total in comments matches actual total
# - no repeated dates in comments

# TODO: everything

require "/usr/local/lib/bclib.pl";

# the oddness below is to prevent newlines from breaking stuff

my(@res) = mysqlhashlist("SELECT *, REPLACE(REPLACE(comments, CHAR(10), '<nl>'), CHAR(13), '<nl>') AS commentspure FROM bc_budget_view WHERE description RLIKE 'doordash' ORDER BY date DESC", "test");

for $i (@res) {

  my(%hash) = %$i;

  # fix comments

  $hash{commentspure} =~s/(<nl>\s)+/\n/;
  $hash{comments} = $hash{commentspure};

  # skip unrecognized w/ warning for now

  unless ($hash{recognized} eq "YES") {
    warn("SKIPPING: $hash{oid}, not recognized");
    next;
  }

  # skip dateless w/ warning for now

  unless ($hash{comments}=~m%([A-Z][a-z]+ [0-9]+\,? [0-9][0-9][0-9][0-9] at [0-9:]+ [apAP][Mm])%) {
    warn("NO DATE: $hash{oid}");
    next;
  }

  my($date) = $1;
  $date=~s/ at / /;
  debug("DATE: $date");
  my($commentdate) = str2time($date);

  my($transdate) = str2time($hash{date});

  debug("DATE: $commentdate vs $transdate");


}
