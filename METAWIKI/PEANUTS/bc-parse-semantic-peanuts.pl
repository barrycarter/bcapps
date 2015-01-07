#!/bin/perl

# copy of bc-parse-semantic.pl for Peanuts, for comments/TODO, see
# bc-parse-semantic.pl

require "/usr/local/lib/bclib.pl";


my($comicname) = "peanuts";
my($metadir) = "/home/barrycarter/BCGIT/METAWIKI";
my($pagedir) = "/usr/local/etc/metawiki/$comicname";
chdir($metadir);

# faster diff
for $i ("OLD", "NEW") {system("mkdir -p $pagedir/$i");}

my(%triples);

# load meta data (TODO: this is cheating, only one section so far)
for $i (`egrep -v '^<|^#|^\$' $metadir/$comicname-meta.txt`) {
  chomp($i);
  my(@data) = split(/\,\s*/, $i);
  $meta{$data[0]} = [@data];
  unless (scalar @data == 4) {warn "LINE HAS !=4 elts: $i";}
}

# imagehashes and prev/next link (assumes largeimagelinks.txt is sorted)
# TODO: confirm largeimagelinks.txt is sorted (sort -c?)
for $i (split(/\n/, read_file("$metadir/$comicname-largeimagelinks.txt"))) {
  # TODO: 32 below may not apply in all cases
  $i=~s/^(.*?)\s+.*?\/([0-9a-f]{32})\??.*?$//;
  my($strip, $hash) = ($1, $2);
  $triples{$strip}{hash}{$hash} = "largeimagelinks";
  $triples{$strip}{class}{strip} = "largeimagelinks";
  $triples{$hash}{class}{string} = 1;
  # record my previous strip
  $triples{$strip}{prev}{$prevstrip} = "largeimagelinks";
  # and previous strips next strip
  $triples{$prevstrip}{next}{$strip} = "largeimagelinks";
  $prevstrip = $strip;
}

my($all) = read_file("$comicname.txt");
$all=~m%<data>(.*?)</data>%s;
for $i (split(/\n/, $1.read_file("$comicname-cl.txt"))) {
  # TODO: *_deaths
  # below allows for multiple dates

  if ($i=~/^MULTIREF/) {parse_multiref($i); next;}

  unless ($i=~/^([\d\-,]+)\s+(.*)$/) {
    debug("IGNORING: $i");
    next;
  }

  # create hash from triples
  for $j (parse_semantic($1, $2)) {
    map(s/\'/&\#39;/g, @$j);
    my($source, $k, $target, $datasource) = @$j;

    if ($source eq $target) {warn "SOURCE==TARGET: $i, $source";}

    # determine relation type
    my($for, $rev, $stype, $ttype) = ("?", "?", "?", "?");
    if ($meta{$k}) {($for, $rev, $stype, $ttype) = @{$meta{$k}};}
    if ($for eq "?") {debug("NO META: $source/$k/$target");}

    # templates inside certain types disallowed
    # TODO: handle this much more generically
    unless ($k eq "notes" || $k eq "description") {
      $target=~s/\{\{(.*?)\|(.*?)\}\}/$2/g;
    }

    # the hash of triples
    $triples{$source}{$k}{$target} = $datasource;

    # classes for source and target...

    unless ($stype eq "*" || $stype eq "null") {
      $triples{$source}{class}{$stype} = "$datasource ($source::$k::$target)";
    }

    unless ($ttype eq "*" || $stype eq "null") {
      $triples{$target}{class}{$ttype} = "$datasource ($source::$k::$target)";
    }

    for $l ($source, $target) {

      # special things for characters
      unless ($triples{$l}{class}{character}) {next;}

      # the character appears in $datasource
      $triples{$datasource}{character}{$l}="$datasource ($source::$k::$target)";

      # if the character has parens in name and no species, note species
      # (note that a species triple will correctly override this)
      if ($l=~/\(([^A-Z]*?)\)$/ && !$triples{$l}{species}) {
	my($specname) = $1;
	$triples{$l}{species}{$specname} = "NAME2SPECIES";
	$triples{$specname}{class}{string} = 1;
#	debug("NAME2SPECIES: $l -> $1");
      }

      # if the character has a "date like" name, tag for addl step
      # TODO: make sure date is actual first appearance
      if ($l=~/^.*? \d{8} \(.*?\)/) {$datename{$l}=1;}
    }

    # if this is an alias, tag for later canonization
    if ($k eq "aka") {$canon{$target} = $source;}

    # TODO: we can't do this too early, it breaks things
    # for character to character relationships, we do more
    if ($stype eq "character" && $ttype eq "character") {
      # create this as a 2 directional relation for both characters
      # using relationships as values (instead of sources) is cheating,
      # but works well for renaming relationships later
      $triples{$source}{relationship}{$target} = $for;
      $triples{$target}{relationship}{$source} = $rev;
      $has_relation{$source} = 1;
      $has_relation{$target} = 1;
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
#  debug("C: $i -> $canon{$i}");

  rename_entity($i, $canon{$i});

  # the above overdoes it, so we fix
  $triples{$canon{$i}}{aka}{$i} = "AKA";
  delete $triples{$i}{aka};

  $triples{$i}{class}{alias} = "AKA";
  delete $triples{$canon{$i}}{class}{alias};
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

  # canonize name (cannot use "#" directly, browsers interpret it)
  my($newname) = "$base $species &#65283;".sprintf("%0.2d",++$times{$base}{$species});
#  debug("RENAME: $i -> $newname");

  rename_entity($i, $newname);
  $triples{$newname}{reference_name}{$i} = "REFERENCE";
  $triples{$i}{class}{string} = "REFERENCE";

}

for $i (keys %times) {
  for $j (keys %{$times{$i}}) {
    if ($times{$i}{$j} == 1) {
      warn("WARNING: $i $j occurs only once, numbering unneeded?");
    }
  }
}

# fix character to character relationships (must come after aka/date
# stuff above)
# TODO: allow for gender
for $i (sort keys %has_relation) {
  for $j (sort keys %{$triples{$i}{relationship}}) {
    my($rel) = $triples{$i}{relationship}{$j};
    # for now, use gender neuter form
    $rel=~s/.*\///;
    # delete this generic relation
    delete $triples{$i}{relationship}{$j};
    # and replace it with parenthesized relation
    $triples{$i}{relationship}{"[[$j]] ($rel)"} = "RELATIONSHIP";
  }
}

  # create empty db (being this direct this is probably bad)
  open(B,"|tee /tmp/triples.txt|sqlite3 /tmp/$comicname-triples.db 1>/tmp/$comicname-myout.txt 2>/tmp/$comicname-myerr.txt");
  # open(A,">/tmp/mysql.txt");
  print B << "MARK";
DROP TABLE IF EXISTS triples;
CREATE TABLE triples (source, k, target, datasource);
CREATE INDEX i1 ON triples(source);
CREATE INDEX i2 ON triples(k);
CREATE INDEX i3 ON triples(target);
BEGIN;
MARK
;

# and now look at the triples for "real"
for $i (sort keys %triples) {

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

  # strings don't get pages
  if ($class eq "string") {next;}

  # insane page name?
  if ($i=~/[\[\{\]\}]/) {
    warn "WARNING: BAD PAGE NAME: $i";
    next;
  }

  # error check (not for PEANUTS)
#  if ($class eq "character" && !$triples{$i}{species}) {
#    warn "WARNING: $i: no species (so probably an error)";
#    debug(sort keys %{$triples{$i}{"-character"}});
#    next;
#  }

  open(A,">$pagedir/NEW/$i.mw");
  print A "{{$class\n|title=$i\n";

  for $j (sort keys %{$triples{$i}}) {
    # ignore negative relations
    if ($j=~/^\-/) {next;}
    my(@ks) = sort keys %{$triples{$i}{$j}};

    # just for sqlite3
    for $k (@ks) {
      $pi = $i; $pj = $j; $pk = $k;
      $pi=~s/\'/''/g;
      $pj=~s/\'/''/g;
      $pk=~s/\'/''/g;
      print B "INSERT INTO triples VALUES ('$pi', '$pj', '$pk', '$triples{$i}{$j}{$k}');\n";
    }

    my($ks) = join(", ", @ks);
    print A "|$j=$ks\n";
  }

  print A "}}\n";
  close(A);
}

print B "COMMIT;\n";
close(B);

# this is ugly, but prevents deletion of rsync'd files
system("rsync -Pavz /home/barrycarter/BCGIT/METAWIKI/*.mw /usr/local/etc/metawiki/$comicname/NEW/");

my(@diffs) = `diff -qr $pagedir $pagedir/NEW`;
my(@cmds);

for $i (@diffs) {
  chomp($i);
  my($cmd);

  # only in NEW? (then yes, do copy)
  if ($i=~m%Only in $pagedir/NEW: (.*)$%) {
    push(@cmds,"mv \"$pagedir/NEW/$1\" $pagedir");
  } elsif ($i=~m%Only in $pagedir: (.*)$%) {
    # TODO: avoid files I rsync over, they still need to be copied
    push(@cmds,"mv \"$pagedir/$1\" $pagedir/OLD");
  } elsif ($i=~m%^Files (.*?) and (.*?) differ$%) {
    push(@cmds,"mv \"$1\" $pagedir/OLD; mv \"$2\" $pagedir");
  } else {
    die "BAD DIFF OUTPUT: $i";
  }
}

for $i (@cmds) {system($i);}

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

sub parse_multiref {
  my($multiref) = @_;
  my(%hash);
  for $i (parse_semantic("MULTIREF", $multiref)) {$hash{$i->[1]}= $i->[2];}

  # fix up title (and notes?)
#  debug("ALPHA: $hash{title}");
  $hash{title}=~s/\'/&\#39\;/g;
#  debug("BETA: $hash{title}");

  # which dates are referenced?
  for $i ($hash{notes}=~m/\[\[(\d{4}-\d{2}-\d{2})\]\]/g) {
    $triples{$hash{title}}{dates}{$i} = "MULTIREF";
  }

  # get rid of the noref:: (which means: don't show that strip, but mention it)
  $hash{notes}=~s/noref:://g;

  # TODO: use of global here is ugly!
  $triples{$hash{title}}{class}{continuity} = "MULTIREF";
  $triples{$hash{title}}{notes}{$hash{notes}} = "MULTIREF";
}

# carefully renames an entity in triples
# TODO: triples should not be global!
sub rename_entity {
  my($oldname, $newname) = @_;

  # everything assigned to the oldname is now assigned to the newname
  for $i (sort keys %{$triples{$oldname}}) {
    for $j (sort keys %{$triples{$oldname}{$i}}) {

      # assign oldname values to newname
      $triples{$newname}{$i}{$j} = $triples{$oldname}{$i}{$j};
      delete $triples{$oldname}{$i}{$j};
#      debug("RI+ $newname/$i/$j","RI- $oldname/$i/$j");

      if ($i=~/^\-/) {
	# if $i is "negative", also fix target -> source relations
	my($irev) = substr($i,1);
	$triples{$j}{$irev}{$newname} = $triples{$j}{$irev}{$oldname};
	delete $triples{$j}{$irev}{$oldname};
#	debug("RI+ $j/$irev/$newname","RI- $j/$irev/$oldname");
      } else {
	# if $i is "positive" fix target negative-relation source relations
	$triples{$j}{"-$i"}{$newname} = $triples{$j}{"-$i"}{$oldname};
	delete $triples{$j}{"-$i"}{$oldname};
#	debug("RI+ $j/-$i/$newname","RI- $j/-$i/$oldname");
      }
    }
  }

  # the oldname now becomes an alias to the newname
#  $triples{$newname}{aka}{$oldname} = "rename_entity";
#  $triples{$oldname}{class}{alias} = "rename_entity";

}
