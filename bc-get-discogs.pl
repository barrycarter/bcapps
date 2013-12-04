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
  ($out,$err,$res) = cache_command2("curl -o user-$user-p1 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=1&per_page=100'");
}

# TODO: slightly inefficient to read (though not load) p1 twice
my($userinfo) = JSON::from_json(read_file("user-$user-p1"));

# get all pages
for $i (2..$userinfo->{pagination}{pages}) {
  unless (-f "user-$user-p$i" && !$globopts{nocache}) {
    ($out,$err,$res) = cache_command2("curl -o user-$user-p$i 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=$i&per_page=100'");
    # avoid hitting API too hard
    sleep(1);
  }
}

# now, go through the pages (including page 1)
for $i (1..$userinfo->{pagination}{pages}) {
  my($json) = JSON::from_json(read_file("user-$user-p$i"));
  debug(var_dump("json",$json));
}


die "TESTING";

# debug("USER",%user)
debug(var_dump("user", $userinfo));

