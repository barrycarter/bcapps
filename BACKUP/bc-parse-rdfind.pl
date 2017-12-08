#!/bin/perl

# this is a oneoff program

# I tried to run rdfind as below:
# sudo rdfind -dryrun true -removeidentinode false -makesymlinks true dir1 dir2
# to free up disk space, but ran into issues. This program addresses
# those issues, which are given in comments

require "/usr/local/lib/bclib.pl";

# for permissions purposes (ugly!)
if ($>) {die("Must be root");}

# to be safe, I check the file existence and file size before
# deleting/symlinking anything; this is tedious, but I can reduce the
# number of files I consider by only looking at large files; how do I
# know a file is large without "-s"'ing it? I don't, but results.txt
# gives filesize at the time it ran, so I can use it to get a list of
# candidates that are large enough; of course, I will doublecheck
# later to make sure these files still exist and have proper size

# to make things even more efficient, results.txt.srt is generated as:
# sort -k4nr results.txt > results.txt.srt
# the program can thus abort when the file size gets too small


debug(sep_but_equal(@ARGV));

die "TESTING";

# files below this size are ignored
my($lower) = 1e+6;

open(A,"results.txt.srt")||die("Can't open results.txt, $!");

while (<A>) {

  chomp;

  # by limiting the split here, I preserve spaces in the filename
  my($duptype, $id, $depth, $size, $device, $inode, $priority, $name) =
    split(/ /, $_, 8);

  debug("NAME: $name");

  # if we've hit a file less than $lower, we assume files are sorted
  # by size, so abort
  if ($size < $lower) {last;}

  # TODO: we could record more about the file here
  # TODO: we could do file safety checks here instead of later(?)

  debug("ASSIGNING $name to size $size");

  $size{$name} = $size;
}

my($bytes);

while (<>) {

  chomp;

  # TODO: ? I could've done this w/ arrays, but ... ?
  # make sure its a symlink recommendation
  # " to " HAS to be one space because some of my filenames end in spaces
  # <h>How bad is your life going if you filenames ending in spaces?</h>

  unless (/symlink\s*(.*?) to (.*)$/) {next;}

  # using array here probably doesnt help much

  my(@f) = ($1,$2);

  for $i (@f) {

    # recsize = size as recorded by results.txt.srt above
    debug("FILE: $i, RECSIZE: $size{$i}");

    # if recorded file size less than min, skip (this covers
    # nonpositive file size, even if lower isnt set)

    if ($size{$i} <= $lower) {
      debug("RSIZE($i) <= $lower");
      next;
    }

    # TODO: should this be somewhere else?
    unless ($i=~/[ -~]/) {
      debug("FILE $i contains unprintable characters");
      next;
    }

    if ($i=~/[\"\$]/) {
      debug("FILE $i contains a quote or a dollar sign");
      next;
    }
  }


  # recorded file sizes should agree
  unless ($size{$f[0]} == $size{$f[1]}) {
    debug("Recorded file sizes differ: $_");
    next;
  }

  # my restriction: the filename itself must match (because otherwise
  # you get all sorts of weird random links)
  
  my($n1, $n2) = ($f1, $f2);
  $n1=~s%^.*/%%;
  $n2=~s%^.*/%%;

  # if either n1 or n2 is empty, warn and move on
  if ($n1=~/^\s*$/ || $n2=~/^\s*$/) {
    # this actually ignores a file whose name is " ", but I'm ok w/ that
    warn "BAD LINE: $_";
    next;
  }

  # unless names are equal move on
  unless ($n1 eq $n2) {next;}

  # do the expensive lstat tests now
  unless (sep_but_equal(@f)) {
    debug("Files fail separate but equal test, $_");
    next;
  }

  # TODO: there is no test than the file sizes are equal to the
  # recorded file sizes, but maybe there should be

  # TODO: add personal filters here re what I do and dont want to remove

  # this uses recorded file size, not actual, hmmm
  $bytes+= (-s $size{$f[0]});
  if (rand()<.01) {debug("BYTES SAVED: $bytes");}

  # TODO: decide which file to remove/symlink

  debug("OK: $_");
}

# TODO: maybe check that files in output of rdfind are actually in cur
# directory, so I'm not using a bad copy of results.txt (though it
# probably doesnt matter)

debug("TOTAL BYTES SAVED: $bytes");

=item sep_but_equal($file1, $file2)

Given two files, confirm that the files are "separate but equal" in
the sense I can remove either one and symlink it to the other. More
specifically, two files are "separate but equal" if:

  - Both files exist and have non-0 length
  - Neither is a symbolic link or other special file type[2]
  - They have different inode numbers [1]
  - They have the same size

[1] in theory, two different files could have the same inode number,
but different device numbers, but I'm ignoring that special case for
now

[2] Neither stat nor lstat tell if a file is a symlink, so I use the
"-l" test below (even "-f" thinks symlinks are real files), although
lstat gives the size of the symlink which should be a giveaway for
large files

=cut

sub sep_but_equal {

  my(@files) = @_;
  my(@stats);
  my(%used);
  
  for $i (0..$#files) {

    # TODO: is testing twice here inefficient? should I use stat(_)?

    unless (-f $files[$i]) {
      debug("$files[$i] is not a normal file or does not exist");
      return 0;
    }

    if (-l $files[$i]) {
      debug("$files[$i] is symlink");
      return 0;
    }

    %{$stats[$i]} = %{stat2hash($files[$i])};

    # inode already seen?
    if ($used{$stats[$i]{inode}}) {
      debug("$files[$i] inode is a repeat");
      return 0;
    }

    $used{$stats[$i]{inode}} = 1;

    # some tests for each file
    for $j ("size", "inode", "device") {
      if ($stats[$i]{$j} <= 0) {
	debug("$files[$i] has negative or zero $j");
	return 0;
      }
    }
  }

  unless ($stats[0]{size} == $stats[1]{size}) {
    debug("Files have different sizes");
    return 0;
  }

  return 1;

}

=item stat2hash($file)

Return the stat of $file as key/value pairs

TODO: move to main lib

TODO: in theory, could use Linux stat, which gives more info

=cut

sub stat2hash {

  my($file) = @_;
  my(%hash);

  # TODO: File::stat apparently already does this
  # what stat returns, in name form
  my(@names) = ("device", "inode", "mode", "nlink", "uid", "gid", "rdev",
		"size", "atime", "mtime", "ctime", "blksize", "blocks");

  my(@stat) = lstat($file);

  for $i (0..$#names) {$hash{$names[$i]} = $stat[$i];}

  return \%hash;
}


