#!/bin/perl

# yet another attempt (still feel I'm not doing it "quite right")

require "/usr/local/lib/bclib.pl";

chdir("/home/barrycarter/BCGIT/METAWIKI/");

# TODO: MULTIREF

# TODO: watch out for "double aliasing" (misc2.sql does NOT currently catch it)
# aliases

open(A, "|sqlite3 /var/tmp/pbs3.db");
for $i ("BEGIN",pbs_schema(),pbs_create_db(),pbs_largeimagelinks(),"COMMIT") {
  print A "$i;\n";
}
close(A);

# this must be called after db is populated
my(@querys) = pbs_fix_numbered_characters();

# and now done in a for loop (separately, since db closed after above)
open(A, "|tee /tmp/output.txt|sqlite3 /var/tmp/pbs3.db");
 for $i ("BEGIN",@querys,"COMMIT") {print A "$i;\n";}
close(A);

# cleanup
system("sqlite3 /var/tmp/pbs3.db < misc2.sql");

# now the query to create the files (splitting on triple pipe avoids
# problems with {{wp|foo}})

my($query) = << "MARK";
SELECT source, GROUP_CONCAT(data,"|||") AS data FROM (
SELECT source, relation||'='||GROUP_CONCAT(target,", ") AS data FROM (
SELECT DISTINCT t1.source, t2.relation, t2.target
 FROM triples t1 JOIN triples t2 ON (t1.source=t2.source)
ORDER BY t1.source, t2.relation, t2.target
) GROUP BY source, relation ORDER BY source, relation
) GROUP BY source ORDER BY source
MARK
;

$pagedir = "/usr/local/etc/metawiki/pbs3-test";
for $i (sqlite3hashlist($query, "/var/tmp/pbs3.db")) {
  # fix commas
  $i->{source}=~s/&\#44\;/,/g;
  $i->{data}=~s/&\#44\;/,/g;
  # remove braces (cant have these in a title)
  debug("ALPHA: $i->{source}");
  $i->{source}=~s/\{\{.*?\|(.*?)\}\}/$1/g;
  $i->{source}=~s/[\[\[]//g;
  debug("BETA: $i->{source}");

  # this works because Perl can cast lists to hashes
  my(%hash) = split(/\|\|\||\=/, $i->{data});
  if ($hash{class}=~/,/) {
    warn "$i->{source}: $hash{class} (multiple classes)";
    next;
  }

  debug("WRITING: $i->{source}");
  open(A, ">$pagedir/$i->{source}.mw");
  print A "{{$hash{class}\n|title=$i->{source}\n";
  # this seems ugly, since I have it in almost the form I need it
  for $j (sort keys %hash) {print A "|$j=$hash{$j}\n";}
  print A "}}\n";
  close(A);
}

# queries to provide largeimagelinks for each strip
sub pbs_largeimagelinks {
  my(@res);
  for $i (split(/\n/, read_file("largeimagelinks.txt"))) {
    $i=~s/^(.*?)\s+.*?\/([0-9a-f]+)\?.*$//;
    push(@res, "INSERT INTO triples (source, relation, target, datasource)
VALUES ('$1', 'hash', '$2', 'largeimagelinks.txt')");
  }
  return @res;
}

# fix numbered characters
sub pbs_fix_numbered_characters {
  my(@res);

  my($query) = << "MARK";
SELECT char, MIN(mindate) AS min FROM (
SELECT source AS char, REPLACE(MIN(datasource),'-','') AS mindate 
FROM triples WHERE source GLOB '* [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
GROUP BY source UNION
SELECT target AS char, REPLACE(MIN(datasource),'-','') AS mindate
FROM triples WHERE target GLOB '* [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
AND relation NOT IN ('notes', 'description', 'event') GROUP BY target
) GROUP BY char ORDER BY char;
MARK
;

  for $i (sqlite3hashlist($query, "/var/tmp/pbs3.db")) {
    $i->{char}=~/^(.*?)\s+(\d{8})\s*\((.*?)\)$/||warn("BAD CHAR: $i->{char}");
    my($base, $date, $species) = ($1, $2, $3);
    unless ($date == $i->{min}) {warn("$i->{char} NOMATCH: $date/$i->{min}");}
    my($newname) = "$base ($species) &#65283;".sprintf("%0.2d",++$times{$base}{$species});
#    debug("GAMMA: $i->{char} -> $newname");
    push(@res,"INSERT INTO triples (source, relation, target, datasource) VALUES ('$newname', 'reference_name', '$i->{char}', 'pbs_fix_numbered_characters')");
    for $j ("source", "target") {
      # below covers cases where char appears in notes/descriptions/etc
      push(@res,"UPDATE triples SET $j=REPLACE($j,'$i->{char}','$newname') WHERE $j LIKE '%$i->{char}%' AND relation NOT IN ('reference_name')");
    }
  }
  return @res;
}

# Querys to populate the database (but not create it)

sub pbs_create_db {
  my(@triples,@res,$multiref);

  my($all) = read_file("pbs.txt");
  $all=~m%<data>(.*?)</data>%s;
  for $i (split(/\n/, $1.read_file("pbs-cl.txt"))) {
    $i=~s/^(\S+)\s+//;
    my($dates) = $1;

    # TODO: this is a hack
#    $i=~s/\{\{wp\|//g;
#    $i=~s/\}\}//g;

    # distinguish multirefs and turn [[foo]] into [[dates::foo]]
    if ($dates eq "MULTIREF") {
      # TODO: these are both serious hacks
      $dates="MULTIREF".++$multiref;
      $i=~s/\[\[(\d{4}\-\d{2}\-\d{2})\]\]/[[dates::$1]]/g;
#      debug("I: $i");
    }

    $i=~s/\'/&\#39\;/g;
    $i=~s/,/&\#44\;/g;
#    debug("ALPHA: $i");
    while ($i=~s/\[\[([^\[\]]*?)\]\]/\001/) {
#      debug("BETA: $i");
      my(@anno) = ($dates, split(/::/, $1));
#      debug("ANNO". join(", ",@anno));

      # this preserves [[double brackets]] in things like notes
      if (scalar @anno > 2) {
	push(@triples, [@anno]);
	$i=~s/\001/$anno[-1]/;
      } else {
	$i=~s/\001/\002$anno[-1]\003/;
      }
    }
  }

  for $i (@triples) {
    # cleanup the [[problem]]
    debug("I23: $i->[2], $i->[3]");
    $i->[2]=~s/\002(.*?)\003/[[$1]]/g;
#    $i->[3]=~s/\002(.*?)\003/[[$1]]/g;

    # len 3 -> date, rel, val, ignore; len 4 -> source, entity, rel, val
    for $j (parse_date_list($i->[0])) {
      for $k (split(/\+/, $i->[1])) {
	for $l (split(/\+/, $i->[2])) {
	  if (scalar(@$i) == 3) {
	    push(@res,"INSERT INTO triples VALUES ('$j', '$k', '$l', '$j')");
	  } elsif (scalar(@$i) == 4) {
	    for $m (split/\+/, $i->[3]) {
	      push(@res,"INSERT INTO triples VALUES ('$k', '$l', '$m', '$j')");
	    }
	  }
	}
      }
    }
  }
  return @res;
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

# literally just returns the schema
sub pbs_schema {
  return ("DROP TABLE IF EXISTS triples",
	  "CREATE TABLE triples (source, relation, target, datasource)",
	  "CREATE INDEX i1 ON triples(source)",
	  "CREATE INDEX i2 ON triples(relation)",
	  "CREATE INDEX i3 ON triples(target)"
	  );
}
