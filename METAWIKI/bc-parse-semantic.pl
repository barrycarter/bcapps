#!/bin/perl

# breaking out the subroutines in pbs-meta-pbs.pl to clean them up a bit

# PBS is "test case" but this "should" work w/ anything

require "/usr/local/lib/bclib.pl";

my($metadir) = "/home/barrycarter/BCGIT/METAWIKI";

# debug(unfold(parse_semantic("2003-12-14", "[[character::Whale 20031214 (whale)+[[deaths::Skippy (seal)]]]] [[Whale 20031214 (whale)+Whale::notes::Assuming the whales from [[2003-12-14]] and [[2005-12-13]] are different]]")));

# debug(unfold(parse_semantic("2003-12-14-2004-01-14", "[[character::Bob+[[Bob::cousin::Lou]]]]")));

# die "TESTING";

# load meta data (TODO: this is cheating, only one section so far)
for $i (`egrep -v '^<|^#|^\$' $metadir/pbs-meta.txt`) {
  chomp($i);
  my(@data) = split(/\,\s*/, $i);
  $meta{$data[0]} = [@data];
  unless (scalar @data == 4) {warn "LINE HAS !=4 elts: $i";}
}

my(%triples);
my(%queries);

# imagehashes
for $i (split(/\n/, read_file("largeimagelinks.txt"))) {
  $i=~s/^(.*?)\s+.*?\/([0-9a-f]+)\?.*$//;
  my($strip, $hash) = ($1, $2);
  $triples{$strip}{hash}{$hash}{largeimagelinks} = 1;
  $triples{$strip}{class}{strip}{largeimagelinks} = 1;
}

for $i (`cat $metadir/pbs.txt $metadir/pbs-cl.txt | egrep -v '^#|^\$'`) {
  # TODO: multirefs!
  # below allows for multiple dates
  unless ($i=~/^([\d\-,]+)\s+(.*)$/) {next;}

  # create hash from triples
  for $j (parse_semantic($1, $2)) {
    map(s/\'/&\#39;/g, @$j);
    my($source, $k, $target, $datasource) = @$j;
    # the hash of triples
    $triples{$source}{$k}{$target}{$datasource} = 1;

    # determine relation type
    unless ($meta{$k}) {warn "NO MAPPING FOR: $k"; next;}
    my($for, $rev, $stype, $ttype) = @{$meta{$k}};

    # classes for source and target...
    $triples{$source}{class}{$stype}{RELATION} = 1;
    $triples{$target}{class}{$ttype}{RELATION} = 1;

    # for character to character relations...
    if ($stype eq "character" && $ttype eq "character") {

      # delete the original relation (we'll never use it)
      delete $triples{$source}{$k}{$target}{$datasource};

      # create this as a 2 directional relation for both characters
      $triples{$source}{relative}{"$target ($for)"} = 1;
      $triples{$target}{relative}{"$source ($rev)"} = 1;

      # both characters are considered to "appear in" this strip
      $triples{$datasource}{character}{$source} = 1;
      $triples{$datasource}{character}{$target} = 1;

      next;
    }

    # if either one is a character... (do this and keep going)
    if ($stype eq "character") {$triples{$datasource}{character}{$source} = 1;}
    if ($ttype eq "character") {$triples{$datasource}{character}{$target} = 1;}

    # for aliases, canonize
    if ($k eq "aka") {
      # queries to normalize source/target
      my($queries) = << "MARK";
UPDATE OR IGNORE triples SET source='$source' WHERE source='$target'
AND NOT (k='class' AND target='alias');

DELETE FROM triples WHERE source='$target'
 AND NOT (k='class' AND target='alias');

UPDATE OR IGNORE
 triples SET target='$source' WHERE target='$target' AND k NOT IN ('aka');

DELETE FROM triples WHERE target='$target' AND k NOT IN ('aka');
MARK
;
      $queries{$queries} = 1;
      next;
    }

  }
}

# "string" and "*" are useless types
delete $triples{string};
delete $triples{"*"};

# once again excessively terse
  open(A,"|tee /tmp/triples2.txt|sqlite3 /usr/local/etc/metawiki/pbs/pbs-triples.db 1>/tmp/pbs2-myout.txt 2>/tmp/pbs2-myerr.txt");
  # open(A,">/tmp/mysql.txt");
  print A << "MARK";
DROP TABLE IF EXISTS triples;
CREATE TABLE triples (source, k, target, datasource);
CREATE INDEX i1 ON triples(source);
CREATE INDEX i2 ON triples(k);
CREATE INDEX i3 ON triples(target);
CREATE INDEX i4 ON triples(datasource);
-- prevent duplicates, which lets me be sloppy w cleanup queries
CREATE UNIQUE INDEX i5 ON triples(source,k,target,datasource);
BEGIN;
MARK
;

for $i (sort keys %triples) {
  for $j (sort keys %{$triples{$i}}) {
    for $k (sort keys %{$triples{$i}{$j}}) {
      for $l (sort keys %{$triples{$i}{$j}{$k}}) {
	print A "INSERT OR IGNORE INTO triples VALUES('$i','$j','$k','$l');\n";
      }
    }
  }
}

# commit queries above and start new batch
print A "COMMIT;\nBEGIN;";

# the queries from the parsing
for $i (keys %queries) {
  print A $i;
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
#	  debug("TRIPLE: $i/$j/$k/$dates");
	  # restore thing we changed earlier, but wo brackets
#	  debug("GAMMA: $string");
	  $string=~s/\003/$k/;
#	  debug("DELTA: $string");
	  # restore brackets to $k
	  $k=~s/\001/[[/g;
	  $k=~s/\002/]]/g;
	  # if $i is one of the dates source is "SELF"
	  for $l (@dates) {
	    if ($dates{$i}) {
	      push(@lol, [$i,$j,$k,"SELF"]);
	    } else {
	      push(@lol, [$i,$j,$k,$l]);
	    }
	  }
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
