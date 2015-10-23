#!/bin/perl

# Downloads given users data similar to bc-dl-by-region

# --sessionid: a valid fetlife session id

# testing shows that rate 24 w/ tor works, but rate 48 does not (the
# speed is not actually in bytes/second, despite what "man curl" says)

require "/usr/local/lib/bclib.pl";

# TODO: user profiles do change

# directory where stuff gets done
dodie('chdir("/home/barrycarter/FETLIFE/FETLIFE-USER-PROFILES/")');

$maxlen = 100000;
my($len) = +Infinity;

unless ($globopts{sessionid}) {die "Usage: $0 --sessionid=x";}

defaults("xmessage=1");

my($cmd) = "curl -f --socks4a 127.0.0.1:9050 --limit-rate 24 --create-dirs --compress -A Fauxzilla -H 'Cookie: _fl_sessionid=$globopts{sessionid}'";

open(B,">cmdlist.txt");

# one userid per line expected

while (<>) {

  my($str);
  chomp;
  ++$innercount;


  # TODO: these profiles are two old, so not checking
  my($fname) = join("",floor($_/10000),"/user",$_);
#  if (-s $fname > 1000 || -s "$fname.bz2" > 1000) {
#    debug("EXISTS: $fname");
#    next;
#  }

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

# TODO: regularly check that homepage.html is large/recent enough
