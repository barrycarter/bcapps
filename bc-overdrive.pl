#!/bin/perl

# quick n dirty script that creates an iMacro to search Kindle books
# in all categories in Albuquerque Digital Library

# --limit: limit to this many pages (currently in alpha order)

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

# TODO: allow user to select subs?

# the guts of the iim file
for $i (sort keys %subs) {

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

  # the fixed values for format and page are Kindle Book, and 25 hits/page
  # and most recent books (since I tend to run this often?)

  # the #$subs{$i} below is solely for end user to know what was searched
  print << "MARK";
TAB OPEN
TAB T=$n
URL GOTO=http://cabq.lib.overdrive.com/en/AdvancedSearch.htm#$subs{$i}
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:format CONTENT=%420
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:page CONTENT=%25
TAG POS=1 TYPE=SELECT FORM=ACTION:BANGSearch.dll ATTR=ID:sub CONTENT=%$i
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ACTION:BANGSearch.dll ATTR=VALUE:Search
TAG POS=1 TYPE=A ATTR=TXT:date<SP>added<SP>to<SP>site
MARK
;
}

