#!/bin/perl

# Trivial script that, given a torrentz.eu URL or similar
# (meta-torrent site), loads torrents or magnet links from each listed
# site if possible, and puts them where utorrent (on a different
# machine) will autoscan them

require "/usr/local/lib/bclib.pl";

# URLs to torrent clients, not to torrents
%exclude = list2hash("http://www.qbittorrent.org","http://deluge-torrent.org",
		     "http://www.transmissionbt.com");

(my($url) = @ARGV)||die("Usage: $0 URL");

my($out,$err,$res) = cache_command2("curl $url","age=86400");

while ($out=~s%href="(.*?)"%%is) {

  my($url2) = $1;

  debug("URLA: $url2");

  # ignore locals and torrent clients
  unless ($url2=~/http/ && !$exclude{$url2}) {next;}

  debug("URLB: $url2");

  # grab url
  debug("URL: $url2");
  my($out2,$err2,$res2) = cache_command2("curl -L '$url2'", "age=86400");
  debug("ERR: $err");

  # obvious torrents and magnets
  

  debug("GOT ($url2): $out");
}

# debug("OUT: $out");


