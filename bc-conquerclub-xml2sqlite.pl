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

# find games
@games = ($all=~m%<game>(.*?)</game>%isg);

# for each game...
for $i (@games) {

  # players and their status
  @players = ($i=~m%(<player state=\".*?\">.*?</player>)%isg);

  # now, find single-valued properties and build up query
  %hash=(); @keys=(); @vals=(); @queryp=();
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
    push(@queryp, "INSERT INTO players (game_number, player, winlose) VALUES
(\"$hash{game_number}\", \"$player\", \"$winlose\")");
  }

$queryp = join(";\n", @queryp).";\n";

  # the queries we want
  print A << "MARK";
DELETE FROM games WHERE game_number='$hash{game_number}';
DELETE FROM players WHERE game_number='$hash{game_number}';
$query
$queryp
MARK
;
}

close(A);

system("sqlite3 /usr/local/etc/CONQUERCLUB/ccgames.db < queries.sql");

=item schema

-- Schema for SQLite3 tables

CREATE TABLE games (
 -- data on a given game
 game_number, -- the game number
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
 round, -- current round
 time_remaining -- time remaining for current player to make move
);

CREATE TABLE players(
 -- players for each game
 game_number, -- game number
 player, -- player username
 winlose -- player status (Won/Lost/Waiting/Ready)
);

CREATE UNIQUE INDEX igame ON games(game_number);
CREATE UNIQUE INDEX iplayer ON players(game_number, player);

=cut
