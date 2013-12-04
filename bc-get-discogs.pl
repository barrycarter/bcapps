#!/bin/perl

# Uses discogs.com API to download data for a given user:

# Pages like http://www.discogs.com/user/[username]/collection do not
# include info on a release's country, genre, style, parent label,
# etc; this program attempts to retrieve those and create a
# user-specific mysql-like file

require "/usr/local/lib/bclib.pl";
dodie("chdir('/usr/local/etc/discogs')");

debug("HELLO");

(my($user)=@ARGV)||die("Usage: $0 username");
my($out,$err,$res);

debug("BETA");

debug("FILETEST", -f "user-$user-p1");

# cache information as much as possible
# TODO: caching here is a bad idea if user adds releases (but OK for testing)
unless (-f "user-$user-p1" && !$globopts{nocache}) {
  debug("running curl");
  ($out,$err,$res) = cache_command2("curl -o user-$user-p1 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=1&per_page=100'");
}

my($userinfo) = JSON::from_json(read_file("user-$user-p1"));

# debug("USER",%user)
debug(var_dump("user", $userinfo));

