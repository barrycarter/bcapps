#!/bin/perl

# Given a valid FetLife session id, downloads user data sequentially,
# until hitting three blanks in a row, to keep my fetlife.db up to
# date

require "/usr/local/lib/bclib.pl";

# public cookie per http://trilema.com/2015/fetlife-the-meat-market/
# TODO: if/when this stops working, allow user to create/set
$fl_cookie = "_fl_sessionid=9c69a3c9bb86f4b1f6ff74064e788824";

my($bad);
my(@have);
my(@got);
my(@bad);

# TODO: start id should not be fixed as it is below

$id = 4623145;

for (;;) {
  $id++;
  if (-f "/usr/local/etc/FETLIFE/user$id.bz2" || -f "/usr/local/etc/FETLIFE/user$id") {
    debug("ALREADYHAVE: $id");
    push(@have,$id);
    next;
  }

  my($url) = "https://fetlife.com/users/$id";
  my($out,$err,$res) = cache_command2("curl -o /usr/local/etc/FETLIFE/user$id -H 'Cookie: $fl_cookie' 'https://fetlife.com/users/$id'", "age=864000");
  my($data) = read_file("/usr/local/etc/FETLIFE/user$id");

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





