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

# things that are considered relations (not necessarily relatives)
%rel = list2hash(split(/,\s+/, "cousin, uncle, aunt, husband, brother,
ex-husband, grandfather, mother, niece, sister, son, wife, neighbor,
girlfriend, boss, friend, father, half-brother, pet, roommate, date"));

pbs_parse_data();
%data = pbs_all();
pbs_storylines();
pbs_characters();
pbs_species_deaths();
pbs_annotations();
die "TESTING";

# TODO: this seems redundant
for $i (keys %data) {
  for $j (keys %{$data{$i}}) {
    # only death for now
    unless ($j eq "deaths") {next;}
    my(@temp) = keys %{$data{$i}{species}};
    debug("$i/$j/$temp[0]");
  }
}

pbs_newspaper_mentions();
pbs_date_pages();

# run subroutines to do stuff
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

# yet another subroutine, this one attempts to handle ALL triples
# properly (it takes the triples and creates hashes that are hopefully
# more useful)

sub pbs_all {
  # the hash we'll return
  my(%data);
  warn "TESTING";

  # TODO: do I really need an sqlite3 db at all now?
  # because species and aka are overrides, they must come first
  for $i (sqlite3hashlist("
SELECT * FROM triples ORDER BY
 CASE k WHEN 'species' THEN '' WHEN 'aka' THEN '' ELSE v END
", "/tmp/pbs-triples.db")) {
    my($source, $k, $v) = ($i->{source}, $i->{k}, $i->{v});
    debug("LINE: $source/$k/$v");

    # canonize $source and $v (repeatedly if needed)
    # do not canonize storylines
    # TODO: this will still create a conflict for storylines named for chars
    unless ($k eq "storyline") {
      while ($data{$v}{canon}) {$v = $data{$v}{canon};}
      while ($data{$source}{canon}) {$source = $data{$source}{canon};}
    }

    # species/profession
    # TODO: if something has a species/profession, it's necessarily a character?
    if ($k eq "species" || $k eq "profession") {
      $data{$source}{$k}{$v}=1;
      next;
    }

    # aka (need canon name)
    if ($k eq "aka") {
      $data{$source}{alias}{$v} = 1;
      $data{$v}{canon} = $source;
      next;
    }

    # TODO: I'm not crazy about this massive 'switch' statement
    if ($k eq "character" || $k eq "deaths" || $k eq "rebirths") {

      # canonize character name using multiple follows if needed (and continue)

      # if character name (after canonization is "string date string"
      # canonize further (and continue)
      if ($v=~/^(.*?)\s+(\d{8})\s*(.*)$/) {
	my($main, $date, $rest) = ($1, $2, $3);
#	debug("MAIN: $main/$date/$rest, V: $v, KEY: $main $rest");
#	$data{$v}{canon} = "$main ".++$count{"$main $rest"}." $rest";
	# TODO: this format sorts better, but may break other stuff?
	$data{$v}{canon} = "$main $rest ".sprintf("%0.2d",++$count{"$main $rest"});
	debug("CHAR CHANGE: $v -> $data{$v}{canon}");
	$v = $data{$v}{canon};
      }

      # build the list of dates the character appears in
      $data{$v}{appears_in}{$source} = 1;
      # and the list of characters in a given strip
      $data{$source}{character}{$v} = 1;
      # identify as character
      $data{character_q}{$v} = 1;

      # if the character doesn't already have a species, we assign it here
      unless ($data{$v}{species}) {
	if ($v=~m/\s+\((.*?)\)[\s\d]*$/) {
	  $data{$v}{species}{$1}=1;
	} else {
	  $data{$v}{species}{unknown} = 1;
	  debug("UNKNOWN SPECIES: $v");
	}
      }

      # assuming only one species here
      # TODO: this seems hideously redundant
      my(@species) = keys %{$data{$v}{species}};
      my($species) = $species[0];

      # if this is NOT a death, we stop here
      if ($k eq "character") {next;}

      # for rebirths
      if ($k eq "rebirths") {
	# note character rebirth on both character and date
	$data{$v}{rebirth}{$source} = 1;
	$data{$source}{rebirths}{$v} = 1;
	next;
      }

      # note character death on both character and date
      $data{$v}{death}{$source} = 1;
      $data{$source}{deaths}{$v} = 1;
      # and number of species death for day (perhaps multiple)
      $data{$species}{death}{$source} += 1;
      # who of this species died today?
      $data{$source}{deaths}{$species}{$v} = 1;
      # record this is a species that has died at some point
      $data{dead_species_q}{$species} = 1;
      next;
    }

    # for storyline/categories, record strips in storyline/category
    if ($k eq "storyline" || $k eq "category") {
      debug("skv: $source/$k/$v");
      $data{$k}{$v}{$source} = 1;
      $data{$source}{$k}{$v} = 1;
      next;
    }

    # for notes, just note the notes in the data
    if ($k eq "notes") {$data{$source}{notes}{$v} = 1; next;}

    # newspaper mentions by day and paper
    if ($k eq "newspaper_mentions") {
      $data{$source}{newspaper_mentions}{$v} = 1;
      $data{$v}{mentioned_on}{$source} = 1;
      next;
    }

    # ignore meta triples, they are internal
    if ($k eq "meta") {next;}

    # for now, we ignore source triples
    if ($k eq "source") {next;}

    # TODO: ignoring cameos for now, but we will want these later
    if ($k eq "cameo") {next;}

    # note description as part of day
    if ($k eq "description") {
      $data{$source}{description}{$v} = 1;
      next;
    }

    debug("K: $k");

    # relations (relatives, neighbors, etc)
    if ($rel{$k}) {
      debug("REL: $source/$k/$v");
      $data{$source}{relative}{"[[$v]] ($k)"} = 1;
      $data{$v}{relative}{"[[${source}]]'s $k"} = 1;
      next;
    }

    # unnamed species death
    debug("K BERFORE: $k");
    if ($k=~/^(.*?)_deaths$/) {
      debug("DEATH: $k");
      my($species) = $1;
      unless ($v=~s/^\#//) {warn "Extra species death does not start with #";}
      $data{$species}{death}{$source} += $v;
      $data{$source}{deaths}{"Anonymous $species"};
      $data{$source}{deaths}{$species}{"Anonymous $species"} = 1;
      next;
    }

    debug("UNHANDLED: $k");
    # TODO: this is just a default for now
    $data{$source}{$k}{$v} = 1;
    next;

    # TODO: should not ignore this long term
    if ($k eq "newspaper_mentions") {next;}

    # for characters, record appearance
    if ($k eq "character") {
      $data{$v}{appearance}{$source} = 1;
      $data{$source}{characters}{$v} = 1;

      # is this character's species part of his name?
      # do this even if character has another explicit species
      if ($v=~m/\s+\((.*?)\)$/) {
	debug("SETTING: $v/species/$1");
	$data{$v}{species}{$1}=1;
      } else {
	debug("NOT SETTING: $source/$k/$v");
      }

      next;
    }

    # notes
    if ($k eq "notes") {
      $data{$source}{notes}{$v} = 1;
      next;
    }

    # relatives
    if ($rel{$k}) {
      $data{$source}{relative}{$v} = $k;
      # and reverse
      $data{$v}{relative}{$source} = "$k of";
      next;
    }

    # deaths
    if ($k eq "deaths") {
      # a death is an appearance <h>(or a disappearance, ha!)</h>
      $data{$v}{appearance}{$source} = 1;
      $data{$source}{characters}{$v} = 1;
      $data{$v}{deaths}{$source} = 1;
      next;
    }

  }

  return %data;
}

# create all species death pages using improved version of pbs_all above

sub pbs_species_deaths {
  # which species have died at least once?
  for $i (sort keys %{$data{dead_species_q}}) {
    # reset running total and page
    my($runtot) = 0;
    my(@page) = ("<table border><tr><th>Strip</th><th>Details</th></tr>");
    # the days this species died
    for $j (sort keys %{$data{$i}{death}}) {
      # how many
      my($deaths) = $data{$i}{death}{$j};
      $runtot += $deaths;
      # who of this species died on this day
      my(@k) = sort keys %{$data{$j}{deaths}{$i}};
      # this is imperfect because it includes the anonymous characters
      map($_="[[$_]]", @k);
      my($names) = join(", ",@k);
      push(@page, "<tr><td>".pbs_table_date($j)."</td><td>Who: $names<br>How many: $deaths<br>Running Total: $runtot</td></tr>");
#      debug("($i,$j) $deaths ($runtot total): DIERS", @k);
    }
    push(@page, "</table>");
    # dont create pages for species that die infrequently
    # TODO: make this limit less arbitrary
    if ($runtot <= 8) {next;}
    debug("RUNTOT($i): $runtot");
    write_file_new(join("\n",@page)."\n", "/usr/local/etc/metawiki/pbs/".ucfirst($i)."_Deaths.mw", "diff=1");
  }
}

sub pbs_characters {
  my(@page) = ("{| class='sortable' border='1' cellpadding='7'", 
	       "!First","!Data",
	       "!<span title='Sort by name'>#</span>",
	       "!<span title='Sort by first appearance'>#</span>",
	       "!<span title='Sort by latest appearance'>#</span>",
	       "!<span title='Sort by number of appearances'>#</span>",
	       "!<span title='Sort by species'>#</span>",
	       "!<span title='Sort by profession'>#</span>",
	       "!<span title='Sort by date of death'>#</span>",
	       "!<span title='Sort quasi-randomly'>#</span>"
	       );
  for $i (sort keys %{$data{character_q}}) {
    my(@apps) = sort keys %{$data{$i}{appears_in}};
    my($first, $num, $latest) = ($apps[0], scalar @apps, $apps[-1]);
    # use hash to shorten code
    my(%hash) = ();
    for $j (sort keys %{$data{$i}}) {
      $hash{$j} = join(", ", sort keys %{$data{$i}{$j}});
    }

    my(%used_keys) = ();

    my(@table) = ("<table border width=100%>",
		  "<tr><th>Name:</th><td>[[$i]]</td></tr>",
		  "<tr><th>First Appearance:</th><td>[[$first]]</td></tr>",
		  "<tr><th>Latest Appearance:</th><td>[[$latest]]</td></tr>",
		  "<tr><th>Number of Appearances:</th><td>$num</td></tr>"
		  );

    # we no longer need "appears_in"
    $used_keys{appears_in} = 1;

    # others, if they exist (need killed_by as inverse of "kills")
    for $j ("death", "rebirth", "kills", "species", "relative", "profession",
	    "alias", "subspecies", "description", "notes") {
      # early exit if no value
      unless ($hash{$j}) {next;}

      my($printval) = $hash{$j};

      # link to target for these keys
      if ($j eq "death"||$j eq "rebirth"||$j eq "kills") {
	$printval= "[[$printval]]";
      }

      # use newlines instead of commas for printing?
      $printval=~s/, /<br \/>\n/g;

      # in all cases...
      push(@table, "<tr><th>".ucfirst($j)."</th><td>$printval</td></tr>");

      # note that we've used this key
      $used_keys{$j} = 1;
    }

    # the keys we haven't used
    for $j (sort keys %hash) {
      if ($used_keys{$j}) {next;}
      push(@table, "<tr><th>".ucfirst($j)." (extra):</th><td>$hash{$j}</td></tr>");
    }

    my($table) = join("\n", @table)."</table>\n";

    push(@page,"|-", "|".pbs_table_date($first), "|$table", 
	 "|data-sort-value=$i|", "|data-sort-value=$first|",
	 "|data-sort-value=$latest|", "|data-sort-value=$num|",
	 "|data-sort-value=$hash{species}|",
	 "|data-sort-value=$hash{profession}|",
	 "|data-sort-value=$hash{death}|",
	 "|data-sort-value=".rand()."|"
	 );
  }
  debug("ABOUT TO WRITE Characters.mw");
  write_file_new(join("\n",@page)."\n", "/usr/local/etc/metawiki/pbs/Characters.mw", "diff=1");
}

# note the same storylines page I created earlier, this one is a table
sub pbs_storylines {
  my(@page) = ("{| class='sortable' border='1' cellpadding='7'","!Storyline","!First","!Last","!Strips");
  for $i (sort keys %{$data{storyline}}) {
    my(@dates) = sort keys %{$data{storyline}{$i}};
    # cleanup page name for linking
    my($pagename) = $i;
    $pagename=~s/[\[\]]//isg;
    $pagename=~s/\{\{\#NewWindowLink:\s+.*?\|(.*?)\}\}/$1/isg;
    # and list
    push(@page, "|-", "|$i ([[$pagename|link]])", "|data-sort-value=$dates[0]|".pbs_table_date($dates[0]), "|data-sort-value=$dates[-1]|".pbs_table_date($dates[-1]), "|".scalar @dates);
  }

  write_file_new(join("\n",@page), "/usr/local/etc/metawiki/pbs/Storylines.mw", "diff=1");

  return; # old code follows

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
#  warn "Skipping pbs-cl.txt";
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
  open(A,"|tee /tmp/triples.txt|sqlite3 /tmp/pbs-triples.db 1>/tmp/pbs-myout.txt 2>/tmp/pbs-myerr.txt");
  # open(A,">/tmp/mysql.txt");
  print A << "MARK";
DROP TABLE IF EXISTS triples;
CREATE TABLE triples (source, k, v, dir);
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
	print A "INSERT INTO triples VALUES ('$i','$j','$k',
'$triples{$i}{$j}{$k}');\n";
      }
    }
  }

  # TODO: not really happy about this kludge (plus it creates duplicates)
#  print A "INSERT INTO triples SELECT source,'character',v FROM triples WHERE k='deaths';";
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

# version 2 simpler (hoping to do popup, but nothing for now
sub pbs_table_date2 {
  my($date) = @_;
  unless ($date=~m/^(\d{4})\-(\d{2})\-(\d{2})$/) {warn "BAD DATE: $date";}
  my($link) = "http://www.gocomics.com/pearlsbeforeswine/$1/$2/$3";
  my($pdate) =  strftime("%Y-%m-%d [%a]", gmtime(str2time($date)));
  # NOTE: this must be one single line for formatting reasons (wikia)
  return << "MARK";
{{#NewWindowLink: $link | $pdate}}<br>
{{#NewWindowLink: $link{$date} | (highest resolution)}}
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
#  debug("parse_semantic($source, $string)");

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

=item comments

Data we want per-character  (not necess in order; some of these columns should be sortable):

Last/most recent appearance

Death date: [also determine species and put on appropriate "species death" page] (and "killed_by" or "kills")

Rebirth date (if applicable):

Hired:

Fired:

=cut
