#!/bin/perl

# Goes through my main TODO list backwards for n days and randomly
# selects 5 items, optionally excluding items with specific tags
# Sample entry in TODO list (all one line):

# 20131120.191106 if night bc-text-weather can also say whether
# brighter planets are up or down [ASTRO]

# This entry was made on 20 Nov 2013, 7:11:06pm local time, and is
# tagged with ASTRO (most entries don't have tags)

# Entries whose first non-time word ends in colon are considered
# "handled" (either I've done them, given up on them, they've become
# obsolete, etc)

# --days = how many days to go back (default = 365)
# --n = how many items to show (default = 5)
# --tags = "tag1,tag2,etc" which tags to exclude

require "/usr/local/lib/bclib.pl";
defaults("days=365&n=5");

$now = time();

# hash the tags <h>(why did I just think of twitter...)</h>
for $i (split/\,/,$globopts{tags}) {$badtag{$i}=1;}
debug("BADTAG",%badtag);

open(A,"tac /home/barrycarter/bc-todo-list.txt|");

FILTER:
while (<A>) {
  chomp;
  m/^(\d{8})\.(\d{6})/ || die ("BAD LINE: $_");
  # TODO list is time ordered, so can bail once hitting too old event
  if ($now-str2time("$1 $2") > 86400*$globopts{days}) {last;}

  # does first word end in colon?
  m/\S+\s+(\S+)/;
  if ($1=~/:$/) {next;}

  # tags
  my(@tags) = m/\[(.*?)\]/g;

  for $i (@tags) {
    if ($badtag{$i}) {
      next FILTER;
    }
  }

  push(@list, $_);
}

@list = randomize(\@list);

# to make this look more like my old version...

# curses values for bold on/off and clear
($clear,$bon,$boff)=("\e[H\e[J","\e[1m","\e[0m");
printf("$clear${bon}Showing $globopts{n} of %d items$boff\n\n", $#list+1);
print join("\n", @list[0..$globopts{n}-1]),"\n"x2;



