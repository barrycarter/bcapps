#!/bin/perl

# Another very specific program that benefits only me: I lost a drive
# recently-- I do have backups but they're somewhat scattered; some of
# the lost files, however, happen to be on another drive stored by the
# sha1sum of their contents; this script attempts to restore those
# files using the results of rdfind (which noted the two files, the
# lost one, and the one in FILESBYSHA1, are the same)

require "/usr/local/lib/bclib.pl";

my(%copy);

while (<>) {

  # there is a lot of redundancy here

  if (/symlink (.*?) to (.*)$/) {handle_files($1,$2); next;}

  if (/sudo ln \-s \"(.*?)\" \"(.*?)\"/) {handle_files($1,$2); next;}

  debug("GOT: $_");
}

# TODO: I *might* be able to use this program to restore files that
# weren't in MP[34]

sub handle_files {

  my(@files) = @_;
  
  # the file in FILESBYSHA1 will always be source, and the file in
  # MP(34) will always be target

  if ($files[0]=~m%/FILESBYSHA1/% && $files[1]=~m%/MP[34]/%) {
    $copy{$files[0]}{$files[1]} = 1;
    return;
  }

  if ($files[1]=~m%/FILESBYSHA1/% && $files[0]=~m%/MP[34]/%) {
    $copy{$files[1]}{$files[0]} = 1;
    return;
  }

  debug("Can't handle:", @files);

}
