#!/bin/perl

# parses conquerclub XML data game files

# Sample curl statements (this program does NOT retrieve data):
# curl -o cc1.xml 'http://www.conquerclub.com/api.php?mode=gamelist&names=Y&events=Y&page=1'
# curl -o ccaog.xml 'http://www.conquerclub.com/api.php?mode=gamelist&names=Y&events=Y&p1un=Army+of+GOD&page=1'

push(@INC,"/usr/local/lib");
require "bclib.pl";

($all)=cmdfile();

# do all work in tmpdir
chdir(tmpdir("xml2sql"));
open(A,">queries.sql");
print A "BEGIN TRANSACTION;\n";

# find games
@games = ($all=~m%<game>(.*?)</game>%isg);

# for each game...
for $i (@games) {

  # players and their status
  @players = ($i=~m%(<player state=\".*?\">.*?</player>)%isg);

  # events
  @events = ($i=~m%(<event timestamp=\".*?\">.*?</event>)%isg);

  # now, find single-valued properties and build up query
  %hash=(); @keys=(); @vals=(); @queryp=(); @eventq=(); @playernames=();
  while ($i=~s%<(.*?)>(.*?)</\1>%%) {
    ($key,$val)=($1,$2);
    $hash{$key}=$val;
    push(@keys,$key);
    push(@vals, "\"$val\"");
  }

  $query = "INSERT INTO games (".join(", ",@keys).") VALUES (".join(", ",@vals).");";

  # and now the player queries
  for $j (@players) {
    #<h>BAD PLAYER indicates parsing error, not quality of player</h>
    $j=~m%<player state=\"(.*?)\">(.*?)</player>%||warn("BAD PLAYER: $j");
    ($winlose,$player) = ($1,$2);
    push(@queryp, qq%INSERT INTO players (game_number, player, winlose) VALUES
("$hash{game_number}", "$player", "$winlose")%);
    # I need array below for events table
    push(@playernames, $player);
  }

  # event queries
  for $j (@events) {
    $j=~m%<event timestamp="(.*?)">(.*?)</event>%||warnlocal("BAD EVENT: $j");
    ($time,$event) = ($1,$2);

    # change numbers to usernames and player queries
    # TODO: cleaner way to do this? (vs all these if statements?)

    # x eliminates y
    if ($event=~m/^(\d+) eliminated (\d+) from the game$/) {
      ($p1,$p2) = ($playernames[$1-1],$playernames[$2-1]);
      push(@eventq, qq%INSERT INTO events (game_number, time, p1, action, p2) VALUES
     ("$hash{game_number}", "$time", "$p1", "eliminated", "$p2")%);
      next;
    }

    # x gets points
    if ($event=~m/^(\d+) (loses|gains) (\d+) points$/){
      ($p1,$dir,$pts) = ($playernames[$1-1],$2,$3);
      if ($dir eq "loses") {$pts*=-1;}
      push(@eventq, qq%INSERT INTO events (game_number, time, p1, action, p2) VALUES
      ("$hash{game_number}", "$time", "$p1", "points", "$pts")%);
      next;
    }

    # 1 or more players wins
    if ($event=~m/^(.*?) won the game$/){
      @winners=split(/\s*\,\s*/,$1);
      map($_=$playernames[$_-1],@winners);
      for $k (@winners) {
	push(@eventq, qq%INSERT INTO events (game_number, time, p1, action, p2) VALUES
        ("$hash{game_number}", "$time", "$k", "wins", "")%);
      }
      next;
    }

    if ($event=~m/^(\d+) was kicked out( for missing too many turns)?$/) {
      $p1 = $playernames[$1-1];
      push(@eventq, qq%INSERT INTO events (game_number, time, p1, action, p2) VALUES
      ("$hash{game_number}", "$time", "$p1", "kicked", "")%);
      next;
    }

    if ($event=~m/(\d+) held the objective$/) {
      $p1 = $playernames[$1-1];
      push(@eventq, qq%INSERT INTO events (game_number, time, p1, action, p2) VALUES
      ("$hash{game_number}", "$time", "$p1", "objective", "")%);
      next;
    }

    warn("UNHANDLED EVENT: $j");
  }

$queryp = join(";\n", @queryp).";\n";
$eventp = join(";\n", @eventq).";\n";

  # the queries we want
  print A << "MARK";
DELETE FROM events WHERE game_number='$hash{game_number}';
DELETE FROM games WHERE game_number='$hash{game_number}';
DELETE FROM players WHERE game_number='$hash{game_number}';
$query
$queryp
$eventp
MARK
;
}

print A "END TRANSACTION;\n";
close(A);

debug("RUNNING QUERIES");
system("sqlite3 /usr/local/etc/CONQUERCLUB/ccgames.db < queries.sql");
debug("QUERIES DONE");

=item schema

-- Schema for SQLite3 tables

CREATE TABLE games (
 -- data on a given game
 game_number INT, -- the game number
 tournament, -- name of tournament, "" if none
 private, -- is game private? (Y/N)
 speed_game, -- is this a speed game? (Y/N)
 map, -- game map
 game_type, -- (S)tandard, (C)Terminator, (A)ssassin, (D)oubles, (T)riples or
 -- (Q)uadruples
 initial_troops, -- initial troops, (E)Automatic or (M)anual
 play_order, -- play order, (S)equential or (F)reestyle
 bonus_cards, -- spoils, (1)No Spoils, (2)Escalating, (3)Flat Rate or 
 -- (4)Nuclear
 fortifications, -- reinforcements, (C)hained, (O)Adjacent or (M)Unlimited
 war_fog, -- Fog of war? (Y/N)
 round INT, -- current round
 time_remaining, -- time remaining for current player to make move
 game_state -- A/F, possibly active/finished
);

CREATE TABLE players(
 -- players for each game
 game_number INT, -- game number
 player, -- player username
 winlose -- player status (Won/Lost/Waiting/Ready)
);

CREATE TABLE events(
 -- XML log events (small subset of HTML log events)
 game_number INT, -- game number
 time INT, -- time of event in Unix seconds
 p1, -- affected player
 action, -- what occurred
 p2, -- for eliminated, the eliminated player.. for points, number of point
);

CREATE UNIQUE INDEX igame ON games(game_number);
CREATE UNIQUE INDEX iplayer ON players(game_number, player);
CREATE UNIQUE INDEX ievents ON events(game_number, time, p1, action, p2);

=cut
