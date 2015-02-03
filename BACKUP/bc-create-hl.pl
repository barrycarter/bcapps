#!/bin/perl

# Given a list of files on the STDIN, replicate them as hardlinks in a
# given directory. Current (and possibly only) use: efficient backups
# with zpaq (which can take a directory as an argument, but not a list
# of files if the list is larger than what the shell can handle)

require "/usr/local/lib/bclib.pl";

# testing
my($rootdir) = "/usr/local/etc/ZPAQ";

while (<>) {
  chomp;

  # directory and name
  /^(.*)\/(.*)$/;
  my($dir,$name) = ($1, $2);

  unless ($dir && $name) {die("BAD DIR ($dir) OR NAME ($name)");}

  # create dir if it doesnt exist
  # TODO: ignore files w apostrophes or other weirdness, but warn about them
  unless (-d "$rootdir/$dir") {system("mkdir -p '$rootdir/$dir'");}

  # and symlink
  system("ln $_ $rootdir/$_");

#  debug("$dir vs $name");
}

