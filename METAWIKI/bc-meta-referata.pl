#!/bin/perl

# potentially better way of parsing stuff (ultimately for referata.com)

# TODO: download auto-generated form stuff (like Template:Strip) from
# referata.com

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/barrycarter/BCGIT/METAWIKI")');
my($etcdir) = "/usr/local/etc/metawiki/pbs-referata";

# predictable randomization
srand(20140625);

# relations I'm ignoring for now (null/meta = ignore forever)
# NOTE: category is doubly special
my(%ignore) = list2hash("null", "char_list_complete", "source", "noref");

# get large image links (hack for now)
for $i (split(/\n/, read_file("largeimagelinks.txt"))) {
  $i=~s/^(.*?)\s+.*?\/([0-9a-f]+)\?.*$//;
  my($strip, $hash) = ($1, $2);
  $hash{$strip}{hash}{$hash} = 1;
  $hash{$strip}{type}{strip} = 1;
}

# HACK: assign next/prev to images
my(@strips) = sort keys %hash;

for $i (0..$#strips) {
  $hash{$strips[$i]}{prev}{$strips[$i-1]} = 1;
  $hash{$strips[$i]}{next} {$strips[$i+1]} = 1;
}

# and kill corner cases
delete $hash{$strips[0]}{prev};
delete $hash{$strips[$#strips]}{next};

# load meta data (TODO: this is cheating, only one section so far)
for $i (`egrep -v '<|#|^\$' pbs-meta.txt`) {
  chomp($i);
  my(@data) = split(/\, /, $i);
  $meta{$data[0]} = [@data];
}

for $i (sqlite3hashlist("SELECT * FROM triples", "/tmp/pbs-triples.db")) {
  my($source, $k, $v) = ($i->{source}, $i->{k}, $i->{v});
  debug("$source/$k/$v");

  # TODO: ignoring deaths for now
  if ($ignore{$k} || $k=~/_deaths$/) {next;}

  my($ignore, $for, $rev, $stype, $ttype) = @{$meta{$k}};

  unless ($for) {warn "NO FORWARD MAPPING FOR: $k"; next;}

  # forward and reverse mappings (not explicitly separating properties
  # and relations, but the target type of a property will be string)

  $hash{$source}{$k}{$v} = 1;

  # NOT doing reverse annos (but am doing types)
#  $hash{$v}{$rev}{$source} = 1;

  $hash{$source}{type}{$stype} = 1;
  $hash{$v}{type}{$ttype} = 1;
}

warn "IGNORING MOST TYPES FOR NOW";

for $i (sort keys %hash) {
  # remove the wildcard type (if it exists) and the string "non type"
  # these aren't considered duplicates and aren't entities
  delete $hash{$i}{type}{"*"};
  delete $hash{$i}{type}{string};

  # all pages know their own title (TODO: do this earlier?)
  $hash{$i}{title}{$i} = 1;
  debug("SELF-TITLING: $i");

  my(@types) = keys %{$hash{$i}{type}};
  if (scalar @types == 0) {warn "NO TYPES FOR: $i"; next;}
  if (scalar @types > 1) {warn "MULTIPLE TYPES FOR: $i",@types; next;}
#  unless ($types[0] eq "character" || $types[0] eq "strip") {next;}
#  unless ($types[0] eq "strip") {next;}
  unless ($types[0] eq "group") {next;}

  # remove templating from object name (only ok in strings)
  $i=~s/\{\{(.*?)\|(.*?)\}\}/$2/isg;

  open(A,">$etcdir/$i.mw.new")||die("Can't open $etcdir/$i.mw.new, $!");
  print A "{{$types[0]\n";
    for $j (sort keys %{$hash{$i}}) {
      my($keys) = join(", ",sort keys %{$hash{$i}{$j}});
      print A "|$j=$keys\n";
    }

  print A "}}\n";
  close(A)||die("Can't close $etcdir/$i.mw.new");

  mv_after_diff("$etcdir/$i.mw");
}

die "TESTING";
pbs_date_strips();
pbs_character_pages();

# the character pages (assumes %hash has been created/filled in)

sub pbs_character_pages {
  for $i (keys %{$hash{character}}) {
    debug("I: $i");
  }
}

# the date strips (assumes %hash has been created/filled in)

sub pbs_date_strips {
  my(@strips) = sort keys %{$hash{strip}};

  # use indexs so I can do "next" and "prev"
  for $l (0..$#strips) {

    # randomization of sorts
#    if (rand()>.01) {next;}

    $i = $strips[$l];

    open(A, ">$etcdir/$i.mw.new");
    print A "{{strip\n";
    print A "|has_date=$i\n|has_hash=$imagehash{$i}\n";
    # TODO: this is currently a circular list (which is cute), but
    # probably shouldn't be
    print A "|has_prev=$strips[$l-1]\n|has_next=$strips[$l+1]\n";

    for $j (sort keys %{$hash{$i}}) {
      my($keys) = join(", ",sort keys %{$hash{$i}{$j}});
      print A "|$j=$keys\n";
    }

    print A "}}\n";
    close(A);
    mv_after_diff("$etcdir/$i.mw");
  }
}

# TODO: species determination
# TODO: character renumbering

=item mv_after_diff($source, $options)

# TODO: move this to bclib.pl

Move $source.new to $source and $source to $source.old; however, if
$source.new and $source are already identical (per cmp), do
nothing. $options currently unused.

TODO: add rm=1 option to remove .new file in case of equality (but
safer to keep it around "just in case")

TODO: This wont work for files that have quotation marks, but those
are hopefully rare

=cut

sub mv_after_diff {
  my($source, $options) = @_;
  my($out,$err,$res) = cache_command2("cmp \"$source\" \"$source.new\" 1> /tmp/cmp.out 2> /tmp/cmp.err", "nocache=1");
    debug("OUT: $out, ERR: $err, RES: $res");
    unless ($res) {
      debug("$source and $source.new already identical");
      return;
    }

  debug("$source and $source.new different, overwriting");
  system("mv \"$source\" \"$source.old\"; mv \"$source.new\" \"$source\"");
}

=item comment

k frequency: (S prefix = handled by strip, C prefix = handled by character)

S 3986|character
S 1907|storyline
765|source
S 278|notes
S 167|deaths
S 165|category
S 137|newspaper_mentions
S 122|meta
117|aka
S 97|cameo
95|profession
57|description
53|neighbor
53|species
33|location
31|cousin
20|crocodile_deaths
20|friend
19|zebra_deaths
18|event
15|subspecies
13|uncle
8|husband

=cut

