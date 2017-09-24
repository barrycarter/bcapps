#!/bin/perl

# one off (but aren't they all?) to parse list of WWF games in this format:

# GAME: winner winner_score, loser loser_score, first_word to
# last_word, (time in some format)

# into gnumeric spreadsheet for now

# NOTE: not sure how useful this is, only "real" thing I get is date parsing?

require "/usr/local/lib/bclib.pl";

while (<>) {

  # replaces spaces with commas for convenience
  s/\s+/,/g;

  # fields after 11 are date and don't need to be split
  my(@list) = split(/,/, $_, 11);

  # for date, convert commas back to spaces
  $list[-1]=~s/,+/ /g;

  # convert to localtime and format per gnumeric specs
  my($date) = strftime("%Y-%m-%d %H:%M:%S", localtime(str2time($list[-1])));

  # and print it
  my($print) = join(",", $list[1], $list[2], $list[4], $list[5], $list[7], $list[9], $date);
  print "$print\n";

  debug("LIST", @list, "DATE: $date");
}
