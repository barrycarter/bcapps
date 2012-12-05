#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

require "/usr/local/lib/bclib.pl";

# As I somewhat suspected earlier, I will have to do this one file at a time

# TODO: in theory, can read existing db for current data vs reading all files

for $file (glob "/mnt/sshfs/tmp/wwf*.html") {
  $all = read_file($file);

  # find all short game descs
  # backslash before quote below is unnecessary, solely to make emacs happy
  while ($all=~s%<li class=\"game game-desc(.*?)</li>%%s) {
    $data = $1;

    # game and opponent number
    $data=~/data-game-id="(\d+)" data-opponent-id="(\d+)"/;
    ($game,$opp) = ($1,$2);

    # last move
    $data=~m%<abbr class="timeago" title="(.*?)"%;
    $lastmove = $1;

    # have I seen this game before? If so, compare lastmove times
    if ($gamedata{$game}{lastmove} > $lastmove) {
      debug("$game: Already have newer information: $gamedata{$game}{lastmove} > $lastmove");
      next;
    }

    # if this game data is newer, wipe out any cached info (ie, state
    # of the board)
    if ($gamedata{$game}{lastmove} < $lastmove) {
      debug("$game: this information strictly newer, wiping out cache");
      $gamedata{$game} = ();
    }

    # note that above excludes case where lastmove time is same: in
    # that case, we keep any information (ie, scores + board state) we
    # had before

    # assign lastmove since its not older
    $gamedata{$game}{lastmove} = $lastmove;

    # opponent name and status
    $data=~m%<div class="title">(.*?)</div>%s;
    $namestat = $1;
    $namestat=~s/^\s*(.*?)\s*$/$1/;

    # start date (as UTC)
    $data=~m%<span class="date">(.*?)</span>%;
    $start = $1;

    # putting into hash (TODO: could do this above too)
    $gamedata{$game}{opp} = $opp;
    $gamedata{$game}{namestat} = $namestat;
    $gamedata{$game}{start} = $start;
    $gamedata{$game}{lastmove} = $lastmove;

    # this is the tricky bit: try to get more info on game ASAP, not
    # after looping thru all short descs as I did earlier
    unless ($all=~s%<div data-game-id="$game" id="game_$game"(.*?)(</div>\s*</div>\s*</div>\s*</div>\s*</div>\s*)%%s) {
      debug("NO EXTRA INFORMATION FOR $game");
      next;
    }

    # there is extra info, so use it
    $gamedata = $1;

    # determine players and scores
    $gamedata=~s%<div class="players">(.*?)</div>\s*</div>\s*</div>\s*%%s;
    $playsco = $1;

    # id, score, name for both players
    $playsco =~s%<div class="player.*? data-player-id="(.*?)">\s*<div class="score">(\d+)</div>\s*<div class="player_1">(.*?)</div>\s*</div>\s*<div class="player.*? data-player-id="(.*?)">\s*<div class="score">(\d+)</div>\s*<div class="player_2">(.*?)\s*$%%;

    # <h>Today on "insane things you must never do with Perl..."</h>
    # we intentionally ignore the 0th match (the whole regex)
    # NOTE: this code is (intentionally) hideous, just to see how badly
    # I could mangle Perls constructs
    $n=0; for $j (1,2) {for $k (split(//,"isn")) {
      $gamedata{$game}{"p$j$k"} = substr($&,$-[++$n],$+[$n]-$-[$n]);
    }}

  # the board
    while ($gamedata=~s%<div class=\"space_(\d+)_(\d+).*?>(.*?)</div>%%s) {
      # row column content
      ($row,$col,$cont) = ($1,$2,$3);

      # just letter for content
      if ($cont=~s%<span class=.*?>(.)</span>%%s) {
	$gamedata{$game}{board}{$row}{$col} = uc($1);
      } else {
	$gamedata{$game}{board}{$row}{$col} = " ";
      }
    }
  }
}

# and now, we go through the latest data for each game

for $i (sort keys %gamedata) {
  # just this game itself
  $game = $gamedata{$i};

  $game->{id} = $i;

  # if namestat shows game has finished, indicate this
  if ($game->{namestat}=~/^(.*?) beat you/i) {
    $game->{win} = $1;
    $game->{oppname} = $game->{win};
    # TODO: can I always get my own name?
    $game->{lose} = "you";
  } elsif ($game->{namestat}=~/^you beat (.*?)$/i) {
    $game->{lose} = $1;
    $game->{oppname} = $game->{lose};
    $game->{win} = "you";
  } else {
    # ie, game is in progress so namestat is just oppname
    $game->{win} = "NA";
    $game->{lose} = "NA";
    $game->{oppname} = $game->{namestat};
  }

  # we no longer need or want namestat
  delete $game->{namestat};

  # fix start time
  $game->{start}=~s/^started\s*//isg;
  $game->{start}=strftime("%Y-%m-%d %H:%M:%S",localtime(str2time($game->{start})));

  # and last move time
  $game->{lastmove}=~/^(.*?)T(.*?)\+/;
  $game->{lastmove}="$1 $2";

  # and now boardstat (in ugly ugly format)
  for $k (0..14) {
    for $l (0..14) {
      $game->{boardstring} .= $game->{board}{$l}{$k};
    }
  }

  debug("BS: $game->{boardstring}");

  # once weve converted it, we dont need it in the db
  delete $game->{board};

  # if "you" won/lost this game, replace with p1n
  if ($game->{win}=~/^you$/i && $game->{p1n}) {
    $game->{win} = $game->{p1n};
  }

  if ($game->{lose}=~/^you$/i && $game->{p1n}) {
    $game->{lose} = $game->{p1n};
  }

  push(@rows,$game);
}

@queries = hashlist2sqlite(\@rows, "wwf");

# we want later entries to replace earlier ones (though this is
# irrelevant when parsing a single file)

for $i (@queries) {$i=~s/INSERT OR IGNORE/REPLACE/isg;}

# print the queries (surrounded by BEGIN/COMMIT)
open(A,">/tmp/bcpwwf.sql");

print A << "MARK";
DROP TABLE IF EXISTS wwf;
CREATE TABLE wwf (id, boardstring, lastmove, lose, opp, oppname,
 p1i, p1n, p1s, p2i, p2n, p2s, start, win);
BEGIN;
MARK
;

print A join(";\n",@queries),";\n";
# special case to ignore really early games
print A "DELETE FROM wwf WHERE lastmove <= '2012-11-01 00:00:00';\n";
print A "COMMIT;\n";

system("sqlite3 /home/barrycarter/BCINFO/sites/DB/wwf.db < /tmp/bcpwwf.sql");

warn "Should not create db over again each time when live";
