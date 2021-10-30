#!/bin/perl

# Similar to bc-bofa-mv.pl: given the text version of a PDF credit
# card statement, determine rewards point information

require "/usr/local/lib/bclib.pl";

# TODO: input to this program is a txt file, not a pdf file

# these variables are global

my($data, $fname) = cmdfile();

# popular regular expressions

my($datepat) = "(\\d{2}/\\d{2}/\\d{4})";
my($commanum) = "([\\d,]+)";

# debug("DATA: $data");

if ($data=~/capitalone/) {
  parse_capital_one();
}

sub parse_capital_one {

#  $data=~m%Rewards Balance as of\s*(\d{2}/\d{2}/\d{4}).*?([\d,]+)\s*Previous Balance\s*([\d,]*)\s*Earned\s*Redeemed\s*([\d,]+)\s*([\d,]+)%is;

  # search for multiple formats
  my($found) = 0;

  # patterns

  my(@pats) = (
	       "Rewards Balance as of $datepat(.*)\$"
	       );

  for $i (@pats) {

    # harden spaces + turn into regex

    $i=~s/ /\\s*/g;
    $i = qr/$i/s;

    debug("LOOKING AT: $i");

    if ($data=~m%$i%) {
      debug("GOT: $1 $2 $3");
      break;
    }
  }




#  if ($data=~m%Rewards\s*Balance\s*as\s*of\s* (\d{2}/\d{2}/\d{4}) .*?([\d,]+)\s*Previous\s*Balance\s*Earned\s*Redeemed\s*([\d,]+)\s*([\d,]+)\s*([\d,]+)%isx) {
#    $found = 1;
#  } elsif ($data=~m%([\d,]+)\s*Rewards as of: (\d{2}/\d{2}/\d{4}).*?Previous Balance\s*Earned\s*Redeemed\s*([\d,]+)\s*([\d,]+)\s*([\d,]+)%is) {
#    $found = 1;
#  } else {
#    $found = 0;
#  }

  debug("X: $fname $1, $2 $3 $4 $5");

}
