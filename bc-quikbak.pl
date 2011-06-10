#!/bin/perl

# Quickly-but-efficiently backup a file so you can edit it w/o worries
# -nots: don't assume identical timestamps mean file hasn't changed

# NOTE: the backup directory contains a copy of $file, and
# $file.quikbak, a series of patches to revert it to any previous
# version

require "bclib.pl";

# where to put the backups
$etcdir="/usr/local/etc/quikbak";

for $i (@ARGV) {
  ($target,$mod) = get_target($i);

  # should I back this up? if so, where?
  unless ($target) {warn("$i ignored"); next;}

  # does target file exist? if not, copy from original and create
  # blank quikbak file

  unless (-f $target) {
    safecopy($i,$target);
    open(A,">>$target.quikbak");
    # format of quikbak file separates mods with "! $time ..."
    print A "! $mod (ORIGINAL)\n";
    close(A);
    warn("First backup for $i");
    next;
}

  # if target exists and has same timestamp as file, ignore (unless -nots)
  @st = stat($target);
  $targstamp = stardate($st[9]);

  if ($targstamp == $mod && !$globopts{nots}) {
    warn("$i $target timestamps match, ignored");
    next;
  }

  # diff current file from most recent backup
  $diff=`/usr/bin/diff -a $i $target`;
  unless ($diff) {
    # do copy over anyway, just to fix timestamp
    safecopy($i,$target);
    warn("$i hasn't changed, ignored");
    next;
  }

  # print the diff and time of backup to .quikbak file
  open(A,">>$target.quikbak")||die("Couldn't open $target.quikbak, $!");
  print A "! $mod\n$diff\n";
  close(A)||die("Couldn't close $target.quikbak, $!");

  # now that we have the diff, copy over the current version
  safecopy($i,$target);
}

# safecopy(i,j): copy i to j, make j readonly after copy, complain on error

sub safecopy {
  my($i,$j) = @_;
  # make $j rwxr--r-- so I can write to it
  chmod(0744,$j);
  # copy $i to $j
  my($res) = system("cp","-p",$i,$j);
  # die on failure
  if ($res) {die("cp $i $j FAILED, $!");}
  # make $j r--r--r--
  chmod(0444,$j);
}

# return the target (backup) file for a given file and its timestamp
# return empty list on non-fatal error

sub get_target {
  my($i) = @_;
  my(@x);
  my($aa);

  # ignore emacs droppings, non-files, and non-existent files
  if ($i=~/~$/) {warn("$i: emacs backup"); return ();}
  unless (-f $i) {warn("$i: not a file"); return();}
  unless (@x=stat($i)) {warn("$i: nostat, $!"); return();}

  # find canonical directory for file
  unless ($i=~m!/!) {$i="./$i";} # add slash if there isn't one already
  if ($i=~m!^(/.*/)!) {
    # given file via full path name
    $aa=$1;
  } elsif ($i=~m!^(.*/)!) {
    # given file in current directory
    $aa="$ENV{PWD}/$1";
  } else {
    die("Can't find dir for $i");
  }

  # create directory in backup area if not already there
  unless (-d "$etcdir/$aa") {system("/bin/mkdir", "-p" ,"$etcdir/$aa");}

  # this is the target filename
  # return it and the timestamp of the original file
  $i=~s!(.*/)(.*)$!$etcdir$aa$2!;
  return ($i,stardate($x[9]));
}
