#!/bin/perl

# Mirrors files to a wiki, using chattr -v to keep track of which
# files have been mirrored. This lets me mirror a small collection of
# files without having to use a global timestamp like bc-mirror-mw.pl
# does

# --api: API endpoint of target wiki (required)

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
defaults("dryrun=1");

# TODO: subroutine for required options?
unless ($apiep = $globopts{api}){die "$0 --api required";}

# look at files on command line
for $pagename (@ARGV) {

  # the name of the page strips off the .mw and path
  # the .mw is a tribute to wikipediafs, I probably don't need it
  unless ($pagename=~s/\.mw$//) {
    warn "BAD FILE: $pagename, skipping";
    next;
  }

  # TODO: this is insanely inefficient, do a global lsattr or stat
  my($ver) = `lsattr -v \"$pagename.mw\"`;
  $ver=~s/\s+.*$//s;
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat("$pagename.mw");

  # already mirrored
  if ($ver eq $mtime) {next;}

  debug("Writing: $pagename");

  # if dry run, continue
  if ($globopts{dryrun}) {next;}

  # TODO: add comment pointing back to git project
  # TODO: check return value
  my($result) = write_wiki_page($apiep, $pagename, read_file("$pagename.mw"), '', $wikia{user}, $wikia{pass});
  my($out, $err, $res) = cache_command("chattr -v $mtime \"$pagename.mw\"", "nocache=1")

}
