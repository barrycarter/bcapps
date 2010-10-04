#!/bin/perl

# reconstructs as much of conquerclub game as possible given full logs
# --nocomment: don't print comments
# --maxrounds: only print equations thru this round (testing only)

# was taking a round-by-round approach, but
# http://userscripts.org/scripts/show/83035 makes me wonder if an
# action-by-action approach is better

# Note: regions always start w/ 3 troops

push(@INC,"/usr/local/lib");
require "bclib.pl";

# sample test game
$all = read_file("sample-data/CONQUERCLUB/7460216.html");

# if --maxrounds not set, set it to infinity
defaults("maxrounds=999999999999999999");

# find end-of-game deployment
$all=~m/map = (.*?);/is;
$map=$1;
$all=~m/armies = (.*?);/is;
$armies=$1;
# armies is an array, map is a hash
@armies = @{JSON::from_json($armies)};
%map = %{JSON::from_json($map)};

# convenience variable (list of country names)
@countries = @{$map{countries}};
for $i (@countries) {
  %hash=%{$i};
  $i=$hash{name};
}

%countries=list2hash(@countries);

# all countries start w/ 3 troops
# TODO: validate above (ie, is it really true?)
# could probably combine this w/ loop above, but pointless
for $j (@countries) {
  push(@out, qq%troops["$j"][0] == 3%);
}

# find log section
$all=~m%<div id="log">(.*?)</div>%s||warn("Can't find log section");
@log = split(/<br>/,$1);

# go thru log lines
for $i (@log) {

  # cleanup occasional oddness
  $i = trim($i);

  # ignore blank lines
  if ($i=~/^\s*$/) {next;}

  # comment for output
  $comment = $i;
  $comment=~s/<([^>]*?)>//isg;

  # time
  $i=~s/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) -\s*//;
  $time = $1;

  # find player (if any) + record player number
  if ($i=~s%<span class="player(\d+)">(.*?)</span>\s*%%) {
    $actor=$2;
    $player[$1]=$actor;
  } else {
    $actor="";
  }

  # TODO: for every country (even those specifically listed) allow for
  # troop loss due to unsuccessful attacks

  # ignore end of player turn (not end of entire turn)
  if ($i=~/^ended the turn$/) {next;}

  # information below is repeated in deployment, so can ignore it here
  if ($i=~/^received \d+ troops for \d+ regions$/) {next;}
  # other stuff we can ignore
  # TODO: combine this w/ 2 regex above?
  if ($i=~/(Game has been initialized|eliminated|won the|lost \d+ points|gained \d+ points|Incrementing game to round \d+)/) {next;}

  # increment round ($prevround is a convenience var only)
  # <h>Part of a series on how to write confusing code</h>
  $prevround = $round++;

  if ($round>= $globopts{maxrounds}) {next;}

  # push log line as comment
  # TODO: comment format may change (haven't decided on backend language yet)
  unless ($globopts{nocomment}) {push(@out, "(* $comment *)");}

  # keep track of which territories are affected by action item
  %affected=();

  if ($i=~/^received (\d+) troops for holding (.*?)$/) {
    # specific region received troops
    ($ntroop, $terr) = ($1,$2);
    unless ($countries{$terr}) {$round--; next;}
    push(@out, qq%troops["$terr"][$round] <= troops["$terr"][$prevround] + $ntroop%);
    $affected{$terr}=1;
  } elsif ($i=~/deployed (\d+) troops on (.*?)$/) {
    # troop deployment
    ($ntroop, $terr) = ($1,$2);
    push(@out, qq%troops["$terr"][$round] <= troops["$terr"][$prevround] + $ntroop%);
    $affected{$terr}=1;
  } elsif ($i=~/^reinforced (.*?) with (\d+) troops from (.*?)$/) {
    # reinforcement
    ($source, $ntroop, $target) = ($3,$2,$1);
    push(@out, qq%troops["$target"][$round] <= troops["$target"][$prevround] + $ntroop%);
    push(@out, qq%troops["$source"][$round] <= troops["$source"][$prevround] - $ntroop%);
    $affected{$source}=1;
    $affected{$target}=1;
  } elsif ($i=~/^assaulted (.*?) from (.*?) and conquered it from \*?(.*?)\*?$/) {
    # conquest
    ($atkr, $dest, $source, $defn) = ($actor,$1,$2,$3);
    # together, source and target have at most as many troops as source did
    push(@out, qq%troops["$source"][$round] + troops["$dest"][$round] <= troops["$source"][$prevround]%);
    $affected{$source}=1;
    $affected{$dest}=1;
    $defn=~s%<span.*?>(.*?)</span>%$1%;
    $owner{$round}{$dest} = $atkr;
    $owner{$round}{$source} = $atkr; # probably redundant
    $owner{$prevround}{$dest} = $defn; # redundant
    # if a territory is conquered delta is probably wrong
    $conquered{$round}{$dest} = 1;
  } else {
    warnlocal("Unhandled: $i");
  }

  # now, every other country
  for $j (@countries) {
    # this applies to affected countries too
    push(@out, qq%troops["$j"][$round] >= 1%);
    if ($affected{$j}) {next;}
    push(@out, qq%troops["$j"][$round] <= troops["$j"][$prevround]%);
  }
}

$player[0]="neutral player"; # special case

# end of game stuff we know
for $i (0..$#armies) {
  # TODO: not really efficient to put this in for loop!
  if ($round > $globopts{maxrounds}) {next;}
  %hash = %{$armies[$i]};
  # TODO: uncomment below!
#  push(@math, qq%owner["$countries[$i]"][$round] = "$player[$hash{player}]"%);
  push(@out, qq%troops["$countries[$i]"][$round] == $hash{quantity}%);
#  push(@math, qq%troops["$countries[$i]"][$round] == $hash{quantity}%);
#  debug("$countries[$i] -> $player[$hash{player}], $hash{quantity}");
}

debug(@out);

write_file("ineq={\n".join(",\n",@out)."\n}\n", "/tmp/math.m");

# TODO: test code to cheat convert Mathematica to Prolog instead of
# doing it correctly above in the first place

$all = read_file("/tmp/math.m");
# vars must start w/ cap
$all=~s/troops/Troops/isg;
# round numbers
$all=~s/\[(\d+)\]/_$1/isg;
# terr names
$all=~s/\[\"(.*?)\"\]/"_".proclean($1)/iseg;
# conditionals
$all=~s/\=\=/\#=/isg;
$all=~s/>\=/\#>=/isg;
# <h>Why doesn't Prolog support "#<="? No one knows, and no one cares!</h>
$all=~s/<\=/\#=</isg;
# junk
$all=~s/ineq\=\{\s*//isg;
$all=~s/\}/./isg;
# collecting vals
@vals = ($all=~m%(Troops\S+?_\d+)%img);
# define the goal
$goal = "goal([".join(",\n",@vals)."]) :-\n";
write_file("$goal$all","/tmp/math.pl");

# cleans up territory names to avoid spaces + other odd chars
sub proclean {
  my($str) = @_;
  $str=~s/[^a-z0-9]/_/isg;
  return $str;
}

die "TESTING";

# TODO: actual stuff here
# reverse sorting by round, last round first
for ($i=$round; $i>=0; $i--) {
  # must look at all countries, not just those that are keys
  for $j (sort @countries) {
    if ($conquered{$i}{$j}) {
      # TODO: stuff
      # ignoring rounds where territory is conquered (for now)
      next;
    }

    # cleanup
    if ($delta{$i}{$j} eq "") {$delta{$i}{$j}=0;}

    # start with 3
    # TODO: not always true for neuts!
    if ($i==0) {
      push(@math, qq%troops["$j"][$i]==3%);
      next;
    }

    # unk = unknown number of troops lost (never gained) between rounds i-1 & i
    push(@math, qq%troops["$j"][$i] == troops["$j"][$i-1]+$delta{$i}{$j}-unk["$j"][$i]%);
    push(@math, qq%troops["$j"][$i] >= 1%, qq%unk["$j"][$i] >= 0%);
#    debug("$i,$j: $owner{$i}{$j} and $delta{$i}{$j}");
  }
}

write_file("ineq={\n".join(",\n",@math)."\n}\n", "/tmp/math.m");

# this is ugly; warnlocal should have a default
sub warnlocal {warn(@_);}

