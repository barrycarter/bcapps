#!/bin/perl

# A much reduced attempt at a metawiki that uses only a fixed number
# of well-known relations, each of which I know how to handle. Hope to
# generalize this into an all-purposes meta wiki at some point.

# Test case for this wiki is Pearls Before Swine comic strip

require "/usr/local/lib/bclib.pl";

# shortcuts just to make code look nicer
# character class excluding brackets
$cc = "[^\\[\\]]";
# double left and right bracket
$dlb = "\\[\\[";
$drb = "\\]\\]";

# links to high-res version of each strip
for $i (split(/\n/, read_file("/home/barrycarter/BCGIT/METAWIKI/largeimagelinks.txt"))) {
  $i=~s/^(.*?)\s+(.*)$//;
  $link{$1}=$2;
}

my($data) = read_file("/home/barrycarter/BCGIT/METAWIKI/pbs.txt");
$data=~s%^.*?<data>(.*?)</data>.*$%$1%s;

# and the data from pbs-cl.txt
$data = "$data\n".read_file("/home/barrycarter/BCGIT/METAWIKI/pbs-cl.txt");

for $i (split(/\n/, $data)) {
  # ignore blanks and comments
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # warn if the line contains a single colon (but keep parsing it)
  if ($i=~/[^:]:[^:]/) {warn "BAD LINE: $i";}

  # split line into source page and then body
  $i=~/^(.*?)\s*($dlb.*)$/;
  my($source, $body) = ($1,$2);
  parse_semantic($source,$body);
}

# this is probably bad
open(A,"|mysql test 1> /tmp/myout.txt 2> /tmp/myerr.txt");
# open(A,">/tmp/mysql.txt");
print A "BEGIN; DELETE FROM triples;\n";

for $i (sort keys %triples) {
  for $j (keys %{$triples{$i}}) {
    for $k (keys %{$triples{$i}{$j}}) {
      # restore [[ and ]] for printing and fix apos
      $k=~s/\001/\[\[/isg;
      $k=~s/\002/\]\]/isg;
      $k=~s/\'/\\'/isg;
      print A "INSERT INTO triples VALUES ('$i','$j','$k');\n";
    }
  }
}

print A "COMMIT;\n";
close(A);

die "TESTING";

# this is ugly, but necessary, to remove .txt files that should no longer exist
system("rm /mnt/extdrive/GOCOMICS/pearlsbeforeswine/page-*.gif.txt");

# open files for writing (currently all /var/tmp/)
open(A,">/var/tmp/bc-pbs-triples.txt");

warn "Ignoring non-date annotations";

for $i (sort keys %triples) {
  # ignore non-dates
  unless ($i=~/^\d/) {next;}

  # write caption files for feh
  open(B,">/mnt/extdrive/GOCOMICS/pearlsbeforeswine/page-$i.gif.txt");
  for $j (keys %{$triples{$i}}) {
    for $k (keys %{$triples{$i}{$j}}) {
      # genercize, group by type of relation, not date
      $rdf{$j}{$k}{$i} = 1;

      # restore [[ and ]] for printing
      $k=~s/\001/[\[/isg;
      $k=~s/\002/]\]/isg;

      # check for dupes
      if ($seen{"$i~$j~$k"}) {
	warn("$i~$j~$k exists twice");
	next;
      }
      $seen{"$i~$j~$k"} = 1;

      print A "$i,$j,$k\n";
      print B "$j,$k\n";

    }
  }
  close(B);
}

close(A);

debug("ASH:",keys %{$rdf{storyline}});

die "TESTING";

open(B,">/var/tmp/bc-pbs-newspaper.txt");
# newspaper mentions
for $i (sort keys %{$rdf{newspaper_mentions}}) {
  # dates on which $i is mentioned
  @dates = sort keys %{$rdf{newspaper_mentions}{$i}};
  debug("DATES",@dates);
  # TODO: find high resolution link for dates
  # printable format + glue with commas
  map($_="{{#NewWindowLink: $link{$_} | ".strftime("%d %b %Y (%a)}}",gmtime(str2time($_))), @dates);
  print B "* $i: ",join(", ",@dates),"\n";
}

close(B);

open(C,">/var/tmp/bc-pbs-storylines.txt");
# create sorted list of dates for each storyline
for $i (keys %{$rdf{storylines}}) {
  debug("I: $i");
  @{$dates{$i}} = sort(keys %{$storylines{$i}});
}

die "TESTING";

# sort storylines by earliest date w/ given storyline
@storylines = sort {$dates{$a}[0] cmp $dates{$b}[0]} (keys %storylines);

# and print...
for $i (@storylines) {
  # dates
  @dates = @{$dates{$i}};

  # restore brackets
  $i=~s/\001/[[/isg;
  $i=~s/\002/]]/isg;

  # the storyline
  print C "* $i\n";

  # and its dates
  for $j (@dates) {
    my($pdate, $link) = date2prli($j);
    print C "** {{#NewWindowLink: $link | $pdate}}\n";
  }

  print C "\n";
}

close(C);

# given a date like "2000-01-01", return "printable" format and direct
# link to PBS comic

sub date2prli {
  my($date) = @_;

  # the link
  unless ($date=~m/^(\d{4})\-(\d{2})\-(\d{2})$/) {warn "BAD DATE: $date";}
  my($link) = "http://www.gocomics.com/pearlsbeforeswine/$1/$2/$3";

  return strftime("%d %b %Y (%a)", gmtime(str2time($date))), $link;
}

# dumps dates for testing
# print join("\n", sort keys %triple),"\n";

# convert things like
# 2013-04-17-2013-04-19,2013-04-22,2013-04-23,2013-04-30,2013-05-01,2013-05-06-2013-05-08,2013-05-13-2013-05-15,2013-05-20-2013-05-22,2013-05-24,2013-05-29
# to a list of source pages
sub parse_source {
  my($source) = @_;
  my(@ret);

  for $i (split(/\,/,$source)) {
    # if source is date range (2002-06-03-2002-06-07), parse further
    if ($i=~/^(\d{4}-\d{2}-\d{2})\-(\d{4}-\d{2}-\d{2})$/) {
      push(@ret, parse_date_range($1,$2));
    } else {
      push(@ret, $i);
    }
  }
  return @ret;
}

# convert 2002-06-03-2002-06-07 to list of dates
sub parse_date_range {
  my($st,$en) = @_;
  my(@ret);
  # integer division below
  for $i (str2time($st)/86400..str2time($en)/86400) {
    push(@ret, strftime("%Y-%m-%d", gmtime($i*86400)));
  }
  if ($#ret>10) {warn "$st-$en: more than 10 or more, probably an error";}
  return @ret;
}

=item parse_semantic($source, $string)

Given a $source of data and a string like "[[x::y]]" (with several
variants), return semantic triples and a string. This function is
called recursively, so $string may have nested "[[]]" constructions
($source may not, however)

Plus signs like [[x+y::...]] are treated like [[x::...]], [[y::...]] 
and return a list of triples and strings

Details:

[[x]] - return [[x]] (but convert [[ and ]] to avoid recursion)
[[x::y]] - return triple [$source,x,y] and string [[y]]
[[x::y|z]] return triple [$source,x,y] and string [[y|z]]
[[x:=y]] - return triple [$source,x,y] and string y
[[x:=y|z]] - return triple [$source,x,y] and string z

[[x::y::z]] - return triples [$x,$y,$z] and [$f,source,$source] where
$f represents the triple [[x::y::z]], and string [[z]]

(this function is specific to this program, but may be generalized, so
I am perldocing it)

TODO: this currently creates a GLOBAL hash, instead of returning a list

=cut

sub parse_semantic {
  my($source, $string) = @_;
#  debug("parse_semantic($source, $string)");

  # list of lists I will need to handle a+b+c and so on
  my(@lol);
  # hash to hold print val of x
  my(%pval);

  # parse the dates
  my(@dates) = parse_source($source);

  # recursion (the while condition does all the work, no while body)
  while ($string=~s/$dlb($cc*?)$drb/parse_semantic($source,$1)/iseg) {}

  # split on double colons
  my(@list) = split(/::/, $string);

  # no double colons? return as is w/ specialized brackets, no triples created
  if (scalar @list <= 1) {return "\001$string\002";}

  # each key/val can be multivalued, so create list of lists
  map(push(@lol, [split(/\+/,$_)]), @list);

  # print val of each element (same as element except with |)
  for $i (@list) {
    if ($i=~s/\|(.*)$//) {$pval{$i} = $1;} else {$pval{$i} = $i;}
  }

  # one double colon? create semantic triple [$source,$key,$val] allowing for |
  if (scalar @list == 2) {
    for $i (@{$lol[0]}) {
      for $j (@{$lol[1]}) {
	for $k (@dates) {
	  # TODO: currently, a GLOBAL hash to hold triples
	  $triples{$k}{$i}{$j}=1;
	}
      }
    }
    return "[[$pval{$list[1]}]]";
  }

  # only remaining legit case
  if (scalar @list == 3) {
    for $i (@{$lol[0]}) {
      for $j (@{$lol[1]}) {
	for $k (@{$lol[2]}) {
	  if (scalar @dates != 1) {warn("DATELIST($string) SHOULD BE 1 element only, not @dates");}
	  for $l (@dates) {
	    # TODO: currently, a GLOBAL hash to hold triples
	    $triples{$i}{$j}{$k}=1;
	    $triples{"$i~$j~$k",}{"source"}{$l} = 1;
	  }
	}
      }
    }
#    debug("RETURNING $pval{$list[2]} (in brackets)");
    return "[[$pval{$list[2]}]]";
  }
}

=item schema

This is the schema of the mysql db that should already exist:

DROP TABLE IF EXISTS triples;
-- val and value and mysql reserved words?
CREATE TABLE triples (source TEXT, k TEXT, v TEXT);
CREATE INDEX i1 ON triples(source(20));
CREATE INDEX i2 ON triples(k(20));
CREATE INDEX i3 ON triples(v(20));

=cut

=item headertext

This is the header text to the "Storylines" page, and I'm adding it manually.

Below are some of the Pearls Before Swine storylines, with links to
each strip in the storyline. Most of this page is autogenerated by 
{{#NewWindowLink: https://github.com/barrycarter/bcapps/blob/master/METAWIKI/bc-meta-pbs.pl}} using
{{#NewWindowLink: https://github.com/barrycarter/bcapps/blob/master/METAWIKI/pbs.txt}}
If you are interested in contributing to this project or are curious about it, please email me at wikia@barrycarter.info or via my Talk page.

This page is experimental: expect errors and incomplete data.

header text for "Newspaper mentions"

[[Stephan Pastis]]' characters occasionally read newspapers in which
Pearls appears. The newspaper title can be hard to read without
zooming, and often changes between panels. The following is a list of
newspapers Pastis' characters have read and when, with a link to a
high-zoom version of the strip. At least twice (New York Times and
Wall Street Journal), Pastis' characters read papers that don't carry
Pearls (or any other comics for that matter).

Most of this page is autogenerated by 
{{#NewWindowLink: https://github.com/barrycarter/bcapps/blob/master/METAWIKI/bc-meta-pbs.pl}} using
{{#NewWindowLink: https://github.com/barrycarter/bcapps/blob/master/METAWIKI/pbs.txt}}
If you are interested in contributing to this project or are curious about it, please email me at wikia@barrycarter.info or via my Talk page.

This page is experimental: expect errors and incomplete data.

=cut

=item notes

Useful things to do w/ bc-pbs-triples.txt

# most frequent characters
fgrep ,character, bc-pbs-triples.txt | perl -F, -anle 'print $F[2]' | sort | uniq -c | sort -nr

=cut
