#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

# --fast: do not attempt to find extra info for games, just basics

# TODO: extract (but do not publicize) chats

require "/usr/local/lib/bclib.pl";

# TODO: in theory, can read existing db for current data vs reading all files
# TODO: use <h5>Your Move</h5> and playerData stuff

# these are the names of the fields in the short form ("data" is the
# entire matched string)
@short = ("data", "state", "game", "opp", "oppname", "start","status");

# extra data in order
@extra = ("", "extstatus", "remaining", "p1s", "p1n", "p2s", "p2n");

# reverse order should help speed things up
@files = `ls -t /mnt/sshfs/WWF/wwf*.html /mnt/sshfs/WWF/wwf*.html.bz2`;

for $file (@files) {
  chomp($file);
  debug("FILENAME: $file");
  $all = read_file($file);

  # note that this is a file
  $isfile{$file} = 1;

  # all game numbers/opponent numbers just to be safe
  # NOTE: this is semi-ugly way to program this
  map($isgame{$_}=1, ($all=~/data-game-id="(.*?)"/isg));
  map($isopp{$_}=1, ($all=~/data-opponent-id="(.*?)"/isg));

  # my name/id (some files have null?!)
  if ($all=~s/playerdata: \{"name":"(.*?)"//i) {
    $myname = $1;
  } elsif ($all=~m%<div class="player_1">(.*?)%isg) {
    $myname = $1;
  } else {
    # so far, all files have at least one of the two above
    die "FILE $file has no user data";
  }

  # all files have this
  unless ($all=~s/zid: (\d+),//) {
    die "NO ZYNGA ID: $file";
  }

  $myid = $1;

  # TODO: keep track of which files have which games + "delete" those
  # files whose games are all finished and in db

  # find all short game descs
  # backslash before quote below is unnecessary, solely to make emacs happy
  while ($all=~s%(<li class=\"game game-desc.*?</li>)%%s) {
    $data = $1;

    # try to get all the short form information at once
    # this is ugly but lets me test all elements at once
    unless ($data=~m%<li class="game (.*?)" data-game-id="(\d+)" data-opponent-id="(\d+)">.*?<div class="title">\s*(.*?)</div>\s*<span class="date">Started (.*?)</span><small>(.*?)</small>%s) {
      die "BAD DATA: $data";
      next;
    }

    # clear pre to avoid stale info
    %pre = ();

    # and assign to prehash (which we mostly copy to real hash, but not 100%)
    for $i (0..$#short) {
      $pre{$short[$i]} = substr($&,$-[$i],$+[$i]-$-[$i]);

      # values must be at least 2 chars
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

    # get last move info from status
    if ($pre{status}=~/no moves yet/i) {
      # if this game has no moves right now, it cant be the latest useful info
      # but still need to record it
      debug("FILE: $file, GAME: $game, nomoves");
      $hasnomoves{$game} = 1;
      next;
    } elsif ($pre{status}=~m%^(.*?)<abbr class="timeago" title="(.*?)">.*?</abbr>%) {
      ($pre{lastmove},$pre{lasttime}) = ($1,$2);
    } else {
      die "BAD STATUS: $pre{status}";
      next;
    }

    # record "max time" of this file
    if ($pre{lasttime} gt $last{$file}) {$last{$file} = $pre{lasttime};}

    debug("FILE: $file, GAME: $game, regular data: $pre{lasttime}");

    # if we have extra info for this game (not necessarily current), record
    # we intentionally use $all here to be safer
    if ($all=~/game_$game/) {
      debug("FILE: $file GAME: $game, extra data: $pre{lasttime}");
      $extradate = $pre{lasttime};
    }

    # if we have more recent status, ignore this status
    if ($gamedata{$game}{lasttime} gt $pre{lasttime}) {
      debug("FILE $file GAME $game: already data for $gamedata{$game}{lasttime}");
      next;
    }

    # if we have same time status AND current extradate info, ignore
    if ($gamedata{$game}{lasttime} eq $pre{lasttime} &&
	$gamedata{$game}{extradate} eq $pre{lasttime}) {
      debug("FILE: $file GAME: $game, extra info already obtained");
      next;
    }

    # TODO: (maybe) if we have current shortstatus but not current
    # long status, jump to getting longstatus?

    # if oppname has 'beat' in it, write winner/loser to fields
    # TODO: there HAS to be a better way to write this!
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
      # game still in progress
      $gamedata{$game}{oppname} = $pre{oppname};
      $gamedata{$game}{loser} = "IP";
      $gamedata{$game}{winner} = "IP";
    }

    # the copyovers
    for $i ("lastmove", "data", "game", "opp", "start", "lasttime") {
      $gamedata{$game}{$i} = $pre{$i};
    }

    # for debugging
    $gamedata{$game}{file} = $file;

    # just want game win/loss data, no extra info
    if ($globopts{fast}) {next;}


    # NOTE: we only get sometimes, depending on whether info for this
    # game is more recent than previous info for this game.
    # TODO: worry about above

    # do we already have info on this game matching the last move
    # if so, we dont want to delete it if this file doesnt have it
    # TODO: can refine this test a bit
#    if ($gamedata{$game}{extradate} eq $gamedata{$game}{lasttime}) {
#      debug("Already have $game extra data for $gamedata{$game}{lasttime}");
#      next;
#    }

    # to make sure were doing the regex right, confirm a simpler regex first
    unless ($all=~/game_$game/) {next;}
    # this file has current extra info for this game
#    $pre{extrainfo} = 1;

    # store date of the extra info
    $gamedata{$game}{extradate} = $gamedata{$game}{lasttime};
    debug("FILE: $file GAME: $game GETTING EXTRA DATA");

    # suck data to next div data-game-id
    $all=~m%(<div data-game-id="$game" id="game_$game".*?)(<div data-game-id|$)%s;
    my($extra) = $1;

    # TODO: in theory could capture player ids, but do I care?
    # Changed $game to \d+ so Perl could compile regexs below; I also tried
    # changing %s to %so but it makes no difference (implicit compilation)
    unless ($extra=~m%<div data-game-id="\d+" id="game_\d+" class="(.*?)">.*?<div class="remaining"><span>(\d+)</span>\s* letters remaining.*?<div class="score">(\d+)</div>\s*<div class="player_1">(.*?)</div>.*?<div class="score">(\d+)</div>\s*<div class="player_2">(.*?)</div>%s) {
 
      warn "BAD EXTRA INFO FOR $game in $file: $extra"
}

    # gave up on trying to be overly clever here
    @matches = ("",$1,$2,$3,$4,$5,$6);

    # note that array starts at 1 on purpose
    for $i (1..$#matches) {
      $gamedata{$game}{$extra[$i]} = $matches[$i];
    }

    # 1: status of game (game hidden over, game inactive hidden, game over, game over hidden, game shown inactive, game shown over)
    # 2: letters remaining
    # 3: player 1 score
    # 4: player 1 name (always "Barry Carter" in my case)
    # 5: player 2 score
    # 6: player 2 name

    # the board
    while ($extra=~s%<div class=\"space_(\d+)_(\d+).*?>(.*?)</div>%%s) {
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

    $gamedata{$game}{boardstring} = build_board(\@bs);

    # delete now unneeded board
    delete $gamedata{$game}{board};
  }
}

# do I have info on all games?
for $i (keys %isgame) {
  if ($hasnomoves{$i}) {debug("$i: no moves yet"); next;}
  if ($gamedata{$i}) {next;}
  die ("NO DATA FOR GAME: $i");
}

debug("About to parse gamedata...");

# TODO: ignore pre-Thanksgiving 2012 games (previously done above)
# TODO: ignore declined games, and "no moves" games (latter = maybe not?)

# and now, we go through the latest data for each game

# find the most recent games for which I dont have extra info

for $i (sort {$gamedata{$b}->{lasttime} cmp $gamedata{$a}->{lasttime}} keys %gamedata) {

  debug("PARSING GAME: $i");

  debug("ALF: $gamedata{$i}->{lasttime} vs $gamedata{$i}{extrainfo}");

  # just this game itself
  # this is just for me: find games where I can maybe get more data?
  $game = $gamedata{$i};

  if ($game->{extradate}) {
    if ($game->{lasttime} gt $game->{extradate}) {
          debug("STALE EXTRA INFO: $i (start $game->{start} $game->{oppname}, $game->{lastmove}), $game->{lasttime} vs $game->{extradate})");
	}
  } else {
    debug("NO EXTRA INFO AT ALL: $i (start $game->{start} $game->{oppname}, $game->{lastmove}) ($game->{lasttime})");
  }

  # final cleanup (TODO: this is yucky)
  # turned off for testing (this tweak belongs after score report [or change extradate too?])
#  $game->{lasttime}=strftime("%Y-%m-%d %H:%M:%S", localtime(str2time($game->{lasttime})));
#  $game->{start} = strftime("%Y-%m-%d %H:%M:%S", localtime(str2time($game->{start})));

  debug("TIME: $game->{start}");

  debug("FILE: $game->{file}, TIME: $last{$game->{file}}");

  # TODO: seriously modify + maybe subroutinize this "report"
  print "GAME: $i (as of $last{$game->{file}})\n";

  # cleanup name for printing (really applies to Mspint only)
  # TODO: should probably create a %print has, not modify $game
  $game->{p2n}=~s/[^ -~]//isg;
  $game->{oppname}=~s/[^ -~]//isg;

  # TODO: this is ugly
  if ($game->{loser} eq "IP") {
    $post = "[in progress] ($game->{lasttime})";
  } else {
    $post = "[final] ($game->{lasttime})";
  }

  if ($game->{extradate} eq $game->{lasttime}) {
    if ($game->{p1s} > $game->{p2s}) {
      print "SCORE: $game->{p1n} $game->{p1s}, $game->{p2n} $game->{p2s} $post\n";
    } elsif ($game->{p2s} > $game->{p1s}) {
      print "SCORE: $game->{p2n} $game->{p2s}, $game->{p1n} $game->{p1s} $post\n";
    } elsif ($game->{p1s} == $game->{p2s}) {
      print "SCORE: TIE: $game->{p1n} $game->{p1s}, $game->{p2n} $game->{p2s} $post\n";
    } else {
      warn("GAME $game->{game} has no winner?!");
    }
  } else {
    print "SCORE: $game->{game}: vs $game->{oppname}, no score $post\n";
  }

  for $j (keys %{$game}) {
    if ($j=~/^boardstring$/) {next;}
    print "$j: $game->{$j}\n";
  }
  print "\n";

  push(@rows,$game);
}

warn "About to run SQL";

debug("ROWS",@rows);
@queries = hashlist2sqlite(\@rows, "wwf");

# we want later entries to replace earlier ones (though this is
# irrelevant when parsing a single file)

for $i (@queries) {$i=~s/INSERT OR IGNORE/REPLACE/isg;}

# these are the keys for gamedata{game} (aka the column names for the db)
# we could compute these, but that takes longer
# INT forces numerical sort
$keys = "boardstring, data, extradate, extstatus, file, game, lastmove, lasttime, loser, opp, oppname, p1n, p1s INT, p2n, p2s INT, remaining, start, winner, extrainfo";

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
#	debug("COLOR: $spec, $color{$1}");
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

