#!/bin/perl

# breaking out the subroutines in pbs-meta-pbs.pl to clean them up a bit

# PBS is "test case" but this "should" work w/ anything

require "/usr/local/lib/bclib.pl";

my($metadir) = "/home/barrycarter/BCGIT/METAWIKI";

# debug(unfold(parse_semantic("2003-12-14", "[[character::Whale 20031214 (whale)+[[deaths::Skippy (seal)]]]] [[Whale 20031214 (whale)+Whale::notes::Assuming the whales from [[2003-12-14]] and [[2005-12-13]] are different]]")));

# debug(unfold(parse_semantic("2003-12-14-2004-01-14", "[[character::Bob+[[Bob::cousin::Lou]]]]")));

# die "TESTING";

my(@triples);
for $i (`cat $metadir/pbs.txt $metadir/pbs-cl.txt | egrep -v '^#|^\$'`) {
  # TODO: multirefs!
  # below allows for multiple dates
  unless ($i=~/^([\d\-,]+)\s+(.*)$/) {next;}
  push(@triples, parse_semantic($1, $2));
}

# once again excessively terse
  open(A,"|tee /tmp/triples2.txt|sqlite3 /usr/local/etc/metawiki/pbs/pbs-triples.db 1>/tmp/pbs2-myout.txt 2>/tmp/pbs2-myerr.txt");
  # open(A,">/tmp/mysql.txt");
  print A << "MARK";
DROP TABLE IF EXISTS triples;
CREATE TABLE triples (source, k, target, datasource);
CREATE INDEX i1 ON triples(source);
CREATE INDEX i2 ON triples(k);
CREATE INDEX i3 ON triples(target);
-- prevent duplicates, which lets me be sloppy w cleanup queries
CREATE UNIQUE INDEX i4 ON triples(source,k,target);
BEGIN;
MARK
;

for $i (@triples) {
  for $j (@$i) {$j=~s/\'/&\#39;/g; $j="'$j'";}
  print A "INSERT OR IGNORE INTO triples VALUES (",join(", ",@$i),");\n";
}

print A "COMMIT;\n";
close(A);

=item parse_semantic($dates, $string)

Given $dates and a string like "[[x::y]]" (with several
variants), return semantic triples (including a 4th 'extra' field to
represent Semantic Internal Objects) and a string.

$string may have nested "[[x::y]]" constructions ($dates, however, may not)

Plus signs like [[x+y::...]] are treated like [[x::...]], [[y::...]]
and return a list of triples and strings

Details:

[[x::y]] - return triple [$dates,x,y] and string [[y]]
[[x::y::z]] - return triple [$x,$y,$z] and string [[z]]

In ALL cases, return "source=$dates" as the 4th parameter

NOTE: Alternation (the value of y or z being "foo|bar") is handled
automatically

TODO: if last parameter has plusses, it cannot be used by other triples

=cut

sub parse_semantic {
  my($dates, $string) = @_;
  my(@lol); # the return value

  # parse the dates and put them in the same "+" format I use for other lists
  # hash lets me check for non-date annotations
  my(@dates) = parse_date_list($dates);
  my(%dates) = list2hash(@dates);
  $dates = join("+",@dates);

  # temporarily replace colonless [[foo]] to avoid parsing issues
  $string=~s/\[\[([^:\[\]]+)\]\]/\001$1\002/g;
#  debug("ALPHA: $string");

  # parse anything with double colons (\001 is a marker to replace later)
  while ($string=~s/\[\[([^\[\]]+?::[^\[\]]+?)\]\]/\003/) {
    # determine the source, relation, and target
    my(@l) = split(/::/, $1);
    # if only two long, date is the implicit first parameter
    if (scalar @l == 2) {unshift(@l, $dates);}

#    debug("BETA",@l);
    # each element of @l can have +s
    for $i (split(/\+/, $l[0])) {
      for $j (split(/\+/, $l[1])) {
	for $k (split(/\+/, $l[2])) {
	  # multiple dates for a non-date annotation (non-self-anno)
	  if (!$dates{$i} && scalar(@dates)>1) {
	    warn("MULTIPLY SOURCED NON-DATE ANNO: $i/$j/$k/$dates");
	  }
	  debug("TRIPLE: $i/$j/$k/$dates");
	  # restore thing we changed earlier, but wo brackets
#	  debug("GAMMA: $string");
	  $string=~s/\003/$k/;
#	  debug("DELTA: $string");
	  # restore brackets to $k
	  $k=~s/\001/[[/g;
	  $k=~s/\002/]]/g;
	  # if $i is itself a date, no need to add dates
	  if ($i=~/^\d{4}\-\d{2}\-\d{2}$/) {
	    push(@lol, [$i,$j,$k,"SELF"]);
	  } else {
	    push(@lol, [$i,$j,$k,$dates]);
	  }
	  # TODO: this won't work if $k has plusses, undefined behavior
	}
      }
    }
  }
  return @lol;
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
