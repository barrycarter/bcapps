#!/bin/perl

# Given a file with a list of idrive accounts and passwords, use
# idevsutil to dump filelists from each account (trivial wrapper
# around idevsutil), including username and password (dumping password
# is baddish, but since I'm using this for backup, it's more important
# to know the pw than to hide it)

require "/usr/local/lib/bclib.pl";

debug(%globopts);

my(@accts) = split(/\n/, read_file("$homedir/idrive-accounts.txt"));

# temp to fix cache command 2 errors

my($tmp) = my_tmpfile();
write_file("hello larry", $tmp);


my($out, $err,$res) = cache_command2("date", "age=86400");

debug("OUT: $out");

die "TESTING";


for $i (@accts) {

  if ($i=~/^\s*$/ || $i=~/^\#/) {next;}

  my($u,$p) = split(/:/, $i);

  # write pw to temp file (required by idrive)
  my($tmp) = my_tmpfile();
  write_file($p, $tmp);

  # find IP address of server
  my($out, $err,$res) = cache_command2("/root/build/idevsutil_linux/idevsutil --password-file=$tmp --getServerAddress $u", "age=86400");

  debug("OUT: $out");

  debug("U: $u, P: $p, X: $tmp");
}

