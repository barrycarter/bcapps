#!/bin/perl

# Given a valid FetLife session id, downloads user data sequentially,
# until hitting three blanks in a row, to keep my fetlife.db up to
# date

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# directory where stuff gets done
dodie('chdir("/usr/local/etc/FETLIFE")');

defaults("xmessage=1");

# public cookie per http://trilema.com/2015/fetlife-the-meat-market/
# TODO: if/when this stops working, allow user to create/set
$fl_cookie = "_fl_sessionid=$private{fetlife}{session}";

my($bad);
my(@have);
my(@got);
my(@bad);

# TODO: start id should not be fixed as it is below

$id = 4625875;

for (;;) {
  $id++;

  # if exists but not bzipped, bzip it
  if (-f "user$id") {system("bzip2 -v user$id");}

  # only need to check for bzip2'd version now
  if (-f "user$id.bz2") {push(@have,$id); next;}

  my($url) = "https://fetlife.com/users/$id";
  my($out,$err,$res) = cache_command2("curl -A 'Fauxzilla' --socks4a 127.0.0.1:9050 -o user$id -H 'Cookie: $fl_cookie' 'https://fetlife.com/users/$id'", "age=864000");
  my($data) = read_file("user$id");
  # TODO: not crazy about putting this bzip2 here
  system("bzip2 -v user$id");

  # look for 10 *consecutive* bds
  unless ($data=~/<title>/) {
    push(@bad,$id);
    $bad++;
  } else {
    push(@got,$id);
    $bad=0;
  }

  if ($bad>10) {last;}
}

# TODO: delete bads, but especially last 10 bads

# TODO: people, especially newbies(?) change their profiles often(?)

# TODO: recheck older bad entries as well, they may have reactivated

# TODO: keep old data (wiki style) so "blanking profile" trick doesn't work

# NOTE: "10 day" cache will keep us from downloading the same bad many times

# TODO: bzip2 others

debug("PROGRAM ENDS HERE");





