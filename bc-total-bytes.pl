#!/bin/perl

require "/usr/local/lib/bclib.pl";

# --justfiles: just print out a list of files (ie, for tar --bzip --from-files)

# --printonly: just print filenames AND parents, but dont count
# (useful to avoid "out of memory" errors)

# --size: field in which size appears (default 0)
# --name: field in which name starts (default 2)

# NOTE: name must always be last field

# file format as in BACKUP/README

# report space used by files and directories (including
# subdirectories) and number of files per directory (include
# subdirectory)

# NOTE: could've sworn I've written something very similar to this already

my(%size,%count);

defaults("size=0&name=2");

while (<>) {
  chomp;

  # ignore lines without slashes (probably just the first/last date lines)
  unless(/\//) {next;}

  my(%file);

  # the below assumes name is the last field, and thus includes spaces
  my(@arr) = split(/\s+/, $_, $globopts{name}+1);
  ($file{size},$file{name}) = ($arr[$globopts{size}],$arr[$globopts{name}]);

  # TODO: filter out dirs/etc
  if ($globopts{justfiles}) {print "$file{name}\n"; next;}

  # to save memory, print file size directly and don't hash it
  # 1 = 1 file

  # for printonly, don't print the file itself
  unless ($globopts{printonly}) {print "$file{size} 1 $file{name}\n";}

  # find all ancestor directories
  while ($file{name}=~s/\/([^\/]*?)$//){

    debug("NAME NOW: $file{name}");

    if ($globopts{printonly}) {print "$file{name}\n"; next;}

    $size{$file{name}}+=$file{size};
    $count{$file{name}}++;
  }
}

for $i (keys %size) {print "$size{$i} $count{$i} $i\n";}
