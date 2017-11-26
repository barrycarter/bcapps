#!/bin/perl

# given the not necessarily sorted output of "sha1sum <files>",
# replace duplicate files w/ symlinks w a special feature for feh:

# if the files have .txt files (feh annotations), uniquely combine
# these for the one image that continues to live as a non-symlink

# this is an edited copy of bc-sha1-dupes.pl 

require "/usr/local/lib/bclib.pl";

# TODO: it would be nice if I could pipe the stdin to "sort | uniq
# --all-repeated=prepend -w 40" or something and read the output in
# real time, but I'm not completely comfortable with IPC (could just
# send a file as input of course)

# TODO: the fact you have to be IN the directory where you took the
# sha1sums is ugly

# my current way is inefficient because it loads entire file

# this is ugly, but relative symlinks are seriously painful
my($cwd) = $ENV{PWD};

# if there are too many missing files, assume you are in wrong directory
my($count);

while (<>) {
  m/^(.*?)\s+(.*?)$/;
  ($sha, $file) = ($1, $2);

  # get rid of leading ./ if any
  $file=~s/^\.\///;

  # add path
  $file = "$cwd/$file";

  debug("FILE: $file");

  unless (-f $file) {
    warn("NOSUCHFILE: $file");
    if (++$count > 1000) {die "Over 1000 files not found";}
    next;
  }

  # note file's sha1 sum and how often we've seen it
  $files{$sha}{$file} = 1;
  $seen{$sha}++;
}

# NOTE: feh allows multiline annotations but not sure i can edit them

# TODO: if doing this in stages, quite possible one is already a link?

# go through sha1s ignoring non-dupes

for $i (keys %seen) {

  # ignore non dupes
  if ($seen{$i} == 1) {next;}

  my(@files) = keys %{$files{$i}};

  # the one file that will not be symlinked
  my($keeper) = shift(@files);

  # make sure its a file not a symlink
  unless (-f $keeper) {die "$keeper should be true file";}

  # which ones have text files (TODO: include keeper? or append?)
  for $j (@files) {

    # symlink unless already link

    unless (-l $j) {
      print "rm $j; ln -s $keeper $j\n";
    }

    if (-f "$j.txt") {
      debug("TEXT FILE EXISTS: $j");
    }
  }

  debug("FILES", @files);

}
