#!/bin/perl

# breaking out the subroutines in pbs-meta-pbs.pl to clean them up a bit

# PBS is "test case" but this "should" work w/ anything

require "/usr/local/lib/bclib.pl";

my($metadir) = "/home/barrycarter/BCGIT/METAWIKI";

for $i (`cat $metadir/pbs.txt $metadir/pbs-cl.txt | egrep -v '^#|^\$'`) {
  # TODO: multirefs!
  # below allows for multiple dates
  unless ($i=~/^([\d\-,]+)\s+(.*)$/) {next;}
  debug("I: $i");
  parse_semantic($1, $2);
}

=item parse_semantic($dates, $string)

Given $dates and a string like "[[x::y]]" (with several
variants), return semantic triples (including a 4th 'extra' field to
represent Semantic Internal Objects) and a string.

$string may have nested "[[x::y]]" constructions ($dates, however, may not)

Plus signs like [[x+y::...]] are treated like [[x::...]], [[y::...]]
and return a list of triples and strings

Details:

[[x::y]] - return triple [$dates,x,y] and string [[y]]
[[x::y|z]] return triple [$dates,x,y] and string [[y|z]]
[[x::y::z]] - return triple [$x,$y,$z] and string [[z]]
[[x::y::z|w]] - return triple [$x,$y,$z] and string [[z|w]]

In ALL cases, return "source=$dates" as the 4th parameter

=cut

sub parse_semantic {
  my($dates, $string) = @_;

  # list of lists I will need to handle a+b+c and so on
  my(@lol);

  # parse the dates and put them in the same "+" format I use for other lists
  $dates = join("+",parse_date_list($dates));

  # temporarily replace colonless [[foo]] to avoid parsing issues
  $string=~s/\[\[([^:\[\]]+)\]\]/\001$1\002/g;
  debug("POST: $string");

  # parse anything with double colons (\001 is a marker to replace later)
#  while ($string=~s/\[\[([^\[\]]+?::[\[\]]+?)\]\]/\003/) {
  while ($string=~s/\[\[([^\[\]]+?::[^\[\]]+?)\]\]/\003/) {
    debug("STRING TOP: $string");
    # determine the source, relation, and target
    my(@l) = split(/::/, $1);
    # if only two long, date is the implicit first parameter
    if (scalar @l == 2) {unshift(@l, $dates);}
    debug("PRESPLIT: ".join(", ",@l));

    # each element of @l can have +s
    for $i (split(/\+/, $l[0])) {
      for $j (split(/\+/, $l[1])) {
	for $k (split(/\+/, $l[2])) {
	  # restore brackets to $k
	  $k=~s/\001/[[/g;
	  $k=~s/\002/]]/g;
	  debug("TRIP: $i,$j,$k");
	  # the last element is the only one that can have "|"
#	  $k=~s/^.*?\|//;
	  # replace the \003 we created earlier
	  # TODO: this won't work if $k has plusses, undefined behavior
	  debug("ALPHA: $string vs $k");
	  $string=~s/\003/[[$k]]/;
	  debug("BETA: $string vs $k");
	  # and the brackets
	  $string=~s/\001/[/g;
	  $string=~s/\002/]/g;
	  debug("STRING BOT (IN $i/$j/$k): $string");
	}
	debug("STRING BOT (end $i/$j): $string");
      }
      debug("STRING BOT (end $i): $string");
    }
    debug("STRING BOT (end all): $string");
  }
  debug("STRING (after while): $string");
}

=item parse_date_list($string)

TODO: move this to bclib

Given a string like "2013-04-17-2013-04-19, 2013-04-22, 2013-04-23,
2013-04-30, 2013-05-01, 2013-05-06-2013-05-08, 2013-05-13-2013-05-15,
2013-05-20-2013-05-22, 2013-05-24, 2013-05-29", return a list of dates.

=cut

sub parse_date_list {
  my($datelist) = @_;
  my(@ret);

  for $i (split(/\,/,$datelist)) {
    # if datelist is date range (2002-06-03-2002-06-07), parse further
    if ($i=~/^(\d{4}-\d{2}-\d{2})\-(\d{4}-\d{2}-\d{2})$/) {
      for $j (str2time($1)/86400..str2time($2)/86400) {
	push(@ret, strftime("%Y-%m-%d", gmtime($j*86400)));
      }
    } else {
      push(@ret, $i);
    }
  }
  return @ret;
}

