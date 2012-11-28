#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

require "/usr/local/lib/bclib.pl";

$all = read_file("/mnt/sshfs/tmp/wwf2.html");

while ($all=~s%<li class="game game-desc\s*right_side"(.*?)</li>%%s) {
  $data = $1;

  # game and opponent number
  $data=~/data-game-id="(\d+)" data-opponent-id="(\d+)"/;
  ($game,$opp) = ($1,$2);

  # opponent name and status
  $data=~m%<div class="title">(.*?)</div>%;
  $namestat = $1;

  # start date (as UTC)
  $data=~m%<span class="date">(.*?)</span>%;
  $start = $1;

  # last move (or end)
  $data=~m%<abbr class="timeago" title="(.*?)"%;
  # <h>I realize last is a reserved word in Perl; IJDGAF!</h>
  $last = $1;

  print << "MARK"
Game: $game
Opp: $opp
NS: $namestat
Start: $start
Last: $last

MARK
;


}

die "TESTING";

# debug("ALL: $all");

# @games = split(/<li class="game game-desc  right_side" data-game-id="3779148583" data-opponent-id="39380772">

while ($all=~s%<span class="tile letter-(.)%%s) {
  debug("1: $1");
}

