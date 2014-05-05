#!/bin/perl

# A much reduced attempt at a metawiki that uses only a fixed number
# of well-known relations, each of which I know how to handle. Hope to
# generalize this into an all-purposes meta wiki at some point.

# Test case for this wiki is Pearls Before Swine comic strip

require "/usr/local/lib/bclib.pl";

# shortcuts just to make code look nicer
# character class excluding colons and brackets
$cc = "[^\\[\\]:]";
# double left and right bracket
$dlb = "\\[\\[";
$drb = "\\]\\]";
debug("CC1: $cc,$dlb,$drb");

my($data) = read_file("/home/barrycarter/BCGIT/METAWIKI/pbs.txt");
$data=~s%^.*?<data>(.*?)</data>.*$%$1%s;

for $i (split(/\n/, $data)) {
  # ignore blanks and comments
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # split line into source page and then body
  $i=~/^(.*?)\s+(.*)$/;
  my($source, $body) = ($1,$2);
  debug("LINE: $i");
  parse_text($source,$body);
}

sub parse_text {
  my($source,$body) = @_;
  # return triplets
  my(@trip) = ();

  # keep things like [[Pig]] as is, but tokenize so they won't bother us
  $body=~s/$dlb($cc+)$drb/\001$1\002/sg;
  debug("BODY: $body");

  # parse the body
#  while ($body=~s/\[\[([^\[\]:]*?)::(.*?)\]\]//) {
  while ($body=~s/$dlb($cc*?)::($cc*?)$drb//) {
    debug("CHOMP: $1,$2");
  }
}

