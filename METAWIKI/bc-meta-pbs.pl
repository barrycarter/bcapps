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

parse_semantic("2007-07-23", "[[character::Pig+Rat+Connie]] [[Connie::aka::Connie the Judgmental Cow]]");

for $i (keys %triples) {
  for $j (keys %{$triples{$i}}) {
    for $k (keys %{$triples{$i}{$j}}) {
      debug("IJK: $i, $j, $k");
    }
  }
}

# debug("TRIPLES",unfold(\%triples), "/TRIPLES");

die "TESTING";

my($data) = read_file("/home/barrycarter/BCGIT/METAWIKI/pbs.txt");
$data=~s%^.*?<data>(.*?)</data>.*$%$1%s;

for $i (split(/\n/, $data)) {
  # ignore blanks and comments
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # split line into source page and then body
  $i=~/^(.*?)\s*($dlb.*)$/;
  my($source, $body) = ($1,$2);
  parse_text($source,$body);
}

# dumps dates for testing
print join("\n", sort keys %triple),"\n";
die "TESTING";

# now, adding stuff to pages from the established triples
for $i (keys %triple) {
  for $j (keys %{$triple{$i}}) {
    for $k (keys %{$triple{$i}{$j}}) {
      # restore [[this]]
      $k=~s/\001/[[/isg;
      $k=~s/\002/]]/isg;
#      print "$i\t$j\t$k\n";
    }
  }
}

sub parse_text {
  my($source,$body) = @_;
  debug("START: $source/$body");
  # return triplets
  my(@trip) = ();
  # source may contain multiple pages
  my(@source) = parse_source($source);

  # keep things like [[Pig]] as is, but tokenize so they won't bother us
  # TODO: undo this before final wiki printing
  $body=~s/$dlb($cc+)$drb/\001$1\002/sg;

  # semantic triple
  while ($body=~s/$dlb($cc*?)::($cc*?)$drb/$2/) {
    # relation and value
    my($relation,$value) = ($1,$2);
    # either of these can be multiple
    for $i (split(/\+/, $relation)) {
      for $j (split(/\+/, $value)) {
	for $source (@source) {
	  # TODO: allow non-1 values to set order
	  $triple{$source}{$i}{$j} = 1;
	}
      }
    }
  }
  debug("SOURCE: $source/$body");
}

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
  # list of lists I will need to handle a+b+c and so on
  my(@lol);
  # hash to hold print val of x
  my(%pval);

  # parse the dates
  my(@dates) = parse_source($source);
  debug("SOURCE: $source, DATES",@dates,"/DATES");

  # recursion (the while condition does all the work, no while body)
  while ($string=~s/$dlb(.*?)$drb/parse_semantic($source,$1)/iseg) {}

  # split on double colons
  my(@list) = split(/::/, $string);

  # no double colons? return as is, no triples created
  if (scalar @list <= 1) {return $string;}

  # each key/val can be multivalued, so create list of lists
  map(push(@lol, [split(/\+/,$_)]), @list);
  debug("LIST",@list,"/LIST");
  debug("LOL",unfold($lol[1]),"/LOL");

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
	  if (scalar @dates != 1) {warn("DATELIST SHOULD BE 1 element only");}
	  for $l (@dates) {
	    # TODO: currently, a GLOBAL hash to hold triples
	    $triples{$i}{$j}{$k}=1;
	    $triples{"$i~$j~$k",}{"source"}{$l} = 1;
	  }
	}
      }
    }
    return "[[$pval{$list[3]}]]";
  }
}

