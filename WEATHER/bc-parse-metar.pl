#!/bin/perl

# parse METAR data from cycle files (and put them in SQL db)

# Runs on one file at a time; to parse multiples use xarg (not
# parallel, since order is important)

# -nosql: dont run SQL commands, just print them out

push(@INC, "/usr/local/lib");
require "bclib.pl";
($all, $arg) = cmdfile();
debug("PROCESSING FILE: $arg");

# list of METAR weather abbrevs (TODO: put this somewhere better)

# do this only after we've got the data (in case user used short path)
chdir(tmpdir());

# remove DOS newlines
$all=~s/\r//isg;

# newlines followed by spaces are one big line
$all=~s/\n+ +/ /isg;

# go through each line

for $i (split("\n", $all)) {
  # ignore comments and empty lines
  if ($i=~/^\#|^\s*$/) {next;}

  # compact multiple spaces + remove leading/trailing
  $i=~s/\s+/ /isg;
  $i = trim($i);

  # remove "METAR" (or "SPECI") at start of line
  $i=~s/^(METAR|SPECI)\s*//isg;

  debug("LINE: $i");

  # skip lines with NIL= (but those w/ just NIL)
  if ($i=~/NIL=/) {next;}

  # parse METAR
  %ac=parse_metar($i);

  if ($ac{ERROR}) {
    warn("ERROR: $ac{ERROR}");
    next;
  }

  # helpful in tracking down errors
  $ac{comment} = "$arg";

  # Create SQL query using returned fields/values
  @f=();
  @v=();
  for $j (sort keys %ac) {
    push(@f,$j);
    $ac{$j}=~s/[^ -~]//isg; # remove nonprintable chars
    $ac{$j}=~s/\'//isg; # and apostrophes

    # convert -4- to -04- for sqlite3
    $ac{$j}=~s/\-(\d)\-/-0$1-/isg;

    push(@v,"'$ac{$j}'");
  }

  $fields = join(", ",@f);
  $values = join(", ",@v);

  $query="REPLACE INTO weather ($fields) VALUES ($values)";

  # nowweather is a hack: it has a unique index on code, so only keeps the
  # latest data for a given station (easier than doing this in SQL
  $query2="REPLACE INTO nowweather ($fields) VALUES ($values)";
  push(@query,$query,$query2);
}

# delete data over a day old
push(@query,"DELETE FROM weather WHERE strftime('%s',timestamp)-strftime('%s','now') < -86400");

# need below because bad old data gets stuck sometimes, even in nowweather
push(@query,"DELETE FROM nowweather WHERE strftime('%s',timestamp)-strftime('%s','now') < -86400");

# create transaction and cleanup afterwords
unshift(@query,"BEGIN");
push(@query,"COMMIT");
push(@query,"VACUUM");

# write queries to file, run
open(B,">queries.txt");
for $i (@query) {print B "$i;\n";} #sqlite3 insists on this semicolon
close(B);

# debug("QUERIES",read_file("queries.txt"));

unless ($globopts{nosql}) {
  # make a local copy of db to tweak
  system("cp /sites/DB/metar.db metar-temp.db 1> cpout 2>cperr");

# DEBUG ONLY
system("cp metar-temp.db metar-before.db");

  # run the commands on the temp db
  system("sqlite3 metar-temp.db < queries.txt 1> /tmp/metar-sql.out 2> /tmp/metar-sql.err");

  # KLUDGE: sometimes the resulting "db" is a 1024-byte garbage file
  # (real SQLite3 dbs are always bigger?)
  if (-s "metar-temp.db" < 2048) {
    die "metar-temp.db ridiculously small";
  }

# DEBUG ONLY
system("cp metar-temp.db metar-after.db");

  # backup old copy (plus any queries accessing don't get confused)
  system("mv /sites/DB/metar.db /sites/DB/metar-old.db");
  # and create new copy
  system("mv metar-temp.db /sites/DB/metar.db");
}

=item schema

Schema for METAR db in case we need to re-create it (also populate
stations from stations.db):

CREATE TABLE nowweather (cloudcover text, code text, dewpoint double, 
leftover text, metar text, pressure double, temperature double, time 
datetime , type text, visibility text, weather text, winddir text, 
windspeed int, gust int, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, comment);
CREATE TABLE stations(
  metar TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  latitude REAL,
  longitude REAL,
  elevation REAL,
  x REAL,
  y REAL,
  z REAL
);
CREATE TABLE weather (cloudcover text, code text, dewpoint double, 
leftover text, metar text, pressure double, temperature double, time 
datetime , type text, visibility text, weather text, winddir text, 
windspeed int, gust int, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, comment);
CREATE UNIQUE INDEX i_code ON nowweather(code);
CREATE UNIQUE INDEX i_codetime ON weather(code,time);

=cut
