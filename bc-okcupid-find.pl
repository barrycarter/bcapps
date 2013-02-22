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
@matches = split(/<div class=\"match_row/is, $text);

for $i (@matches) {
  if ($i=~/your rating of her/i) {next;}
  $i=~/id=\"usr-(.*?)"/;
  print "/root/build/firefox/firefox -remote 'openURL(http://www.okcupid.com/profile/$1)'; sleep 2\n";
}

# debug($text);

# <div class="match_row
