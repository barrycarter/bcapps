#!/bin/perl

require "/usr/local/lib/bclib.pl";

chdir("/home/barrycarter/BCGIT/METAWIKI/");

for $i (`cat pbs.txt pbs-cl.txt | egrep -v '^#|^\$'`) {
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

for $i (@triples) {
  # len 3 -> date, rel, val, ignore; len 4 -> source, entity, rel, val
  for $j (parse_date_list($i->[0])) {
    for $k (split(/\+/, $i->[1])) {
      for $l (split(/\+/, $i->[2])) {
	if (scalar(@$i) == 3) {
	  debug("ALPHA: $j/$k/$l/$j");
	} elsif (scalar(@$i) == 4) {
	  for $m (split/\+/, $i->[3]) {
	    debug("BETA: $k/$l/$m/$j");
	  }
	}
      }
    }
  }
}

die "TESTING";

debug(unfold(@triples));

die "TESTING";

open(A,"| tee /tmp/pbs-simple.txt |sqlite3 /tmp/pbs-simple.db");
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
  print A "INSERT INTO triples VALUES ('$i->[0]','$i->[1]','$i->[2]','$i->[3]');\n";
}

print A "COMMIT;\n";
close(A);

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
