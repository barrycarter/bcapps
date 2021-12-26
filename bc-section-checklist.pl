#!/bin/perl

# Extract a section of a file (delimited by <tagname> and </tagname>
# where both tags are left-aligned), copy that section to a
# timestamped new file and bring up that timestamped file in emacs

# --section: the section to extract

# --stdout: print the section to STDOUT, don't write it to file

# --list: list sections in given file

require "/usr/local/lib/bclib.pl";

my($dir) = "/usr/local/etc/section-checklist";

unless (-d $dir) {die "$dir does not exist";}

unless ($globopts{section} || $globopts{list}) {die "--section or --list required";}

my($data, $fname) = cmdfile();

# if list requested

if ($globopts{list}) {

  # this is a terrible way to find "XML tags"

  my(%tags, %tage);

  for $i (split(/\n/, $data)) {

    # tags = start of tag, tage = end of tag

    # because we are looking for only special tags, disallow spaces

    # no forward slashes in start tab

    if ($i=~/^<([^<>\s\/]+)>\s*$/) {$tags{$1} = 1;}
    if ($i=~/^<\/([^<>\s]+)>\s*$/) {$tage{$1} = 1;}

  }

  # anything that has both, print it out

  for $j (sort keys %tags) {
    if ($tage{$j}) {print "$j\n";}
  }

#  while ($data=~s%<([^<>]*?)>(.*?)<\/\1>%%s) {
#    debug(length($data));
#    print "$1 ",length($2), "\n";
#  }

exit;
}

my($section) = $globopts{section};

# $data=~m%<$section[^>]%;

# 14 Oct 2021: if section has any other key/vals in header, there must
# be at least one space between the section name and those key/vals
# (caused glitch on 14 Oct 2021)

# TODO: had to remove key/val section entirely, fix

$data=~m%<$section>(.*?)<\/$globopts{section}>%s||die("No section $section");

my($list) = $1;

if ($globopts{stdout}) {
  print $list;
  exit(0);
}

my($stardate) = stardate(time());

my($fname) = "$section-$stardate.txt";

write_file($list, "$dir/$fname");

system("emacs $dir/$fname &");

# debug($fname);

# TODO: add "list sections in file"




