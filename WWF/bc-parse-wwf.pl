#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

# in directory with wwf*.html files:
# \ls -1t /mnt/sshfs/tmp/*.html | xargs -n 1 bc-parse-wwf.pl | sqlite3 /home/barrycarter/BCINFO/sites/DB/wwf.db
# TODO: above is nonideal since assumes file mtimes are correct
# TODO: instead, use "last move" time to see which entry for given game is more current

require "/usr/local/lib/bclib.pl";

($all,$fname) = cmdfile();

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

  # have i seen this game before?
  # is this version of this game older than what I already have?
  if ($gamedata{$game} && str2time($last) < str2time($gamedata{$game}{last})) {
    debug("IGNORING $game: $last < $gamedata{$game}{last}");
    next;
  }

  # putting into hash (TODO: could do this above too)
  $gamedata{$game}{opp} = $opp;
  # TODO: separate name and status into two fields
  $gamedata{$game}{namestat} = $namestat;
  $gamedata{$game}{start} = $start;
  $gamedata{$game}{last} = $last;
}

# more details on the games?

# divs ended up nested 5 deep (this is wrong, but easy way to find gamedata)
while ($all=~s%<div data-game-id="(\d+)" id="game_(\d+)"(.*?)(</div>\s*</div>\s*</div>\s*</div>\s*</div>\s*)%%s) {
  # $id[12] are probably identical <h>(or $id-entical?)</h>
  ($id1,$id2, $gamedata, $delimiter) = ($1,$2,$3,$4);

  # determine players and scores first
  $gamedata=~s%<div class="players">(.*?)</div>\s*</div>\s*</div>\s*%%s;
  $playsco = $1;

  # id, score, name for both players
  $playsco =~s%<div class="player.*? data-player-id="(.*?)">\s*<div class="score">(\d+)</div>\s*<div class="player_1">(.*?)</div>\s*</div>\s*<div class="player.*? data-player-id="(.*?)">\s*<div class="score">(\d+)</div>\s*<div class="player_2">(.*?)\s*$%%;
  ($p1i, $p1s, $p1n, $p2i, $p2s, $p2n) = ($1, $2, $3, $4, $5, $6);

  # if neither player score is higher than what we already have,
  # ignore this entry (its old)
  if ($p1s<=$gamedata{$id1}{p1s} && $p2s<=$gamedata{$id1}{p2s}) {
    debug("ISOLD: $id1");
    next;
  }

  # the board
  while ($gamedata=~s%<div class=\"space_(\d+)_(\d+).*?>(.*?)</div>%%s) {
    # row column content
    ($row,$col,$cont) = ($1,$2,$3);
#    debug("RCC: $row/$col/$cont");

    # just letter for content
    if ($cont=~s%<span class=.*?>(.)</span>%%s) {
 #     debug("1: $1");
      $gamedata{$id1}{$row}{$col} = uc($1);
    } else {
      $gamedata{$id1}{$row}{$col} = " ";
    }
  }

  for $i (0..14) {
#    print "\n";
    for $j (0..14) {
#      print $board[$i][$j]," ";
    }
  }

#  print "\n";

  # assigning to hash
  $gamedata{$id1}{p1i} = $p1i;
  $gamedata{$id1}{p1s} = $p1s;
  $gamedata{$id1}{p1n} = $p1n;
  $gamedata{$id1}{p2i} = $p2i;
  $gamedata{$id1}{p2s} = $p2s;
  $gamedata{$id1}{p2n} = $p2n;

  # chat messages
  $gamedata=~s%<ul class="chat_messages">(.*?)</ul>%%s;
#  debug("CHAT: $1");

  # this is just cleanup so I can see it better, no programmatic use
  $gamedata=~s/\s*\n+\s*/\n/sg;

  # TODO: scores, gameover?, chat messages, rack letters

#  debug("<GD>",$gamedata,"</GD>");
}

for $i (sort keys %gamedata) {
  # just this game itself
  %game = %{$gamedata{$i}};

  # create hash for this game (as db row)
  $hashref = {};
  my(%hash) = %{$hashref};

  $hash{game} = $i;

  # if namestat shows game has finished, indicate this
  if ($game{namestat}=~/^(.*?) beat you/i) {
    $hash{win} = $1;
    $hash{oppname} = $hash{win};
    # TODO: can I always get my own name?
    $hash{lose} = "you";
  } elsif ($game{namestat}=~/^you beat (.*?)$/i) {
    $hash{lose} = $1;
    $hash{oppname} = $hash{lose};
    $hash{win} = "you";
  } else {
    # ie, game is in progress so namestat is just oppname
    $hash{win} = "NA";
    $hash{lose} = "NA";
    $hash{oppname} = $game{namestat};
  }

  # we no longer need or want namestat
  delete $hash{namestat};

  # fix start time
  $game{start}=~s/^started\s*//isg;
  $hash{start} = strftime("%Y-%m-%d %H:%M:%S", localtime(str2time($game{start})));

  # and last move time
  $game{last}=~/^(.*?)T(.*?)\+/;
  $hash{last}="$1 $2";

  # opponent number just gets copied over
  $hash{opp} = $game{opp};

  # some games have additional information, like player scores (and
  # other info that turns out to be surprisingly useless)
  for $j ("p1s", "p2s", "p1i", "p2i", "p1n", "p2n") {$hash{$j} = $game{$j};}

  # and now boardstat (in ugly ugly format)
  for $k (0..14) {
        for $l (0..14) {
	  $hash{board} .= $game{$l}{$k};
	}
      }

  # if "you" won/lost this game, replace with p1n
  if ($hash{win}=~/^you$/i && $hash{p1n}) {
    $hash{win} = $hash{p1n};
  }

  if ($hash{lose}=~/^you$/i && $hash{p1n}) {
    $hash{lose} = $hash{p1n};
  }

  push(@rows,\%hash);
}

@queries = hashlist2sqlite(\@rows, "wwf");

# we want later entries to replace earlier ones (though this is
# irrelevant when parsing a single file)

for $i (@queries) {$i=~s/INSERT OR IGNORE/REPLACE/isg;}

# print the queries (surrounded by BEGIN/COMMIT)
open(A,">/tmp/bcpwwf.sql");

print A << "MARK";
DROP TABLE IF EXISTS wwf;
CREATE TABLE wwf (board, game, last, lose, opp, oppname, p1s, p2s,
 start, win, p1i, p2i, p1n, p2n);
BEGIN;
MARK
;

print A join(";\n",@queries),";\n";
# special case to ignore really early games
print A "DELETE FROM wwf WHERE last <= '2012-11-01 00:00:00';\n";
print A "COMMIT;\n";

system("sqlite3 /home/barrycarter/BCINFO/sites/DB/wwf.db < /tmp/bcpwwf.sql");

warn "Should not create db over again each time when live";

=item schema

DROP TABLE IF EXISTS wwf;
CREATE TABLE wwf (board, game, last, lose, opp, oppname, p1s, p2s,
 start, win, p1i, p2i, p1n, p2n);
-- CREATE UNIQUE INDEX igame ON wwf(game);

=cut





