#!/bin/perl

# breaking out the subroutines in pbs-meta-pbs.pl to clean them up a bit

# PBS is "test case" but this "should" work w/ anything

# Problems w/ using just pure generated triples:

# [[date::deaths::some_character]] =>
# [[date::character::some_character]] (for example)

# [[char1::relation::char2]] => [[sourcedate::charater:char1+char2]]

# [[char1::sister::char2]] => [[char1::relative::char2 (sister)]] for example

# [[alias::relation::foo]] => [[character::relation::foo]] (ie,
# aliases must be canonized except for [[character::aka::alias]]

# "name date (species)" should have alias "name canon_number
# (species)" and insure date is first appearance

require "/usr/local/lib/bclib.pl";

my($metadir) = "/home/barrycarter/BCGIT/METAWIKI";
my($pagedir) = "/usr/local/etc/metawiki/pbs3";

my(%triples);

# load meta data (TODO: this is cheating, only one section so far)
for $i (`egrep -v '^<|^#|^\$' $metadir/pbs-meta.txt`) {
  chomp($i);
  my(@data) = split(/\,\s*/, $i);
  $meta{$data[0]} = [@data];
  unless (scalar @data == 4) {warn "LINE HAS !=4 elts: $i";}
}

# imagehashes and prev/next link (assumes largeimagelinks.txt is sorted)
# TODO: confirm largeimagelinks.txt is sorted (sort -c?)
for $i (split(/\n/, read_file("$metadir/largeimagelinks.txt"))) {
  $i=~s/^(.*?)\s+.*?\/([0-9a-f]+)\?.*$//;
  my($strip, $hash) = ($1, $2);
  $triples{$strip}{hash}{$hash} = "largeimagelinks";
  $triples{$strip}{class}{strip} = "largeimagelinks";
  # record my previous strip
  $triples{$strip}{prev}{$prevstrip} = "largeimagelinks";
  # and previous strips next strip
  $triples{$prevstrip}{next}{$strip} = "largeimagelinks";
  $prevstrip = $strip;
}

for $i (`cat $metadir/pbs.txt $metadir/pbs-cl.txt | egrep -v '^#|^\$'`) {

  # TODO: multirefs!
  # TODO: *_deaths
  # below allows for multiple dates
  unless ($i=~/^([\d\-,]+)\s+(.*)$/) {next;}

  # create hash from triples
  for $j (parse_semantic($1, $2)) {
    map(s/\'/&\#39;/g, @$j);
    my($source, $k, $target, $datasource) = @$j;

    # the hash of triples
    $triples{$source}{$k}{$target} = $datasource;

    # determine relation type
    my($for, $rev, $stype, $ttype) = ("?", "?", "?", "?");
    if ($meta{$k}) {($for, $rev, $stype, $ttype) = @{$meta{$k}};}

    if ($for eq "?") {debug("NO META: $source/$k/$target");}

    # classes for source and target...

    unless ($stype eq "*" || $stype eq "string" || $stype eq "null") {
      $triples{$source}{class}{$stype} = "$datasource ($source::$k::$target)";
    }

    unless ($ttype eq "*" || $ttype eq "string" || $stype eq "null") {
      $triples{$target}{class}{$ttype} = "$datasource ($source::$k::$target)";
    }

    for $l ($source, $target) {

      # special things for characters
      unless ($triples{$l}{class}{character}) {next;}

      # the character appears in $datasource
      $triples{$datasource}{character}{$l}="$datasource ($source::$k::$target)";

      # if the character has parens in name and no species, note species
      # (note that a species triple will correctly override this)
      if ($l=~/\((.*?)\)$/ && !$triples{$l}{species}) {
	$triples{$l}{species}{$1} = "NAME2SPECIES";
      }

      # if the character has a "date like" name, tag for addl step
      # TODO: make sure date is actual first appearance
      if ($l=~/^.*? \d{8} \(.*?\)/) {$datename{$l}=1;}
    }

    # if this is an alias, tag for later canonization
    if ($k eq "aka") {$canon{$target} = $source;}

    # for character to character relations, we do more
    if ($stype eq "character" && $ttype eq "character") {
      # create this as a 2 directional relation for both characters
      $triples{$source}{relative}{"$target ($for)"}="$datasource ($for/$rev)";
      $triples{$target}{relative}{"$source ($rev)"}="$datasource ($for/$rev)";
    }
  }
}


# create reverse triples for everything
for $i (keys %triples) {
  for $j (keys %{$triples{$i}}) {
    # ignore if already reversed
    if ($j=~/^\-/) {next;}
    for $k (keys %{$triples{$i}{$j}}) {
      $triples{$k}{"-$j"}{$i} = $triples{$i}{$j}{$k};
    }
  }
}

# TODO: handle characters that are storylines (ie, they have both
# classes and dates match exactly)

# handle aliases that have non-trivial triples
for $i (sort keys %canon) {
  # if this alias isn't posing as a character, do nothing
  unless ($triples{$i}{class}{character}) {next;}
  debug("C: $i -> $canon{$i}");
  # find canon name
  my(@canon) = sort keys %{$triples{$i}{"-aka"}};
  if (scalar @canon >=2) {warn "WARNING: More than one canon name: $i";}
  my($canon) = $canon[0];

  # we no longer need "-aka" or the "character" class
  delete $triples{$i}{"-aka"};
  delete $triples{$i}{class}{character};

  # and reassign properties
  for $j (sort keys %{$triples{$i}}) {
    # "alias" class remains with the actual alias
    if ($j eq "class") {next;}

    # j2 is unsigned version of j
    my($j2) = $j;
    $j2=~s/^\-//;

    for $k (sort keys %{$triples{$i}{$j}}) {

      # if $j is a negative relation ($dir is true), backwards assign
      # in both cases assign, the negative relations too
      if ($j=~/^\-/) {
	debug("NEG+: $k/$j2/$canon $canon/-$j2/$k",
	      "NEG-: $k/$j2/$i, $i/-$j2/$k");
	$triples{$k}{$j2}{$canon} = $triples{$k}{$j2}{$i};
	$triples{$canon}{"-$j2"}{$k} = $triples{$k}{$j2}{$i};
	# and delete originals
	delete $triples{$k}{$j2}{$i};
	delete $triples{$i}{"-$j2"}{$k};
      } else {
	debug("POS+: $canon/$j/$k $k/-$j/$canon",
	      "POS-: $i/$j/$k $k/-$j/$i");
	# if $j is a forward relation, assign it to the canon
	$triples{$canon}{$j}{$k} = $triples{$i}{$j}{$k};
	$triples{$k}{"-$j"}{$canon} = $triples{$i}{$j}{$k};
	# and delete from the alias
	delete $triples{$i}{$j}{$k};
	delete $triples{$k}{"-$j"}{$i};
      }
    }
  }
}

# do something similar for "date names"
# since this comes after aka normalization, we can also do a "first date" check
for $i (sort keys %datename) {
  $i=~/(^.*?)\s+(\d{4})(\d{2})(\d{2})\s*(.*?)$/;
  my($base, $date, $species) = ($1, "$2-$3-$4", $5);
#  debug("DBS: $base/$date/$species");

  # first appearance of character
  my(@apps) = sort keys %{$triples{$i}{"-character"}};
  unless ($date eq $apps[0]) {warn "WARNING: $i: $date != $apps[0])";}

  # canonize name
  my($newname) = "$base $species #".sprintf("%0.2d",++$times{$base}{$species});
  debug("RENAME: $i -> $newname");

  # and reassign as I did for aliases
  for $j (sort keys %{$triples{$i}}) {
    for $k (sort keys %{$triples{$i}{$j}}) {
      $triples{$newname}{$j}{$k} = $triples{$i}{$j}{$k};
      delete $triples{$i}{$j}{$k};
    }
  }

}

for $i (keys %times) {
  for $j (keys %{$times{$i}}) {
    if ($times{$i}{$j} == 1) {
      warn("WARNING: $i $j occurs only once, numbering unneeded?");
    }
  }
}

# and now look at the triples for "real"
for $i (sort keys %triples) {

  # insane page name?
  if ($i=~/[\[\{\]\}]/) {
    warn "WARNING: BAD PAGE NAME: $i";
    next;
  }

  # determine class for this entity
  my(@classes) = sort keys %{$triples{$i}{class}};

  if (scalar @classes == 0) {
    debug("NO CLASSES: $i");
    next;
  }

  if (scalar @classes >= 2) {
    warn("WARNING: $i appears in multiple classes:".join(", ",@classes));
    next;
  }

  my($class) = shift(@classes);
  open(A,">$pagedir/$i.mw.new");
  print A "{{$class\n|title=$i\n";

  # error check
  if ($class eq "character" && !$triples{$i}{species}) {
    warn "WARNING: $i: no species (so probably an error)";
    next;
  }

  for $j (sort keys %{$triples{$i}}) {
    # ignore negative relations
    if ($j=~/^\-/) {next;}
    my($ks) = join(", ", sort keys %{$triples{$i}{$j}});
    print A "|$j=$ks\n";
  }

  print A "}}\n";
  close(A);
  mv_after_diff("$i.mw");
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
	  # restore thing we changed earlier, but wo brackets
#	  debug("GAMMA: $string");
	  $string=~s/\003/$k/;
#	  debug("DELTA: $string");
	  # restore brackets to $k
	  $k=~s/\001/[[/g;
	  $k=~s/\002/]]/g;
	  # if $i is one of the dates source is "SELF"
	  if ($dates{$i}) {
	    # debug("TRIPLE (SELF): $i/$j/$k/$i");
	    push(@lol, [$i,$j,$k,$i]);
	  } else {
	    for $l (@dates) {
	      # debug("TRIPLE (MULTI): $i/$j/$k/$l");
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
