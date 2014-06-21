#!/bin/perl

# --dir: location of directory (below /usr/local/etc/metawiki)
# --api: API endpoint of target wiki
# does what bc-mirror-server.pl does, except for
# http://pearls-before-swine-bc.wikia.com/
# (should be generalized to work w/ wikis in general)


require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
option_check(["realsies","dryrun","dir","api"]);

# TODO: subroutine for required options?
unless ($globopts{dir}&&$globopts{api}){die "$0 --dir --api both required";}

# while testing, dryrun is assumed (unless --realsies)
unless ($globopts{realsies}) {$globopts{dryrun}=1;}

# directory where the mediawiki files are kept
$mwdir = "/usr/local/etc/metawiki/$globopts{dir}/";

# the API endpoint for PBS-BC wiki

# wikia: http://pearls-before-swine-bc.wikia.com/api.php
# referata: http://pearlsbeforeswine.referata.com/w/api.php

$apiep = $globopts{api};

# the lastmirror file for PBS-BC metawiki
$mirfile = "/usr/local/etc/bcmirror/metawiki/lastmirror.$globopts{dir}";

# TODO: check to see if user really needs to "mkdir" or not
unless (-f $mirfile) {
  # dont do this for user, since they may just have wrong directory
  die("No lastmirror file, try touch -t 7001010000 $mirfile (you may need to 'mkdir -p' first)");
}

# before we mirror anything, touch new timestamp (so we'll catch files
# that change during the mirror)
system("touch $mirfile.new");

# find all files newer than last mirror in source directory
# these will all be at the top level for now
# some .mw files are symlinked to my git
@mirror = `find $mwdir -type f -follow -iname '*.mw' -newer $mirfile`;

for $i (@mirror) {
  chomp($i);
  # the name of the page strips off the .mw and path
  # the .mw is a tribute to wikipediafs, I probably don't need it
  my($pagename) = $i;
  $pagename=~s/\.mw$//;
  $pagename=~s/^.*\///;
  debug("Writing: $pagename");

  # if dry run, don't actually write page
  unless ($globopts{dryrun}) {
    # TODO: add comment pointing back to git project
    write_wiki_page($apiep, $pagename, read_file($i), '', $wikia{user}, $wikia{pass});
  }
}

# assumed success here (unless dry run)
unless ($globopts{dryrun}) {
  system("mv $mirfile $mirfile.old; mv $mirfile.new $mirfile");
}
