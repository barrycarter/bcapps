#!/bin/perl

# Trivial script that, given a torrentz.eu URL or similar
# (meta-torrent site), loads torrents or magnet links from each listed
# site if possible, and puts them where utorrent (on a different
# machine) will autoscan them

require "/usr/local/lib/bclib.pl";

# work directory for testing
dodie('chdir("/home/barrycarter/20151013/TORRENTS")');

# URLs to torrent clients, not to torrents
%exclude = list2hash("http://www.qbittorrent.org","http://deluge-torrent.org",
		     "http://www.transmissionbt.com");

(my($url) = @ARGV)||die("Usage: $0 URL");

# to hold magnets
my(@magnets);

my($out,$err,$res) = cache_command2("curl $url","age=86400");
my($all) = $out;

while ($all=~s%href="(.*?)"%%is) {

  my($turl) = $1;

  # ignore locals and torrent clients
  unless ($turl=~/http/ && !$exclude{$turl}) {next;}

  # grab url
  my($out,$err,$res) = cache_command2("curl -L '$turl'", "age=86400");

  # site of turl for local links
  debug("TURL: $turl");
  $turl=~s%^(.*?//.*?)/.*$%$1%;

  while ($out=~s%href="(.*?)"%%is) {
    my($link) = $1;

    # just to avoid collision (TODO: find a better way to do this, sha1?)
    $count++;

    if ($link=~/^magnet/i) {
#      write_file("$link\n","magnet.$count.torrent");
#      write_file("<a href='$link'>magnet</a>\n","magnet.$count.html");
      next;
    }

    if ($link=~/\.torrent$/) {
      debug("LINK: $turl/$link");
      my($tout,$terr,$tres) = cache_command2("curl '$turl/$link'","age=86400");
#      debug("OUT: $tout, ERR: $terr");
      write_file("$tout", "$count.torrent");
    }

#    debug("GOT: $link");
  }

  # obvious torrents and magnets
#  debug("OUT: $out");

}
