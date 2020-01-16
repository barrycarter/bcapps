#!/bin/perl

# Extract a section of a file (delimited by <tagname> and </tagname>),
# copy that section to a timestamped new file and bring up that
# timestamped file in emacs

# --section: the section to extract

require "/usr/local/lib/bclib.pl";

unless ($globopts{section}) {die "--section required";}

my($data, $fname) = cmdfile();

my($section) = $globopts{section};

# $data=~m%<$section[^>]%;

$data=~m%<$section[^>]*>(.*?)<\/$globopts{section}>%s||die("No section $section");

debug($1);

# TODO: add "list sections in file"




