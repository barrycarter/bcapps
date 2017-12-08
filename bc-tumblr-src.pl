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

  chomp;

  debug("\nLINE: $_");

  # figure out what blog this came from using filename
  s/(^.*?)://;
  my($fname) = $1;
  debug("FILENAME: $fname");

  # first thing in path that looks like a name
  unless ($fname=~s%/([\w-]+?)/%%) {warn("BAD BLOG: $fname"); next;}
  my($blog) = $1;
  debug("BLOG: $blog");

  # this is probably bad in a loop
  # can maybe memoize this per blog
  unless (-d "$blog/media") {
    debug("$blog has no media subdir, creating one");
    mkdir("$blog/media");
  }

  while (s/src="(.*?)"//) {

    my($src) = $1;

    # seem to be quite a few repeats, kill them here first
    if ($seen{$src}) {debug("REP1"); next;}
    $seen{$src} = 1;

    # TODO: assuming last part of path is unique, if wrong, this fails
    my($base) = $src;
    $base=~s%^.*/%%;

    # also check if shortened form seen
    if ($seen{$base}) {debug("REP2"); next;}
    $seen{$base} = 1;

    # key test: do we have it already?

    # <h>glob is an anagram of blog</h>

    # we need the * after $base because tumblr-backup.py will add a .mp4, eg

    # this also assumes that tumblr files length means globs are unique too
    my(@glob) = glob("$blog/*/$base*");

    # <h>variable name re-use... only in Perl!</h>
    my($seen) = 0;

    # for now, just print what we dont have
    # TODO: give URL for stuff we dont have
    unless (@glob) {print "$base\n";}

    # TODO: is this too slow?
    if (@glob) {
      debug("WE HAVE: $base");
    } else {
      debug("NO $base");
    }

#    for $i ("images", "media") {
#      if (-f "$blog/$i/$src") {$seen=1; last;}
#    }

  }
}


