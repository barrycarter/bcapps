#!/bin/perl

# quick n dirty script that creates an iMacro to search Kindle books
# in all categories in Albuquerque Digital Library

# --only=m,n: only provide iim for subjects m through n, 0 based (eg,
# --only=0,4 would choose the first five subjects the user wants)

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

debug(sort values %subs);

# these are regexs I personally want
# TODO: allow user to set these
# NOTE TO SELF: this list is not complete
@regex = ("analysis", "business", "cartoon", "comic", "computer", "education",
	  "engineering", "erotic", "fantasy", "finance", "folklore", "games",
	  "humor", "math", "science", "TV");

# figure out which subjects user has chosen
for $i (sort keys %subs) {

  # does this meet a regex I want
  $wanted = 0;
  for $j (@regex) {
    if ($subs{$i}=~/$j/i) {
      $wanted=1;
      last;
    }
  }

    if ($wanted) {push(@wanted,$i);}
}

# parse --only (or choose everything if no such option)
if ($globopts{only}=~/^(\d+)\-(\d+)$/) {
  ($start, $end) = ($1, $2);
} else {
  ($start, $end) = (0, $#wanted);
}

debug("START/END: $start/$end");

# TODO: allow user to select subs?

# write to iim directory (probably a bad idea?)
open(B,">$ENV{HOME}/iMacros/Macros/bc-overdrive.iim");

# the guts of the iim file
for $i (@wanted[$start..$end]) {

  # does this meet a regex I want
  $wanted = 0;
  for $j (@regex) {
    if ($subs{$i}=~/$j/i) {
      $wanted=1;
      last;
    }
  }
  unless ($wanted) {next;}

  $n++;

  if ($globopts{limit} && $n > $globopts{limit}) {last;}

  $count++; # yes, I should use $n for this, sigh

  # the fixed values for format and page are Kindle Book, and 25 hits/page
  # and most recent books (since I tend to run this often?)

  # the #$subs{$i} below is solely for end user to know what was searched
  print B << "MARK";
TAB OPEN
TAB T=$n
URL GOTO=http://cabq.lib.overdrive.com/en/AdvancedSearch.htm
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:format CONTENT=%420
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:page CONTENT=%25
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:sub CONTENT=%$i
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ACTION:BANGSearch.dll ATTR=VALUE:Search
TAG POS=1 TYPE=A ATTR=TXT:date<SP>added<SP>to<SP>site
MARK
;
}

close(B);

print "$count subjects (of $#wanted+1) chosen; use --only to limit\n";

