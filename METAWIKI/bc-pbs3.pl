#!/bin/perl

# yet another attempt (still feel I'm not doing it "quite right")

require "/usr/local/lib/bclib.pl";

chdir("/home/barrycarter/BCGIT/METAWIKI/");

# TODO: largeimagelinks.txt and MULTIREF
# create_pbs_db();

# TODO: watch out for "double aliasing" (misc2.sql does NOT currently catch it)
# aliases

# fix numbered characters

for $i (sqlite3hashlist("
 SELECT DISTINCT target FROM triples WHERE target  GLOB 
 '* [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*' UNION
 SELECT DISTINCT source FROM triples WHERE source  GLOB 
 '* [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*' ORDER BY 1
", "/var/tmp/pbs-play.db")) {
  debug("I:", unfold($i));
}

sub fix_pbs_aka {
  open(A,"|sqlite3 /var/tmp/pbs-play.db");
  print A "BEGIN;\n";

  for $i (sqlite3hashlist("SELECT * FROM triples WHERE relation='aka'", "/var/tmp/pbs-play.db")) {
    for $j ("source", "target") {
      print A "UPDATE triples SET $j='$i->{source}' WHERE $j='$i->{target}'
               AND relation NOT IN ('aka', 'storyline');\n";
    }
  }
  print A "COMMIT;\n";
}

sub create_pbs_db {

  my($all) = read_file("pbs.txt");
  $all=~m%<data>(.*?)</data>%s;
  for $i (split(/\n/, $1.read_file("pbs-cl.txt"))) {
    $i=~s/^(\S+)\s+//;
    my($dates) = $1;
    $i=~s/\'/&\#39\;/g;
    $i=~s/,/&\#44\;/g;
    while ($i=~s/\[\[([^\[\]]*?)\]\]/\001/) {
      my(@anno) = ($dates, split(/::/, $1));
      push(@triples, [@anno]);
      $i=~s/\001/$anno[-1]/;
    }
  }

  open(A,"|tee /tmp/bc-pbs3.txt|sqlite3 /var/tmp/pbs-play.db");
  print A << "MARK";
DROP TABLE IF EXISTS triples;
CREATE TABLE triples (source, relation, target, datasource);
CREATE INDEX i1 ON triples(source);
CREATE INDEX i2 ON triples(relation);
CREATE INDEX i3 ON triples(target);
BEGIN;
MARK
;

  for $i (@triples) {
    # len 3 -> date, rel, val, ignore; len 4 -> source, entity, rel, val
    for $j (parse_date_list($i->[0])) {
      for $k (split(/\+/, $i->[1])) {
	for $l (split(/\+/, $i->[2])) {
	  if (scalar(@$i) == 3) {
	    print A "INSERT INTO triples VALUES ('$j', '$k', '$l', '$j');\n";
	  } elsif (scalar(@$i) == 4) {
	    for $m (split/\+/, $i->[3]) {
	      print A "INSERT INTO triples VALUES ('$k', '$l', '$m', '$j');\n";
	    }
	  }
	}
      }
    }
  }

  print A "COMMIT;\n";
  close(A);
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
