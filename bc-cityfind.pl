#!/bin/perl

# given a list of placenames on the command line, attempts to find the
# canonical place name for each

# requires (and is really just a thin wrapper around) the
# geonames/geonames.db at:
# http://geonames.db.94y.info/

# Example: $0 paris santa.fe.new.mexico.united.states chicago.us
# corpus.christi.tx portugal michigan james.island tx.amarillo us.tx
# us.amarillo "portland oregon" "portland maine"

# TODO: add elevation and timezone

push(@INC, "/usr/local/lib");
require "bclib.pl";
($tmp1, $tmp2) = (my_tmpfile("cityp"),my_tmpfile("cityq"));

for $i (@ARGV) {
  # lc everything
  $i=lc($i);
  # change all non chars into dots
  push(@final, partition(0,$i,split(/[^a-z]+/i,$i)));
  # reverse code only works if nonalpha splits admins
  # GOOD: us.fl.miami
  # BAD: united.states.fl.miami (read as Miami, FL, States United)
  push(@final, partition(1,$i,split(/[^a-z]+/i,$i)));
}

write_file(join("\n",@final),$tmp1);

write_file("
CREATE TABLE match1 (count INT, orig TEXT, c1 TEXT, c2 TEXT, c3 TEXT, c4 TEXT);
CREATE INDEX i_c1 ON match1(c1);
CREATE INDEX i_c2 ON match1(c2);
CREATE INDEX i_c3 ON match1(c3);
CREATE INDEX i_c4 ON match1(c4);
CREATE INDEX i_count ON match1(count);
.separator \"\\t\"
.import $tmp1 match1

ATTACH DATABASE '/sites/DB/geonames.db' AS geonames;

SELECT m.orig, gn1.geonameid, gn1.asciiname, gn5.asciiname, gn6.asciiname, 
 gn1.population, gn1.latitude/((1<<24)-1.)*180.,
 gn1.longitude/((1<<24)-1.)*360.,
 tz.name
FROM match1 m
 JOIN geonames.altnames an1 ON (m.c1 = an1.name)
 JOIN geonames.geonames gn1 ON (an1.geonameid = gn1.geonameid)
 JOIN geonames.altnames an2 ON (m.c2 = an2.name)
 JOIN geonames.geonames gn2 ON (an2.geonameid = gn2.geonameid)
 JOIN geonames.altnames an3 ON (m.c3 = an3.name)
 JOIN geonames.geonames gn3 ON (an3.geonameid = gn3.geonameid)
 JOIN geonames.altnames an4 ON (m.c4 = an4.name)
 JOIN geonames.geonames gn4 ON (an4.geonameid = gn4.geonameid)
 JOIN geonames.tzones tz ON (gn1.timezone = tz.timezoneid)
 LEFT JOIN geonames.geonames gn5 ON (gn1.admin1_code = gn5.geonameid)
 LEFT JOIN geonames.geonames gn6 ON (gn1.country_code = gn6.geonameid)
WHERE

 gn2.geonameid IN (0, gn1.admin4_code, gn1.admin3_code, gn1.admin2_code,
                   gn1.admin1_code, gn1.country_code) AND

 gn3.geonameid IN (0, gn2.admin4_code, gn2.admin3_code, gn2.admin2_code,
                   gn2.admin1_code, gn2.country_code) AND

 gn4.geonameid IN (0, gn3.admin4_code, gn3.admin3_code, gn3.admin2_code,
                   gn3.admin1_code, gn3.country_code)
ORDER BY m.count, gn1.population DESC
;", $tmp2);

($out,$err,$res) = cache_command("sqlite3 < $tmp2");

# choose the first row for each code
for $i (split("\n",$out)) {
  $i=~/^(.*?)\t/;
  $val = $1;
  if ($hash{$val}) {next;}
  $hash{$val} = $i;
}

# and now the results
for $i (@ARGV) {
  # TODO: improve output format
  if ($hash{$i}) {
    print "$i: $hash{$i}\n";
  } else {
    print "$i: NOT FOUND\n";
  }
}

sub partition {
  my($rev, $code, @list) = @_;
  my(@ret);

  if ($rev) {@list = reverse(@list);}

  for $i (0..$#list) {
    for $j ($i..$#list) {
      for $k ($j..$#list) {
	$count++;
	my(@l1) = @list[0..$i];
	my(@l2) = @list[$i+1..$j];
	my(@l3) = @list[$j+1..$k];
	my(@l4) = @list[$k+1..$#list];
	push(@ret,join("\t",$count,$code,
		       join("",@l1),join("",@l2),join("",@l3),join("",@l4)));
      }
    }
  }
  return @ret;
}
