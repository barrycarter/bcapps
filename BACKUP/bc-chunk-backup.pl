#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# --stop=num: stop at this chunk

# see README for file format

defaults("stop=1");

# setting $tot to $limit so first run inside loop increments chunk
# TODO: $limit should be an option
my($limit) = 50e+9;
my($tot) = $limit;
my($count);

while (<>) {
  chomp;
  my($orig) = $_;
  $count++;

  # if we've gone over limit (or first run), move on to next chunk
  if ($tot>=$limit) {
    $chunk++;
    if ($chunk > $globopts{stop}) {last;}
    debug("STARTING CHUNK: $chunk");
    $tot=0;
    close(A);
    close(B);
    open(A,">filelist$chunk.txt")||die("Can't open, $!");
    open(B,">statlist$chunk.txt")||die("Can't open, $!");
    # TODO: replace below w zpaq (which requires hardlinks, non trivial)
  }

  my(%file);

  for $i ("size", "mtime", "inode", "raw", "gid", "uid") {
    s/^(.*?)\s+//;
    $file{$i} = $1;
  }

  $file{name} = $_;

  # the hex and octal modes for regular files + symlinks
  unless ($file{raw}=~/^[89ab]/ || $file{raw}=~/^1[02]/) {
    # TODO: test that I'm not skipping I need
#    debug("SKIP: $_, $file{raw}");
    next;
  }

  $tot+= $file{size};

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$file{name}\n";
  print B "$orig\n";
}

close(A); close(B);

debug("Used $count files to meet total");

# TODO: check zpaq errors
