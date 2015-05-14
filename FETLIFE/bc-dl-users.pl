#!/bin/perl

# Given a valid FetLife session id, downloads user data sequentially,
# until hitting three blanks in a row, to keep my fetlife.db up to
# date

# --start: the starting user id
# --direction: set to -1 to go backwards
# --list: obtain list of user numbers from stdin (start/direction ignored)

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

  if ($globopts{list}) {
    $id = <>;
    chomp($id);
  } elsif ($globopts{direction}==-1) {
    $id--;
  } else {
    $id++;
  }

  # this feels like a hack
  my($d1) = $id%10000;
  my($d2) = floor($id/10000);
  my($d3) = $d2*10000;
  my($fname) = "$d2/user$id.bz2";

  # skip if I got it already
  if (-f $fname) {
    debug("HAVE: $id");
    $bad=0;
    next;
  }

  debug("GETTING: $id");

  # no caching, since we used existence of file as cache check above
  my($out,$err,$res) = cache_command2("curl --compress -A 'Fauxzilla' --socks4a 127.0.0.1:9050 -H 'Cookie: $fl_cookie' 'https://fetlife.com/users/$id'");

  # if being asked to login, session id is probably no longer valid
  if ($out=~s%<a href="https://fetlife.com/login">redirected</a>%%) {die "BAD LOGIN ID!";}

  # if no title move on to next, but increment bad and exit after 10 in a row
  # TODO: temporarily commenting this out, since I am traversing known good ids
#  unless ($out=~/<title>/) {if (++$bad>10) {last;} next;}

  # bzip2 and write to correct place (and reset bad)
  $bad=0;
  local(*A);
  open(A,"|bzip2 -v - > $fname")||die("Can't open for writing, $!");
  print A $out;
  close(A);

  # delay to avoid flooding servers
  sleep(2);

}

# TODO: people, especially newbies(?) change their profiles often(?)

# TODO: recheck older bad entries as well, they may have reactivated

# TODO: keep old data (wiki style) so "blanking profile" trick doesn't work

# TODO: rename older profiles to follow user[number].bz2 scheme
