#!/bin/perl

# parse METAR data from cycle files (and put them in SQL db)

# Runs on one file at a time; to parse multiples use xarg (not
# parallel, since order is important)

# -nosql: dont run SQL commands, just print them out

push(@INC, "/usr/local/lib");
require "bclib.pl";
($all, $arg) = cmdfile();

# do this only after we've got the data (in case user used short path)
chdir(tmpdir());

# go through each line

for $i (split("\n", $all)) {

  # compact multiple spaces + remove leading/trailing
  $i=~s/\s+/ /isg;
  $i = trim($i);

  debug("METAR: $i");

  # parse METAR
  %ac=parse_metar($i);

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

unless ($NOSQL) {
  # make a local copy of db to tweak
  system("cp /sites/DB/metar.db metar-temp.db");
  # run the commands on the temp db
  system("sqlite3 metar-temp.db < queries.txt 1>output.txt 2>error.txt");

  # backup old copy (plus any queries accessing don't get confused)
  system("mv /sites/DB/metar.db /sites/DB/metar-old.db");
  # and create new copy
  system("mv metar-temp.db /sites/DB/metar.db");
}

# parse_metar(string): parses a METAR string to put into a db

sub parse_metar {
  my($a)=@_;

  my(%b)=(); # to hold results
  my(@clouds)=(); # to hold multiple clouds
  my(@weather)=(); # multiple weathers
  my(@leftover)=(); # anything i can't parse

  # we want to store the full metar
  $b{metar}=$a;

  # fix things like "2 1/2SM" and "3/4SM", eval to avoid div by zero death
  eval {$a=~s!(\d+)\s+(\d)/(\d)sm!eval($1+$2/$3)."SM"!ie};
  eval {e$a=~s!(\d)/(\d)sm!eval($1/$2)."SM"!ie};

  # split METAR by spaces
  @b=split(/\s+/,$a);

  # first field is always station
  $b{code}=shift(@b);

  # second field is ddhhmm in GMT
  $aa=shift(@b);
  $aa=~/(\d{2})(\d{2})(\d{2})z/i||warn("BAD TIME: $aa");
  ($day,$hour,$min)=($1,$2,$3);

  # need to figure out month and year (only really an issue at month change)

  # current time/date (just need month and year)
  my($ignore,$ignore,$ignore,$mday,$mon,$year) = gmtime();
  # Perl bizzarely counts months 0..11
  $mon++;

  # if report date is in future, subtract one month
  if (str2time("$year-$mon-$day $hour:$min") > time()) {
    $mon--;
    if ($mon==0) {$year--; $mon=12;}
  }

  # we will return time in sqlite3 format
  $b{time} = "$year-$mon-$day $hour:$min";

  # for convenience, note age of data (caller can toss old data)
#  my($time) = str2time($b{time});
#  $b{age} = time()-$time;
#  debug("AGE: -> $b{age}");

  # remaining fields may be in any order
  for $i (@b) {

    # wind direction/speed
    if ($i=~/^(\d{3}|vrb)(\d{2})kt/i) {
      ($b{winddir},$b{windspeed})=($1,$2);
      next;
    }

    # wind direction/speed (gusting)
    if ($i=~/^(\d{3}|vrb)(\d{2})g(\d{2})kt/i) {
      ($b{winddir},$b{windspeed},$b{gust})=($1,$2,$3); 
      next;
    }

    # visibility
    if ($i=~s/sm$//i) {
      $b{visibility}=$i;
      next;
    }

    # temp/dew point in C (whole degrees)
    # more than 3 digits = bad
    if ($i=~m!^(M?\d{1,3})/(M?\d{1,3})$!) {
      # if we already have a more accurate temperature from RMK, ignore this
      if (exists $b{temperature}) {next;}

      ($b{temperature},$b{dewpoint})=($1,$2);
      if ($b{temperature}=~s/^m//i) {$b{temperature}*=-1;}
      if ($b{dewpoint}=~s/^m//i) {$b{dewpoint}*=-1;}
      next;
    }

    # some reports have temperature only, no dewpoint
    if ($i=~m!^(M?\d{1,3})/$!) {
      # if we already have a more accurate temperature from RMK, ignore this
      if (exists $b{temperature}) {next;}

      $b{temperature}=$1;
      if ($b{temperature}=~s/^m//i) {$b{temperature}*=-1;}
      next;
    }

    # RMK section sometimes has more accurate temperature and dewpoint
    if ($i=~m!^t(\d)(\d{3})(\d)(\d{3})$!i) {
      ($b{temperature},$b{dewpoint})=((-2*$1+1)*$2/10,(-2*$3+1)*$4/10);
      next;
    }

    # Barometric pressure in inches
    if ($i=~/^a(\d{4})/i) {
      $b{pressure}=$1/100; 
      next;
    }

    # Barometric pressure in millibars; we convert to inches for consistency
    if ($i=~/q(\d+)/i) {
      if (exists $b{pressure}) {next;}
      $b{pressure}=$1/33.86388;
      next;
    }

    # Note down how much cloud cover there is
    if ($i=~/^(clr|few|sct|bkn|ovc)/i) {push(@clouds,$i); next;}

    # signifigant weather
    if ($i=~/^([\+\-]?)($abbrevs|)($abbrevs)$/i) {
      push(@weather,$i);
      next;
    }

    # Was this report automatically generated?
    if ($i eq "AUTO") {$b{type}="AUTO"; next;}

    # uninteresting stuff (data on sensors, sea-level pressure,
    # non-aviation temperature, remarks separator); we preserve this
    # in the METAR field (and leftover field) but don't break it out
    # into separate fields

    if ($i=~/^ao\d$/i || $i=~/^slp\d+$/i || $i=~/^4(\d{8})$/|| $i eq "RMK") {
      next;
    }

    push(@leftover,$i);
  }

  # combine lists into strings
  $b{cloudcover}=join(" ",@clouds);
  $b{weather}=join(" ",@weather);
  $b{leftover}=join(" ",@leftover);
  return(%b);
}
