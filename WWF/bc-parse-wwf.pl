#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

require "/usr/local/lib/bclib.pl";

$all = read_file("/mnt/sshfs/tmp/wwf5.html");

while ($all=~s%<li class="game game-desc(.*?)</li>%%s) {
  $data = $1;

#  debug("DATA: $data");

  # game and opponent number
  $data=~/data-game-id="(\d+)" data-opponent-id="(\d+)"/;
  ($game,$opp) = ($1,$2);

  # opponent name and status
  $data=~m%<div class="title">(.*?)</div>%s;
  $namestat = $1;
  $namestat=~s/^\s*(.*?)\s*$/$1/;

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

# more details on the games?

# divs ended up nested 5 deep (this is wrong, but easy way to find gamedata)
while ($all=~s%<div data-game-id="(\d+)" id="game_(\d+)"(.*?)(</div>\s*</div>\s*</div>\s*</div>\s*</div>\s*)%%s) {
  # $id[12] are probably identical <h>(or $id-entical?)</h>
  ($id1,$id2, $gamedata, $delimiter) = ($1,$2,$3,$4);

  print "GAME2: $id1\n";

  # the board
  while ($gamedata=~s%<div class=\"space_(\d+)_(\d+).*?>(.*?)</div>%%s) {
    # row column content
    ($row,$col,$cont) = ($1,$2,$3);
#    debug("RCC: $row/$col/$cont");

    # just letter for content
    if ($cont=~s%<span class=.*?>(.)</span>%%s) {
 #     debug("1: $1");
      $board[$row][$col] = uc($1);
    } else {
      $board[$row][$col] = " ";
    }
  }

  for $i (0..14) {
    print "\n";
    for $j (0..14) {
      print $board[$i][$j]," ";
    }
  }

  print "\n";

  # players and scores
  $gamedata=~s%<div class="players">(.*?)</div>\s*</div>\s*</div>\s*%%s;
  $playsco = $1;

  # id, score, name for both players
  $playsco =~s%<div class="player.*? data-player-id="(.*?)">\s*<div class="score">(\d+)</div>\s*<div class="player_1">(.*?)</div>\s*</div>\s*<div class="player.*? data-player-id="(.*?)">\s*<div class="score">(\d+)</div>\s*<div class="player_2">(.*?)\s*$%%;
  ($p1i, $p1s, $p1n, $p2i, $p2s, $p2n) = ($1, $2, $3, $4, $5, $6);
  debug($p1i, $p1s, $p1n, $p2i, $p2s, $p2n);


  # chat messages
  $gamedata=~s%<ul class="chat_messages">(.*?)</ul>%%s;
  debug("CHAT: $1");

  # this is just cleanup so I can see it better, no programmatic use
  $gamedata=~s/\s*\n+\s*/\n/sg;

  # TODO: scores, gameover?, chat messages, rack letters

  debug("<GD>",$gamedata,"</GD>");
}

