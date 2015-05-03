#!/bin/perl

# Given a valid FetLife session id, downloads user data sequentially,
# until hitting three blanks in a row, to keep my fetlife.db up to
# date

# --start: the starting user id
# --direction: set to -1 to go backwards

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# directory where stuff gets done
dodie('chdir("/home/barrycarter/FETLIFE/FETLIFE-USER-PROFILES/")');

defaults("xmessage=1");

# public cookie per http://trilema.com/2015/fetlife-the-meat-market/
# TODO: if/when this stops working, allow user to create/set
$fl_cookie = "_fl_sessionid=$private{fetlife}{session}";

my($bad,@bad);

# TODO: start id should not be fixed as it is below
# TODO: direction should not be hardcoded

$id = $globopts{start};

for (;;) {

  if ($globopts{direction}==-1) {$id--;} else {$id++;}

  # the filename for a given $id (only works for > 1000000 or
  # something but OK w/ that for now)
  $id=~/^(\d{3})(\d{4})$/ || die("BAD ID: $id");
  my($fname) = "$1/user$1$2.bz2";
  # skip if I got it already
  if (-f $fname) {$bad=0; next;}

  # no caching, since we used existence of file as cache check above
  my($out,$err,$res) = cache_command2("curl --compress -A 'Fauxzilla' --socks4a 127.0.0.1:9050 -H 'Cookie: $fl_cookie' 'https://fetlife.com/users/$id'");

  # bzip2 and write to correct place
  debug("GETTNG: $id");
  local(*A);
  open(A,"|bzip2 -v - > $fname");
  print A $out;
  close(A);

  # if being asked to login, session id is probably no longer valid
  # TODO: need to delete this bad file, but just ending prog for now
  if ($out=~s%<a href="https://fetlife.com/login">redirected</a>%%) {
    warn "BAD LOGIN ID?";
    last;
  }

  # if $out looks ok, reset bad counter and continue
  if ($out=~/<title>/) {$bad=0; next;}

  # otherwise, increment bad counter, note bad file + possibly exit
  push(@bad,$fname);
  if (++$bad>10) {last;}
}

for $i (-11..0) {system("rm $bad[$i]");}

# TODO: people, especially newbies(?) change their profiles often(?)

# TODO: recheck older bad entries as well, they may have reactivated

# TODO: keep old data (wiki style) so "blanking profile" trick doesn't work

# TODO: rename older profiles to follow user[number].bz2 scheme
