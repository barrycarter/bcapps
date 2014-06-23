#!/bin/perl

# potentially better way of parsing stuff (ultimately for referata.com)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/barrycarter/BCGIT/METAWIKI")');
my($etcdir) = "/usr/local/etc/metawiki/pbs-referata";

# relations I'm ignoring for now (null/meta = ignore forever)
my(%ignore) = list2hash("null", "meta", "char_list_complete", "source",
			"noref", "cameo", "category");

# the following are considered "properties", and not links
# TODO: event should probably be noted semantically
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

# the forward and reverse mappings of k, plus the prettyprint version
# (currently only for forward version)

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

# defines the pretty prints of SOME of the semantic relations above
my(%prettyprint) = (
		    "has_character" => "Character(s)",
		    "has_death" => "Death(s)",
		    "in_storyline" => "Storyline(s)",
		    "notes" => "Notes",
		    "description" => "Description",
		    "event" => "Events",
		    "" => ""
		    );

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

pbs_date_strips();
die "TESTING";

# the date strips (assumes %hash has been created/filled in)

sub pbs_date_strips {
  my(%is_strip);

  # TODO: there must be a better way to do this?
  for $i (keys %hash) {if ($i=~/^\d{4}\-\d{2}\-\d{2}$/) {$is_strip{$i}=1;}}
  my(@strips) = sort keys %is_strip;

  # use indexs so I can do "next" and "prev"
  for $l (0..$#strips) {
    $i = $strips[$l];

#    if ($l > 200) {die "TESTING";}

    # the big table (containing date table and semantic annotations)
    my(@table) = ("<table width=100%><tr><th>", pbs_table_date($i),
		     "</th><td align=right valign=top>");
    # don't publish the image URL directly
    delete $hash{$i}{image_url};

    # the semantic information table (row 1, column 2 of big table)
    push(@table, "<table border><tr><th colspan=2>Semantic Information</th></tr>");

    # the categories (we dont print them yet, and "strips" is always one)
    # strips is always last one, despite sorting
    my(@cats) = (sort keys %{$hash{$i}{category}}, "strips");
    map($_="[[Category:$_]]", @cats);

    # the portion of the page below the main table, above cat list
    my(@outer);

    # since we list categories at bottom of page, they are not in info
    # box (although I suppose they could be)
    delete $hash{$i}{category};

    # the other properties for this strip
    for $j (sort keys %{$hash{$i}}) {

      # the values for this key
      my(@keys) = sort keys %{$hash{$i}{$j}};

      # not sure why this happens, but ignore it quietly
      # TODO: look into this Perl oddness
      unless (@keys) {next;}

      # if $j is a property (not a relation), print it outside any table
      if ($props{$j}) {
	push(@outer,  "== $prettyprint{$j} ==\n");
	push(@outer, join("\n",@keys), "\n");
	next;
      }

      # $j is a true relation, not just a property
      # turn keys into useful semantic information
      for $k (@keys) {
	$k=~s/\{\{wp\|(.*?)\}\}/$1/g;
	$k="[[${j}::$k]]";
      }

      # join for printing
      my($keys) = join("<br>\n",@keys);

      # and put into semantic (small) table and end small table
      push(@table, "<tr><th>$prettyprint{$j}</th><td>$keys</td></tr>");
    }

      # end cell that contains semantic table and also outer table itself
      push(@table, "</table></td></tr></table>");

      # links to next and previous strips

      my($strip) = $strips[$l-1];
      my($date) = strftime("%d %b %Y (%A)", gmtime(str2time($strip)));
      my($prev) = "{{WikiLink|$strip|<< $date}}";
      my($prev) = "[[$strip|<< $date]]";

      $strip = $strips[$l+1];
      $date = strftime("%d %b %Y (%A)", gmtime(str2time($strip)));
      my($next) = "{{WikiLink|$strip|$date >>}}";
      my($next) = "[[$strip|$date >>]]";

      # special cases
      if ($l==0) {$prev="<b>No previous strip</b>";}
      if ($l==$#strips) {$next="<b>No next strip</b>";}

      # print to file
      open(A, ">$etcdir/$i.mw.new");
      # the table
      print A join("\n", @table),"\n";
      # below the table
      print A join("\n", @outer),"\n";
      # the categories
      print A join("\n", @cats),"\n";
      # the prev/next bar
      print A "<table width=100%><tr><td>$prev</td><td align=right>$next</td></tr></table>\n";
      # and done
      close(A);

      # only replace existing file if changed
      mv_after_diff("$etcdir/$i.mw");
  }
}

# create the per-day strips
# TODO: category: strip, table at top, notes/description are
# important, maybe more
# TODO: species determination
# TODO: character renumbering

for $i (sort keys %hash) {

  if (++$count>20) {die "TESTING";}

  unless ($i=~/^\d{4}\-/) {next;}

  # semantical table
  # TODO: using "semantical" for testing, change to "semantic"

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

    # turn keys into useful semantic information
    for $k (@keys) {
      $k=~s/\{\{wp\|(.*?)\}\}/$1/g;
      $k="[[${j}::$k]]";
    }

    my($keys) = join("<br>\n",@keys);
    push(@table,"<tr><th>$prettyprint{$j}</th><td>$keys</td></tr>");
  }

  push(@table,"</table>","</td></tr></table>");
#  print A "__SHOWFACTBOX__\n";

  print A join("\n",@table),"\n";

  print A "<table width=100%><tr><td>&lt;&lt; PREV (not working)</td><td align=right>NEXT (not working) &gt;&gt;</td></tr></table>\n";

  print A "\n[[Category: Strips]]\n";
  close(A);
  mv_after_diff("/usr/local/etc/metawiki/pbs-referata/$i.mw");
}

# creates the table used to display a given strip (referata version)

sub pbs_table_date {
  my($date) = @_;
  unless ($date=~m/^(\d{4})\-(\d{2})\-(\d{2})$/) {warn "BAD DATE: $date";}
  my($link) = "http://www.gocomics.com/pearlsbeforeswine/$1/$2/$3";
  my($pdate) =  strftime("%d %b %Y (%A)", gmtime(str2time($date)));

  # notes for this strip
#  my($notes) = join(". ",sort keys %{$hash{$date}{notes}});
  # remove wp links
#  $notes=~s/\{\{\#NewWindowLink:\s+.*?\|(.*?)\}\}/$1/isg;
  # fix up quotation marks
#  $notes=~s/\"/&quot;/isg;

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
}

# TODO: move this to bclib.pl

=item mv_after_diff($source, $options)

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

