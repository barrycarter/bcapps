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

  if ($data=~/We are unable to provide your Rewards Summary/) {return;}

  # search for multiple formats
  my($found) = 0;

  # patterns

  my(@pats) = (
	       "Rewards Balance as of $datepat .*? $commanum Previous Balance Earned Redeemed $commanum $commanum $commanum",
	       "Rewards Balance .*? Previous Balance Earned This Period Redeemed This Period $commanum $commanum $commanum",
	       "Rewards as of: $datepat Rewards Balance .* $commanum Previous Balance Earned This Period Redeemed this period $commanum $commanum $commanum",
	       "$commanum Rewards as of: $datepat .* Previous Balance Earned This Period Redeemed this period $commanum $commanum $commanum"
	       );

  for $i (@pats) {

    # harden spaces + turn into regex

    $i=~s/ /\\s*/g;
    $i = qr/$i/s;

    debug("LOOKING AT: $i");

    if ($data=~m%$i%) {
      debug("GOT: $fname $1 $2 $3 $4 $5");
      $found = 1;
      break;
    }
  }

  unless ($found) {
    debug("NO PATTERN IN: $data");
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
