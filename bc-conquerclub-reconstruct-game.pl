#!/bin/perl

# reconstructs as much of conquerclub game as possible given full logs

# Note: regions always start w/ 3 troops

push(@INC,"/usr/local/lib");
require "bclib.pl";

# sample test game
$all = read_file("sample-data/CONQUERCLUB/7460216.html");

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

# find log section
$all=~m%<div id="log">(.*?)</div>%s||warn("Can't find log section");
@log = split(/<br>/,$1);

$round=0; # starting round

# go thru log lines
for $i (@log) {

  # cleanup occasional oddness
  $i = trim($i);

  # ignore blank lines
  if ($i=~/^\s*$/) {next;}

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

  # ignore end of player turn (not end of entire turn)
  if ($i=~/^ended the turn$/) {next;}

  # information below is repeated in deployment, so can ignore it here
  if ($i=~/^received \d+ troops for \d+ regions$/) {next;}

  # specific region received troops
  if ($i=~/^received (\d+) troops for holding (.*?)$/) {
    ($ntroop, $terr) = ($1,$2);
    # this territory got this many troops
    $delta{$round}{$terr} += $ntroop;
    next;
  }

  # troop deployment
  if ($i=~/deployed (\d+) troops on (.*?)$/) {
    ($ntroop, $terr) = ($1,$2);
    # this territory got this many troops
    $delta{$round}{$terr} += $ntroop;
    next;
  }

  # round increment
  if ($i=~/^Incrementing game to round (\d+)$/) {$round=$1;next;}

  # reinforcement
  if ($i=~/^reinforced (.*?) with (\d+) troops from (.*?)$/) {
    ($source, $ntroop, $target) = ($3,$2,$1);
    $delta{$round}{$source} -= $ntroop;
    $delta{$round}{$target} += $ntroop;
    next;
  }

  # conquest
  if ($i=~/^assaulted (.*?) from (.*?) and conquered it from \*?(.*?)\*?$/) {
    ($atkr, $dest, $source, $defn) = ($actor,$1,$2,$3);
    $defn=~s%<span.*?>(.*?)</span>%$1%;
    $owner{$round}{$dest} = $atkr;
    $owner{$round}{$source} = $atkr; # probably redundant
    $owner{$round-1}{$dest} = $defn; # redundant
    # if a territory is conquered delta is probably wrong
    $conquered{$round}{$dest} = 1;
    next;
  }

  # other stuff we can ignore
  if ($i=~/(Game has been initialized|eliminated|won the|lost \d+ points|gained \d+ points)/) {next;}

  warnlocal("Unhandled: $i");
}

$player[0]="neutral player"; # special case

# end of game stuff we know
for $i (0..$#armies) {
  %hash = %{$armies[$i]};
  # TODO: uncomment below!
#  push(@math, qq%owner["$countries[$i]"][$round] = "$player[$hash{player}]"%);
  push(@math, qq%troops["$countries[$i]"][$round] == $hash{quantity}%);
#  debug("$countries[$i] -> $player[$hash{player}], $hash{quantity}");
}

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

