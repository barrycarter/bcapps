#!/bin/perl

# vark.com shutdown a while back and promised everyone a dump of their
# data; I finally got mine; this script parses the vark log into
# unapproved WP posts, similar to vark2wp.pl, but non-identical

require "/usr/local/lib/bclib.pl";

$data = read_file("/home/barrycarter/VARK-carter_barry-at-gmail_com.txt");

# split into questions (each starts with "*something*")

@qs = split(/\*(.*?)\*/s, $data);

for $i (@qs) {
  debug("I: $i");
}


