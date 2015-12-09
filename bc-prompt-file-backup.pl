#!/bin/perl

# backs up files to promptfile.com, encrypting them first

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# directory where I am keeping keys for now
my($dir) = "/home/barrycarter/20151207/";
chdir($dir)||die("Can't chdir to $dir, $!");

for $i (@ARGV) {

  # encrypt the filename, after trimming it and adding size
  my($size) = -s $i;
  unless ($size) {warn "EMPTY FILE: $i, ignoring"; next;}
  my($name) = $i;
  $name=~s%.*/%%;
  $name = "$name.$size";

  # using salted sha1hash is terrible, not reversible
  # TODO: keep track of salted hashes locally!
  my($encname) = sha1_hex("$name.$size.$private{promptfile}{salt}");

  # TODO: allow for multiple runs, don't hardcode "filename"
#  open(A,"|openssl rsautl -inkey rsakey -encrypt|base64 > filename");
#  print A $name;
#  close(A);
#  my($encname) = read_file("filename");
#  $encname=~s/\s//g;
#  $encname=~s%/%-%g;
#  $encname=~s%\+%,%g;
#  debug("ENC: $i -> $encname");

  # now the ncftp command to send it over
  # NOTE: to decrypt "openssl enc -d -bf ..."

  # NOTE: the -z below doesn't work because uploaded files aren't
  # visible in promptfile's directory tree
  print "openssl enc -bf -pass file:rsakey -in \"$i\" | ncftpput -c -z -u $private{promptfile}{username} -p $private{promptfile}{password} $private{promptfile}{server} $encname\n";

}


