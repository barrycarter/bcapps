#!/bin/perl

# attempts to create a fetlife location database (of pure locations
# only, not who lives where) from the data bc-dl-by-region.pl gets
# incidentally

require "/usr/local/lib/bclib.pl";

print "BEGIN;\n";

for $i (glob "/home/barrycarter/FETLIFE/FETLIFE-BY-REGION/*.txt") {

  unless ($i=~/(countries|administrative_areas)\-(\d+)\.txt$/) {
    warn("IGNORING: $i");
    next;
  }

  my(@parent) = ($1,$2);
  my($all) = read_file($i);

  # if this is a country, get its name
  if ($parent[0] eq "countries") {
    $all=~s/kinksters living in (.*?)<//is||warn("NO CUNT: $i");
    my($cunt) = $1;
    print "INSERT INTO fetlife_locations (type,num,name,parent) VALUES ('country','$parent[1]','$cunt',0);\n";
  }

  while ($all=~s%/(administrative_areas|cities)/(\d+)\".*?>(.*?)</a>%%is) {
    my($type,$num,$name) = ($1,$2,$3);

      print "INSERT INTO fetlife_locations (type,num,name,parent) VALUES ('$type','$num','$name','$parent[1]');\n";
#    print "$2:$1:$3:$parent[1]:$parent[0]\n";
  }
}

print "COMMIT";

=item schema

-- TODO: since I don't enumerate cities in each administrative_areas,
-- this db is highly incomplete, need to augment with user profiles

-- TODO: should type be an ENUM?

CREATE TABLE fetlife_locations (
 type TEXT,
 num INT,
 name TEXT,
 parent INT
);

CREATE INDEX i1 ON fetlife_locations(type(10));
CREATE INDEX i2 ON fetlife_locations(num);
CREATE INDEX i3 ON fetlife_locations(parent);

CREATE VIEW cities AS
SELECT f1.num, CONCAT(f1.name, ", ", f2.name, ", ", f3.name) AS name
 FROM fetlife_locations f1 LEFT JOIN fetlife_locations f2 ON
 (f1.parent = f2.num) LEFT JOIN fetlife_locations f3 ON
 (f2.parent = f3.num) WHERE
f1.type='cities' AND f2.type='administrative_areas' AND f3.type='country';



=cut



