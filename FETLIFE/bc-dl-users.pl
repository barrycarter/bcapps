#!/bin/perl

# Downloads given users data similar to bc-dl-by-region

# --sessionid: a valid fetlife session id

require "/usr/local/lib/bclib.pl";

# TODO: user profiles do change

# directory where stuff gets done
dodie('chdir("/home/barrycarter/FETLIFE/FETLIFE-USER-PROFILES/")');

$maxlen = 100000;
my($len) = +Infinity;

unless ($globopts{sessionid}) {die "Usage: $0 --sessionid=x";}

defaults("xmessage=1");

my($cmd) = "curl -f --create-dirs --compress -A Fauxzilla --socks4a 127.0.0.1:9050 -H 'Cookie: _fl_sessionid=$globopts{sessionid}'";

open(B,">cmdlist.txt");

# one userid per line expected

while (<>) {

  my($str);
  chomp;
  ++$innercount;
  # TODO: bzip2? (or check for bzipped version?)

  my($fname) = join("",floor($_/10000),"/user",$_);
  if (-s $fname > 1000 || -s "$fname.bz2" > 1000) {
    debug("EXISTS: $fname");
    next;
  }

  # every so often, visit home page to avoid block
  if ($innercount%25==0) {
    $str .= "-o homepage.html 'https://fetlife.com/home/v4' ";
  }

  my($url) = "https://fetlife.com/users/$_";
  $str .= "-o '$fname' '$url' ";

  # enough room to print string? (if not, print return first + curl)
  $len += length($str);

  if ($len <= $maxlen) {print B $str; next;}

  # length too long, so print new line
  $str = "\n$cmd $str";
  $len = length($str);
  print B $str;
}

die "TESTING";

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
