#!/bin/perl

# Given a valid FetLife session id, downloads user data sequentially,
# until hitting three blanks in a row, to keep my fetlife.db up to
# date

require "/usr/local/lib/bclib.pl";

# public cookie per http://trilema.com/2015/fetlife-the-meat-market/
# TODO: if/when this stops working, allow user to create/set
$fl_cookie = "_fl_sessionid=9c69a3c9bb86f4b1f6ff74064e788824";


# TODO: start id should not be fixed as it is below

$id = 4623145;

for (;;) {
  $id++;
  if (-f "/usr/local/etc/FETLIFE/user$id.bz2" || -f "/usr/local/etc/FETLIFE/user$id") {next;}
  debug("DLSTART: $id");
  my($url) = "https://fetlife.com/users/$id";
  my($out,$err,$res) = cache_command2("curl -o /usr/local/etc/FETLIFE/user$id -H 'Cookie: $fl_cookie' 'https://fetlife.com/users/$id'", "age=86400");
  my($data) = read_file("/usr/local/etc/FETLIFE/user$id");
  debug("RES: $res");

  if (++$count%25==0) {
    debug("DURING DEBUT STAGE, HIT ENTER TO CONTINE (every 25)");
    <STDIN>;
  }
}




