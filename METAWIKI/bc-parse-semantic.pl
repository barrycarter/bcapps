#!/bin/perl

# breaking out the subroutines in pbs-meta-pbs.pl to clean them up a bit

# PBS is "test case" but this "should" work w/ anything

require "/usr/local/lib/bclib.pl";

my($metadir) = "/home/barrycarter/BCGIT/METAWIKI";

my(@data) = `cat $metadir/pbs.txt $metadir/pbs-cl.txt | egrep -v '^#|^\$'`;

debug("DATA",@data);

die "TESTING";

=item parse_semantic($source, $string)

Given a $source of data and a string like "[[x::y]]" (with several
variants), return semantic triples (including a 4th 'extra' field to
represent Semantic Internal Objects) and a string.

$string may have nested "[[x::y]]" constructions ($source, however, may not)

Plus signs like [[x+y::...]] are treated like [[x::...]], [[y::...]]
and return a list of triples and strings

Details:

[[x::y]] - return triple [$source,x,y] and string [[y]]
[[x::y|z]] return triple [$source,x,y] and string [[y|z]]
[[x::y::z]] - return triple [$x,$y,$z] and string [[z]]
[[x::y::z|w]] - return triple [$x,$y,$z] and string [[z|w]]

In ALL cases, return "source=$source" as the 4th parameter

=cut

sub parse_semantic {
  my($source, $string) = @_;

  # list of lists I will need to handle a+b+c and so on
  my(@lol);
  # hash to hold print val of x
  my(%pval);

  # parse the dates
  my(@dates) = parse_date_list($source);

  # parse "[[...::...::...]]" (two sets of double colons)
  while ($string=~s/\[\[(.*?)::(.*?)::(.*?)\]\]//) {
    debug("GOT: $1");
  }

}

=item comment

COMMENTED OUT CODE
    # split on double colons
    my(@list) = split(/::/, $string);

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
#    return "\001$pval{$list[1]}\002";
    return $pval{$list[1]};
  }

  # only remaining legit case
  if (scalar @list == 3) {
    for $i (@{$lol[0]}) {
      for $j (@{$lol[1]}) {
	for $k (@{$lol[2]}) {
	  for $l (@dates) {
	    # TODO: currently, a GLOBAL hash to hold triples
	    $triples{$i}{$j}{$k}=1;
	    $triples{"$i~$j~$k"}{"source"}{$l} = 1;
	  }
	}
      }
    }
#    return "\001$pval{$list[2]}\002";
    return $pval{$list[2]};
  }
}

=cut

=item parse_date_list($string)

TODO: move this to bclib

Given a string like "2013-04-17-2013-04-19, 2013-04-22, 2013-04-23,
2013-04-30, 2013-05-01, 2013-05-06-2013-05-08, 2013-05-13-2013-05-15,
2013-05-20-2013-05-22, 2013-05-24, 2013-05-29", return a list of dates.

= cut

sub parse_date_list {
  my($source) = @_;
  my(@ret);

  for $i (split(/\,/,$source)) {
    # if source is date range (2002-06-03-2002-06-07), parse further
    if ($i=~/^(\d{4}-\d{2}-\d{2})\-(\d{4}-\d{2}-\d{2})$/) {
      for $j (str2time($st)/86400..str2time($en)/86400) {
	push(@ret, strftime("%Y-%m-%d", gmtime($j*86400)));
      }
    } else {
      push(@ret, $i);
    }
  }
  return @ret;
}
