#!/bin/perl

# this is a oneoff program

# I tried to run rdfind as below:
# sudo rdfind -dryrun true -removeidentinode false -makesymlinks true dir1 dir2
# to free up disk space, but ran into issues. This program addresses
# those issues, which are given in comments

# to run: `$0 < output_of_above > commands_to_run.sh` BUT!!!
# `tac output_of_above | $0 > commands_to_run.sh may work` better
# because bigger files may show up first

# the output is a shell script you should check and run (probably
# redirect output just to catch mistakes)

# See which files are biggest remaining duplicates:
# tac fix-everything-again.sh | sudo ~user/BCGIT/BACKUP/bc-parse-rdfind.pl
# --debug | & grep -A 2 '^FILES' | & less

require "/usr/local/lib/bclib.pl";

# I have privately named drives
require "/home/user/bc-private.pl";

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


# files below this size are ignored
# TODO: this should almost definitely be an option
my($lower) = 1e+6;

# warn "Temporarily looking at 100K+ files";

# warn("Temproarily lowering LOWER for special case");
# cutting to bone?
# $lower = 10000;

open(A,"results.txt.srt")||die("Can't open results.txt.srt, $!");

while (<A>) {

  chomp;

  # by limiting the split here, I preserve spaces in the filename
  my($duptype, $id, $depth, $size, $device, $inode, $priority, $name) =
    split(/ /, $_, 8);

#  debug("SIZE: $size");

#  debug("NAME: $name");

  # if we've hit a file less than $lower, we assume files are sorted
  # by size, so abort
  if ($size < $lower) {last;}

  # TODO: we could record more about the file here
  # TODO: we could do file safety checks here instead of later(?)

#  debug("ASSIGNING $name to size $size");

  $size{$name} = $size;
}

my($bytes);

debug("PHASE TWO INITIATED");

# TODO: warn user if no STDIN detected for 5 seconds or something
# print "This program expects a filename argument or a STDIN\n";

while (<>) {

  chomp;

  # TODO: ? I could've done this w/ arrays, but ... ?
  # make sure its a symlink recommendation
  # " to " HAS to be one space because some of my filenames end in spaces
  # <h>How bad is your life going if you filenames ending in spaces?</h>

  unless (/symlink\s*(.*?) to (.*)$/) {next;}

  # using array here probably doesnt help much

  my(@f) = ($1,$2);

  # <h>"my bad".. get it?</h>
  my($bad) = 0;

  for $i (@f) {

    # recsize = size as recorded by results.txt.srt above
#    debug("FILE: $i, RECSIZE: $size{$i}");

    # if recorded file size less than min, skip (this covers
    # nonpositive file size, even if lower isnt set)

    if ($size{$i} <= $lower) {
#      debug("RSIZE($i) == $size{$i} <= $lower");
      $bad=1; last;
    }

    # TODO: should this be somewhere else?
    unless ($i=~/[ -~]/) {
      debug("FILE $i contains unprintable characters"); $bad=1; last;
      next;
    }

    if ($i=~/[\"\$]/) {
      debug("FILE $i contains a quote or a dollar sign"); $bad=1; last;
      next;
    }
  }

  if ($bad) {next;}

  # recorded file sizes should agree
  unless ($size{$f[0]} == $size{$f[1]}) {
    debug("Recorded file sizes differ: $_");
    next;
  }

  # my restriction: the filename itself must match (because otherwise
  # you get all sorts of weird random links)
  
  my($n1, $n2) = @f;
  $n1=~s%^.*/%%;
  $n2=~s%^.*/%%;

  # if either n1 or n2 is empty, warn and move on
  if ($n1=~/^\s*$/ || $n2=~/^\s*$/) {
    # this actually ignores a file whose name is " ", but I'm ok w/ that
    warn "BAD LINE: $_";
    next;
  }

  # unless names are equal move on
  warn "EQUAL NAME TEST TURNED OFF!";
#  unless ($n1 eq $n2) {next;}

  # do the expensive lstat tests now
  unless (sep_but_equal(@f)) {
    debug("Files fail separate but equal test, $_");
    next;
  }

  # TODO: there is no test than the file sizes are equal to the
  # recorded file sizes, but maybe there should be

  # TODO: add personal filters here re what I do and dont want to remove
  choose_file(@f);

  # this uses recorded file size, not actual, hmmm
  $bytes+= $size{$f[0]};
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

  debug("LSTAT($file)");

  # TODO: File::stat apparently already does this
  # what stat returns, in name form
  my(@names) = ("device", "inode", "mode", "nlink", "uid", "gid", "rdev",
		"size", "atime", "mtime", "ctime", "blksize", "blocks");

  my(@stat) = lstat($file);

  for $i (0..$#names) {$hash{$names[$i]} = $stat[$i];}

  return \%hash;
}

# this subroutine changes every run (TODO: argh!) and decides:
# 1) which of the two files I want to keep
# 2) whether to symlink the other file or rm it entirely

sub choose_file {
  my(@files) = @_;

  debug("FILES", @files);

  # remove the copy NOT in /SPICE/GAIA/

  for $i (0,1) {
    if ($files[$i]=~m%/SPICE/GAIA/GaiaSource% &&
	!($files[1-$i]=~m%/SPICE/GAIA/GaiaSource%)) {
      print qq%sudo rm "$files[1-$i]";\necho "keeping $files[$i]"\n%;
    }
  }

return;

  # remove the copy on the archived version of an old drive

  for $i (0,1) {
    if ($files[$i]=~m%/$private{cdrive}/% && 
    !($files[1-$i]=~m%/$private{cdrive}/%)) {
      print qq%sudo rm "$files[$i]";\necho "keeping $files[1-$i]"\n%;
    }
  }

return;

  # remove the copy on kemptown if only one is on kemptown

  for $i (0,1) {
    if ($files[$i]=~m%/kemptown/% && !($files[1-$i]=~m%/kemptown/%)) {
      print qq%sudo rm "$files[$i]";\necho "keeping $files[1-$i]"\n%;
    }
  }

return;

  # DVD trumps LIB2KINDLE w symlink

  for $i (0,1) {
    if  ($files[$i]=~m%^//mnt/extdrive5/$private{edrive}/LIB2KINDLE/% &&
	 $files[1-$i]=~m%^//mnt/lobos/DVD/%) {
      print qq%sudo rm "$files[$i]"\n%;
      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return; 

  # nothing in a /TORRENTS/ dir is canonical

  for $i (0,1) {
    if  ($files[$i]=~m%/TORRENTS/% &&
	 !($files[1-$i]=~m%/TORRENTS/%)) {
      print qq%sudo rm "$files[$i]"\n%;
#      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return;

  # canonical SCANS dir beats old SCANS dir
  
  for $i (0,1) {
    if  ($files[$i]=~m%^//mnt/extdrive5/$private{edrive}/SCANS/% &&
	 $files[1-$i]=~m%^//mnt/villa/user/SCANS/%) {
      print qq%sudo rm "$files[$i]"\n%;
#      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return;

  # MP4 vs DVD, resolve in favor of DVD

  for $i (0,1) {
    if  ($files[$i]=~m%^//mnt/extdrive5/$private{edrive}/MP4/% &&
	 $files[1-$i]=~m%^//mnt/lobos/DVD/%) {
      print qq%sudo rm "$files[$i]"\n%;
      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return; 

  # if one is in the correct WEATHER directory and other is in bad
  # /data dir, remove the /data version

  # note these conditions are mutually exclusive
  for $i (0,1) {
    if  ($files[$i]=~m%^//mnt/extdrive5/$private{edrive}/WEATHER/% &&
	 $files[1-$i]=~m%^//mnt/lobos/extdrive2/data/%) {
      print qq%sudo rm "$files[1-$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }

return;

  # /MAXTOR/ is an ancient drive; anything not on it wins
  for $i (0,1) {
    if  ($files[$i]=~m%/MAXTOR/% &&
	 !($files[1-$i]=~m%/MAXTOR/%)) {
      print qq%sudo rm "$files[$i]"\n%;
      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return; 

  # if there's a copy in UNGPG and DVD, the latter wins

  for $i (0,1) {
    if ($files[$i]=~m%/mnt/lobos/DVD/% && 
	$files[1-$i]=~m%/UNGPG/% &&
	!($files[1-$i]=~m%/DVD/%)) {
      print qq%sudo rm "$files[1-$i]"\n%;
      print qq%sudo ln -s "$files[$i]" "$files[1-$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }

return;

  # if one is in known old dir and other isnt, delete the old version

  for $i (0,1) {
    if  ($files[$i]=~m%/20140131.on.$private{pdrive}/% &&
	 !($files[1-$i]=~m%/20140131.on.$private{pdrive}/%)) {
      print qq%sudo rm "$files[$i]"\n%;
#      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return;

  # if both are in tumblr, just link one to other
  # the 100K limit will prevent trivial linkages
  # TODO: consider an even lower limit for tumblr
  # note there is no loop here

  # also, neither file can be a .txt file OR be in /OLD/

  # some files are references as //mnt/villa/... grumble
  if (
      $files[0]=~m%^/+mnt/villa/user/TUMBLR/% &&
      $files[1]=~m%^/+mnt/villa/user/TUMBLR/% &&
      !($files[0]=~m%(/OLD/|\.txt)%) &&
      !($files[1]=~m%(/OLD/|\.txt)%)
     ) {
      print qq%sudo rm "$files[0]"\n%;
      print qq%sudo ln -s "$files[1]" "$files[0]"\n%;
      print qq%echo keeping "$files[1]"\n%;
    }

return;


  # if one copy's in //mnt/lobos/extdrive2/mysql/ and the other's not,
  # nuke the one in //mnt/lobos/extdrive2/mysql/ (which I no longer
  # use)

  for $i (0,1) {
    if  (($files[$i]=~m%/mnt/lobos/extdrive2/mysql/%) && 
	 !($files[1-$i]=~m%/mnt/lobos/extdrive2/mysql/%)) {
      print qq%sudo rm "$files[$i]"\n%;
#      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return;

  # if one copy's in /ISO/ and the other's not, nuke the one that's not

  for $i (0,1) {
    if  (($files[$i]=~m%/ISO/%) && !($files[1-$i]=~m%/ISO/%)) {
      print qq%sudo rm "$files[1-$i]"\n%;
#      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }


return;

  # if one copy's in FROMBRIGHTON + the other isn't, the other is canon

  for $i (0,1) {
    # TODO: could probably combine these somehow
    if  (($files[$i]=~m%/FROMBRIGHTON/%) && !($files[1-$i]=~m%/FROMBRIGHTON/%)) {
      print qq%sudo rm "$files[$i]"\n%;
      print qq%sudo ln -s "$files[1-$i]" "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return;

  # if there's a copy in UNGPG and FILESBYSHA1, the latter wins

  for $i (0,1) {
    if ($files[$i]=~m%/mnt/lobos/FILESBYSHA1/% && 
	$files[1-$i]=~m%/UNGPG/% &&
	!($files[1-$i]=~m%/FILESBYSHA1/%)) {
      print qq%sudo rm "$files[1-$i]"\n%;
      print qq%sudo ln -s "$files[$i]" "$files[1-$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }



return;

  # /mnt/villa/user/Downloads is the canonical downloads directory; if
  # another file is in A download dir (but not this one) and there's a
  # copy in the canonical version, delete the noncanon

  for $i (0,1) {
    if ($files[$i]=~m%/mnt/villa/user/Downloads/% && 
	!($files[1-$i]=~m%/mnt/villa/user/Downloads/%) &&
       $files[1-$i]=~m%/Downloads?%) {
      print qq%sudo rm "$files[1-$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }


return;

  # after making /DVD/ canonical, I can run this step:
  # if one is in MP4 and the other isnt, toast the one that isnt

  for $i (0,1) {
    if ($files[$i]=~m%/MP4/% && !($files[1-$i]=~m%/MP4/%) ) {
      print qq%sudo rm "$files[1-$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }


return;

  # if I have two files both in my books dir (LIB2KINDLE, legacy
  # name), and one is in a single letter subdir, remove that one

  for $i (0,1) {
    # both must be in lib2 kindle
    if ( $files[$i]=~m%/LIB2KINDLE/% && $files[1-$i]=~m%/LIB2KINDLE/% &&
	 $files[$i]=~m%/[A-Z]/% && !($files[1-$i]=~m%/[A-Z]/%) ) {
      print qq%sudo rm "$files[$i]"\n%;
      print qq%echo keeping "$files[1-$i]"\n%;
    }
  }

return; 

  # if one copy on DVD restored files, the other not, keep the DVD
  # version, symlink the other (not sure this is good idea, maybe
  # backwards would be better?)

  # this is slightly less inefficient but still stupid
  for $i (0,1) {
    # TODO: could probably combine these somehow
    if  (($files[$i]=~m%/DVD/%) && !($files[1-$i]=~m%/DVD/%)) {
      print qq%sudo rm "$files[1-$i]"\n%;
      print qq%sudo ln -s "$files[$i]" "$files[1-$i]"\n%;
      print qq%echo keeping "$files[$i]"\n%;
    }
  }


return;

  # if one copy is an /MP4/ dir and the other isn't, delete the other
  if ($files[0]=~m%/MP4/% && !($files[1]=~m%/MP4/%)) {
    print qq%sudo rm "$files[1]";\necho "keeping $files[0]"\n%;
  }

  if ($files[1]=~m%/MP4/% && !($files[0]=~m%/MP4/%)) {
    print qq%sudo rm "$files[0]";\necho "keeping $files[1]"\n%;
  }

return;

  # remove the copy on kemptown if only one is on kemptown
  if ($files[0]=~m%/kemptown/% && !($files[1]=~m%/kemptown/%)) {
    print qq%sudo rm "$files[0]";\necho "keeping $files[1]"\n%;
  }

  if ($files[1]=~m%/kemptown/% && !($files[0]=~m%/kemptown/%)) {
    print qq%sudo rm "$files[1]";\necho "keeping $files[0]"\n%;
  }

return;

  # if one is in a categorized subdir and the other isn't, kill the
  # uncategorized one

  for $i ("MUSIC", "WLIIA", "GAMESHOWS", "BIGBROTHER") {

    if ($files[0]=~m%/$i/% && !($files[1]=~m%/$i/%)) {
    print qq%sudo rm "$files[1]";\necho "keeping $files[0]"\n%;
  }
    
    if ($files[1]=~m%/$i/% && !($files[0]=~m%/$i/%)) {
    print qq%sudo rm "$files[0]";\necho "keeping $files[1]"\n%;
  }
    
  }


return;

  # special case-- if one has a dir path ending in 2 and the other
  # doesn't, kill the 2 version

  if ($files[0]=~m%2/% && !($files[1]=~m%2/%)) {
    print qq%sudo rm "$files[0]";\necho "keeping $files[1]"\n%;
  }


  if ($files[1]=~m%2/% && !($files[0]=~m%2/%)) {
    print qq%sudo rm "$files[1]";\necho "keeping $files[0]"\n%;
  }



return;

  # if one has sdrive in path and one doesn't, kill the one that does
  if ($files[0]=~/$private{sdrive}/ && !($files[1]=~/$private{sdrive}/)) {
    print qq%sudo rm "$files[0]";\necho "keeping $files[1]"\n%;
  }


  if ($files[1]=~/$private{sdrive}/ && !($files[0]=~/$private{sdrive}/)) {
    print qq%sudo rm "$files[1]";\necho "keeping $files[0]"\n%;
  }

return; 

  # remove (don't link) the copy on kemptown if only one is on kemptown
  if ($files[0]=~m%/kemptown/% && !($files[1]=~m%/kemptown/%)) {
    print qq%sudo rm "$files[0]";\necho "keeping $files[1]"\n%;
  }

  if ($files[1]=~m%/kemptown/% && !($files[0]=~m%/kemptown/%)) {
    print qq%sudo rm "$files[1]";\necho "keeping $files[0]"\n%;
  }

return;


  die "TESTING";

  # keep the file in FILESBYSHA1 assuming the other copy isn't
  if ($files[0]=~m%/FILESBYSHA1/% && !($files[1]=~m%/FILESBYSHA1/%)) {
    print qq%sudo rm "$files[1]"; sudo ln -s "$files[0]" "$files[1]"\n%;
  }

  if ($files[1]=~m%/FILESBYSHA1/% && !($files[0]=~m%/FILESBYSHA1/%)) {
    print qq%sudo rm "$files[0]"; sudo ln -s "$files[1]" "$files[0]"\n%;
  }

return;

  die "TESTING"; 

  # if one is on bdrive other on sdrive, rm the one on bdrive

  if ($files[0]=~m%/$private{bdrive}/% && $files[1]=~m%/$private{sdrive}/%) {
    print "rm \"$files[0]\"\n";
    return;
  }

  if ($files[1]=~m%/$private{bdrive}/% && $files[0]=~m%/$private{sdrive}/%) {
    print "rm \"$files[1]\"\n";
    return;
  }

  # neither condition matches, delete nothing (for now)
  return;

  # if we reach this point, badness!
  die "TESTING";

  # very dicey here, will look at results by hand
  # this is filename length
  # theory: longer filenames = better categorized
  if (length($files[0]) > length($files[1])) {
    print qq%sudo rm "$files[1]"\necho "keeping $files[0]"\n%;
  } else {
    print qq%sudo rm "$files[0]"\necho "keeping $files[1]"\n%;
  }
}
