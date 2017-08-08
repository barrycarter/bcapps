#!/bin/perl

# Given a file with a list of idrive accounts and passwords, use
# idevsutil to dump filelists from each account (trivial wrapper
# around idevsutil), including username and password (dumping password
# is baddish, but since I'm using this for backup, it's more important
# to know the pw than to hide it)

require "/usr/local/lib/bclib.pl";

debug(%globopts);

# had to change this for saopaulo
my($cmd) = "/root/build/idevsutil_linux64/idevsutil.old";


my(@accts) = split(/\n/, read_file("$homedir/idrive-accounts.txt"));

for $i (@accts) {

  if ($i=~/^\s*$/ || $i=~/^\#/) {next;}

  my($u,$p) = split(/:/, $i);

  # must write pw to consistent temp file for caching
  my($pwfile) = "/var/tmp/".sha1_hex($i);
  write_file($p, $pwfile);

  # find IP address of server
  my($out, $err,$res) = cache_command2("$cmd --password-file=$pwfile --getServerAddress $u", "age=86400");

  unless ($out=~/cmdUtilityServerIP=\"(.*?)\"/) {
    warn "NO IP ADDRESS FOR: $u";
    next;
  }

  my($ip) = $1;

  # TODO: standardize where I keep idevsutil
  my($cmd) = "$cmd --password-file=$pwfile --search $u\@$ip\:\:home/", "age=3600";

  debug("CMD: $cmd");

  ($out, $err, $res) = cache_command2($cmd, "age=3600");

  print "User: $u\nPass: $p\n$out\n";
}

