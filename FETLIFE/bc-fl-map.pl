#!/bin/perl

# not really FL specific, helps map FetLife users and give canonical
# place names

require "/usr/local/lib/bclib.pl";

# determine what are lat/lon bounds are

%q = str2hash($ENV{QUERY_STRING});

my($nlat,$wlon) = slippy2latlon($q{x},$q{y},$q{zoom},0,0);

# this is technically one pixel past the tile, but that's OK
my($slat,$elon) = slippy2latlon($q{x},$q{y},$q{zoom},256,256);

debug("$wlon/$elon/$slat/$nlat");

# TODO: SQL_CALC_FOUND_ROWS FOUND_ROWS() isn't returning correct
# results AND is overwriting good results, so turning it off for now
# (instead, will assume 24 results means there are more, though that's
# not always true)

# my(@res) = mysqlhashlist("SELECT SQL_CALC_FOUND_ROWS * FROM placecounts WHERE
# latitude>=$slat AND latitude<=$nlat AND longitude>=$wlon AND longitude<=$elon 
# ORDER BY count DESC LIMIT 24; SELECT FOUND_ROWS()", "shared");

my(@res) = mysqlhashlist("SELECT * FROM placecounts WHERE
latitude>=$slat AND latitude<=$nlat AND longitude>=$wlon AND longitude<=$elon 
ORDER BY count DESC LIMIT 24", "shared");

for $i (@res) {
  my($text) = "($i->{count}): $i->{city}, $i->{state}, $i->{country}";
  debug("TEXT: $text");
  unless ($text=~/[a-z]/i) {next;}
  push(@print,$text);
}

push(@print,$ENV{QUERY_STRING},"lat:$slat-$nlat,lon=$wlon-$elon");

debug("PRNT",@print);

# copied largely from bc-mytile.pl

print "Content-type: image/gif\n\n";
open(A,"|fly -q");

print A << "MARK";
new
size 256,256
setpixel 0,0,255,255,255
rect 0,0,256,256,255,0,0
MARK
;

$y=0;

for $i (@print) {
  print A td("string 255,0,255,2,$y,small,$i\n");
  $y+=10;
}

close(A);

# this hideous formula derived using Mathematica

# sub lat2py {
# (2^(-1 + zoom)*(256*Pi - 2^(9 - zoom)*Pi*y - 
#   256*Log[Tan[(90*Pi + lat*Pi)/360]]))/Pi

# below copied from MAPS/playground2.pl, need to make it a real function later

=item mysqlhashlist($query,$db,$user)

Run $query (should be a SELECT statement) on $db as $user, and return
list of hashes, one for each row

NOTE: return array first index is 1, not 0

TODO: add error checking

=cut

sub mysqlhashlist {
  my($query,$db,$user) = @_;
  unless ($user) {$user="''";}
  my(@res,$row);
  chdir(tmpdir());

  write_file($query,"query");

  my($temp) = `date +%N`;
  chomp($temp);
  # TODO: for large resultsets, loading entire output may be bad
  my($out,$err,$res) = cache_command2("mysql -w -u $user -E $db < query","salt=$query&cachefile=/tmp/cache.$temp");

  debug("OUT: $out");

  # go through results
  for $i (split(/\n/,$out)) {
    # new row
    if ($i=~/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; $res[$row]={}; next;}
    unless ($i=~/^\s*(.*?):\s*(.*)/) {warn("IGNORING: $_"); next;}
    $res[$row]->{$1}=$2;
  }
  return @res;
}

# below copied from other prog, but really should be moved to bclib

=item td(@list)

Transparent debugging: print @list to stderr and return it.

=cut

sub td {
  my(@list) = @_;
  debug("TRANSDEBUG:",@list);
  return @list;
}
