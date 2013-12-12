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
# --recent: just show the most recent entries in reverse order, no randomness

# --plot: plot the number of items on my todo list per diem as function of time
# --ignore = when plotting, ignore these many most recent days
# (because averages tend to jump around with small denominators),
# default 7

require "/usr/local/lib/bclib.pl";
defaults("days=365&n=5&ignore=7");

$now = time();

# hash the tags <h>(why did I just think of twitter...)</h>
for $i (split/\,/,$globopts{tags}) {$badtag{$i}=1;}

open(A,"tac /home/barrycarter/bc-todo-list.txt|");
open(B,">/tmp/bcrtd.txt");

FILTER:
while (<A>) {
  chomp;
  m/^(\d{8})\.(\d{6})/ || die ("BAD LINE: $_");
  # TODO list is time ordered, so can bail once hitting too old event
  my($age) = ($now-str2time("$1 $2"))/86400;
  if ($age > $globopts{days}) {last;}

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

  my($avg) = ++$n/$age;
  # we need to put stuff around the graph, so don't actually print it here
  print B "$age $avg\n";

  # calculate max/min (later) avoiding too recent days
  if ($age > $globopts{ignore}) {push(@avgs,$avg);}

  push(@list, $_);
}

close(B);

($min,$max) = (min(@avgs),max(@avgs));

if ($globopts{recent}) {
  print join("\n",@list),"\n";
  exit();
}

@list = randomize(\@list);

# to make this look more like my old version...

# curses values for bold on/off and clear
($clear,$bon,$boff)=("\e[H\e[J","\e[1m","\e[0m");
printf("$clear${bon}Showing $globopts{n} of %d items$boff\n\n", $#list+1);
# the final sort here is so I see the randomly chosen entries in correct order
print join("\n", sort(@list[0..$globopts{n}-1])),"\n"x2;

if ($globopts{plot}) {
  open(C,">/tmp/bcrtdg.txt");
  print C qq!plot [] [$min:$max] "/tmp/bcrtd.txt" with linespoints;\n!;
  close(C);
  system("gnuplot -persist /tmp/bcrtdg.txt");
}


