#!/bin/perl

# does what bc-mirror-server.pl does, except for
# http://pearls-before-swine-bc.wikia.com/
# (should be generalized to work w/ wikis in general)

require "/usr/local/lib/bclib.pl";

# directory where the mediawiki files are kept
$mwdir = "/usr/local/etc/metawiki/pbs/";

# the API endpoint for PBS-BC wiki
$apiep = "http://pearls-before-swine-bc.wikia.com/api.php";

# the lastmirror file for PBS-BC metawiki
my($mirfile) = "/usr/local/etc/bcmirror/metawiki/lastmirror.pbs";

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
@mirror = `find $mwdir -type f -iname '*.mw' -newer $mirfile`;

for $i (@mirror) {
  # todo: handle dry run
  debug("Writing $i to wikia");
  # the name of the page strips off the .mw
  # the .mw is a tribute to wikipediafs, I probably don't need it
  my($pagename) = $i;
  $pagename=~s/\.mw$//;
  # TODO: add comment pointing back to git project
  debug("write_wiki_page($apiep, $pagename, read_file($i), '', $wikia{user}, $wikia{pass})");
}

# assumed success here (unless dry run)
unless ($globopts{dryrun}) {
  system("mv $mirfile $mirfile.old; mv $mirfile.new $mirfile");
}
