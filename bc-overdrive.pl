#!/bin/perl

# quick n dirty script that creates an iMacro to search Kindle books
# in all categories in Albuquerque Digital Library

#<h>Part of the useless-except-to-me series of programs!</h>

require "/usr/local/lib/bclib.pl";

# obtain the search page (the subject ids are not sequential/etc, but
# don't change much)

my($out,$err,$res) = cache_command("curl -L http://cabq.lib.overdrive.com/en/AdvancedSearch.htm", "age=86400");

# subject values
$out=~m%<select name="Subject"(.*?)</select>%isg;
$subs = $1;

while ($subs=~s%<option value="(.*?)">(.*?)</option>%%) {
  $subs{$1} = $2;
}

# TODO: allow user to select subs?

# the guts of the iim file
for $i (sort keys %subs) {
  $n++;

  if ($n>10) {die "TESTING";}
  # the fixed values for format and page are Kindle Book, and 25 hits/page
  print << "MARK";
TAB OPEN
TAB T=$n
URL GOTO=http://cabq.lib.overdrive.com/en/AdvancedSearch.htm
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:format CONTENT=%420
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:page CONTENT=%25
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:sub CONTENT=%$i
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ACTION:BANGSearch.dll ATTR=VALUE:Search
MARK
;
}

