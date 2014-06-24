#!/bin/perl

# potentially better way of parsing stuff (ultimately for referata.com)

# TODO: download auto-generated form stuff (like Template:Strip) from
# referata.com

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/barrycarter/BCGIT/METAWIKI")');
my($etcdir) = "/usr/local/etc/metawiki/pbs-referata";

# relations I'm ignoring for now (null/meta = ignore forever)
# NOTE: category is doubly special
my(%ignore) = list2hash("null", "meta", "char_list_complete", "source",
			"noref", "cameo", "category");

my(%hash);
# get large image links (hack for now)
for $i (split(/\n/, read_file("largeimagelinks.txt"))) {
  $i=~s/^(.*?)\s+(.*)$//;
  $hash{$1}{image_url}{$2}=1;
  # this is ugly, not all strips have annotations
  $hash{strip}{$1} = 1;

}

# load meta data (TODO: this is cheating, only one section so far)
for $i (`egrep -v '<|#|^\$' pbs-meta.txt`) {
  chomp($i);
  my(@data) = split(/\, /, $i);
  $meta{$data[0]} = [@data];

  # if the result type is string, mark this as a "property" not "relation"
  if ($data[4] eq "string") {
    debug("SETTING $data[1] type to prop");
    $meta{$data[1]}{type} = "property";
  }
}

# defines the pretty prints of SOME of the semantic relations above
my(%prettyprint) = 
(
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
  debug("$source/$k/$v");

  # TODO: ignoring deaths for now
  if ($ignore{$k} || $k=~/_deaths$/) {next;}

  my($ignore, $for, $rev, $stype, $ttype) = @{$meta{$k}};

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
    $i = $strips[$l];

    if ($l > 20) {die "TESTING";}

    debug("{{strip");
    for $j (sort keys %{$hash{$i}}) {
      my($keys) = join(", ",sort keys %{$hash{$i}{$j}});
      debug("|$j=$keys");
    }
    debug("}}");

    die "TESTING";

    # hidden properties (required for templating results)
    unless ($i=~m/^(\d{4})\-(\d{2})\-(\d{2})$/){warn "BAD DATE: $i"; return;}
    my($link) = "http://www.gocomics.com/pearlsbeforeswine/$1/$2/$3";
    my(@hash) = keys %{$hash{$i}{image_url}};
    $hash[0]=~s/^.*?([^\/]*?)\?width\=.*$/$1/;
    my($pdate) =  strftime("%d %b %Y (%A)", gmtime(str2time($i)));
    my(@hidden) = ("[[has_link::$link| ]]", "[[has_date::$i| ]]",
		   "[[has_pdate::$pdate| ]]", "[[has_hash::$hash[0]| ]]");

    # the big table (containing date table and semantic annotations)
    my(@table) = ("<table width=100%><tr><th>", pbs_table_date($i),
		     "</th><td align=right valign=top>");
    # don't publish the image URL directly
    delete $hash{$i}{image_url};

    # the semantic information table (row 1, column 2 of big table)
#    push(@table, "<table border><tr><th colspan=2>Semantic Information</th></tr>");

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

      debug("J: $j, $meta{$j}{type}");

      # the values for this key
      my(@keys) = sort keys %{$hash{$i}{$j}};

      # not sure why this happens, but ignore it quietly
      # TODO: look into this Perl oddness
      unless (@keys) {next;}

      # if $j is a property (not a relation), print it outside any table
      if ($meta{$j}{type} eq "property") {
	push(@outer,  "== $prettyprint{$j} ==\n");
	push(@outer, join("\n",@keys), "\n");
	next;
      }

      # $j is a true relation, not just a property
      # turn keys into useful semantic information
      for $k (@keys) {
	$k=~s/\{\{wp\|(.*?)\}\}/$1/g;
#	$k="[[${j}::$k]]";
      }

      # join for printing
#      my($keys) = join("<br>\n",@keys);
      my($keys) = join(", ",@keys);

      # and put into semantic (small) table and end small table
#      push(@table, "<tr><th>$prettyprint{$j}</th><td>$keys</td></tr>");
      push(@table, "|$j=$keys");
    }

      # end cell that contains semantic table and also outer table itself
#      push(@table, "</table></td></tr></table>");

    debug("TABLE",@table);

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
      # the prev/next bar
    print A "<table width=100%><tr><td>$prev</td><td align=right>$next</td></tr></table>\n";
    # hidden props
    print A join("\n", @hidden),"\n";
      # the categories
      print A join("\n", @cats),"\n";
      # and done
      close(A);

      # only replace existing file if changed
      mv_after_diff("$etcdir/$i.mw");
  }
}

# TODO: species determination
# TODO: character renumbering

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

  # the first parameter is intentionally blank below
  return "{{DateTable| |$date|$pdate|$link|$thumb}}";

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

