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

# parse_semantic("2007-04-16","[[storyline::[[character::Junior]] dates [[character::[[Zebra::niece::Joy]]]]]]");
# parse_semantic("2007-04-16","[[character::[[Zebra::niece::Joy]]]]]]");
# debug(unfold({%triples}));
# parse_semantic("2014-03-07", "[[character::Rat+Pig+[[deaths::Bob (lemming)]]]]");

# run subroutines to do stuff
pbs_parse_data();
pbs_characters();
pbs_annotations();
pbs_storylines();
for $i ("crocodile", "penguin", "human", "antelope", "zebra") {
  pbs_species_deaths($i);
}
pbs_newspaper_mentions();
die "TESTING";
pbs_date_pages();
# putting data into a db and immediately extracting it seems useless
# but hopefully isn't

my(@storylines) = sqlite3hashlist("SELECT v, GROUP_CONCAT(source) AS dates FROM triples WHERE k='storyline' GROUP BY v ORDER BY MIN(source)", "/tmp/pbs-triples.db");

# where the storylines go
@storylinesmw = ();

for $i (@storylines) {
  push(@storylinesmw, "* $i->{v}");
  for $j (split(/\,/, $i->{dates})) {
    push(@storylinesmw, ":: ".pbs_table_date($j)."<br />");
  }
  push(@storylinesmw, "");
}

$storylinesmw = join("\n", @storylinesmw)."\n";

write_file_new($storylinesmw, "/usr/local/etc/metawiki/pbs/Storylines.mw", "diff=1");

die "TESTING";

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

sub pbs_characters {
  my(@ret) = ("{| class='sortable' border='1' cellpadding='7'","!Name","!First","!#");
  # TODO: add akas for name
#  warn "LIMIT!";
  # TODO: use of 'deaths' to mean 'character' below is a kludge
  for $i (sqlite3hashlist("SELECT v AS name,
 MIN(source) AS first, COUNT(*) AS count FROM triples
 WHERE k IN ('character', 'deaths') GROUP BY name ORDER BY name", 
 "/tmp/pbs-triples.db")) {
#    push(@ret, "|-", "|[[$i->{name}]]", "|[[$i->{first}]]", "|$i->{count}");
    push(@ret, "|-", "|[[$i->{name}]]", "|data-sort-value=$i->{first}|".pbs_table_date($i->{first}), "|$i->{count}");
  }
  push(@ret, "|}");
  write_file_new(join("\n",@ret), "/usr/local/etc/metawiki/pbs/Characters.mw", "diff=1");

}

# note the same storylines page I created earlier, this one is a table
sub pbs_storylines {
  my(@ret) = ("{| class='sortable' border='1' cellpadding='7'","!Storyline","!Start","!End","!Strips");
  for $i (sqlite3hashlist("SELECT v, MIN(source) AS mindate, MAX(source) AS maxdate, COUNT(*) AS count, GROUP_CONCAT(source) AS dates FROM triples WHERE k='storyline' GROUP BY v ORDER BY mindate", "/tmp/pbs-triples.db")) {

    # TODO: create page for each storyline w list of strips (similar
    # to my old Storylines page:
    # http://pearls-before-swine-bc.wikia.com/wiki/Storylines?oldid=8568

    # the page name is the storyline name cleaned up
    my($pagename) = $i->{v};
    # TODO: need to get rid of "new window link" stuff too, harder
    $pagename=~s/[\[\]]//isg;
    debug("PN: $pagename");
    $pagename=~s/\{\{\#NewWindowLink:\s+.*?\|(.*?)\}\}/$1/isg;
    debug("PNB: $pagename");

    push(@ret, "|-", "|$i->{v} ([[$pagename|link]])", "|$i->{mindate}", "|$i->{maxdate}", "|$i->{count}");
  }
  push(@ret, "|}");
  write_file_new(join("\n",@ret), "/usr/local/etc/metawiki/pbs/Storylines.mw", "diff=1");
}

# significant events
sub pbs_sig_events {
  my(@ret);
#  for $i (sqlite3hashlist("SELECT 
}

# creates the "newspaper mentions" page
sub pbs_newspaper_mentions {
  my(@ret);
  for $i (sqlite3hashlist("SELECT v, GROUP_CONCAT(source) AS dates FROM triples WHERE k='newspaper_mentions' GROUP BY v ORDER BY v","/tmp/pbs-triples.db")) {
    push(@ret, "* $i->{v}");
    for $j (split(/\,/, $i->{dates})) {
      push(@ret, ":: ".pbs_table_date($j)."<br />");
    }
    push(@ret,"");
  }
  push(@ret,"");
  write_file_new(join("\n",@ret), "/usr/local/etc/metawiki/pbs/Newspaper_Mentions.mw", "diff=1");
}

# creates .txt files to annotate PBS strips using feh
sub pbs_annotations {
  # ugly but needed (remove txt files created earlier by mistake)
  system("rm /mnt/extdrive/GOCOMICS/pearlsbeforeswine/page-*.gif.txt");
  for $i (sqlite3hashlist('SELECT source, GROUP_CONCAT(k||","||v,"<CR>") AS data FROM triples WHERE source LIKE "2%" GROUP BY source', "/tmp/pbs-triples.db")) {
    $i->{data}=~s/<CR>/\n/isg;
    write_file($i->{data}, "/mnt/extdrive/GOCOMICS/pearlsbeforeswine/page-$i->{source}.gif.txt");
  }
}

# creates many pages with notes (per-strip pages) + Observations page
# TODO: temporarily turned off the per-date pages (too many pages?)
sub pbs_date_pages {
  my(@obs) = ("<table border>");
  for $i (sqlite3hashlist("SELECT source, GROUP_CONCAT(v) AS notes FROM triples WHERE k='notes' GROUP BY source", "/tmp/pbs-triples.db")) {
    # for the Observations page
    push(@obs, "<tr><th>",pbs_table_date($i->{source}),"</th><td>$i->{notes}</td></tr>");
    # write the strip and the notes
#   my($str) = pbs_table_date($i->{source})."\n\n== Notes ==\n\n$i->{notes}\n";
#   write_file_new($str, "/usr/local/etc/metawiki/pbs/$i->{source}.mw", "diff=1");
  }
  write_file_new(join("\n",@obs)."\n</table>\n", "/usr/local/etc/metawiki/pbs/Observations.mw");
}

# parses the data in pbs.txt and pbs-cl.txt and creates
# /tmp/pbs-triples.db, which is required by other subroutines
# also creates the (sadly global) %link hash
# TODO: %triples is a global variable, which is probably bad

sub pbs_parse_data {
  # links to high-res version of each strip
  for $i (split(/\n/, read_file("/home/barrycarter/BCGIT/METAWIKI/largeimagelinks.txt"))) {
    $i=~s/^(.*?)\s+(.*)$//;
    $link{$1}=$2;
  }

  my($data) = read_file("/home/barrycarter/BCGIT/METAWIKI/pbs.txt");
  $data=~s%^.*?<data>(.*?)</data>.*$%$1%s;

  # and the data from pbs-cl.txt
  $data = "$data\n".read_file("/home/barrycarter/BCGIT/METAWIKI/pbs-cl.txt");

  # parse the data
  for $i (split(/\n/, $data)) {
    # ignore blanks and comments
    if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

    # warn if the line contains a single colon (but keep parsing it)
    if ($i=~/[^:]:[^:]/) {warn "BAD LINE: $i";}

    # fix wp template
#    debug("PRE: $i");
    $i=~s/\{\{wp\|(.*?)\}\}/"{{#NewWindowLink: http:\/\/en.wikipedia.org\/wiki\/".fix_wp_template($1)."}}"/iseg;
#    debug("POST: $i");

    # split line into source page and then body
    $i=~/^(.*?)\s*($dlb.*)$/;
    my($source, $body) = ($1,$2);
    parse_semantic($source,$body);
  }

  local(*A);
  # create empty db (being this direct this is probably bad)
  open(A,"|tee /tmp/debug.txt|sqlite3 /tmp/pbs-triples.db 1>/tmp/pbs-myout.txt 2>/tmp/pbs-myerr.txt");
  # open(A,">/tmp/mysql.txt");
  print A << "MARK";
DROP TABLE IF EXISTS triples;
CREATE TABLE triples (source, k, v);
CREATE INDEX i1 ON triples(source);
CREATE INDEX i2 ON triples(k);
CREATE INDEX i3 ON triples(v);
BEGIN;
DELETE FROM triples;
MARK
;
  # now insert the data
  for $i (sort keys %triples) {
    # TODO: ignoring nondates for now (really really bad)
#    unless ($i=~/^\d{4}/) {next;}
    for $j (keys %{$triples{$i}}) {
      for $k (keys %{$triples{$i}{$j}}) {
	# will this work?
	for $l ($i,$j,$k) {
	  # restore [[ and ]] for printing and fix apos
	  $l=~s/\001/\[\[/isg;
	  $l=~s/\002/\]\]/isg;
	  $l=~s/\'/&\#39;/isg;
	}

	# restore [[ and ]] for printing and fix apos
#	$k=~s/\001/\[\[/isg;
#	$k=~s/\002/\]\]/isg;
#	$k=~s/\'/&\#39;/isg;
	print A "INSERT INTO triples VALUES ('$i','$j','$k');\n";
      }
    }
  }

  print A "COMMIT;\n";
  close(A);
}

# creates the table used to display a given strip (overrides date2prli)

sub pbs_table_date {
  my($date) = @_;
  unless ($date=~m/^(\d{4})\-(\d{2})\-(\d{2})$/) {warn "BAD DATE: $date";}
  my($link) = "http://www.gocomics.com/pearlsbeforeswine/$1/$2/$3";
  my($pdate) =  strftime("%d %b %Y (%A)", gmtime(str2time($date)));
  # NOTE: this must be one single line for formatting reasons (wikia)
  return << "MARK";
<table border><tr><th>{{#NewWindowLink: $date | $pdate}}</th></tr><tr><th>{{#NewWindowLink: $link | <verbatim>$date</verbatim>}}</th></tr><tr><th>{{#NewWindowLink: $link{$date} | (highest resolution)}}</th></tr></table>
MARK
;
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
  debug("parse_semantic($source, $string)");

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
  # TESTING!!!!
#  if (scalar @list <= 1) {return $string;};

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
	  debug("TRIPLE (one double colon): $k,$i,$j");
	  $triples{$k}{$i}{$j}=1;
	}
      }
    }
    debug("RETURNING (one double colon) [[$pval{$list[1]}]]");
    return $pval{$list[1]};
  }

  # only remaining legit case
  if (scalar @list == 3) {
    for $i (@{$lol[0]}) {
      for $j (@{$lol[1]}) {
	for $k (@{$lol[2]}) {
	  if (scalar @dates != 1) {warn("DATELIST($string) SHOULD BE 1 element only, not @dates");}
	  for $l (@dates) {
	    # TODO: currently, a GLOBAL hash to hold triples
	    debug("TRIPLE: $i,$j,$k");
	    $triples{$i}{$j}{$k}=1;
	    $triples{"$i~$j~$k",}{"source"}{$l} = 1;
	  }
	}
      }
    }
#    debug("RETURNING $pval{$list[2]} (in brackets)");
    debug("RETURNING [[$pval{$list[2]}]]");
    return $pval{$list[2]};
  }
}

# breaking this up into one subroutine per page (or so) is a bad idea,
# but really useful for testing

sub pbs_species_deaths {
  # probably only useful for zebra and crocodile...
  my($species) = @_;

  # the return array (joined to create the return string)
  my(@ret) = ("<table border><tr><th>Strip</th><th>Details</th></tr>");
  # running total
  my($rtot);

  # This query cheats in many ways; eg, it assumes ALL deaths on a
  # given day are of the same species
  my($query) = << "MARK";
SELECT t1.source, t1.v AS num, GROUP_CONCAT(t2.v) AS names 
 FROM triples t1 LEFT JOIN triples t2 ON 
 (t1.source = t2.source AND t2.k='deaths')
WHERE t1.k = '${species}_deaths' GROUP BY t1.source, t1.v ORDER BY t1.source;
MARK
;
  my(@res) = sqlite3hashlist($query,"/tmp/pbs-triples.db");
  for $i (@res) {
    # running total
    $rtot += $i->{num};

    # remove all brackets from names
    $i->{names}=~s/[\[\]]//g;
    # list of names
    my(@names) = split(/\,/,$i->{names});
    # add brackets to all
    map($_="[[$_]]", @names);
    # and join with comma space
    my($names) = join(", ",@names);
    # TODO: handle case where one name known, other not
    unless ($names) {$names = "[unknown]";}

    push(@ret, "<tr><td>".pbs_table_date($i->{source})."</td>
<td>Who: $names<br>How many: $i->{num}<br>Running Total: $rtot</td></tr>");
  }
  push(@ret,"</table>");

  my($ucspec) = ucfirst($species);
  write_file_new(join("\n",@ret)."\n", "/usr/local/etc/metawiki/pbs/${ucspec}_Deaths.mw", "diff=1");
}

# kludge fix for wikipedia templates (I use them wrong in pbs.txt)
# from {{wp|foo|bar}}, this function gets "foo|bar"
sub fix_wp_template {
  my($str) = @_;
  my($link, $text) = split(/\|/, $str);
  # if there is no text, set it to the link (before despacing the link)
  unless ($text) {$text=$link;}
  # remove link spaces
  $link=~s/\s/_/g;
  return "$link|$text";
}

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
