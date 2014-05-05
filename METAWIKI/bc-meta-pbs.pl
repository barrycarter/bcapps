#!/bin/perl

# A much reduced attempt at a metawiki that uses only a fixed number
# of well-known relations, each of which I know how to handle. Hope to
# generalize this into an all-purposes meta wiki at some point.

# Test case for this wiki is Pearls Before Swine comic strip

require "/usr/local/lib/bclib.pl";

# shortcuts just to make code look nicer
# character class excluding colons and brackets
$cc1 = "[^\\[\\]:]";
debug("CC1: $cc1");

my($data) = read_file("/home/barrycarter/BCGIT/METAWIKI/pbs.txt");
$data=~s%^.*?<data>(.*?)</data>.*$%$1%s;

for $i (split(/\n/, $data)) {
  # split line into source page and then body
  $i=~/^(.*?)\s+(.*)$/;
  my($source, $body) = ($1,$2);
  parse_text($source,$body);
}

sub parse_text {
  my($source,$body) = @_;
  # return triplets
  my(@trip) = ();

  # keep things like [[Pig]] as is, but tokenize so they won't bother us
  $body=~s/\[\[

  debug("BODY: $body");

  # parse the body
#  while ($body=~s/\[\[([^\[\]:]*?)::(.*?)\]\]//) {
  while ($body=~s/\[\[($cc1*?)::($cc1*?)\]\]//) {
    debug("CHOMP: $1,$2");
  }
}

