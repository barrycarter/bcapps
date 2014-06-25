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
  $imagehash{$1} = $2;
}

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
  debug("FOR: $for");

  unless ($for) {warn "NO FORWARD MAPPING FOR: $k"; next;}

  # forward and reverse mappings (not explicitly separating properties
  # and relations, but the target type of a property will be string)

  $hash{$source}{$for}{$v} = 1;
  $hash{$v}{$rev}{$k} = 1;
  $hash{$stype}{$source} = 1;
  $hash{$ttype}{$v} = 1;
}

pbs_date_strips();
die "TESTING";
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

k frequency: (H prefix = handled by template)

H 3986|character
H 1907|storyline
765|source
H 278|notes
H 167|deaths
H 165|category
H 137|newspaper_mentions
H 122|meta
117|aka
H 97|cameo
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

