#!/bin/perl

# Extract a section of a file (delimited by <tagname> and </tagname>),
# copy that section to a timestamped new file and bring up that
# timestamped file in emacs

# --section: the section to extract
# --stdout: print the section to STDOUT, don't write it to file

require "/usr/local/lib/bclib.pl";

my($dir) = "/usr/local/etc/section-checklist";

unless (-d $dir) {die "$dir does not exist";}

unless ($globopts{section}) {die "--section required";}

my($data, $fname) = cmdfile();

my($section) = $globopts{section};

# $data=~m%<$section[^>]%;

$data=~m%<$section[^>]*>(.*?)<\/$globopts{section}>%s||die("No section $section");

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




