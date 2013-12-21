#!/bin/perl

# Uses discogs.com API to download data for a given user:

# Pages like http://www.discogs.com/user/[username]/collection do not
# include info on a release's country, genre, style, parent label,
# etc; this program attempts to retrieve those and create a
# user-specific mysql-like file

require "/usr/local/lib/bclib.pl";
dodie("chdir('/usr/local/etc/discogs')");

(my($user)=@ARGV)||die("Usage: $0 username");
my($out,$err,$res);

# cache information as much as possible
# TODO: caching here is a bad idea if user adds releases (but OK for testing)
unless (-f "user-$user-p1" && !$globopts{nocache}) {
  ($out,$err,$res) = cache_command2("curl -o user-$user-p1 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=1&per_page=100'");
}

# TODO: slightly inefficient to read (though not load) p1 twice
my($userinfo) = JSON::from_json(read_file("user-$user-p1"));

# get all pages
for $i (2..$userinfo->{pagination}{pages}) {
  unless (-f "user-$user-p$i" && !$globopts{nocache}) {
    ($out,$err,$res) = cache_command2("curl -o user-$user-p$i 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=$i&per_page=100'");
    # avoid hitting API too hard
    sleep(1);
  }
}

# now, go through the pages (including page 1) + record releases
for $i (1..$userinfo->{pagination}{pages}) {
  my($json) = JSON::from_json(read_file("user-$user-p$i"));
  # record release ids
  for $j (@{$json->{releases}}) {$relid{$j->{basic_information}{id}}=1;}
}

# get release info (unless we have it)
for $i (keys %relid) {
  # intentionally ignoring nocache here, could be dangerous
  unless (-f "release-$i") {
    ($out,$err,$res) = cache_command2("curl -o release-$i 'http://api.discogs.com/releases/$i'");
    sleep(1);
  }

  # and parse
  my($json) = JSON::from_json(read_file("release-$i"));
  push(@releases, $json);
}

# pushing releases gives us a "root"
hash2rdf(\@releases, "root");

# triplets printing (as test)

for $i (@triplets) {
  my(@l) = @{$i};
  print join("\t", @l),"\n";
}

=item hash2rdf($ref,$name="")

Given a scalar/array/hash reference $ref, returns RDF triplets recursively.

If $name is given, assigns name $name to $ref. Otherwise, creates a name

Pretty much does what unfold() does, only in RDF

=cut

sub hash2rdf {
  my($ref,$name) = @_;
  my($type) = ref($ref);

  # if no type at all, just return self (after cleanup)
  unless ($type) {
    $ref=~s/\n/\r/isg;
    $ref=~s/\"/\\"/isg;
    return $ref;
  }

  # name I will give $ref if not given
  unless ($name) {$name = "REF".++$hash2rdf_count;}
  # TODO: making $hash2rdf_count global is bad
  # TODO: making @triplets global is unacceptably bad (but just testing now)
  # my(@triplets);


  if ($type eq "ARRAY") {
    # interim var
    my(@l) = @{$ref};
    # push triplets for my children
    for $i (0..$#l) {push(@triplets, [$name, $i, hash2rdf($l[$i])]);}
    # return the name I gave myself
    return $name;
  }

  if ($type eq "HASH") {
    # interim var
    my(%h) = %$ref;
    for $i (keys %h) {push(@triplets, [$name, $i, hash2rdf($h{$i})]);}
    return $name;
  }

  # hopefully it's referring to a scalar at this point!
  return $$ref;
}

=item schema

; where dump.txt is output of this program
DROP TABLE IF EXISTS rdf;
CREATE TABLE rdf (hash, key, val);
CREATE INDEX i1 ON rdf(hash);
CREATE INDEX i2 ON rdf(key);
CREATE INDEX i3 ON rdf(val);
.separator "\t"
.import dump.txt rdf

; useful queries

SELECT r1.key AS f1,
 IFNULL(r2.key,r1.val) AS f2,
 IFNULL(r3.key,r2.val) AS f3,
 IFNULL(r4.key,r3.val) AS f4,
 r4.val FROM rdf r1
 LEFT JOIN rdf r2 ON (r1.val=r2.hash)
 LEFT JOIN rdf r3 ON (r2.val=r3.hash)
 LEFT JOIN rdf r4 ON (r3.val=r4.hash)
WHERE r1.hash='root' AND f2='title';

=cut
