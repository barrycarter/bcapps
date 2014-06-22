#!/bin/perl

# potentially better way of parsing stuff (ultimately for referata.com)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/barrycarter/BCGIT/METAWIKI")');

# relations I'm ignoring for now (null/meta = ignore forever)
my(%ignore) = list2hash("null", "meta", "char_list_complete", "source",
			"noref", "cameo", "category");

# the following are considered "properties", and not links
my(%props) = list2hash("notes", "description", "event");

# TODO: category is doubly special

# below forces creation/recency of pbs-triples.db
system("make");

my(%hash);
# get large image links (hack for now)
for $i (split(/\n/, read_file("largeimagelinks.txt"))) {
  $i=~s/^(.*?)\s+(.*)$//;
  $hash{$1}{image_url}{$2}=1;
}

# the forward and reverse mappings of k

# assuming friendship/cousin is symmetric, possibly not always true
# (for cousins, reverse could be "great uncle" or something weird?)

my(%map) = (
	    "character" => ["has_character", "appears_in"],
	    "storyline" => ["in_storyline", "has_strip"],
	    "deaths" => ["has_death", "dies_on"],
	    "rebirths" => ["has_undeath", "un_dies_on"],
	    "newspaper_mentions" => ["mentions_paper", "mentioned_on"],
	    "aka" => ["alias", "canon"],
	    "profession" => ["has_profession", "has_member"],
	    "neighbor" => ["has_neighbor", "has_neighbor"],
	    "cousin" => ["has_cousin", "has_cousin"],
	    "friend" => ["has_friend", "has_friend"],
	    "species" => ["has_species", "has_member"],
	    "subspecies" => ["has_subspecies", "has_member"],
	    "location" => ["has_location", "has_resident"],
	    # <h>No to gay marriage: it screws up semantic transitivity!</h>
	    "husband" => ["has_husband", "has_wife"],
	    "wife" => ["has_wife", "has_husband"],
	    "girlfriend" => ["has_girlfriend", "has_boyfriend"],
	    "boyfriend" => ["has_boyfriend", "has_girlfriend"],
	    "ex-husband" => ["had_husband", "had_wife"],
	    "half-brother" => ["has_half_brother", "has_half_sibling"],
	    # no generic term for niece/nephew?
	    "uncle" => ["has_uncle", "uncle_of"],
	    "niece" => ["has_niece", "has_uncle"],
	    "aunt" => ["has_aunt", "aunt_of"],
	    "date" => ["dates", "dates"],
	    "boss" => ["boss_of", "employee_of"],
	    "brother" => ["has_brother", "has_sibling"],
	    "sister" => ["has_sister", "has_sibling"],
	    "grandmother" => ["has_grandmother", "has_grandchild"],
	    "grandfather" => ["has_grandfather", "has_grandchild"],
	    "pet" => ["has_pet", "pet_of"],
	    "mother" => ["has_mother", "has_child"],
	    "father" => ["has_father", "has_child"],
	    "roommate" => ["has_roommate", "has_roommate"],
	    "kills" => ["kills", "killed_by"],
	    "member" => ["member_of", "has_member"],
	    "members" => ["has_member", "member_of"],
	    "son" => ["has_son", "has_parent"],
	    "coworker" => ["has_coworker", "has_coworker"],
	    "fires" => ["fires", "fired_by"],
	    "religion" => ["has_religion", "has_follower"],
	    "orientation" => ["has_sexual_orientation", "has_member"]
);

# debug($map{character}[0]);

for $i (sqlite3hashlist("SELECT * FROM triples", "/tmp/pbs-triples.db")) {
  my($source, $k, $v) = ($i->{source}, $i->{k}, $i->{v});

  # TODO: ignoring deaths for now
  if ($ignore{$k} || $k=~/_deaths$/) {next;}

  if ($map{$k}) {
    $hash{$source}{$map{$k}[0]}{$v} = 1;
    $hash{$v}{$map{$k}[1]}{$k} = 1;
    next;
  }

  # props are unidirectional
  if ($props{$k}) {
    $hash{$source}{$k}{$v} = 1;
    next;
  }

  warn("NOT UNDERSTOOD: $k: $source -> $v");
}

# create the per-day strips
# TODO: category: strip, table at top, notes/description are
# important, maybe more
# TODO: species determination
# TODO: character renumbering

for $i (sort keys %hash) {

  if (++$count>10) {die "TESTING";}

  unless ($i=~/^\d{4}\-/) {next;}

  # TODO: DO NOT REWRITE EVERY SINGLE TIME (diffs only)
  # the page
  open(A,">/usr/local/etc/metawiki/pbs-referata/$i.mw");

  # the table
  print A pbs_table_date($i),"\n";
  # no need to publish the image URL?
  delete $hash{$i}{image_url};

  # extra categories (if any)
  # TODO: bad placement for categories, put at bottom?
  for $j (sort keys %{$hash{$i}{category}}) {
    print A "[[Category: $j]]\n";
  }
  delete $hash{$i}{category};

  for $j (sort keys %{$hash{$i}}) {
    my(@keys) = sort keys %{$hash{$i}{$j}};

    # no keys? <h>no justice</h> ignore
    unless (@keys) {next;}

    # if this is a property, print it out, don't create triple
    if ($props{$j}) {
      print A "== ".ucfirst($j)." ==\n\n";
      print A join("\n",@keys),"\n\n";
      next;
    }

    for $k (@keys) {
      debug("$i, $j, $k");
      # print nothing
      print A "[[${j}::$k| ]]\n";
    }
  }

  print A "\n[[Category: Strips]]\n";
  print A "__SHOWFACTBOX__\n";
  close(A);
}


# creates the table used to display a given strip (referata version)

sub pbs_table_date {
  my($date) = @_;
  unless ($date=~m/^(\d{4})\-(\d{2})\-(\d{2})$/) {warn "BAD DATE: $date";}
  my($link) = "http://www.gocomics.com/pearlsbeforeswine/$1/$2/$3";
  my($pdate) =  strftime("%d %b %Y (%A)", gmtime(str2time($date)));

  # notes for this strip
  my($notes) = join(". ",sort keys %{$hash{$date}{notes}});
  # remove wp links
  $notes=~s/\{\{\#NewWindowLink:\s+.*?\|(.*?)\}\}/$1/isg;
  # fix up quotation marks
  $notes=~s/\"/&quot;/isg;

  # the image itself
  my(@hash) = keys %{$hash{$date}{image_url}};
  unless (@hash) {
    warn "NO IMAGE URL FOR $date";
    return;
  }

  $hash[0]=~/([^\/]*?)\?width\=/;
  my($thumb) = $1;

  my($image) = "{{#widget:Thumbnail|hash=$thumb}}";

  return << "MARK";
<table border>
<tr><th>{{WikiLink|$date|$pdate}}</th></tr>
<tr><th>{{#widget:LinkedThumbnail|url=$link|hash=$thumb}}
</th></tr>
<tr><th>{{#widget:Extlink|url=$hash[0]|text=highest resolution}}
</th></tr></table>
MARK
;

  # NOTE: this must be one single line for formatting reasons (wikia)
  return << "MARK";
<table border><tr><th>{{#NewWindowLink: $date | $pdate}}</th></tr><tr><th title="$notes">{{#NewWindowLink: $link | $image</th></tr><tr><th>{{#NewWindowLink: $link{$date} | (highest resolution)}}</th></tr></table>
MARK
;
}



=item comment

k frequency:

3986|character
1907|storyline
765|source
278|notes
167|deaths
165|category
137|newspaper_mentions
122|meta
117|aka
97|cameo
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

