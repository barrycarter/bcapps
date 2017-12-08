#!/bin/perl

# similar to bc-tumblr-inline.pl but assumes you've done:
# grep -R src= ~/TUMBLR
# (or whatever your tumblr-backup.py TUMBLR directory is) and are
# feeding in the results

# NOTE: "grep -R src= ~/TUMBLR > allsrc.txt" is a good way to save the
# data in case a direct pipe breaks, but if allsrc.txt is IN ~/TUMBLR
# you will get an error (and possibly bad results) when grep tries to
# grep allsrc.txt itself

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/user/TUMBLR/")');

my(%seen);

while (<>) {

  # figure out what blog this came from using filename
  s/(^.*?)://;
  my($fname) = $1;
#  debug("FILENAME: $fname");

  # first thing in path that looks like a name
  unless ($fname=~s%/(\w+?)/%%) {warn("BAD BLOG: $fname"); next;}
  my($blog) = $1;
#  debug("BLOG: $blog");

  while (s/src="(.*?)"//) {

    my($src) = $1;

    # seem to be quite a few repeats, kill them here first
    if ($seen{$src}) {next;}
    $seen{$src} = 1;

    debug("SRC: $src");
  }

#  debug("GOT: $_");
}

