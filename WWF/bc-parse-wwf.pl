#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

# --fast: do not attempt to find extra info for games, just basics

require "/usr/local/lib/bclib.pl";

# TODO: in theory, can read existing db for current data vs reading all files
# TODO: use <h5>Your Move</h5> and playerData stuff

# these are the names of the fields in the short form ("data" is the
# entire matched string)
@short = ("data", "state", "game", "opp", "oppname", "start","status");

# reverse order should help speed things up
@files = `ls -t /mnt/sshfs/WWF/wwf*.html /mnt/sshfs/WWF/wwf*.html.bz2`;

for $file (@files) {
  debug("FILENAME: $file");
  $all = read_file($file);

  # find my name (doesnt always work, but helps)
  $all=~s/playerdata: \{"name":"(.*?)"//is;
  $myname = $1;

  # TODO: keep track of which files have which games + "delete" those
  # files whose games are all finished and in db

  # find all short game descs
  # backslash before quote below is unnecessary, solely to make emacs happy
  while ($all=~s%(<li class=\"game game-desc.*?</li>)%%s) {
    $data = $1;

    # try to get all the short form information at once
    # this is ugly but lets me test all elements at once
    unless ($data=~m%<li class="game (.*?)" data-game-id="(\d+)" data-opponent-id="(\d+)">.*?<div class="title">\s*(.*?)</div>\s*<span class="date">Started (.*?)</span><small>(.*?)</small>%s) {
# <small>'(.*?)' played <abbr class="timeago" title="(.*?)">%s) {
      die "BAD DATA: $data";
      next;
    }

    # clear pre to avoid stale info
    %pre = ();

    # and assign to prehash (which we mostly copy to real hash, but not 100%)
    for $i (0..$#short) {
      # if value is empty, we parsed badly ('0' however is ok)
      $pre{$short[$i]} = substr($&,$-[$i],$+[$i]-$-[$i]);

      # in fact must be at least 2 chars long
      if (length($pre{$short[$i]}) < 2) {
	die "BAD: $short[$i] -> $pre{$short[$i]}";}
    }

    # convenience variable
    $game = $pre{game};

    # HTML is space-insensitive, and altho SQLite3 can handle
    # newlines, I dont want to deal with them
    $pre{data}=~s/\s+/ /isg;
    # since I use double quotes as delimiters, get rid of those too
    $pre{data}=~s/\"/\'/isg;
    # TODO: tweak hashlist2sqlite to have an option to use "'" as delimiter

    # at this point, acknowledge this game exists, in case we drop it
    # by mistake later
    $isgame{$game} = 1;

    # ignore declined games and games w no moves
    # TODO: reconsider ignoring moveless games
    if ($pre{status}=~/declined/i || $pre{status}=~/no moves yet/i) {
      debug("IGNORING GAME WITH STATUS: $pre{status}");
      delete $isgame{$game};
      next;
    }

    # get last move info from status
    unless ($pre{status}=~m%^(.*?)<abbr class="timeago" title="(.*?)">.*?</abbr>%) {
      die "BAD STATUS: $pre{status}";
      next;
    }

    ($pre{lastmove},$pre{lasttime}) = ($1,$2);
    
    # ignore pre-Thanksgiving-2012 games
    if ($pre{lasttime} lt "2012-11-23T00:07:00+00:00") {
      debug("IGNORING GAME WITH LASTTIME: $pre{lasttime}");
      delete $isgame{$game};
      next;
    }

    # ignore games for which we have more recent status
#      debug("GAME $game: COMPARING $gamedata{$game}{lasttime} vs $pre{lasttime}");
    if ($gamedata{$game}{lasttime} gt $pre{lasttime}) {
      debug("GAME $game: $gamedata{$game}{lasttime} > $pre{lasttime}");
      next;
    }

    # fix start and last move time (and start creating true hash)
    for $j ("start", "lasttime") {
      $gamedata{$game}{$j}=$pre{$j}
    }

    # if oppname has 'beat' in it, write winner/loser to fields
    if ($pre{oppname}=~/you beat (.*?)$/is) {
      $gamedata{$game}{oppname} = $1;
      $gamedata{$game}{winner} = $myname;
      $gamedata{$game}{loser} = $gamedata{$game}{oppname};
    } elsif ($pre{oppname}=~/^(.*?) beat you/i) {
      $gamedata{$game}{oppname} = $1;
      $gamedata{$game}{loser} = $myname;
      $gamedata{$game}{winner} = $gamedata{$game}{oppname};
    } elsif ($pre{oppname}=~/you tied (.*?)$/is) {
      $gamedata{$game}{oppname} = $1;
      $gamedata{$game}{loser} = "TIE";
      $gamedata{$game}{winner} = "TIE";
    } else {
      $gamedata{$game}{oppname} = $pre{oppname};
      $gamedata{$game}{loser} = "IP";
      $gamedata{$game}{winner} = "IP";
    }

    # is the game over or still in progress (we could get this from "x
    # beat y", but this provides a nice double check
    # note the space is needed below, sometimes class is "inactive"
    if ($pre{state}=~/ active/) {
      $gamedata{$game}{gameover}=0;
    } else {
      $gamedata{$game}{gameover}=1;
    }

    # the copyovers
    for $i ("lastmove", "data", "game", "opp") {
      $gamedata{$game}{$i} = $pre{$i};
    }

    # for debugging
    $gamedata{$game}{file} = $file;

    # just want game win/loss data, no extra info
    if ($globopts{fast}) {next;}

    # NOTE: we only get sometimes, depending on whether info for this
    # game is more recent than previous info for this game.
    # TODO: worry about above

    # to make sure were doing the regex right, confirm a simpler regex first
    if ($all=~/game_$game/) {
      $pre{extrainfo} = 1;
    } else {
      $pre{extrainfo} = 0;
      next;
    }

    # date of the extra info
    $gamedata{$game}{extradate} = $gamedata{$game}{lasttime};
    debug("GETTING EXTRA DATA ($game)");

    # suck data to next div data-game-id
    $all=~m%(<div data-game-id="$game" id="game_$game".*?)(<div data-game-id|$)%s;
    my($extra) = $1;

    # TODO: in theory could capture player ids, but do I care?
    # hideous double regex since score can come before or after player name
    # Changed $game to \d+ so Perl could compile regexs below; I tried
    # changing %s to %so but it makes no difference
    unless ($extra=~m%<div data-game-id="\d+" id="game_\d+" class="(.*?)">.*?<div class="remaining"><span>(\d+)</span>\s* letters remaining.*?<div class="score">(\d+)</div>\s*<div class="player_1">(.*?)</div>.*?<div class="score">(\d+)</div>.*?<div class="player_2">(.*?)</div>.*?<div class="score">(\d+)</div>%s || $extra=~m%<div data-game-id="\d+" id="game_\d+" class="(.*?)">.*?<div class="remaining"><span>(\d+)</span>\s* letters remaining.*?<div class="score">(\d+)</div>\s*<div class="player_1">(.*?)</div>.*?<div class="score">(\d+)</div>\s*<div class="player_2">(.*?)</div>%s) {
 
      warn "BAD EXTRA INFO FOR $game in $file: $extra"
}

    # gave up on trying to be overly clever here
    @matches = ("",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10);

    for $i (0..$#matches) {
      debug("MATCHES[$i]: $matches[$i]");
    }

    # 1: status of game (game hidden over, game inactive hidden, game over, game over hidden, game shown inactive, game shown over)
    # 2: letters remaining
    # 3: player 1 score
    # 4: player 1 name (always "Barry Carter" in my case)
    # 5: player 2 score
    # 6: player 2 name
    # 7: 

    next;

    debug("I AM NOT REACHED");

    # assign filename for extended data
    $gamedata{$game}{extrafile} = $file;

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

      # push the raw string to an array (we might use later)
      $bs[$row][$col] = $&;

      # just letter for content
      if ($cont=~s%<span class=.*?>(.)</span>%%s) {
	$gamedata{$game}{board}{$row}{$col} = uc($1);
      } else {
	$gamedata{$game}{board}{$row}{$col} = " ";
      }
    }

    # last play
    $gamedata=~s%<p>(.*?)</p>%%;
    $gamedata{$game}{lastplay} = $1;
    $gamedata{$game}{lastplay}=~s/<.*?>//isg;

#    debug("BS",unfold(@bs));
    $gamedata{$game}{boardstring} = build_board(\@bs);

  }
}

debug("About to parse gamedata...");

# TODO: use the isgame check!

# and now, we go through the latest data for each game

# find the most recent games for which I dont have extra info

for $i (sort {$gamedata{$b}->{lasttime} cmp $gamedata{$a}->{lasttime}} keys %gamedata) {
  debug("ALF: $gamedata{$i}->{lasttime}");

  # just this game itself
  # this is just for me: find games where I can maybe get more data?
  $game = $gamedata{$i};

  if ($game->{extradate}) {
    if ($game->{lasttime} gt $game->{extradate}) {
          debug("STALE EXTRA INFO: $i (start $game->{start} $game->{oppname}, $game->{lastmove}), $game->{lasttime} vs $game->{extradate}) ($game->{gameover})");
	}
  } else {
    debug("NO EXTRA INFO AT ALL: $i (start $game->{start} $game->{oppname}, $game->{lastmove}) ($game->{lasttime}) ($game->{gameover})");
  }

#  next;

  # compare lasttime to extratime
  debug("TC: $game->{lasttime} >? $game->{extradate}");

#  debug("GAMEHAS:",%{$game});

  # and now boardstat (in ugly ugly format)
  for $k (0..14) {
    for $l (0..14) {
#      $game->{boardstring} .= $game->{board}{$l}{$k};
    }
  }

  debug("BS: $game->{boardstring}");

  # once weve converted it, we dont need it in the db
  delete $game->{board};

  debug("GAME: ");

  push(@rows,$game);
}

debug("ROWS",@rows);
@queries = hashlist2sqlite(\@rows, "wwf");

# we want later entries to replace earlier ones (though this is
# irrelevant when parsing a single file)

for $i (@queries) {$i=~s/INSERT OR IGNORE/REPLACE/isg;}

# these are the keys for gamedata{game} (aka the column names for the db)
# we could compute these, but that takes longer
$keys = "data, game, gameover, lastmove, lasttime, loser, opp, oppname, start, winner, file, extradate";

# print the queries (surrounded by BEGIN/COMMIT)
open(A,">/tmp/bcpwwf.sql");

print A << "MARK";
DROP TABLE IF EXISTS wwf;
CREATE TABLE wwf ($keys);
BEGIN;
MARK
;

print A join(";\n",@queries),";\n";
print A "COMMIT;\n";

system("sqlite3 /home/barrycarter/BCINFO/sites/DB/wwf.db < /tmp/bcpwwf.sql");

warn "Should not create db over again each time when live";

sub build_board {
  my($listref) = @_;
  my($letter,$color,$spec);
  my(@list) = @$listref;
  my(@ret);

  # really no need to define this here
  my(%color) = ("tw" => "#ff8000", "tl" => "#00ff00", "dl" => "#8080ff",
	       "dw" => "#ff8080");
  debug("TEST: $color{tw}");

  push(@ret, "<table border>");
  for $i (0..14) {
    push(@ret, "<tr>");
    for $j (0..14) {

      # determine letter
      if ($list[$i][$j]=~s%<span class=.*?>(.*?)</span>%%) {
	$letter = $1;
      } else {
	$letter = "<font size='-4'>.</font>";
      }

      # determine color
      if ($list[$i][$j]=~/space (..) /) {
	$spec = $1;
	$color = $color{$spec};
	debug("COLOR: $spec, $color{$1}");
      } else {
	# TODO: this is probably wrong
	$color = "#ffffff";
	$spec = "";
      }

      # TODO: maybe add scores either as title or teeny subscript
      push(@ret,"<td bgcolor='$color' align='center' title='$spec' width='20px' height='20px'>$letter</td>");
    }
    push(@ret,"</tr>");
  }
  push(@ret,"</table>");

  return join("\n",@ret);
}

=item regex2array()

Returns the most recently matches regex parts as an array.

WARNING: not sure how long regex variables stay in scope, so this may
not work all the time (or at all)

NOTE: this function is either not working or not useful, possibly both

=cut

sub regex2array {
  debug("ALLMATCH: $& vs $1");
  my(@res);
  debug("MINARR:",@-, );
  debug("MAXARR:",@+);
  debug("LENGTH",length($&));
  for $i (0..$#-) {
    
    push(@res,substr($&,$-[$i],$+[$i]-$-[$i]));
  }

  debug("RES",@res);
  return @res;
}

=item sample

Sample of short form description (used w opponent permission). Note
that wwf165541_files is an artifact of "save as web page complete".

<li class="game game-desc  right_side active" data-game-id="3857526416" data-opponent-id="88745690">
        <a href="#" data-game-id="3857526416">
          <span class="arrow"></span>
          <span class="eyeballs"></span>
                  <span class="game_photo wwf" title="TX Barbara M">
          <img src="wwf165541_files/blank_user_icon.png" alt="TX Barbara M">
          <span class="letter">T</span>
          <div class="letterValue"></div>
        </span>
      
          <div class="title">
            TX Barbara M</div>
          <span class="date">Started December 10, 2:12pm</span><small>'RETRAINED' played <abbr class="timeago" title="2012-12-10T23:50:31+00:00">5 minutes ago</abbr></small>
          </a>
      </li>

Here is a sample of the long game information for the same game (the
wwf165541_files stuff is again an artifact of 'save frame as' complete
web page)

        <div data-game-id="3857526416" id="game_3857526416" class="game shown inactive">
              <div class="scoreboard">
                <div class="game_status">
                  <a style="display: inline;" class="game-btn store"><span>store</span></a>
                  <div class="player_image me"><span class="game_photo" title="Barry Carter">
          <img src="wwf165541_files/UlIqmHJn-SK.gif" alt="Barry Carter">
          <div class="indicator"><img src="wwf165541_files/blank.png"><span></span></div>
        </span></div>
                  <div class="player_image"><span class="game_photo wwf" title="TX Barbara M">
          <img src="wwf165541_files/blank_user_icon.png" alt="TX Barbara M">
          <span class="letter">T</span>
          <div class="indicator"><img src="wwf165541_files/blank.png"><span></span></div>
        </span></div>
                  <div class="remaining"><span>62</span> letters remaining</div>
                  <div class="players"><div class="player" data-player-id="62489603">
        <div class="score">105</div>
        <div class="player_1">Barry Carter</div>
      </div>
      <div class="player active" data-player-id="88745690">
        <div class="score">64</div>
        <div class="player_2">TX Barbara M</div>
      </div></div>
                  <p>Barry Carter played <span>RETRAINED</span> for 24 points</p>
                  <a href="#game_3857526416_chat" class="game-btn chat chat_button has_tooltip"><span>chat</span></a>
                  <div class="eye left"><div class="pupil"></div></div>
                  <div class="eye right"><div class="pupil"></div></div>
                </div>
              </div><div style="display: none;" class="chat_container">

[the chat container is intentionally not shown]

=cut

