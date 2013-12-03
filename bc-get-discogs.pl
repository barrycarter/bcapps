#!/bin/perl

# Uses discogs.com API to download data for a given user:

# Pages like http://www.discogs.com/user/[username]/collection do not
# include info on a release's country, genre, style, parent label,
# etc; this program attempts to retrieve those and create a
# user-specific mysql-like file

require "/usr/local/lib/bclib.pl";

(my($user)=@ARGV)||die("Usage: $0 username");


my($out,$err,$res) = cache_command2("curl http://api.discogs.com/users/$user/collection/folders/0/releases", "age=86400");

my($userinfo) = JSON::from_json($out);
# debug("USER",%user)
debug(var_dump("user", $userinfo));

