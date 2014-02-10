#!/bin/perl

# Given the HTML output of an okcupid.com search, lists those users
# who have you have not rated yet (rating a user 4-5 stars sends them
# a message saying you like them). Helps you semi-efficiently "spam"
# girls (or guys I suppose) by rating them 5 stars.

# Note: on an okcupid.com search page, hold down PAGE DOWN until there
# are no more entries

require "/usr/local/lib/bclib.pl";

($text,$file) = cmdfile();

# <div class="match row..."> splits rows
# @matches = split(/<div class=\"match_row/is, $text);
# later it's div id="usr-[name]...
@matches = split(/<div id=\"usr\-/is, $text);

for $i (@matches) {
  # ignore the wrapper (need main section)
  if ($i=~/^[a-z_\-0-9]+\-wrapper/i) {next;}
  # already rated?
  if ($i=~/flat_stars\s+show/is) {next;}
  # can't obtain username?
  unless ($i=~/^([a-z\-0-9_]+?)\"/i) {next;}
  print "/root/build/firefox/firefox -remote 'openURL(http://www.okcupid.com/profile/$1)'; sleep 2\n";
}

# later:
# class="star-rating match_card_rating flat_stars"> = not rated
# class="star-rating match_card_rating flat_stars show  " = rated

# <div class="match_row
