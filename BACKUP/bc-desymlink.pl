#!/bin/perl

# Another very specific program that benefits only me: I lost a drive
# recently-- I do have backups but they're somewhat scattered; some of
# the lost files, however, happen to be on another drive stored by the
# sha1sum of their contents; this script attempts to restore those
# files using the results of rdfind (which noted the two files, the
# lost one, and the one in FILESBYSHA1, are the same)

require "/usr/local/lib/bclib.pl";

# this will be target source, since each target should have one source max
my(%copy);

while (<>) {

  # there is a lot of redundancy here

  if (/symlink (.*?) to (.*)$/) {handle_files($1,$2); next;}

  if (/sudo ln \-s \"(.*?)\" \"(.*?)\"/) {handle_files($1,$2); next;}

  warn("Can't handle: $_");
}

# TODO: handle odd case of multiple targets?

for $i (sort keys %copy) {

  # find the portion of the target after MP3/ put it under /home/user instead

  my($relpath) = $i;
  $relpath=~s%^.*/(MP[34])/%/$1/%;
  $relpath = "/home/user/$relpath";

  # if that already exists, we do not overwrite
  # TODO: if this is a symlink to nowhere, it SHOULD be ovewritten

  if (-f $relpath) {next;}

  # if the directory in question doesn't exist create it

  my($dir) = $relpath;
  $dir=~s%/[^/]+?$%%;

  unless (-d $dir) {
    # this should really not be done here
    my($out, $err, $res) = cache_command2("mkdir -p \"$dir\"");
  }

  # find (hopefully unique) source

  my(@source) = keys %{$copy{$i}};

  if ($#source > 0) {
    warn "MULTIPLE SOURCES FOR $i, IGNORING";
    next;
  }

  debug("SOURCES", @source);

  # and print the cp command without actually runnning it
  print "cp -n \"$source[0]\" \"$relpath\"\n";

#   debug("I: $i", "RELPATH: $relpath, DIR: $dir");

}

# TODO: I *might* be able to use this program to restore files that
# weren't in MP[34]

sub handle_files {

  my(@files) = @_;
  
  # the file in FILESBYSHA1 will always be source, and the file in
  # MP(34) will always be target

  if ($files[1]=~m%/FILESBYSHA1/% && $files[0]=~m%/MP[34]/%) {
    $copy{$files[0]}{$files[1]} = 1;
    return;
  }

  if ($files[0]=~m%/FILESBYSHA1/% && $files[1]=~m%/MP[34]/%) {
    $copy{$files[1]}{$files[0]} = 1;
    return;
  }

  warn("Can't handle: $files[0]/$files[1]");

}
