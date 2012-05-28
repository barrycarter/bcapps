#!/bin/perl

# Generates alternate names for various large cities and their
# county/state/country. Part of
# http://wordpress.barrycarter.info/index.php/sfcse-society-to-foster-cruelty-to-search-engines/

require "/usr/local/lib/bclib.pl";

# TODO: can I do this as a single efficient db query?
# TODO: change this to 100K or 10K; 1M is just for testing
# TODO: make LIMIT 20 a parameter

# 20 cities over 1M, and the altnames for them, their admin4, etc; see also
# http://b1a018382a48c44e5ebb44a956b7c815.geonames.db.barrycarter.info/
# <h>or don't, it's hideous!</h>

$poplimit = 1e+5;
$number = 20;

# webify
print "Content-type: text/html\n\n<ul>\n";

$query = "SELECT t.*, an.geonameid AS altid, an.name FROM (SELECT * FROM geonames WHERE population > $poplimit ORDER BY RANDOM() LIMIT $number) AS t JOIN altnames an ON (an.geonameid IN (IFNULL(t.geonameid,0), IFNULL(t.admin4_code,0), IFNULL(t.admin3_code,0), IFNULL(t.admin2_code,0), IFNULL(t.admin1_code,0), IFNULL(t.country_code,0)))";

# TODO: change db below to live copy, not semi-local one
# @res = sqlite3hashlist($query,"/mnt/sshfs/geonames2.db");
@res = sqlite3hashlist($query,"/sites/DB/geonames2.db");
# below no longer necessary, but useful for debugging
write_file(Dumper(\@res),"/tmp/dumpme.txt");

# get all possible names for each geonameid we know about, and store
# admin codes for ids we want

for $i (@res) {
#  debug("ID/NAME, $i->{altid}, $i->{name}");
  $isname{$i->{altid}}{$i->{name}}=1;

  # in theory, the asciiname should also be an altname, but..
  $ascname{$i->{geonameid}} = $i->{asciiname};

  $admin{4}{$i->{geonameid}} = $i->{admin4_code};
  $admin{3}{$i->{geonameid}} = $i->{admin3_code};
  $admin{2}{$i->{geonameid}} = $i->{admin2_code};
  $admin{1}{$i->{geonameid}} = $i->{admin1_code};
  # <h>$admin{contact} = "it's the answer..."</h>
  $admin{0}{$i->{geonameid}} = $i->{country_code};
  $wanted{$i->{geonameid}} = 1;
}

# and now, build up names of the ids we want
for $i (sort keys %wanted) {
  debug("I: $i, $ascname{$i}");

  # build up name into array
  @name = ();

  # name of city admins
  for $j (0..4) {
    # if the city is its own admin$j, ignore it
    if ($admin{$j}{$i} == $i) {next;}

    @names = keys %{$isname{$admin{$j}{$i}}};
#    debug("$i/$j names:",@names);
    @rand = randomize(\@names);
    push(@name, $rand[0]);
  }

  # and the city itself (which could really be state, country, etc, of course)
  @names = keys %{$isname{$i}};
  @rand = randomize(\@names);
  push(@name, $rand[0]);

  # join them and clean it up
  $url = join(".", reverse(@name)).".weather.94y.info/";
  $url=~s/\.+/./isg;

  print "<li><a href='http://$url'>$ascname{$i}</a>\n";
}

print "</ul>\n";
